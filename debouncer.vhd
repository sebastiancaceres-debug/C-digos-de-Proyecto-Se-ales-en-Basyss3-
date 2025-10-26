library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
    Generic (
        CLK_FREQ_HZ : integer := 100_000_000; -- Frecuencia del reloj del sistema (100 MHz para Basys 3)
        STABLE_TIME_MS : integer := 10         -- Tiempo de estabilización en ms
    );
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        btn_in   : in  std_logic;
        btn_out  : out std_logic
    );
end debouncer;

architecture Behavioral of debouncer is
    -- Constante para el contador de debounce, calculada a partir de los genéricos
    constant DEBOUNCE_LIMIT : integer := (CLK_FREQ_HZ / 1000) * STABLE_TIME_MS;

    -- Señales internas
    signal counter     : integer range 0 to DEBOUNCE_LIMIT := 0;
    signal internal_q  : std_logic_vector(1 downto 0) := "00";
    signal debounced_signal : std_logic := '0';

begin
    process(clk, reset)
    begin
        if reset = '1' then
            internal_q <= "00";
            counter <= 0;
            debounced_signal <= '0';
        elsif rising_edge(clk) then
            -- Se crea una pequeña cadena de registros para filtrar glitches
            internal_q(0) <= btn_in;
            internal_q(1) <= internal_q(0);

            -- Si la señal cambia, se resetea el contador
            if internal_q(1) /= debounced_signal then
                counter <= 0;
            -- Si la señal es estable por el tiempo definido, se actualiza la salida
            elsif counter < DEBOUNCE_LIMIT then
                counter <= counter + 1;
            else
                debounced_signal <= internal_q(1);
            end if;
        end if;
    end process;

    btn_out <= debounced_signal;

end Behavioral;