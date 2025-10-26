library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin_to_bcd is
    Port (
        binary_in : in  std_logic_vector(23 downto 0);
        bcd3      : out std_logic_vector(3 downto 0); -- Miles
        bcd2      : out std_logic_vector(3 downto 0); -- Cientos
        bcd1      : out std_logic_vector(3 downto 0); -- Decenas
        bcd0      : out std_logic_vector(3 downto 0)  -- Unidades
    );
end bin_to_bcd;

architecture Behavioral of bin_to_bcd is
begin
    process(binary_in)
        variable temp_val : integer;
        variable temp_bcd3, temp_bcd2, temp_bcd1, temp_bcd0 : integer range 0 to 9;
    begin
        temp_val := to_integer(unsigned(binary_in));

        -- Limita la visualización a 9999
        if temp_val > 9999 then
            temp_val := 9999;
        end if;

        temp_bcd3 := temp_val / 1000;
        temp_val  := temp_val mod 1000;

        temp_bcd2 := temp_val / 100;
        temp_val  := temp_val mod 100;

        temp_bcd1 := temp_val / 10;
        temp_bcd0 := temp_val mod 10;

        bcd3 <= std_logic_vector(to_unsigned(temp_bcd3, 4));
        bcd2 <= std_logic_vector(to_unsigned(temp_bcd2, 4));
        bcd1 <= std_logic_vector(to_unsigned(temp_bcd1, 4));
        bcd0 <= std_logic_vector(to_unsigned(temp_bcd0, 4));
    end process;
end Behavioral;