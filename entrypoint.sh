#!/bin/sh -l

echo "Hello $1"

echo "abc_method_average=6.4" >> $GITHUB_OUTPUT
echo "code_smells_per_file=0.5" >> $GITHUB_OUTPUT
echo "similarity_score_per_file=12.0" >> $GITHUB_OUTPUT
echo "total_score=18.9" >> $GITHUB_OUTPUT