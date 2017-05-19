**DISCLAIMER**

This project, and all code contained within it, is currently in a state that is, by all accounts, non-functional. It needs significant overhaul and continuous improvement. While it is not in a suitable state for those without digital design capabilities to experiment with, it does contain components or code which may be considered useful to those undergoing digital design projects. The project and all files within will be frequently redesigned, reorganized, and many will likely be trimmed/removed as this project nears completion. For those who do choose to make use of this repo, please do not under any circumstances update without first scanning the changelog, as every change will likely break your circuits and designs. 

In addition, the developers, designers, and engineers involved in this project make no claims of its functionality, and are not liable for any damages done to your devices while investigating hardware security features and/or flaws. Hack safely, and be careful.



**ABOUT**

GlitchHammer is a WORK IN PROGRESS coprocessor focused on enabling extremely time sensitive electrical stimulus responses in systems where cycle-level accuracy is desired. GlitchHammer as a whole is a complex system consisting of many parts. Currently, this repo contains only the HDL code needed to implement the digital layer on an FPGA or theoretically a CPLD/ASIC. It uses its own, as-of-yet unnamed and (sorry) undocumented ISA to enable external programs focused on cycle-specific responses.

This system was initially developed out of necessity for performing Vectorhax, a fault-injection-based exploit in the Nintendo 3DS. However since then, it has expanded into a far larger and more ambitious project. Ideally, GlitchHammer will enable non-professionals to develop, experiment with, and execute hardware security research projects from home using low-cost tools and some DIY know-how. Currently, it is /not/ in this state, however. Use with caution. 



**FEATURES**

##Current Features:

-A small ISA, consisting of:
    -checks against a list of stimuli (geared for i2c commands)
    -cycle-accurate timing delays
    -digital-to-analog converter interfacing commands
-The HDL needed to perform these tasks on an FPGA 
-A simple 8-pin debugging interface
-Common circuit elements, contained in folder "common" which may be appropriate for use in other projects, and may at a later date be spun into their own project.


##Features in the works:
-UART interface to enable programming from a master node
-Assembly language and assembler to enable master node automation
-Rework of ISA to add jumps, compares, some RISC-style enable/disable logic, and generally cleaner command syntax
-Higher quality analog interface to enable higher general performance.


##Planned features:
-Redesign in systemverilog
-UART debugging 
-Zynq/other all-programmable SoC-specific systems for implementing in FPGA cells, for faster comms between master CPU and GlitchHammer
-Multiple ADC channels
-sample code and projects + documentation
-Documentation of ISA and sample analog frontends to enable home use.



**USAGE**

While this project is really not intended for usage by any without experience in FPGA's and RTL design at the moment, if you wish to use it, you will need an FPGA, plus a vendor-provided toolchain. For ISE users, a sample .ucf file exists which dictates pinouts for the Xilinx ML402 board. Chip_interface.v is project specific, and while you may glean some guidance from it, you likely will want to nuke that file from orbit before starting your own instantiation.

Reminder, do not blindly update this code. Every push will likely, if not guranteed, break circuits built on the previous push's design. 

Best of luck!



**CREDITS AND THANKS**

##I'd like to thank the following for their contributions on this project thus far and im sure in the future:
-Kitlith -- For his really just incredible help and enthusiasm. He took on the challenge of making a proper assembly language and assembler and it really is a labor of love. Without him that wouldn't be possible.
-Stuckpixel -- For the assistance in troubleshooting and brainstorming.
-Normmatt -- For debugging and constantly catching bugs even in a language he didn't even understand.
-SciresM -- For being an all around genius, and also freeing me of the time constraint to finish 3DS exploitation, so this project can blossom into something really great. 
-My partner, Muu -- For supporting me and not minding the long nights disappearing into this pet project. I'm really sorry for being so busy all the time, and i love you deeply
-All the folks in my team who I haven't named here because its a lot. You know who you are <3
-All the people who came to watch my streams while I worked on developing this. I hope you all learned something cool


**LICENSE**

All code contained within this repo is free to use in any project, and does not need my nor any permission to be included should the project also be free and open-source, and link back to this repo. If this code is to be used in any projects resulting in revenue for the developers/engineers responsible, they must obtain written permission to include code contained within this repo. 

(c) hedgeberg, 2016-2017