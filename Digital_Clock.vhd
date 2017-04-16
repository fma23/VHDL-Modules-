--Author: Farid Mabrouk

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;


ENTITY Digital_Clock IS port (
  														
  clk               :   in  std_logic; 
  Clear_Up_Down 	:	in std_logic_vector(2 downto 0);
  reset             :   in std_logic;
  count             :   BUFFER  std_logic_vector (25 downto 0);
  --count           :   BUFFER  std_logic_vector (13 downto 0); --for testing
  countS            :   BUFFER  std_logic_vector (5 downto 0);
  countM            :   BUFFER  std_logic_vector (5 downto 0);
  countH            :   BUFFER  std_logic_vector (4 downto 0);
   
  hex0_d	        :	out std_logic_vector(6 downto 0);
  hex0_dp	        :	out std_logic ;
  hex1_d	        :	out std_logic_vector(6 downto 0);
  hex1_dp	        :	out std_logic;
  
  hex2_d	        :	out std_logic_vector(6 downto 0);
  hex2_dp	        :	out std_logic ;
  hex3_d	        :	out std_logic_vector(6 downto 0);
  hex3_dp	        :	out std_logic;
  
  hex4_d	        :	out std_logic_vector(6 downto 0);
  hex4_dp	        :	out std_logic ;
  hex5_d	        :	out std_logic_vector(6 downto 0);
  hex5_dp	        :	out std_logic 
  );
  
 END Digital_Clock ;
 
 ARCHITECTURE MyCounter OF Digital_Clock IS
       
 	constant  blank	: std_logic_vector(6 downto 0)    := "1111111";
	constant  zero	: std_logic_vector(6 downto 0)    := "1000000";
	constant  one 	: std_logic_vector(6 downto 0)    := "1111001";
	constant  two 	: std_logic_vector(6 downto 0)    := "0100100";
	constant  three	: std_logic_vector(6 downto 0)    := "0110000";
	constant  four 	: std_logic_vector(6 downto 0)    := "0011001";
	constant  five 	: std_logic_vector(6 downto 0)    := "0010010";
	constant  six	: std_logic_vector(6 downto 0)    := "0000010";
	constant  seven : std_logic_vector(6 downto 0)    := "1111000";
	constant  eight : std_logic_vector(6 downto 0)    := "0000000";
    constant  nine	: std_logic_vector(6 downto 0)    := "0010000";
    
    type state_machines is (idle,count_up, count_down);
    signal currstate: state_machines;
       
BEGIN
     
hex0_dp <= '1';		-- turn off decimal point
hex1_dp <= '1';
hex2_dp <= '1';	
hex3_dp <= '1';
hex4_dp <= '1';	
hex5_dp <= '1';


