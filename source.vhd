----------------------------------------------------------------------------------
-- Engineer: Eugenio Ostrovan (866052 / 10527025)
-- Create Date: 23.03.2019 18:34:31
-- Design Name: Progetto reti logiche
-- Module Name: progetto - Behavioral
-- Description: Realizzazione della specifica proposta per il progetti di reti logiche 2018/2019
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR(7 downto 0);
           o_address : out STD_LOGIC_VECTOR(15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR(7 downto 0));
end project_reti_logiche;

architecture arch of project_reti_logiche is
--definition of the state type for the FSM
type state_type is (reset, ask, hold, read, assign_signals, calcd, calcdm1, calcdm2, calcdm, calcmask, writemask, done);
--these signals store the current and next state of the FSM
signal current_state, next_state : state_type;
--input mask indicates the valid centroids for processing, it is stored in RAM at address 0
signal input_mask : std_logic_vector(7 downto 0);
--x coordinate of the reference point
signal x_reference : SIGNED (8 downto 0);
--y coordinate of the reference point
signal y_reference : SIGNED (8 downto 0);
--coordinates of the assigned points
signal x1 : SIGNED (7 downto 0) := (others => '0');
signal y1 : SIGNED (7 downto 0) := (others => '0');
signal x2 : SIGNED (7 downto 0) := (others => '0');
signal y2 : SIGNED (7 downto 0) := (others => '0');
signal x3 : SIGNED (7 downto 0) := (others => '0');
signal y3 : SIGNED (7 downto 0) := (others => '0');
signal x4 : SIGNED (7 downto 0) := (others => '0');
signal y4 : SIGNED (7 downto 0) := (others => '0');
signal x5 : SIGNED (7 downto 0) := (others => '0');
signal y5 : SIGNED (7 downto 0) := (others => '0');
signal x6 : SIGNED (7 downto 0) := (others => '0');
signal y6 : SIGNED (7 downto 0) := (others => '0');
signal x7 : SIGNED (7 downto 0) := (others => '0');
signal y7 : SIGNED (7 downto 0) := (others => '0');
signal x8 : SIGNED (7 downto 0) := (others => '0');
signal y8 : SIGNED (7 downto 0) := (others => '0');
--the distances from each point to the reference point
signal d1sig : signed (8 downto 0) := (others => '1');
signal d1 : UNSIGNED (8 downto 0) := (others => '1');
signal d2 : UNSIGNED (8 downto 0) := (others => '1');
signal d3 : UNSIGNED (8 downto 0) := (others => '1');
signal d4 : UNSIGNED (8 downto 0) := (others => '1');
signal d5 : UNSIGNED (8 downto 0) := (others => '1');
signal d6 : UNSIGNED (8 downto 0) := (others => '1');
signal d7 : UNSIGNED (8 downto 0) := (others => '1');
signal d8 : UNSIGNED (8 downto 0) := (others => '1');
--the distance from the reference point to the closest point among those to be considered
signal d_min : UNSIGNED (8 downto 0);-- := (others => '1');
--these signals are used in the intermediate steps when calculating the minimum distance
--'d ab' takes the smallest value between 'd a' and 'd b'
signal d12 : UNSIGNED (8 downto 0) := (others => '1');
signal d34 : UNSIGNED (8 downto 0) := (others => '1');
signal d56 : UNSIGNED (8 downto 0) := (others => '1');
signal d78 : UNSIGNED (8 downto 0) := (others => '1');

signal d1234 : UNSIGNED (8 downto 0) := (others => '1');
signal d5678 : UNSIGNED (8 downto 0) := (others => '1');
--this signal stores the output mask
signal output : std_logic_vector (7 downto 0) := (others => '0');
--the indexes are used to build the memory addresses from which to read data
signal index : integer;
signal next_index : integer;
--data stores all coordinates read from the memmory which will be assigned to individual signals
signal data : std_logic_vector(0 to 152) := (others => '0');

