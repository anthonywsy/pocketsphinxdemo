#!/bin/bash
#by anthony
#2016-09-27

##### Parameters #####
#TOKEN="(use your telegram bot token here)"
GlobalOutputFile=""
IncomeVoiceDir="voice"

##### Functions #####

function logerr
{
	logdate="$(date +'%Y%m%d')"
	LOGFILE="pocketsphinx.$logdate.err.log"
	echo "$(date) - $1" >> $LOGFILE
}

#Call curl to get the file path, then call wget to download the file
#input: file_id
function callwget
{
	fileId=$1
	#echo $fileId
	fileId="${fileId%\"}"
	#echo $fileId
	fileId="${fileId#\"}"
	#echo $fileId
	url="https://api.telegram.org/bot$TOKEN/getFile?file_id=$fileId"
	#echo "$url"
	jsonRes=$(curl -s -X GET $url)
	ok=$(echo $jsonRes | jq .ok)
	if [ $ok != true ];
	then
		logerr "At callwget - return false message from telegram."
	else
		filePath=$(echo $jsonRes | jq .result.file_path)
		if [ filePath == null ];
		then
			logerr "At callwget - file_path is null"
		else
			#echo "start to download the voice file"
			filePath="${filePath%\"}"
			filePath="${filePath#\"}"
			url="https://api.telegram.org/file/bot$TOKEN/$filePath"
			#echo "$url"
			wget -q -P $IncomeVoiceDir "$url"
			callffmpeg $filePath $filePath.wav
			callpocketsphinx_continous $filePath.wav
			GlobalOutputFile="$filePath.wav.txt"
		fi
	fi
}


function replyVoiceMsg
{
	#echo "at replyVoiceMsg"

	#echo "$2"
	#echo "GlobalOutputFile at replyVoiceMsg is $GlobalOutputFile"
	reTxt="You%20said:%20"
	reTxt2="$(<$2)"
	#echo "at replyVoiceMsg reTxt2 is $reTxt2"
	reTxt3=" "
	reTxt4="%20"
	reTxt5=${reTxt2//$reTxt3/$reTxt4}
	#echo "at replyVoiceMsg reTxt5 is $reTxt5"
	reTxt6="$reTxt%20$reTxt5"
	url="https://api.telegram.org/bot$TOKEN/sendMessage?chat_id=$1&text=$reTxt6"
	jsonRes=$(curl -s -X GET $url)
	ok=$(echo $jsonRes | jq .ok)
	if [ $ok != true ];
	then
		logerr "At replyVoiceMsg - return false message from telegram."
	fi
	echo $jsonRes
}

function replyTextMsg
{
	reTxt="I%20cannot%20recognize%20your%20text%20msg."
	url="https://api.telegram.org/bot$TOKEN/sendMessage?chat_id=$1&text=$reTxt"
	jsonRes=$(curl -s -X GET $url)
	ok=$(echo $jsonRes | jq .ok)
	if [ $ok != true ];
	then
		logerr "At replyTextMsg - return false message from telegram."
	fi
	#echo $jsonRes
}

function dealwithMsg
{
	chatId=$(echo $1 | jq .result[0].message.chat.id)
		
	fileId=$(echo $1 | jq .result[0].message.voice.file_id)
	if [ $fileId != null ];
	then
		echo "this is a voice msg"
		callwget "$fileId"
		#echo "GlobalOutputFile at dealwithMsg is $GlobalOutputFile"
		#echo $txtFile
		
		if [ $GlobalOutputFile != "" ];
		then
			replyVoiceMsg $chatId $GlobalOutputFile
			GlobalOutputFile=""
		fi
		#sleep 3
		return 1
	fi
	text=$(echo $1 | jq .result[0].message.text)
	if [ $text != null ];
	then
		echo "this is a text msg"
		#echo "GlobalOutputFile at dealwithMsg is $GlobalOutputFile"
		replyTextMsg $chatId
		return 1
	fi


	echo "this is an unkown msg"
}

function callCurlGetOneUpdatebyOffset
{
	#echo "at callCurlGetOneUpdatebyOffset"
	url="https://api.telegram.org/bot$TOKEN/getUpdates?offset=$1&limit=1"
	#echo "url is $url"
	jsonRes=$(curl -s -X GET $url)
	ok=$(echo $jsonRes | jq .ok)
	if [ $ok != true ];
	then
		logerr "At callCurlGetOneUpdatebyOffset - return false message from telegram."
	fi
	response=$jsonRes
	echo "$response"
}



function calldwdiff
{
	#dwdiff -i -s $1 $2 &> compare.result.txt
	result = $(dwdiff -i -s $1 $2)
	echo $result
}

function callpocketsphinx_continous
{
	#echo "at callpocketsphinx_continous"
	#echo $1
	OutputTxt=$1.txt
	#echo $OutputTxt
	pocketsphinx_continuous -lm model/en-us/en-us.lm.bin -dict model/en-us/cmudict-en-us.dict -hmm model/en-us/en-us -infile $1 > $OutputTxt
	#echo "end of callpocketsphinx_continous"
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


echo "set initial updateid to 1"
updateId=1
echo "start the loop"
while [ 1 == 1 ]; do
	response=$(callCurlGetOneUpdatebyOffset $updateId)
	updateId=$(echo $response | jq .result[0].update_id)
	if [ $updateId == null ];
	then
		echo "updateId is null, keep looping"
		sleep 1 
	else
		let "updateId = $updateId + 1"
		echo "start to deal with this Msg"
		dealwithMsg "$response"
	fi
done

