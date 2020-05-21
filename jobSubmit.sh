#!/bin/bash
#$ -cwd -V
#$ -q all.q
#$ -N SnO_Auto_1
#$ -e q.error
#$ -o q.output

bash gulp_auto_fit.sh 
