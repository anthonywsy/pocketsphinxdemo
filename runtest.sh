#!/bin/bash
#by anthony
#2016-09-27

testFile1="test/data/goforward.raw"
echo $testFile1
resultFile1="$testFile1.txt"	
echo $resultFile1
pocketsphinx_continuous -lm model/en-us/en-us.lm.bin -dict model/en-us/cmudict-en-us.dict -hmm model/en-us/en-us -infile $testFile1 > $resultFile1

testFile2="test/data/cards/001.wav"
echo $testFile2
resultFile2="$testFile2.txt"	
echo $resultFile2
pocketsphinx_continuous -lm model/en-us/en-us.lm.bin -dict model/en-us/cmudict-en-us.dict -hmm model/en-us/en-us -infile $testFile2 > $resultFile2

echo "result of test 1: $(tail $resultFile1)"
echo "result of test 2: $(tail $resultFile2)"
