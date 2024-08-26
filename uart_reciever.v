module uart_rx #(parameter BAUD_DIV = 5208 // Divisor for 50MHz clock and 9600 baud rate
)
(
    input clk,
    input rst_n,
    input rs232,
    output reg [7:0] rx_data,
    output reg done
);

    reg rs232_t, rs232_t1, rs232_t2;
    reg [12:0] baud_cnt;
    reg bit_flag;
    reg [3:0] bit_cnt;
    reg state;

    localparam IDLE = 1'b0;
    localparam RECEIVE = 1'b1;

    /* Synchronize the rs232 signal */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rs232_t <= 1'b1;
            rs232_t1 <= 1'b1;
            rs232_t2 <= 1'b1;
        end 
        else begin
            rs232_t <= rs232;
            rs232_t1 <= rs232_t;
            rs232_t2 <= rs232_t1;
        end
    end

    /* Baud Counter and Bit Flag Generation */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt <= 13'd0;
            bit_flag <= 1'b0;
        end 
        else if (state == RECEIVE) begin
            if (baud_cnt == (BAUD_DIV - 1)) begin
                baud_cnt <= 13'd0;
                bit_flag <= 1'b1;  // Signal to sample the next bit
            end 
            else begin
                baud_cnt <= baud_cnt + 1'b1;
                bit_flag <= 1'b0;
            end
        end 
        else begin
            baud_cnt <= 13'd0;
            bit_flag <= 1'b0;
        end
    end

    /* State Machine */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            bit_cnt <= 4'd0;
            done <= 1'b0;
            rx_data <= 8'd0;
        end 
        else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (rs232_t2 == 1'b0) begin // Detect start bit (falling edge)
                        state <= RECEIVE;
                        baud_cnt <= BAUD_DIV / 2; // Align to the middle of the start bit
                    end
                end
                RECEIVE: begin
                    if (bit_flag) begin
                        case (bit_cnt)
                            4'd0: ; // Start bit, already detected
                            4'd1: rx_data[0] <= rs232_t2;
                            4'd2: rx_data[1] <= rs232_t2;
                            4'd3: rx_data[2] <= rs232_t2;
                            4'd4: rx_data[3] <= rs232_t2;
                            4'd5: rx_data[4] <= rs232_t2;
                            4'd6: rx_data[5] <= rs232_t2;
                            4'd7: rx_data[6] <= rs232_t2;
                            4'd8: rx_data[7] <= rs232_t2;
                            4'd9: done <= 1'b1; // Stop bit
                        endcase
                        if (bit_cnt == 4'd9) begin
                            state <= IDLE;
                            bit_cnt <= 4'd0;
                        end 
                        else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                end
            endcase
        end
    end

endmodule
