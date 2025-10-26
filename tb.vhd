library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_freq_meter is
end tb_freq_meter;

architecture behavior of tb_freq_meter is
    -- Instancia del componente a probar (DUT: Device Under Test)
    component top_level
        Port (
            clk         : in  std_logic;
            sw          : in  std_logic_vector(0 downto 0);
            btnc        : in  std_logic;
            digital_in  : in  std_logic;
            anodes      : out std_logic_vector(3 downto 0);
            segments    : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Señales de entrada para el testbench
    signal clk_tb         : std_logic := '0';
    signal sw_tb          : std_logic_vector(0 downto 0) := (others => '0');
    signal btnc_tb        : std_logic := '0';
    signal digital_in_tb  : std_logic := '0';

    -- Señales de salida para observar
    signal anodes_tb      : std_logic_vector(3 downto 0);
    signal segments_tb    : std_logic_vector(6 downto 0);

    -- Constantes para la simulación
    constant CLK_PERIOD : time := 10 ns; -- Reloj de 100 MHz

    -- Señal para terminar la simulación
    signal stop_sim : boolean := false;

begin
    -- Instancia del DUT
    uut: top_level port map (
        clk         => clk_tb,
        sw          => sw_tb,
        btnc        => btnc_tb,
        digital_in  => digital_in_tb,
        anodes      => anodes_tb,
        segments    => segments_tb
    );

    -- Proceso para generar el reloj
    clk_process : process
    begin
        if not stop_sim then
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        else
            wait;
        end if;
    end process;

    -- Proceso para generar los estímulos de entrada
    stimulus_process: process
        -- Periodo para generar una señal de 1234 Hz
        constant TEST_FREQ_PERIOD : time := 810373 ns; 
    begin
        -- *ESCENARIO 1: Medir señal digital de 1234 Hz*
        report "INICIO SIM: Escenario 1 - Medir 1234 Hz";
        sw_tb <= "1"; -- Seleccionar entrada digital
        btnc_tb <= '0';
        
        -- Generar señal de 1234 Hz por un poco más de 1 segundo
        digital_in_tb <= '0';
        for i in 1 to 1500 loop
             wait for TEST_FREQ_PERIOD / 2;
             digital_in_tb <= '1';
             wait for TEST_FREQ_PERIOD / 2;
             digital_in_tb <= '0';
        end loop;

        wait for 0.5 sec; -- Esperar a que se actualice el display

        -- *ESCENARIO 2: Medir pulsador*
        report "SIM: Escenario 2 - Simular pulsaciones de botón";
        sw_tb <= "0"; -- Seleccionar entrada del pulsador
        digital_in_tb <= '0';
        
        -- Simular 5 pulsaciones en menos de 1 segundo
        for i in 1 to 5 loop
            btnc_tb <= '1';
            wait for 50 ms;
            btnc_tb <= '0';
            wait for 100 ms;
        end loop;

        wait for 1.5 sec; -- Esperar a que el resultado (5 Hz) se muestre
        
        report "FIN DE LA SIMULACION";
        stop_sim <= true;
        wait;
    end process;

end;