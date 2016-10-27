# pocketsphinxdemo
Demo pocketsphinx

DESCRIPTION  
This project is the demonstration of sphinx. 
Just a simple Linux bash shell script in this project. 
The script will get the voice message from telegram bot.
Then convert the voice to text.
And send back to telegram bot.
  
ENVIRONMENT  
This shell script was tested at Ubuntu 16.0.4 Server/Desktop
  
PRE-CONDITION  
1. Register a telegram bot, refer to https://core.telegram.org/bots  
2. Build pocketsphinx, refer to http://cmusphinx.sourceforge.net/wiki/tutorialpocketsphinx  
3. Need some other tools like ffmpeg (https://www.ffmpeg.org/) and jq (https://stedolan.github.io/jq/)  
  
GET IT WORK  
1. Get this shell script to local  
2. Input the telegram bot token to the script  
3. Execute this script  
  
HOW IT WORKS  
1. The script will call the telegram bot API via HTTP request to get voice message. Repeat this step every serveral seconds.  
2. When it download a voice file (.oga), it will conver the file to .wav via ffmpeg.  
3. Then deal with the file by pocketsphinx, to conver it to .txt file.  
4. Finally, reply the text content back to telegram bot.
  
THANKS TO  
Thanks to telegram bot's HTTP GET/POST API. With this API, we don't need to rent a server to deal with the message.    
Thanks to sphinx.    
  
CONTACT US  
Any question please email to anthony(at)nicodemus.club  
  
WHY WE OPEN THIS PROJECT  
(TBD)  
