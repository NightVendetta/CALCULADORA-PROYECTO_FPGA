module mult (
    input              rst,
    input              clock,
    input              start,
    output reg         completed,
    output reg [31:0]  product,
    input      [15:0]  operand_A,
    input      [15:0]  operand_B
);

parameter IDLE           = 3'b000;
parameter LOAD_OPERANDS  = 3'b001;
parameter CHECK_BIT      = 3'b010;
parameter SHIFT_OPERANDS = 3'b011;
parameter ADD_OPERAND    = 3'b100;
parameter DONE           = 3'b101;

reg [2:0]  current_state;
reg [15:0] temp_A;
reg [15:0] temp_B;
reg [4:0]  cycle_counter;

initial begin
    product    = 0;
    completed  = 0;
end

always @(posedge clock or posedge rst) begin
    if (rst) begin
        completed <= 0;
        product   <= 0;
        current_state = IDLE;
    end else begin
        case(current_state)
            IDLE: begin
                cycle_counter =  0;
                completed     <= 0;
                product       =  0;
                if(start)
                    current_state = LOAD_OPERANDS;
                else
                    current_state = IDLE;
            end

            LOAD_OPERANDS: begin
                temp_A      <= operand_A;
                temp_B      <= operand_B;
                completed   <= 0;
                product     =  0;
                current_state = CHECK_BIT;
            end

            CHECK_BIT: begin
                if(temp_B[0])
                    current_state = ADD_OPERAND;
                else
                    current_state = SHIFT_OPERANDS;
            end

            SHIFT_OPERANDS: begin
                temp_B    = temp_B >> 1;
                temp_A    = temp_A << 1;
                completed = 0;
                if(temp_B==0)
                    current_state = DONE;
                else
                    current_state = CHECK_BIT;
            end

            ADD_OPERAND: begin
                product <= product + temp_A;
                completed = 0;
                current_state = SHIFT_OPERANDS;
            end

            DONE: begin
                completed = 1;
                cycle_counter = cycle_counter + 1;
                current_state = (cycle_counter > 29) ? IDLE : DONE;
            end

            default: current_state = IDLE;
        endcase
    end
end

`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
    case(current_state)
        IDLE:           state_name = "IDLE";
        LOAD_OPERANDS:  state_name = "LOAD_OPERANDS";
        CHECK_BIT:      state_name = "CHECK_BIT";
        SHIFT_OPERANDS: state_name = "SHIFT_OPERANDS";
        ADD_OPERAND:    state_name = "ADD_OPERAND";
        DONE:           state_name = "DONE";
    endcase
end
`endif

endmodule