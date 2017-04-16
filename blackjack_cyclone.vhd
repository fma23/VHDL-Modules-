--Author:Farid Mabrouk

-- This is a VHDL program that implements the basic rules of the game BalckJack on Altera DE2-70 development 
--Board. The objective of the Blackjack game is to collect a hand of up to 5 cards that is as close to the 
--total card value of 21 as possible without exceeding it.  In this modified game, rules such as double, 
--insurance, and split are not used.  In addition, although Aces (A) can be used as the value of 1 or 11 
--under official rules, for simplicity reasons, only the value of 1 is used in this modified game. The rules 
-- of the game are:
--1)If the player obtains 5 cards without busting, then the player wins.
--2)If the player busts and the dealer does not, the dealer wins.
--3)If the dealer busts and the player does not, the player wins.
--4)If neither the dealer nor the player bust, the person with the highest total card value wins. 
--5)In the case of a tie, the dealer wins

--Extra Freature: Score Counter
--an extra feature that is supposed to make the game more exciting was added to the game. Both the player and the 
--dealer can keep track of their winning score. LED seven segments: Hex1 and Hex3 was used for this purpose together
-- with the help of switch 0 and switch 1. Switch 0 is used to give the users the ability to choose to display the 
--score premanently or just to check the score for a short moment at any round of the game. The score counter can 
--count up to 9 times for a duration of up to 9 games, after that it just resets itself to zero. Switch 0 was used as 
--a reset button to reset the scores to zero at any time the users decide to. The scores can be reset to zero by pressing 
--the stop button first then pressing switch 1 which is the reset control. 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY blackjack_cyclone IS PORT (
  														
  start_n	:	IN 	std_logic;							-- start button input, active low
  stop_n	:	IN 	std_logic;							-- stop button input, active low
  hit_n		:	IN	std_logic;              			-- hit button input,active low
  stand_n	:   IN	std_logic;              			-- stand button input, active low
  fifty_mclk	:	IN	std_logic;                      -- 50 MHz system clcock
  switch    :IN std_logic;                              -- turn score display on and off
  reset     :IN std_logic;                              -- Reset the displayed score to zero
					
  d_total	: BUFFER std_logic_vector(4 downto 0);	    -- dealer's total card on LEDs (LEDR11 - LEDR7)
  p_total	: BUFFER std_logic_vector(4 downto 0);	    -- player's total card on LEDs (LEDs17 - LEDs13)
  
  d_count	: BUFFER std_logic_vector(3 downto 0);	    -- dealer's score counter
  p_count	: BUFFER std_logic_vector(3 downto 0);	    -- player's score counter
  
  p_card    : BUFFER std_logic_vector(2 downto 0);      -- number of cards player has drawn
  d_card	: BUFFER std_logic_vector(2 downto 0);      -- number of cards dealer has drawn
	
  p_rand    : BUFFER std_logic_vector(3 downto 0);      -- player's random number (1 - 13)
  d_rand    : BUFFER std_logic_vector(3 downto 0);      -- dealer's random number (1 - 13)
	
  p_comp    : BUFFER std_logic_vector(3 downto 0);	    --the actual value of each single card drawn by player (1-10)
  d_comp	: BUFFER std_logic_vector(3 downto 0);	    --the actual value of each single card drawn by dealter(1-10)
	
  player_win_out	: OUT std_logic;					-- player win LED indicator (LEDG1)
  dealer_win_out	: OUT std_logic;                    -- dealer win LED indicator  (LEDG0)
  ledg0             :BUFFER std_logic;                  -- store value of dealer winning code
  ledg1             :BUFFER std_logic;                  -- store value of player wining code
     			
  hex0_d	:	OUT std_logic_vector(6 downto 0);		-- number of cards dealt to dealer 
  hex0_dp	:	OUT std_logic;
  hex1_d	:	OUT std_logic_vector(6 downto 0);		-- number of winning games for dealer 
  hex1_dp	:	OUT std_logic;
  hex2_d	:	OUT std_logic_vector(6 downto 0);		-- number of cards dealt to player
  hex2_dp	:	OUT std_logic;
  hex3_d	:	OUT std_logic_vector(6 downto 0);		-- number of wining games for player 
  hex3_dp	:	OUT std_logic;
  hex4_d	:	OUT std_logic_vector(6 downto 0);		-- dealer's card total, least significant digit
  hex4_dp	:	OUT std_logic;
  hex5_d	:	OUT std_logic_vector(6 downto 0);		-- dealer's card total, most significant digit
  hex5_dp	:	OUT std_logic;
  hex6_d	:	OUT std_logic_vector(6 downto 0);		-- player's card total, least significant digit
  hex6_dp	:	OUT std_logic;
  hex7_d	:	OUT std_logic_vector(6 downto 0);		-- player's card total, most significant digit
  hex7_dp	:	OUT std_logic;	
  ledg3		:   OUT std_logic;							-- button pressed indicator
  ledg7     :	OUT std_logic;							-- demo program indicator
  ledg6		:   OUT std_logic);							-- demo program indicator
    