---Frequency Devider
curStProc:process(clk,reset,currstate)
 begin
   if( reset='1') then
         count<=  "00000000000000000000000000";
         --count<=  "00000000000000"; testing
         countS<= "000000";
         countM<= "000000";
         currstate<=idle;
         
   elsif(clk'event and clk = '1') then 
        case currstate is
	        when idle=>
	          count<=  "00000000000000000000000000";
	          --count<=  "00000000000000"; testing
              countS<= "000000";
              countM<= "000000";
              countH<=  "00000";
	          if( Clear_Up_Down="010") then
                 currstate<=count_up;
               elsif(Clear_Up_Down="001")then
                  currstate<=count_down;
               elsif(Clear_Up_Down(2)='1')then
                  currstate<=idle;
               end if;
               
	        when count_up=>
	             count <= count + 1;
			     if(count="10111110101111000001111111") then
	              count<=  "00000000000000000000000000";
			     --if(count= "11001011000111") then
			      -- count<=  "00000000000000";  
	       
	             countS<=countS+1; 
	                if (countS="111011")then 
	                 countS<="000000";
	                 countM<=countM+1;
	                     if(countM="111011")then
	                       countM<="000000";
	                       countH<=countH+1;
	                         if(countH="10111")then
	                            countH<="00000";
	                          end if;
	                      end if;
	                  end if;
	              end if;
	             
	             if (Clear_Up_Down(2)='1')then
	             currstate<=idle; 
	             elsif(Clear_Up_Down="000") then
                 currstate<=idle;
                 elsif(Clear_Up_Down="001") then
                 currstate<=count_down;
                 elsif(Clear_Up_Down="011") then
                 currstate<=idle;
	             end if;
	     
	         when count_down =>
	             count <= count - 1;
			     if (count="00000000000000000000000000") then
                     count<="10111110101111000001111111";
                 
                 --if (count=  "00000000000000") then -- generating one hour per second for testing
                 --count<="11001011000111";   --testing
	             countS<=countS-1;
	                 if (countS="000000")then 
	                     countS<="111011";
	                     countM<=countM-1;
	                        if(countM="000000") then
	                          countM<="111011";
	                          countH<=countH-1;
	                             if(countH="00000") then
	                                countH<="10111";
	                             end if;
	                               
	                        end if;
	                  end if;
	              end if;
	            
	             if (Clear_Up_Down(2)='1')  then
	             currstate<=idle; 
	             elsif(Clear_Up_Down="000") then
                 currstate<=idle;
                 elsif(Clear_Up_Down="010") then
                 currstate<=count_down;
                 elsif(Clear_Up_Down="011") then
                 currstate<=idle;
	             end if;
	       
	    when others=> null;
	 end case;
  end if;
end process curStProc;

 Secondes_Decoder: PROCESS (countS)
    BEGIN
    
         case countS(5 downto 0) is
		    when "000000"=>
		        hex0_d <= zero;
                hex1_d <= zero;
			when "000001" =>
                hex0_d <= one;
                hex1_d <= zero;
			when "000010" =>
                hex0_d <= two;
			    hex1_d <= zero;
			when "000011" =>
                hex0_d <= three;
			    hex1_d <= zero;
			when "000100" =>
                hex0_d <= four;
			    hex1_d <= zero;
			when "000101" =>
                hex0_d <= five;
                hex1_d <= zero;
			when "000110" =>
                hex0_d <= six;
                hex1_d <= zero;
			when "000111" =>
                hex0_d <= seven;
			    hex1_d <= zero;
			when "001000" =>
                hex0_d <= eight;
			    hex1_d <= zero;
			when "001001" =>
                hex0_d <= nine;
                hex1_d <= zero;
            when "001010" =>
                hex0_d <= zero;
			    hex1_d <= one;
			when "001011" =>
                hex0_d <= one;
                hex1_d <= one;
            when "001100" =>
                hex0_d <= two;
			    hex1_d <= one;
			when "001101" =>
                hex0_d <= three;
                hex1_d <= one;
            when "001110" =>
                hex0_d <= four;
			    hex1_d <= one;
			when "001111" =>
                hex0_d <= five;
                hex1_d <= one;  
            when "010000" =>
                hex0_d <= six;
                hex1_d <= one; 
            when "010001" =>
                hex0_d <= seven;
                hex1_d <= one; 
            when "010010" =>
                hex0_d <= eight;
                hex1_d <= one; 
            when "010011" =>
                hex0_d <= nine;
                hex1_d <= one;
           when "010100" =>
                hex0_d <= zero;
                hex1_d <= two;  
           when "010101" =>
                hex0_d <= one;
                hex1_d <= two;  
           when "010110" =>
                hex0_d <= two;
                hex1_d <= two; 
           when "010111" =>
                hex0_d <= three;
                hex1_d <= two; 
           when "011000" =>
                hex0_d <= four;
                hex1_d <= two;
           when "011001" =>
                hex0_d <= five;
                hex1_d <= two;
           when "011010" =>
                hex0_d <= six;
                hex1_d <= two;
           when "011011" =>
                hex0_d <= seven;
                hex1_d <= two;
           when "011100" =>
                hex0_d <= eight;
                hex1_d <= two;
           when "011101" =>
                hex0_d <= nine;
                hex1_d <= two;
           when "011110" =>
                hex0_d <= zero;
                hex1_d <= three;
           when "011111" =>
                hex0_d <= one;
                hex1_d <= three;      
           when "100000" =>
                hex0_d <= two;
                hex1_d <= three;           
           when "100001" =>
                hex0_d <= three;
                hex1_d <= three;           
           when "100010" =>
                hex0_d <= four;
                hex1_d <= three; 
           when "100011" =>
                hex0_d <= five;
                hex1_d <= three;     
           when "100100" =>
                hex0_d <= six;
                hex1_d <= three;    
           when "100101" =>
                hex0_d <= seven;
                hex1_d <= three; 
           when "100110" =>
                hex0_d <= eight;
                hex1_d <= three; 
           when "100111" =>
                hex0_d <= nine;
                hex1_d <= three;
           when "101000" =>
                hex0_d <= zero;
                hex1_d <= four;       
          when "101001" =>
                hex0_d <= one;
                hex1_d <= four;
           when "101010" =>
                hex0_d <= two;
                hex1_d <= four;           
           when "101011" =>
                hex0_d <= three;
                hex1_d <= four; 
           when "101100" =>
                hex0_d <= four;
                hex1_d <= four;
           when "101101" =>
                hex0_d <= five;
                hex1_d <= four;     
           when "101110" =>
                hex0_d <= six;
                hex1_d <= four;     
           when "101111" =>
                hex0_d <= seven;
                hex1_d <= four;     
           when "110000" =>
                hex0_d <= eight;
                hex1_d <= four;   
           when "110001" =>
                hex0_d <= nine;
                hex1_d <= four; 
           when "110010" =>
                hex0_d <= zero;
                hex1_d <= five;
           when "110011" =>
                hex0_d <= one;
                hex1_d <= five; 
           when "110100" =>
                hex0_d <= two;
                hex1_d <= five; 
           when "110101" =>
                hex0_d <= three;
                hex1_d <= five; 
           when "110110" =>
                hex0_d <= four;
                hex1_d <= five;
           when "110111" =>
                hex0_d <= five;
                hex1_d <= five; 
           when "111000" =>
                hex0_d <= six;
                hex1_d <= five;  
           when "111001" =>
                hex0_d <= seven;
                hex1_d <= five; 
           when "111010" =>
                hex0_d <= eight;
                hex1_d <= five;  
           when "111011" =>
                hex0_d <= nine;
                hex1_d <= five;
           when others =>
                hex0_d <= zero;
                hex1_d <= zero;
		end case;  
	
 end process Secondes_Decoder;
 
Minutes_Decoder: PROCESS (countM)
    BEGIN
    
         case countM(5 downto 0) is
		    when "000000"=>
		        hex2_d <= zero;
                hex3_d <= zero;
			when "000001" =>
                hex2_d <= one;
                hex3_d <= zero;
			when "000010" =>
                hex2_d <= two;
			    hex3_d <= zero;
			when "000011" =>
                hex2_d <= three;
			    hex3_d <= zero;
			when "000100" =>
                hex2_d <= four;
			    hex3_d <= zero;
			when "000101" =>
                hex2_d <= five;
                hex3_d <= zero;
			when "000110" =>
                hex2_d <= six;
                hex3_d <= zero;
			when "000111" =>
                hex2_d <= seven;
			    hex3_d <= zero;
			when "001000" =>
                hex2_d <= eight;
			    hex3_d <= zero;
			when "001001" =>
                hex2_d <= nine;
                hex3_d <= zero;
            when "001010" =>
                hex2_d <= zero;
			    hex3_d <= one;
			when "001011" =>
                hex2_d <= one;
                hex3_d <= one;
            when "001100" =>
                hex2_d <= two;
			    hex3_d <= one;
			when "001101" =>
                hex2_d <= three;
                hex3_d <= one;
            when "001110" =>
                hex2_d <= four;
			    hex3_d <= one;
			when "001111" =>
                hex2_d <= five;
                hex3_d <= one;  
            when "010000" =>
                hex2_d <= six;
                hex3_d <= one; 
            when "010001" =>
                hex2_d <= seven;
                hex3_d <= one; 
            when "010010" =>
                hex2_d <= eight;
                hex3_d <= one; 
            when "010011" =>
                hex2_d <= nine;
                hex3_d <= one;
           when "010100" =>
                hex2_d <= zero;
                hex3_d <= two;  
           when "010101" =>
                hex2_d <= one;
                hex3_d <= two;  
           when "010110" =>
                hex2_d <= two;
                hex3_d <= two; 
           when "010111" =>
                hex2_d <= three;
                hex3_d <= two; 
           when "011000" =>
                hex2_d <= four;
                hex3_d <= two;
           when "011001" =>
                hex2_d <= five;
                hex3_d <= two;
           when "011010" =>
                hex2_d <= six;
                hex3_d <= two;
           when "011011" =>
                hex2_d <= seven;
                hex3_d <= two;
           when "011100" =>
                hex2_d <= eight;
                hex3_d <= two;
           when "011101" =>
                hex2_d <= nine;
                hex3_d <= two;
           when "011110" =>
                hex2_d <= zero;
                hex3_d <= three;
           when "011111" =>
                hex2_d <= one;
                hex3_d <= three;      
           when "100000" =>
                hex2_d <= two;
                hex3_d <= three;           
           when "100001" =>
                hex2_d <= three;
                hex3_d <= three;           
           when "100010" =>
                hex2_d <= four;
                hex3_d <= three; 
           when "100011" =>
                hex2_d <= five;
                hex3_d <= three;     
           when "100100" =>
                hex2_d <= six;
                hex3_d <= three;    
           when "100101" =>
                hex2_d <= seven;
                hex3_d <= three; 
           when "100110" =>
                hex2_d <= eight;
                hex3_d <= three; 
           when "100111" =>
                hex2_d <= nine;
                hex3_d <= three;
           when "101000" =>
                hex2_d <= zero;
                hex3_d <= four;       
           when "101001" =>
                hex2_d <= one;
                hex3_d <= four;
           when "101010" =>
                hex2_d <= two;
                hex3_d <= four;           
           when "101011" =>
                hex2_d <= three;
                hex3_d <= four; 
           when "101100" =>
                hex2_d <= four;
                hex3_d <= four;
           when "101101" =>
                hex2_d <= five;
                hex3_d <= four;     
           when "101110" =>
                hex2_d <= six;
                hex3_d <= four;     
           when "101111" =>
                hex2_d <= seven;
                hex3_d <= four;     
           when "110000" =>
                hex2_d <= eight;
                hex3_d <= four;   
           when "110001" =>
                hex2_d <= nine;
                hex3_d <= four; 
           when "110010" =>
                hex2_d <= zero;
                hex3_d <= five;
           when "110011" =>
                hex2_d <= one;
                hex3_d <= five; 
           when "110100" =>
                hex2_d <= two;
                hex3_d <= five; 
           when "110101" =>
                hex2_d <= three;
                hex3_d <= five; 
           when "110110" =>
                hex2_d <= four;
                hex3_d <= five;
           when "110111" =>
                hex2_d <= five;
                hex3_d <= five; 
           when "111000" =>
                hex2_d <= six;
                hex3_d <= five;  
           when "111001" =>
                hex2_d <= seven;
                hex3_d <= five; 
           when "111010" =>
                hex2_d <= eight;
                hex3_d <= five;  
           when "111011" =>
                hex2_d <= nine;
                hex3_d <= five;
           when others =>
                hex2_d <= zero;
                hex3_d <= zero;
		end case;  
	
 end process Minutes_Decoder;
 
Hours_Decoder: PROCESS (countH)
    BEGIN
    
         case countH(4 downto 0) is
		    when "00000"=>
		        hex4_d <= zero;
                hex5_d <= zero;
			when "00001" =>
                hex4_d <= one;
                hex5_d <= zero;
			when "00010" =>
                hex4_d <= two;
			    hex5_d <= zero;
			when "00011" =>
                hex4_d <= three;
			    hex5_d <= zero;
			when "00100" =>
                hex4_d <= four;
			    hex5_d <= zero;
			when "00101" =>
                hex4_d <= five;
                hex5_d <= zero;
			when "00110" =>
                hex4_d <= six;
                hex5_d <= zero;
			when "00111" =>
                hex4_d <= seven;
			    hex5_d <= zero;
			when "01000" =>
                hex4_d <= eight;
			    hex5_d <= zero;
			when "01001" =>
                hex4_d <= nine;
                hex5_d <= zero;
            when "01010" =>
                hex4_d <= zero;
			    hex5_d <= one;
			when "01011" =>
                hex4_d <= one;
                hex5_d <= one;
            when "01100" =>
                hex4_d <= two;
			    hex5_d <= one;
			when "01101" =>
                hex4_d <= three;
                hex5_d <= one;
            when "01110" =>
                hex4_d <= four;
			    hex5_d <= one;
			when "01111" =>
                hex4_d <= five;
                hex5_d <= one;  
            when "10000" =>
                hex4_d <= six;
                hex5_d <= one; 
            when "10001" =>
                hex4_d <= seven;
                hex5_d <= one; 
            when "10010" =>
                hex4_d <= eight;
                hex5_d <= one; 
            when "10011" =>
                hex4_d <= nine;
                hex5_d <= one;
           when "10100" =>
                hex4_d <= zero;
                hex5_d <= two;  
           when "10101" =>
                hex4_d <= one;
                hex5_d <= two;  
           when "10110" =>
                hex4_d <= two;
                hex5_d <= two; 
           when "10111" =>
                hex4_d <= three;
                hex5_d <= two; 
           when others =>
                hex4_d <= zero;
                hex5_d <= zero;
		end case;  
	
 end process Hours_Decoder;
         
         
end MyCounter;
           
     
            
            
            
    
            
            
            
            
     
 