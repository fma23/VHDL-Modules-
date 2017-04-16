# VHDL-Modules-
The below modules were implemented on Altera Cyclone II FPGA Development Kit with: EP2C70F896C6 FPGA chip. 

Digital_Clock.vhd module is an implementation of a 24 hours digital clock. Time is displayed on 7 segments LEDs display. The VHDL code in implemented using a Finite State Machine.

mult_system_4_stage.vhd and mult_system_5_stage.vhd modules are 16x16 bits pipeline 4 stages and 5 stages multipliers, respectively. Also inculded is a simlation file for the waveforms for each multiplier. Although FPGA comes with embedded 16x16 bits multipliers, this module was implemented just as an exrecise to explore the concept of pipeline processing.
The max operating frequency of this design is 145.35 MHz for the 4-stage multiplier and 170.77Mhz for 5-stage multiplier. The system clock was 50 MHz.
