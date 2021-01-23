# ASMWAVE
 A simple audio analysis program written in x86 assembly.

	The purpose of this program is not for serious use - it is more of a proof-of-concept and a fun project!
This code does 2 things: First, the average volume (as it would appear on a dB meter) is calculated. 
Next, a frequency comparison is run, comparign how prominent each of 5 bands are in relation to each other. 
Please Note: 1) Only 24bit and 16bit stereo and mono can be used. 
2) The sub band comparison is disabled on 24bit. 
3) The simple DFT algorithm is used, the FFT was too big brain to implement; so
it takes a slight bit of time to run through. 
4) Due to the #3, only the left channel frequencies are analyzed, to save time. 5) THE FREQENCY RESULTS MAY BE WRONG SOMETIMES, idk.
6) The progress bar might be a bit f u n k y for smaller files.