begin
--this process describes the behaviour of the FSM in each of its states. See documentation for details.
FSM : process(i_clk, i_rst, current_state, index, i_data, data, input_mask, x_reference, y_reference, x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8, d1, d2, d3, d4, d5, d6, d7, d8, d12, d34, d56, d78, d1234, d5678, d_min, output, i_start, current_state, next_state, next_index)
begin
    case current_state is
        when reset =>
            o_done <= '0';
            o_en <= '0';
            o_we <= '0';
            
        when ask =>
            if rising_edge(i_clk) then
                o_en <= '1';
                o_address <= std_logic_vector(to_unsigned(index, 16));
            end if;
            
        when hold =>
            null;
            
        when read =>
            if rising_edge(i_clk) then
                data(index * 8 to index * 8 + 7) <= i_data;
            end if;
            
        when assign_signals =>
            if rising_edge(i_clk) then
                x_reference <= '0' & signed(data(136 to 143));
                y_reference <= '0' & signed(data(144 to 151));
                
                input_mask <= data(0 to 7);
                
                x1 <= signed(data(8 to 15));
                y1 <= signed(data(16 to 23));
                
                x2 <= signed(data(24 to 31));
                y2 <= signed(data(32 to 39));
                
                x3 <= signed(data(40 to 47));
                y3 <= signed(data(48 to 55));
                
                x4 <= signed(data(56 to 63));
                y4 <= signed(data(64 to 71));
                
                x5 <= signed(data(72 to 79));
                y5 <= signed(data(80 to 87));
                
                x6 <= signed(data(88 to 95));
                y6 <= signed(data(96 to 103));
                
                x7 <= signed(data(104 to 111));
                y7 <= signed(data(112 to 119));
                
                x8 <= signed(data(120 to 127));
                y8 <= signed(data(128 to 135));
            end if;
            
        when calcd =>
        if rising_edge(i_clk) then
        if input_mask(0) = '1' then
            d1sig <= abs(y_reference - ('0' & y1));
            d1 <= unsigned(abs(x_reference - ('0' & x1)) + abs(y_reference - ('0' & y1)));
        else
            d1 <= (others => '1');
        end if;
        if input_mask(1) = '1' then
            d2 <= unsigned(abs(x_reference - ('0' & x2)) + abs(y_reference - ('0' & y2)));
        else
            d2 <= (others => '1');
        end if;
        if input_mask(2) = '1' then
            d3 <= unsigned(abs(x_reference - ('0' & x3)) + abs(y_reference - ('0' & y3)));
        else
            d3 <= (others => '1');
        end if;
        if input_mask(3) = '1' then
            d4 <= unsigned(abs(x_reference - ('0' & x4)) + abs(y_reference - ('0' & y4)));
        else
            d4 <= (others => '1');
        end if;
        if input_mask(4) = '1' then
            d5 <= unsigned(abs(x_reference - ('0' & x5)) + abs(y_reference - ('0' & y5)));
        else
            d5 <= (others => '1');
        end if;
        
        if input_mask(5) = '1' then
            d6 <= unsigned(abs(x_reference - ('0' & x6)) + abs(y_reference - ('0' & y6)));
        else
            d6 <= (others => '1');
        end if;
        
        if input_mask(6) = '1' then
            d7 <= unsigned(abs(x_reference - ('0' & x7)) + abs(y_reference - ('0' & y7)));
        else
            d7 <= (others => '1');
        end if;
        if input_mask(7) = '1' then
            d8 <= unsigned(abs(x_reference - ('0' & x8)) + abs(y_reference - ('0' & y8)));
        else
            d8 <= (others => '1');
        end if;
        end if;
        
        when calcdm1 =>
        if rising_edge(i_clk) then
            if d1 < d2 then
                d12 <= d1;
            else
                d12 <= d2;
            end if;
            if d3 < d4 then
                d34 <= d3;
            else
                d34 <= d4;
            end if;
            if d5 < d6 then
                d56 <= d5;
            else
                d56 <= d6;
            end if;
            if d7 < d8 then
                d78 <= d7;
            else
                d78 <= d8;
            end if;
            end if;
            
        when calcdm2 =>
        if rising_edge(i_clk) then
            if d12 < d34 then
                d1234 <= d12;
            else
                d1234 <= d34;
            end if;
            if d56 < d78 then
                d5678 <= d56;
            else
                d5678 <= d78;
            end if;
            end if;
            
        when calcdm =>
        if rising_edge(i_clk) then
            if d1234 < d5678 then
                d_min <= d1234;
            else
                d_min <= d5678;
            end if;
            end if;
            
        when calcmask =>
        if rising_edge(i_clk) then
            if input_mask(0) = '1' and d1 = d_min then
                output(0) <= '1';
            else
                output(0) <= '0';
            end if;
            if input_mask(1) = '1' and d2 = d_min then
                output(1) <= '1';
            else
                output(1) <= '0';
            end if;
            if input_mask(2) = '1' and d3 = d_min then
                output(2) <= '1';
            else
                output(2) <= '0';
            end if;
            if input_mask(3) = '1' and d4 = d_min then
                output(3) <= '1';
            else
                output(3) <= '0';
            end if;
            if input_mask(4) = '1' and d5 = d_min then
                output(4) <= '1';
            else
                output(4) <= '0';
            end if;
            if input_mask(5) = '1' and d6 = d_min then
                output(5) <= '1';
            else
                output(5) <= '0';
            end if;
            if input_mask(6) = '1' and d7 = d_min then
                output(6) <= '1';
            else
                output(6) <= '0';
            end if;
            if input_mask(7) = '1' and d8 = d_min then
                output(7) <= '1';
            else
                output(7) <= '0';
            end if;
            end if;
        when writemask =>
            if rising_edge(i_clk) then
                o_we <= '1';
                o_data <= output;
                o_done <= '1';
            end if;
            o_address <= std_logic_vector(to_unsigned(19, 16));
            o_en <= '1';
        when done =>
            if rising_edge(i_clk) then
                if i_start = '0' then
                    o_done <= '0';
                    o_we <= '0';
                    o_en <= '0';
                end if;
            end if;
        end case;
end process FSM;

--this process assigns values to the next state signal based on input and current state
next_state_assignment : process(i_clk, i_rst, i_start, current_state, index)
begin
    if i_rst = '1' and rising_edge(i_clk) then
        next_state <= reset;
    end if;
    if i_start = '1' and rising_edge(i_clk) then
    case current_state is
        when reset =>
            next_state <= ask;
            next_index <= 0;
        when ask =>
            next_state <= hold;
        when hold =>
            next_state <= read;
        when read =>
            if index = 18 then
                next_state <= assign_signals;
            else
                next_state <= ask;
            end if;
            next_index <= index + 1;
        when assign_signals =>
            next_state <= calcd;
        when calcd =>
            next_state <= calcdm1;
        when calcdm1 =>
            next_state <= calcdm2;
        when calcdm2 =>
            next_state <= calcdm;
        when calcdm =>
            next_state <= calcmask;
        when calcmask =>
            next_state <= writemask;
        when writemask =>
            next_state <= done;
        when done =>
            next_state <= done;
    end case;
    end if;
end process next_state_assignment;

--this process moves the FSM to the next state every clock cycle
current_state_assignment : process(i_clk, next_state, next_index)
begin
    current_state <= next_state;
    index <= next_index;
end process current_state_assignment;

end arch;
