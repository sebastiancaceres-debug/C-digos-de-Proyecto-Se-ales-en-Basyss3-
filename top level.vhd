library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    Port (
        clk         : in  std_logic;
        sw          : in  std_logic_vector(0 downto 0); -- SW0 para seleccionar entrada
        btnc        : in  std_logic; -- Pulsador central para medir su frecuencia
        digital_in  : in  std_logic; -- Entrada digital genérica
        anodes      : out std_logic_vector(3 downto 0);
        segments    : out std_logic_vector(6 downto 0)
    );
end top_level;

architecture Behavioral of top_level is

    -- Señales para interconectar los módulos
    signal debounced_btn_signal : std_logic;
    signal selected_signal      : std_logic;
    signal reset_signal         : std_logic := '0'; -- Reset global (si no se usa un botón específico)
    signal frequency_bin        : std_logic_vector(23 downto 0);
    signal bcd3, bcd2, bcd1, bcd0 : std_logic_vector(3 downto 0);

begin

    -- Instancia del debouncer para el pulsador
    debouncer_inst : entity work.debouncer
        port map (
            clk      => clk,
            reset    => reset_signal,
            btn_in   => btnc,
            btn_out  => debounced_btn_signal
        );

    -- Multiplexor para seleccionar la señal a medir usando SW0
    -- SW0 = 0 -> Pulsador (debounced)
    -- SW0 = 1 -> Entrada digital
    selected_signal <= debounced_btn_signal when sw(0) = '0' else digital_in;

    -- Instancia del medidor de frecuencia
    freq_meter_core_inst : entity work.freq_meter_core
        port map (
            clk         => clk,
            reset       => reset_signal,
            signal_in   => selected_signal,
            freq_out    => frequency_bin
        );

    -- Instancia del conversor Binario a BCD
    bin_to_bcd_inst : entity work.bin_to_bcd
        port map (
            binary_in => frequency_bin,
            bcd3      => bcd3,
            bcd2      => bcd2,
            bcd1      => bcd1,
            bcd0      => bcd0
        );

    -- Instancia del driver de 7 segmentos
    seven_segment_driver_inst : entity work.seven_segment_driver
        port map (
            clk      => clk,
            reset    => reset_signal,
            bcd3     => bcd3,
            bcd2     => bcd2,
            bcd1     => bcd1,
            bcd0     => bcd0,
            anodes   => anodes,
            segments => segments
        );

end Behavioral;