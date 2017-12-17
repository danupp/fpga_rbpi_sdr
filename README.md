# FPGA SDR for Raspberry Pi 3

This repository contains FPGA firmware for Software Defined Radio on the Raspberry Pi 3.
It is based on the FPGA DSP stand-alone SDR described elsewhere and in the Elektor magazine in 2017.
 
Development started back in 2013 on a Cyclone II board prototype but the current platforms target a Cyclone IV on a board developed together with Elektor Labs.

This repository was created 2017-12-17.

For an overall project description, please visit: https://sm6vfz.wordpress.com/dspsdr-with-fpga/

## Firmware source and binary

This repository contains vhdl and other source files for the FPGA itself. Under output_files the compiled binaries can be found. For programming the latest built firmware into the non-volatile flash memory, use the JTAG Indirect Configuration file, [trx.jic](fpga/output_files/trx.jic), with an USB Blaster or similar programmer and the Quartus Prime software. (When running the latter in Linux, it is sometimes necessary to run the jtag daemon, jtagd, as root user.) 

## Communication protocol

Communication with the FPGA is over I2C or UART.
Please refer to the [register map](/docs/register-map.org) for more information about how the FPGA is controlled.

## Changelog

2017-12-17:  
   * Initial release to new repository.  