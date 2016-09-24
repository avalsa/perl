#!/bin/bash
ls -l | 
perl -e '$/="\n"; while(<>) {@array = split(/\s+/, $_, 9);print( join(";", @array)) if (defined $array[4]); }'