END blackjack_cyclone;

ARCHITECTURE ENSC350 OF blackjack_cyclone IS
	
	TYPE fsm_states IS( idle, first_card, player_turn, dealer_turn, player_win, player_lose);
	SIGNAL blackjack: fsm_states;
	
	--seven-segment LEDs display pattterns
	CONSTANT  blank	: std_logic_vector(6 downto 0)    := "1111111";
	CONSTANT   zero	: std_logic_vector(6 downto 0)    := "1000000";
	CONSTANT   one 	: std_logic_vector(6 downto 0)    := "1111001";
	CONSTANT   two 	: std_logic_vector(6 downto 0)    := "0100100";
	CONSTANT   three: std_logic_vector(6 downto 0)    := "0110000";
	CONSTANT   four : std_logic_vector(6 downto 0)    := "0011001";
	CONSTANT   five : std_logic_vector(6 downto 0)    := "0010010";
	CONSTANT   six	: std_logic_vector(6 downto 0)    := "0000010";
	CONSTANT   seven: std_logic_vector(6 downto 0)    := "1111000";
	CONSTANT   eight: std_logic_vector(6 downto 0)    := "0000000";
    CONSTANT   nine	: std_logic_vector(6 downto 0)    := "0010000";
	

	SIGNAL start_n_dly	: std_logic;  -- sampled version of start_n
	SIGNAL hit_n_dly	: std_logic;  -- sampled version of hit_n
	SIGNAL stand_n_dly	: std_logic;  -- sampled version of stand_n
	
BEGIN

-- turn off dots on 7-segment LEDs
  hex0_dp <= '1';
  hex1_dp <= '1';
  hex2_dp <= '1';
  hex3_dp <= '1';
  hex4_dp <= '1';
  hex5_dp <= '1';
  hex6_dp <= '1';
  hex7_dp <= '1';
 
-- turn off demo program indicators
  ledg7 <= '0';
  ledg6 <= '0';

-- this LED when turns on, confirms visually that a button is being pressed 
  ledg3 <= '1' WHEN ((start_n = '0') OR (stop_n = '0') OR (hit_n = '0') OR (stand_n = '0')) ELSE '0';
 
