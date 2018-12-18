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

**2017-12-17:**  
* Initial release to new repository.  

**2017-12-18:**   
* DAC A cos, DAC B sin in TX.  

**2017-12-23**:  
* Coded a digital, band pass, roofing filter between ADC and downmix/decimation. Currently running at 100 MHz, seems a bit too fast. Scaling probably not correct. Bypassed!  

**2017-12-26**:  
* Removed roofing filter.
* Changed to 625 ksps output from ADC.
* Changed decimation to 8, giving 78.125 ksps. Implemented 640 taps Chebyshev low pass decimation filter, running at 60 MHz.  

**2017-12-28**:  
* Changed decimation filter to hanning type. But does not work properly.  

**2018-01-02**:  
* Fixed decimation filter problem.

**2018-01-03**:  
* Fixed another decimation filter problem. TODO: Reduce memory for buffers and make room for more taps by taking advantage of every second sample being zero after downconversion.  

**2018-01-08**:  
* Optimized downmixer and decimation for very low resource footprint. According to todo.  
	
**2018-01-10**:  
* Added iqswap.  
	
**2018-01-15**:  
* Improved code slightly in downdec. Turned on the "Allow Any ROM Size for Recognition"-option in advanced synthesis settings but still cannot force FIR-taps go to hard memory.  

**2018-01-30**:  
* Changed decimation factor to 7. Now giving 89.2857.. ksps with 625 ksps in ADC. This also moves I2S-clock harmonic away from center frequency.  

**2018-02-04**:  
* Bugfix. Now proper decimation by 7.  

**2018-11-13**: 
* Added memory for cos and sin generation for DAC A. Added TX-multiplier taking input from I2S. Built jic-binary.  
	
**2018-11-16**: 
* Bugfix DDS sin tables. Now looping back received I2S data in TX. Built jic-binary.
	
**2018-12-17**:  
* Now running on RX clock also in TX. Least significant bit in I2S left channel is now KEY in TX. Built jic-binary.
  
**2018-12-17b**:  
* Mic audio sent back in I2S left channel in TX.  
  
*2018-12-18**: 
* Fixed proper signed cos/sin-tables and shift to unsigned in DAC driver. Solves bug with garbage in TX.  
* Audio loopback in TX can now be selected by configuration bit. (See register map.)
* LSB in both I2S left and right is now key in TX.
* Added better clock synch between codec and i2s for mic audio.