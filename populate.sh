#!/bin/bash

my_dir=`dirname "$0"`
cd $my_dir

ls  -d ./*ALLINONE* | xargs -l1 rsync -Pr Archive/
