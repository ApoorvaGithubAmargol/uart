`timescale 1ns / 1ps

module uart_rx_tb;

    // Testbench Signals
    reg clk;
    reg rst_n;
    reg rs232;
    wire [7:0] rx_data;
    wire done;

    // Instantiate the UART Receiver
    uart_rx #(
        .BAUD_DIV(5208) // 50MHz clock, 9600 baud rate
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .rs232(rs232),
        .rx_data(rx_data),
        .done(done)
    );

    // Clock Generation: 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 20 ns period = 50 MHz clock
    end

    // Test Sequence
    initial begin
        // Initialize Inputs
        rst_n = 0;
        rs232 = 1; // Idle state

        // Apply Reset
        #100;
        rst_n = 1;

        // Wait for a few clock cycles
        #500;

        // Send First Byte
        rs232 = 0; #5208; // Start Bit
        rs232 = 1; #5208; // Data Bit 0
        rs232 = 0; #5208; // Data Bit 1
        rs232 = 1; #5208; // Data Bit 2
        rs232 = 0; #5208; // Data Bit 3
        rs232 = 1; #5208; // Data Bit 4
        rs232 = 0; #5208; // Data Bit 5
        rs232 = 1; #5208; // Data Bit 6
        rs232 = 1; #5208; // Data Bit 7
        rs232 = 1; #5208; // Stop Bit

        // Wait for 'done' signal
        wait(done);
        $display("Received Byte: %b at Time=%0t", rx_data, $time);

        // Send Second Byte
        rs232 = 0; #5208; // Start Bit
        rs232 = 0; #5208; // Data Bit 0
        rs232 = 1; #5208; // Data Bit 1
        rs232 = 1; #5208; // Data Bit 2
        rs232 = 1; #5208; // Data Bit 3
        rs232 = 0; #5208; // Data Bit 4
        rs232 = 1; #5208; // Data Bit 5
        rs232 = 1; #5208; // Data Bit 6
        rs232 = 0; #5208; // Data Bit 7
        rs232 = 1; #5208; // Stop Bit

        // Wait for 'done' signal
        wait(done);
        $display("Received Byte: %b at Time=%0t", rx_data, $time);

        // End Simulation
        #500;
    end

endmodule
