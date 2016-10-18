#!/bin/bash
#by anthony
#2016-09-27

testFile1="test/data/goforward.raw"
echo $testFile1
resultFile1="$testFile1.txt"	
echo $resultFile1
pocketsphinx_continuous -lm model/en-us/en-us.lm.bin -dict model/en-us/cmudict-en-us.dict -hmm model/en-us/en-us -infile $testFile1 > $resultFile1
tail $resultFile1
