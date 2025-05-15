module Multiplier #(
    parameter N = 4
) (
    input wire clk,
    input wire rst_n,

    input wire start,
    output reg ready,

    input wire   [N-1:0] multiplier,
    input wire   [N-1:0] multiplicand,
    output reg [2*N-1:0] product
);

// Registradores internos
reg [2*N-1:0] reg_multiplier;
reg [N-1:0]   reg_multiplicand;

// Máquina de estados
reg [1:0] state_machine, next_state;
localparam S1 = 2'b00, S2 = 2'b01, S3 = 2'b10;

// Bloco sequencial: atualização de estado
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state_machine <= S1;
    else
        state_machine <= next_state;
end

// Bloco combinacional: transição de estados
always @(*) begin
    case (state_machine)
        S1:  next_state = (start) ? S2 : S1;
        S2:  next_state = (reg_multiplicand != 0) ? S2 : S3;
        S3:  next_state = S1;
        default: next_state = S1;
    endcase
end

// Bloco sequencial: lógica principal
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        product <= 0;
        reg_multiplier <= 0;
        reg_multiplicand <= 0;
        ready <= 0;
    end else begin
        case (state_machine)
            S1: begin
                if (start) begin
                    product <= 0;
                    reg_multiplier <= multiplier;
                    reg_multiplicand <= multiplicand;
                    ready <= 0;
                end
            end

            S2: begin
                if (reg_multiplicand[0])
                    product <= product + reg_multiplier;

                reg_multiplier <= reg_multiplier << 1;
                reg_multiplicand <= reg_multiplicand >> 1;
            end

            S3: begin
                ready <= 1;
            end
        endcase
    end
end

endmodule
