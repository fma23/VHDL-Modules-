# VHDL-Modules-
The below modules were implemented on Altera Cyclone II FPGA Development Kit with: EP2C70F896C6 FPGA chip. 

Digital_Clock.vhd module is an implementation of a 24 hours digital clock. Time is displayed on 7 segments LEDs display. The VHDL code in implemented using a Finite State Machine.

mult_system_4_stage.vhd and mult_system_5_stage.vhd modules are 16x16 bits pipeline 4 stages and 5 stages multipliers, respectively. Also inculded is a simlation file for the waveforms for each multiplier. Although FPGA comes with embedded 16x16 bits multipliers, this module was implemented just as an exrecise to explore the concept of pipeline processing.
The max operating frequency of this design is 145.35 MHz for the 4-stage multiplier and 170.77Mhz for 5-stage multiplier. The system clock was 50 MHz.

blackjack_cyclone.vhd:
This is a VHDL program that implements the basic rules of the game BalckJack on Altera DE2-70 development Board. The objective of the Blackjack game is to collect a hand of up to 5 cards that is as close to the total card value of 21 as possible without exceeding it.  In this modified game, rules such as double, insurance, and split are not used.  In addition, although Aces (A) can be used as the value of 1 or 11 
under official rules, for simplicity reasons, only the value of 1 is used in this modified game. The rules of the game are:
1)If the player obtains 5 cards without busting, then the player wins.
2)If the player busts and the dealer does not, the dealer wins.
3)If the dealer busts and the player does not, the player wins.
4)If neither the dealer nor the player bust, the person with the highest total card value wins. 
5)In the case of a tie, the dealer wins

Extra Freature: Score Counter
an extra feature that is supposed to make the game more exciting was added to the game. Both the player and the dealer can keep track of their winning score. LED seven segments: Hex1 and Hex3 was used for this purpose together with the help of switch 0 and switch 1. Switch 0 is used to give the users the ability to choose to display the score premanently or just to check the score for a short moment at any round of the game. The score counter can count up to 9 times for a duration of up to 9 games, after that it just resets itself to zero. Switch 0 was used as a reset button to reset the scores to zero at any time the users decide to. The scores can be reset to zero by pressing the stop button first then pressing switch 1 which is the reset control. 
