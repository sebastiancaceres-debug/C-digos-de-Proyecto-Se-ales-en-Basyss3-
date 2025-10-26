library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segment_driver is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        bcd3     : in  std_logic_vector(3 downto 0); -- Miles
        bcd2     : in  std_logic_vector(3 downto 0); -- Cientos
        bcd1     : in  std_logic_vector(3 downto 0); -- Decenas
        bcd0     : in  std_logic_vector(3 downto 0); -- Unidades
        anodes   : out std_logic_vector(3 downto 0); -- Control de ánodos (activos en bajo)
        segments : out std_logic_vector(6 downto 0)  -- Control de cátodos (activos en bajo)
    );
end seven_segment_driver;

architecture Behavioral of seven_segment_driver is
    -- Divisor de reloj para obtener una frecuencia de refresco de ~800 Hz
    constant REFRESH_LIMIT : integer := 125000; -- 100MHz / 800Hz
    signal refresh_counter : integer range 0 to REFRESH_LIMIT - 1 := 0;
    signal refresh_tick    : std_logic := '0';

    -- Contador para seleccionar el display a encender (0 a 3)
    signal digit_selector : unsigned(1 downto 0) := "00";
    
    -- Señal para el dígito BCD que se mostrará
    signal current_bcd : std_logic_vector(3 downto 0);

begin

    -- Generador de tick de refresco
    process(clk, reset)
    begin
        if reset = '1' then
            refresh_counter <= 0;
            refresh_tick <= '0';
        elsif rising_edge(clk) then
            if refresh_counter = REFRESH_LIMIT - 1 then
                refresh_counter <= 0;
                refresh_tick <= '1';
            else
                refresh_counter <= refresh_counter + 1;
                refresh_tick <= '0';
            end if;
        end if;
    end process;

    -- Lógica de multiplexación y selección de dígito
    process(clk, reset)
    begin
        if reset = '1' then
            digit_selector <= "00";
        elsif rising_edge(clk) then
            if refresh_tick = '1' then
                digit_selector <= digit_selector + 1;
            end if;
        end if;
    end process;

    -- Multiplexor para seleccionar el BCD del dígito actual
    with digit_selector select
        current_bcd <= bcd0 when "00", -- Dígito menos significativo
                       bcd1 when "01",
                       bcd2 when "10",
                       bcd3 when others; -- Dígito más significativo

    -- Decodificador de ánodos (activo en bajo)
    with digit_selector select
        anodes <= "1110" when "00", -- Activa AN0
                  "1101" when "01", -- Activa AN1
                  "1011" when "10", -- Activa AN2
                  "0111" when others; -- Activa AN3

    -- Decodificador BCD a 7 segmentos (cátodos, activo en bajo)
    -- Segmentos: g, f, e, d, c, b, a
    with current_bcd select
        segments <= "1000000" when "0000", -- 0
                    "1111001" when "0001", -- 1
                    "0100100" when "0010", -- 2
                    "0110000" when "0011", -- 3
                    "0011001" when "0100", -- 4
                    "0010010" when "0101", -- 5
                    "0000010" when "0110", -- 6
                    "1111000" when "0111", -- 7
                    "0000000" when "1000", -- 8
                    "0010000" when "1001", -- 9
                    "1111111" when others; -- Apagado
end Behavioral;