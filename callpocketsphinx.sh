#!/bin/bash
#by anthony
#2016-09-27

##### Functions #####

function callpocketsphinx_continous
{
	echo "start to call pocketsphinx_continous"
	pocketsphinx_continuous -lm model/en-us/en-us.lm.bin -dict model/en-us/cmudict-en-us.dict -hmm model/en-us/en-us -infile test/data/file_1.wav > result.txt
	echo "end of call pocketsphinx_continous"
}

function callffmpeg
{
	echo "start to call ffmpeg"
	ffmpeg -i test/data/file_1.oga -ar 16000 test/data/file_1.wav
	echo "end of call ffmpeg"
}
##### Main #####

callffmpeg
callpocketsphinx_continous

#remove the wav file
rm test/data/file_1.wav
