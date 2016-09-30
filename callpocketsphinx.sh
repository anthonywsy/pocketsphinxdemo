#!/bin/bash
#by anthony
#2016-09-27

##### Parameters #####
TOKEN="(use your telegram bot token here)"
InOga=test/data/file_1.oga
OutWav=test/data/file_1.wav
OriginTxt=sample1.oga.txt
ResultTxt=result.txt

##### Functions #####

function logerr
{
	logdate="$(date +'%Y%m%d')"
	LOGFILE="pocketsphinx.$logdate.log"
	echo "$(date) - $1" >> $LOGFILE
}

function dealwithMsg
{
	echo "at dealwithMsg"
	echo $1
	text=$(echo $1 | jq .result[0].message.text)
	if [ $text != null ];
	then
		echo "this is a text msg"
		exit 1
	fi

	voice=$(echo $1 | jq .result[0].message.voice)
	if [ $voice != null ];
	then
		echo "this is a voice msg"
		exit 1
	fi

	echo "this is an unkown msg"
}

function callCurlGetOneUpdatebyOffset
{
	echo "at callCurlGetOneUpdatebyOffset"
	url="https://api.telegram.org/bot$TOKEN/getUpdates?offset=$1&limit=1"
	jsonRes=$(curl -s -X GET $url)
	ok=$(echo $jsonRes | jq .ok)
	if [ $ok != true ];
	then
		logerr "At callCurlGetOneUpdatebyOffset - return false message from telegram."
	fi
	echo $jsonRes
}

function callCurlGetOneUpdate
{
	echo "at callCurlGetOneUpdate"
	jsonRes=$(curl -s -X GET https://api.telegram.org/bot$TOKEN/getUpdates?limit=1)
	#echo $jsonRes
	ok=$(echo $jsonRes | jq .ok)
	if [ $ok != true ];
	then
		logerr "At callCurlGetOneUpdate - return false message from telegram."
	fi
	echo $jsonRes
}

function callCurlGetUpdate
{
	jsonRes = $(curl -s -X GET https://api.telegram.org/bot$TOKEN/getUpdates)
	updateId = $(echo $jsonRes | jq .result[0].update_id)
	echo $updateId	
	result = $(echo $jsonRes | jq .result)
	echo $result
	let "updateId = $updateId + 1"
	echo $updateId
	url = "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$updateId&limit=1"
	jsonRes = $(curl -s -X GET $url)
	
	result = $(echo $jsonRes | jq .result)
	echo $result
}

function callcurl
{
	jsonRes=$(curl -s -X GET https://api.telegram.org/bot$TOKEN/getUpdates)
	ok=$(echo $jsonRes | jq .ok)
	result=$(echo $jsonRes | jq .result)
	updateId=$(echo $jsonRes | jq .result[0].update_id)
	messageId=$(echo $jsonRes | jq .result[0].message.message_id)
	fromId=$(echo $jsonRes | jq .result[0].message.from.id)
	userName=$(echo $jsonRes | jq .result[0].message.from.username)
	text=$(echo $jsonRes | jq .result[0].message.text)
	msgDate=$(echo $jsonRes | jq .result[0].message.date)
	if [ $ok == true ];
	then
		echo "return true"
	else
		echo "return false"
	fi
	
	if [ $result == "[]" ];
	then
		echo "result is []"
	else
		echo "result is not []"
	fi
	echo $(date -d @$msgDate)
}
 
function calldwdiff
{
	#dwdiff -i -s $1 $2 &> compare.result.txt
	result = $(dwdiff -i -s $1 $2)
	echo $result
}

function callpocketsphinx_continous
{
	pocketsphinx_continuous -lm model/en-us/en-us.lm.bin -dict model/en-us/cmudict-en-us.dict -hmm model/en-us/en-us -infile test/data/file_1.wav > result.txt
}

function callffmpeg
{
	ffmpeg -i $1 -ar 16000 $2 
}
##### Main #####


#callffmpeg $InOga $OutWav 
#callpocketsphinx_continous
#calldwdiff $OriginTxt $ResultTxt
#callcurl
#callCurlGetUpdate

#The 1st time to start up, need to get the update_id
echo "start to call curl to get an update"
response=$(callCurlGetOneUpdate)
echo $response
echo "start to parse the response json to get update id"
result=$(echo $response | jq .ok)
echo "start echo"
echo $result
echo "star the 1st loop"
while [ $updateId == null ]; do
	echo "at the 1st start up, updateId is null, keep looping"
	sleep 5
	response=$(callCurlGetOneUpdate)
	updateId=$(echo $response | jq .result[0].update_id)
done

#just need to get the updateId, will deal with the msg in next loop
echo "start the 2nd loop"
while [ 1 == 1 ]; do

	let "updateId = $updateId + 1"
	response=$(callCurlGetOneUpdatebyOffset $updateId)
	updateId=$(echo $response | jq .result[0].update_id)
	if [ $updateId == null ];
	then
		echo "updateId is null, keep looping"
		sleep 5
	else
		$(dealwithMsg $result)
	fi
done

#remove the wav file
#rm $OutWav 
