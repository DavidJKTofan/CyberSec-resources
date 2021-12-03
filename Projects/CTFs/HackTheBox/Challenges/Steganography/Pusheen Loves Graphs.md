# CHALLENGE DESCRIPTION

Pusheen just loves graphs, Graphs and IDA. Did you know cats are weirdly controlling about their reverse engineering tools? Pusheen just won't use anything except IDA.

***
***

1. Downloaded the attached ZIP file and extracted the content.

2. Since the description says that she should use IDA, we will download and use https://hex-rays.com/ida-free/

We take a look at the file:
`file /Downloads/Pusheen`

This gives us the following info: 
`ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, not strippe`

3. Open the file with IDA, and change the settings of max number of nodes to 8000, and then we head to the main function where the flag should appear.