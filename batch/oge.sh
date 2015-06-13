#!/bin/sh
for file in `ls /some/projects/folder`;
do qsub bin2mat.sh $file;
done