module control_unit_b2b( clock, reset, start, finished, shift, load, select, load_msb, add_enable, zero );
 input       clock;
 input       reset;
 input       start;
 input       zero;

 output reg finished;
 output reg shift;
 output reg load;
 output reg select;
 output reg load_msb;
 output reg add_enable;

 parameter STATE_START     = 3'b000;
 parameter STATE_CHECK     = 3'b001;
 parameter STATE_SHIFT     = 3'b010;
 parameter STATE_ADD       = 3'b011;
 parameter STATE_LOAD      = 3'b100;
 parameter STATE_END       = 3'b101;

 
 reg [2:0] current_state;
 reg [5:0] delay_count;

always @(posedge clock) begin
  if (reset) begin
    current_state = STATE_START;
    delay_count = 0;
  end else begin
  case(current_state)

    STATE_START:begin
      delay_count = 0;
      if(start)
        current_state = STATE_SHIFT;
      else
        current_state = STATE_START;
    end

    STATE_SHIFT: begin
      current_state = STATE_CHECK;
    end

    STATE_CHECK: begin
      if(zero)
        current_state = STATE_END;
      else
        current_state = STATE_LOAD;
    end

    STATE_LOAD: begin
      current_state = STATE_ADD;
    end

    STATE_ADD: begin
      current_state = STATE_SHIFT;
    end

    STATE_END: begin
      delay_count = delay_count + 1;
      current_state = (delay_count>30) ? STATE_START : STATE_END;
    end

    default: current_state = STATE_START;
   endcase
  end
end


always @(*) begin
  case(current_state)
    STATE_START: begin
      finished   = 0;
      load_msb = 0;
      select    = 0;
      shift     = 0;
      load      = 1;
      add_enable= 0;
    end

    STATE_SHIFT: begin
      finished   = 0;
      load_msb = 1;
      select    = 1;
      shift     = 1;
      load      = 0;
      add_enable= 0;
    end

    STATE_CHECK: begin
      finished   = 0;
      load_msb = 1;
      select    = 1;
      shift     = 0;
      load      = 0;
      add_enable= 0;
    end

    STATE_LOAD: begin
      finished   = 0;
      load_msb = 0;
      select    = 0;
      shift     = 0;
      load      = 0;
      add_enable= 1;
    end

    STATE_ADD: begin
      finished   = 0;
      load_msb = 0;
      select    = 0;
      shift     = 0;
      load      = 0;
      add_enable= 0;
    end

    STATE_END: begin
      finished   = 1;
      load_msb = 0;
      select    = 0;
      shift     = 0;
      load      = 0;
      add_enable= 0;
    end
    default: begin
      finished   = 0;
      load_msb = 0;
      select    = 0;
      shift     = 0;
      load      = 1;
      add_enable= 0;
    end
  endcase
end

// Para simulación, podemos mantener el debug de estados si está definido BENCH
`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(current_state)
    STATE_START     : state_name = "STATE_START";
    STATE_CHECK     : state_name = "STATE_CHECK";
    STATE_SHIFT     : state_name = "STATE_SHIFT";
    STATE_ADD       : state_name = "STATE_ADD";
    STATE_LOAD      : state_name = "STATE_LOAD";
    STATE_END       : state_name = "STATE_END";
  endcase
end
`endif

endmodule