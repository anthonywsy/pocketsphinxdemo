#/usr/bin/python2.7
#Author: anthony
#Date: 2019-09-29
from os import environ, path

from pocketsphinx.pocketsphinx import *
from sphinxbase.sphinxbase import *

MODELDIR = "model"
DATADIR = "test/data"

# Create a decoder with certain mode
config = Decoder.default_config()
config.set_string('-hmm', path.join(MODELDIR, 'en-us/en-us'))
config.set_string('-lm', path.join(MODELDIR, 'en-us/en-us.lm.bin'))
config.set_string('-dict', path.join(MODELDIR, 'en-us/cmudict-en-us.dict'))
decoder = Decoder(config)

# Decode streaming data
decoder = Decoder(config)
decoder.start_utt()
#FILENAME = "librivox/sense_and_sensibility_01_austen_64kb-0870.wav"
#FILENAME = "goforward.raw"
#FILENAME = "cards/001.wav"
FILENAME = "file_1.1.wav"

stream = open(path.join(DATADIR, FILENAME), 'rb')
while True:
  buf = stream.read(1024)
  #buf = stream.read(4096)
  if buf:
    decoder.process_raw(buf, False, False)
  else:
    break
decoder.end_utt()
print ('Best hypothesis segments: ',[seg.word for seg in decoder.seg()])