-- Sample all the button inputs
  IRQ_PROC  : PROCESS(fifty_mclk)   
  BEGIN
  	IF (fifty_mclk'EVENT AND fifty_mclk = '1') THEN
		start_n_dly <= start_n;   -- if start_n_dly <> start_n, then the start button has just been pressed
  	 	hit_n_dly   <= hit_n;
        stand_n_dly <= stand_n;
  	END IF;
  END PROCESS IRQ_PROC;

  
 p_card_gen: PROCESS (fifty_mclk, stop_n)      ---- player's card generator, cards value are between 0 and 13
	BEGIN
		IF (stop_n = '0') THEN
		    p_rand <= "0000";
		    
		ELSIF (fifty_mclk'EVENT AND fifty_mclk = '1') THEN
		    IF (p_rand >= "1101") THEN	-- 1101 = 13.
				 p_rand <= "0001";
			ELSE
				p_rand <= p_rand + "0001";
			END IF;
		END if;
END PROCESS p_card_gen;

			
d_card_gen: PROCESS (fifty_mclk, stop_n)          ----Dealer's card generator, card values are between 0 and 13
	BEGIN	
		IF (stop_n = '0') THEN
		    d_rand <= "0000";
		ELSIF (fifty_mclk'EVENT AND fifty_mclk = '1') THEN
		    IF (d_rand <= "0001" ) THEN
				d_rand <= "1101";
			ELSE
				d_rand <= d_rand - "0001";
			END IF;
		END IF;
END PROCESS d_card_gen;

--Concurrents statements are used here to compress the random number generator outputs to within the range of 1-10

--Compressing Player's random card value ta a value between 0 and 10
Comp_P:PROCESS (p_rand)
BEGIN 
 CASE p_rand(3 downto 0) IS 
  
   WHEN"0000"=>
       p_comp<="0000";
   WHEN"0001"=>
       p_comp<="0001";
   WHEN"0010"=>
       p_comp<="0010";
   WHEN"0011"=>
       p_comp<="0011";
   WHEN"0100"=>
       p_comp<="0100";
   WHEN"0101"=>
       p_comp<="0101";
   WHEN"0110"=>
       p_comp<="0110";
   WHEN"0111"=>
       p_comp<="0111";
   WHEN"1000"=>
       p_comp<="1000";
   WHEN"1001"=>
       p_comp<="1001";
   WHEN"1010"=>
       p_comp<="1010";
   WHEN"1011"=>
       p_comp<="1010";
   WHEN"1100"=>
       p_comp<="1010";
   WHEN"1101"=>
       p_comp<="1010";
   WHEN OTHERS=> NULL;
   
 END CASE;
END PROCESS Comp_P;

--Compressing dealer's card's value to a value between o and 10
Comp_D:PROCESS (d_rand)
BEGIN 
 CASE d_rand(3 downto 0) IS 
   WHEN"0000"=>
       d_comp<="0000";
   WHEN"0001"=>
       d_comp<="0001";
   WHEN"0010"=>
       d_comp<="0010";
   WHEN"0011"=>
       d_comp<="0011";
   WHEN"0100"=>
       d_comp<="0100";
   WHEN"0101"=>
       d_comp<="0101";
   WHEN"0110"=>
       d_comp<="0110";
   WHEN"0111"=>
       d_comp<="0111";
   WHEN"1000"=>
       d_comp<="1000";
   WHEN"1001"=>
       d_comp<="1001";
   WHEN"1010"=>
       d_comp<="1010";
   WHEN"1011"=>
       d_comp<="1010";
   WHEN"1100"=>
       d_comp<="1010";
   WHEN"1101"=>
       d_comp<="1010";
   WHEN OTHERS=>NULL;
 END CASE;
END PROCESS Comp_D;

-- binary to 7-segment LED decoder blocks:

--Displaying dealer's wining score
Binary_to_7_segment_LED_decoder_Dealer_Count: PROCESS (d_count,switch)
BEGIN 
             
             IF (switch='0')    THEN hex1_d <= blank;
             ELSIF(d_count="0000") THEN hex1_d <= zero;
		     ELSIF(d_count="0001") THEN hex1_d <= one;
             ELSIF(d_count="0010") THEN hex1_d <= two;
             ELSIF(d_count="0011") THEN hex1_d <= three;
             ELSIF(d_count="0100") THEN hex1_d <= four;
             ELSIF(d_count="0101") THEN hex1_d <= five;
             ELSIF(d_count="0110") THEN hex1_d <= six;
             ELSIF(d_count="0111") THEN hex1_d <= seven;
             ELSIF(d_count="1000") THEN hex1_d <= eight;
             ELSIF(d_count="1001") THEN hex1_d <= nine;
             ELSE  hex1_d  <= zero;
             END IF;
         
END PROCESS Binary_to_7_segment_LED_decoder_Dealer_Count;

--Displaying player's winning score
Binary_to_7_segment_LED_decoder_Player_Count: PROCESS (p_count,switch)  
BEGIN
           
           IF( switch='0')       THEN hex3_d <=blank;
           ELSIF(p_count="0000") THEN hex3_d <= zero;
		   ELSIF(p_count="0001") THEN hex3_d  <= one;
           ELSIF(p_count="0010") THEN hex3_d  <= two;
           ELSIF(p_count="0011") THEN hex3_d  <= three;
           ELSIF(p_count="0100") THEN hex3_d  <= four;
           ELSIF(p_count="0101") THEN hex3_d  <= five;
           ELSIF(p_count="0110") THEN hex3_d  <= six;
           ELSIF(p_count="0111") THEN hex3_d  <= seven;
           ELSIF(p_count="1000") THEN hex3_d  <= eight;
           ELSIF(p_count="1001") THEN hex3_d  <= nine;
           ELSE  hex3_d  <= zero;
           END IF;

END PROCESS Binary_to_7_segment_LED_decoder_Player_Count; 
        
--Displaying total number of player's cards	
Binary_to_7_segment_LED_decoder_Player_Cards: PROCESS (p_card)
	BEGIN
	  CASE p_card IS
			WHEN "000" =>
		        hex2_d <= zero;
			WHEN "001" =>
				hex2_d <= one;
			WHEN "010" =>
				hex2_d <= two;
			WHEN "011" =>
				hex2_d <= three;
			WHEN"100" =>
				hex2_d <= four;
			WHEN "101" =>
				hex2_d <= five;
			WHEN OTHERS =>
				hex2_d <= blank;
		END CASE;
END PROCESS Binary_to_7_segment_LED_decoder_Player_Cards;

--Displaying total number of dealer's cards	
Binary_to_7_segment_LED_decoder_Dealer_Cards:PROCESS(d_card) 
	BEGIN
	  CASE d_card IS
			WHEN "000" =>
		        hex0_d <= zero;
			WHEN "001" =>
				hex0_d <= one;
			WHEN "010" =>
				hex0_d <= two;
			WHEN "011" =>
				hex0_d <= three;
			WHEN "100" =>
				hex0_d <= four;
			WHEN "101" =>
				hex0_d <= five;
			WHEN OTHERS =>
				hex0_d <= blank;
		END CASE;
END PROCESS Binary_to_7_segment_LED_decoder_Dealer_Cards;

--Displaying total value of player's cards	
Binary_to_7_segment_LED_decoder_Player_Total: PROCESS (p_total)
BEGIN
 CASE p_total(4 DOWNTO 0)is	    
		     WHEN "00000"=>
		        hex6_d <= zero;
                hex7_d <= zero;
	 		WHEN "00001" =>
                hex6_d <= one;
                hex7_d <= zero;
			WHEN "00010" =>
                hex6_d <= two;
		        hex7_d <= zero;
			WHEN "00011" =>
                hex6_d <= three;
			    hex7_d <= zero;
			WHEN "00100" =>
                hex6_d <= four;
			    hex7_d <= zero;
			WHEN "00101" =>
                hex6_d <= five;
                hex7_d <= zero;
			WHEN "00110" =>
                hex6_d <= six;
                hex7_d <= zero;
			WHEN "00111" =>
                hex6_d <= seven;
			    hex7_d <= zero;
			WHEN "01000" =>
                hex6_d <= eight;
			    hex7_d <= zero;
			WHEN "01001" =>
                hex6_d <= nine;
                hex7_d <= zero;   
            WHEN "01010" =>
                hex6_d <= zero;
			    hex7_d <= one;
			WHEN "01011" =>
                hex6_d <= one;
                hex7_d <= one; 
            WHEN "01100" =>
                hex6_d <= two;
			    hex7_d <= one;
			WHEN "01101" =>
                hex6_d <= three;
                hex7_d <= one;
            WHEN "01110" =>
                hex6_d <= four;
			    hex7_d <= one;
			WHEN "01111" =>
                hex6_d <= five;
                hex7_d <= one;     
           WHEN "10000" =>
                hex6_d <= six;
                hex7_d <= one;        
           WHEN "10001" =>
                hex6_d <= seven;
                hex7_d <= one;
           WHEN "10010" =>
                hex6_d <= eight;
                hex7_d <= one; 
           WHEN "10011" =>
                hex6_d <= nine;
                hex7_d <= one;
           WHEN "10100" =>
                hex6_d <= zero;
                hex7_d <= two;    
           WHEN "10101" =>
                hex6_d <= one;
                hex7_d <= two;      
           WHEN "10110" =>
                hex6_d <= two;
                hex7_d <= two; 
           WHEN "10111" =>
                hex6_d <= three;
                hex7_d <= two;   
           WHEN "11000" =>
                hex6_d <= four;
                hex7_d <= two;
           WHEN "11001" =>
                hex6_d <= five;
                hex7_d <= two;
           WHEN "11010" =>
                hex6_d <= six;
                hex7_d <= two;      
           WHEN "11011" =>
                hex6_d <= seven;
                hex7_d <= two;
           WHEN "11100" =>
                hex6_d <= eight;
                hex7_d <= two;     
           WHEN "11101" =>
                hex6_d <= nine;
                hex7_d <= two;
           WHEN "11110" =>
                hex6_d <= zero;
                hex7_d <= three;
           WHEN OTHERS =>
                hex6_d <= blank;
                hex7_d <= blank;
		END CASE;  
	
END PROCESS Binary_to_7_segment_LED_decoder_Player_Total;

--Displaying total value of dealer's cards	
Binary_to_7_segment_LED_decoder_Dealer_Total:PROCESS (d_total)
BEGIN	    
	CASE d_total(4 downto 0) IS    
		    WHEN "00000"=>
		        hex4_d <= zero;
                hex5_d <= zero;
			WHEN "00001" =>
                hex4_d <= one;
                hex5_d <= zero;
			WHEN "00010" =>
                hex4_d <= two;
		        hex5_d <= zero;
			WHEN "00011" =>
                hex4_d <= three;
			    hex5_d <= zero;
			WHEN "00100" =>
                hex4_d <= four;
			    hex5_d <= zero;
			WHEN "00101" =>
                hex4_d <= five;
                hex5_d <= zero;
			WHEN "00110" =>
                hex4_d <= six;
                hex5_d <= zero;
			WHEN "00111" =>
                hex4_d <= seven;
			    hex5_d <= zero;
			WHEN "01000" =>
                hex4_d <= eight;
			    hex5_d <= zero;
			WHEN "01001" =>
                hex4_d <= nine;
                hex5_d <= zero;   
            WHEN "01010" =>
                hex4_d <= zero;
			    hex5_d <= one;
			WHEN "01011" =>
                hex4_d <= one;
                hex5_d <= one; 
            WHEN "01100" =>
                hex4_d <= two;
			    hex5_d <= one;
			WHEN "01101" =>
                hex4_d <= three;
                hex5_d <= one;
            WHEN "01110" =>
                hex4_d <= four;
			    hex5_d <= one;
			WHEN "01111" =>
                hex4_d <= five;
                hex5_d <= one;     
           WHEN "10000" =>
                hex4_d <= six;
                hex5_d <= one;        
           WHEN "10001" =>
                hex4_d <= seven;
                hex5_d <= one;
           WHEN "10010" =>
                hex4_d <= eight;
                hex5_d <= one; 
           WHEN "10011" =>
                hex4_d <= nine;
                hex5_d <= one;
           WHEN "10100" =>
                hex4_d <= zero;
                hex5_d <= two;    
           WHEN "10101" =>
                hex4_d <= one;
                hex5_d <= two;      
           WHEN "10110" =>
                hex4_d <= two;
                hex5_d <= two; 
           WHEN "10111" =>
                hex4_d <= three;
                hex5_d <= two;   
           WHEN "11000" =>
                hex4_d <= four;
                hex5_d <= two;
           WHEN "11001" =>
                hex4_d <= five;
                hex5_d <= two;
           WHEN "11010" =>
                hex4_d <= six;
                hex5_d <= two;      
           WHEN "11011" =>
                hex4_d <= seven;
                hex5_d <= two;
           WHEN "11100" =>
                hex4_d <= eight;
                hex5_d <= two;     
           WHEN "11101" =>
                hex4_d <= nine;
                hex5_d <= two;
           WHEN "11110" =>
                hex4_d <= zero;
                hex5_d <= three;
           WHEN OTHERS =>
                hex4_d <= blank;
                hex5_d <= blank;
		END CASE;  
		
END PROCESS Binary_to_7_segment_LED_decoder_Dealer_Total;

-- State machine which cycles through the various states when a game is in progress	

 state_machine	: PROCESS(fifty_mclk, stop_n)
    
BEGIN
  IF (stop_n= '0') THEN           -- stop button has been pressed
      player_win_out<='0';        --clear player winning code 
      dealer_win_out<='0';        --clear dealer winning code
		
      p_total<="00000";           --clear player total cards value
      d_total<="00000";           --clear dealer total cards value
             
      p_card<="000";              --clear number of cards drawn by player
      d_card<="000";              --clear number of cards drawn by dealer
      
      blackjack<=idle;            -- Forces state machine to go to idle state
       
   ELSIF (fifty_mclk'event AND fifty_mclk = '1') THEN
			
			CASE blackjack IS
			    WHEN idle =>
			         IF ((start_n = '0' AND start_n_dly = '1')) THEN      -- start button has been pressed
			            
						p_total<=p_total+p_comp; --compressed value of player's first card is generated
						d_total<=d_total+d_comp; --compressed value of dealer's first card is generated
						
                        p_card<="001";           -- set the card counter for player to 1
                        d_card<="001";           -- set the card counter for dealer to 1
                        
                        p_count<=p_count;        --player score counter is not changed      
                        d_count<=d_count;        --dealer score counter is not changed
                        			
						blackjack<=first_card;   -- Change state of blackjack to first_state	
						
						  ELSIF(reset='1')then
                          d_count<="0000";       -- dealer's score counter is reset to zero when reset button is pressed
                          p_count<="0000";       -- players's score counter is reset to zero when reset button is pressed
                          blackjack<=idle;	
					
			         END IF;
			         
			 WHEN first_card =>
			         IF (start_n = '1' AND start_n_dly = '0') THEN	 -- start button has been released
						
						p_total<=p_total+ p_comp;      --update the running total for the player 
						d_total<=d_total+ d_comp;      --update the running total for the dealer 
						
						p_card<=p_card+1;              -- set the card count of player to 2
                        d_card<=d_card+1;              -- set the card count of player to 2
				
						blackjack<=player_turn ;       -- change state of blackjack
    			      END IF;
			
		    WHEN player_turn=>
		            
		             IF(p_total=d_total) THEN         --in case of tie a dealer wins automatically
                       blackjack<=player_lose;
                       d_count<=d_count+1;            --increment winning score of the dealer by 1
                       p_count<=p_count;              --player's score is unchanged
                          IF(d_count="1001")THEN      -- score counter for both dealer and player is reset to zero after 9 games
                             d_count<="0000";
                             p_count<="0000";
                           END IF;
                           
                       
		             ELSIF(p_total>"10101" ) THEN        -- Player bust
			               blackjack<=player_lose;
			               d_count<=d_count+1;           --increment winning score of the dealer by 1        
                           p_count<=p_count;             --player's score is unchanged
                             IF(d_count="1001")then      -- score counter for both dealer and player is reset to zero after 9 games
                             d_count<="0000";
                             p_count<="0000";
                          END IF;
                            
                     ELSIF (p_total="10101")THEN       --player scored 21
			               blackjack<=player_win;      
			               d_count<=d_count;           --dealer's score is unchanged
                           p_count<=p_count+1;         --increment winning score of the player by 1
                             IF(p_count="1001")then    -- score counter for both dealer and player is reset to zero after 9 games
                                d_count<="0000";
                                p_count<="0000";
                             END IF;
			                   
			          ELSIF(p_total<"10101" and p_card="101")THEN --player did not bust after drawing 5 cards
			               blackjack<=player_win;
			               d_count<=d_count;                      --dealer's score counter unchanged
                           p_count<=p_count+1;                    --player's score counter is incremented
                             IF(p_count="1001")then               --score counter for both dealer and player is reset to zero after 9 games
                             d_count<="0000";
                             p_count<="0000";
                             END IF;
			         --hit button is pressed: player chose to hit                 
			         ELSIF (hit_n = '0' AND hit_n_dly = '1'AND p_card<5 AND ledg0='0' AND ledg1='0')THEN  
			                                  
			                p_total<=p_total+ p_comp;            --update the running total for the player 
						    p_card<=p_card+1;                    --set the card count of player
						
						    blackjack<=player_turn;
			    
	                 ELSIF (stand_n = '0' AND stand_n_dly ='1'AND p_card<5 AND ledg0='0'AND ledg1='0') THEN 
			                blackjack<=dealer_turn;
			         END IF;
			     
	         WHEN dealer_turn=>   
	            
	                 IF(d_total=p_total)THEN            --in case of tie dealer wins automatically
                      blackjack<=player_lose;            
                      d_count<=d_count+1;               --dealer's score counter is incremented
                      p_count<=p_count;                 --player's score counter is unchanged
                      IF(d_count="1001")then            --score counter for both dealer and player is reset to zero after 9 games
                             d_count<="0000";
                             p_count<="0000";
                          END IF;
                       
                      --the dealer wins once his/her total equals to or exceeds 
			          -- the player's without having to press the stand button. 
	                  ELSIF(d_total>p_total AND d_total<"10110") THEN
                      blackjack<=player_lose;
                      d_count<=d_count+1;         --dealer's score counter is incremented
                      p_count<=p_count;           --palyer's score counter is unchanged
                         IF(d_count="1001")then   -- score counter for both dealer and player is reset to zero after 9 games
                             d_count<="0000";
                             p_count<="0000";
                           END IF;
                           
			          ELSIF(d_total>"10101") THEN  --dealer loses if he/she busts (d_total>21)
                      blackjack<=player_win;
                      d_count<=d_count;            --dealer's score counter is unchanged
                      p_count<=p_count+1;          --palyer's score counter is incremented
                          IF(p_count="1001")then   -- score counter for both dealer and player is reset to zero after 9 games
                             d_count<="0000";
                              p_count<="0000";
                           END IF;
                       
                      ELSIF(d_total<p_total AND d_card="101")THEN  --dealer loses if his total at the 5th card exceeds21 
                      blackjack<=player_win;
                      d_count<=d_count;             --dealer's score counter is unchanged
                      p_count<=p_count+1;           --player's score counter is incremented
                      IF(p_count="1001")then        -- score counter for both dealer and player is reset to zero after 9 games
                              d_count<="0000";
                              p_count<="0000";
                       END IF;
                       
                      --if any of the green led's is on and total number of cards dealt is 5, pressing any of 
                      --the keys other than the stop key will be ineffective.(e.g: pressing hit key will not generate a sixth card                                                                         
	                  ELSIF (hit_n = '0' AND hit_n_dly = '1'AND ledg0='0'AND ledg1='0'AND p_card<5 )THEN 
			                                          
					  d_total<=d_total+ d_comp;           --update the running total for the dealer 
                      d_card<=d_card+1;                   --update the card counter of the dealer
                                          
                      blackjack<=dealer_turn;
                      END IF;
                 
              WHEN player_win=>
                      dealer_win_out<='0';         --green lEDG0 is off
			          player_win_out<='1';         --Green LEDG1 goes on  
                              
                      IF(stop_n='0')THEN
			          blackjack<=idle;
			          END IF;
			          
		      WHEN player_lose=>
		             dealer_win_out<='1';         --Green LEDG0 goes on 
			         player_win_out<='0';         --Green LEDG1 is off
                         
                     IF(stop_n='0')THEN
			         blackjack<=idle;
			         END IF;
			   
			  WHEN others =>
			         blackjack<=idle;
			
        END CASE;
    END IF;
END PROCESS state_machine;

END ENSC350;			 

	
