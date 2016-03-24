#!/bin/sh
#$ -N bin2mat
#$ -S /bin/sh
#$ -j y
#$ -q long.q
#$ -o /path/to/some/log/file.log
#$ -u username
matlab -nodesktop -nosplash -nodisplay -r "try ogeConversionBin2Mat('$1'); catch; end; quit"