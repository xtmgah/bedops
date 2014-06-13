#!/bin/tcsh -ef

# author  : sjn and apr
# date    : June 2014
# version : v2.5.0

#
#    BEDOPS
#    Copyright (C) 2011, 2012, 2013, 2014 Shane Neph, Scott Kuehn and Alex Reynolds
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

############################
# some input error checking
############################

set help = "\nUsage: bam2starchcluster_gnuParallel [--help] [--clean] <input-indexed-bam-file> [output-starch-file]\n\n"
set help = "$help  Pass in the name of an indexed BAM file to create a Starch file using GNU Parallel.\n\n"
set help = "$help  (stdin isn't supported through this wrapper script.)\n\n"
set help = "$help  Add --clean to remove <input-indexed-bam-file> after starching it up.\n\n"
set help = "$help  You can pass in the name of the output Starch archive to be created.\n"
set help = "$help  Otherwise, the output will have the same name as the input file, with an additional\n"
set help = "$help   '.bed' ending.  If the input file ends with '.bam', that will be stripped off.\n"

if ( $#argv == 0 ) then
  printf "$help"
  exit -1
endif

@ inputset = 0
@ clean = 0
foreach argc (`seq 1 $#argv`)
  if ( "$argv[$argc]" == "--help" ) then
    printf "$help"
    exit 0
  else if ( "$argv[$argc]" == "--clean" ) then
    @ clean = 1
  else if ( $argc == $#argv ) then
    if ( $inputset > 0 ) then
      set output = "$argv[$argc]"
    else
      set originput = "$argv[$argc]"
      set output = $originput:t.bed
    endif
    @ inputset = 1
  else if ( $inputset > 0 ) then
    printf "$help"
    printf "Multiple input files cannot be specified\n"
    exit -1
  else
    set originput = "$argv[$argc]"
    set output = $originput:t.bed
    @ inputset = 1
  endif
end

if ( $inputset == 0 ) then
  printf "No input file specified\n"
  exit -1
else if ( ! -s $originput ) then
  printf "Unable to find BAM file: %s\n" $originput
  exit -1
else if ( "$output" == "$originput:t.bed" && "$originput:e" == "bam" ) then
  set output = "$originput:t:r.bed"
endif

set origininputindex = "$originput.bai"
if ( ! -s $origininputindex ) then
  printf "Unable to find associated BAI file (is the BAM file indexed?): %s\n" $origininputindex
  exit -1
endif

###############################################################
# new working directory to keep file pileups local to this job
###############################################################

set nm = b2bcg.`uname -a | cut -f2 -d' '`.$$
if ( -d $nm ) then
  rm -rf $nm
endif
mkdir -p $nm

set here = `pwd`
cd $nm
if ( -s ../$originput ) then
  set input = ../$originput
else
  # $originput includes absolute path
  set input = $originput
endif

# $output:h gives back $output if there is no directory information
if ( -d ../$output:h || "$output:h" == "$output" ) then
  set output = $here/$output
else if ( `echo $output | awk '{ print substr($0, 1, 1); }'` == "/" ) then
  # $output includes absolute path
else
  # $output includes non-absolute path
  set output = $here/$output
endif

#####################################################
# extract information by chromosome and bam2bed it
#####################################################

@ chrom_count = (`samtools idxstats $input | cut -f1 | awk 'END { print NR }'`)

samtools idxstats $input | cut -f1 | parallel "samtools view -b $input {} | bam2starch > $here/$nm/{}.starch"

@ converted_file_count = `find $here/$nm -name '*.starch' | wc -l`
if ( $chrom_count != $converted_file_count ) then
  printf "Error: Only some or no files were submitted to GNU Parallel successfully\n"
  exit -1
endif

##################################################
# create final bed archive and clean things up
##################################################

starchcat $here/$nm/*.starch > $output

cd $here
rm -rf $nm

if ( $clean > 0 ) then
  rm -f $originput
endif

exit 0
