# Projects for ECE 327, Digital Hardware Systems


## Project 1: Hamming Decoder
Takes in a 12 bit hamming encoded message  
Outputs:  
&nbsp;&nbsp; 8 data bits, with 1-bit error detection  
&nbsp;&nbsp; 4 bit syndrome detailing which bit contained an error (1 indexed, 0 meaning no error)  


## Project 2: Keypad Lock
Signals which of 2 passkeys are selected, if correct  

## Project 3: O(n) Sorting Engine
Sorts an array of n numbers with bit-length m in O(n) time  

## Project 4: Memory System Tester
Pipelined implementation of a memory system tester  
Tests all bits of each byte in the memory system by writing and reading to registers, and keeps track of the error count  
Pipelining allows for 1 register to be tested per clock cycle (2 tests per register, 0x00 and 0xFF)  
