library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity freq_meter_core is
    Generic (
        CLK_FREQ_HZ : integer := 100_000_000 -- Frecuencia del reloj del sistema
    );
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        signal_in   : in  std_logic;
        freq_out    : out std_logic_vector(23 downto 0) -- Salida para frecuencias de hasta 9999 Hz y más
    );
end freq_meter_core;

architecture Behavioral of freq_meter_core is
    -- Contador para la ventana de 1 segundo
    signal time_base_counter : integer range 0 to CLK_FREQ_HZ - 1 := 0;

    -- Contador para los eventos (flancos de subida)
    signal event_counter : unsigned(23 downto 0) := (others => '0');

    -- Señal para registrar el último estado de la entrada y detectar flancos
    signal last_signal_state : std_logic := '0';

begin

    process(clk, reset)
    begin
        if reset = '1' then
            time_base_counter <= 0;
            event_counter     <= (others => '0');
            last_signal_state <= '0';
            freq_out          <= (others => '0');
        elsif rising_edge(clk) then
            -- Lógica de la base de tiempo de 1 segundo
            if time_base_counter = CLK_FREQ_HZ - 1 then
                time_base_counter <= 0;
                -- Al cumplirse 1 segundo, se actualiza la salida de frecuencia
                freq_out <= std_logic_vector(event_counter);
                -- Y se reinicia el contador de eventos
                event_counter <= (others => '0');
            else
                time_base_counter <= time_base_counter + 1;
            end if;

            -- Detección del flanco de subida y conteo de eventos
            if signal_in = '1' and last_signal_state = '0' then
                event_counter <= event_counter + 1;
            end if;
            
            last_signal_state <= signal_in;
        end if;
    end process;

end Behavioral;