`timescale 1ns / 1ps
module top(
  input clock,
  input start,     // Switch para iniciar
  output a, b, c, d, e, f, g,
  output [3:0] an,
  output led,      // LED de encendido
  output reg s1,   // Cambiado a reg
  output reg s2,   // Cambiado a reg
  output reg s3,   // Cambiado a reg
  output reg m1,   // Cambiado a reg
  output reg m2,   // Cambiado a reg
  output reg m3    // Cambiado a reg
);

reg [3:0] first;
reg [3:0] second;
reg [22:0] delay;
reg led_status;     // Estado del LED
reg s1_on, s2_on, s3_on, m1_on, m2_on, m3_on;


// Lógica del contador y control de LED
always @ (posedge clock)
begin
  if (!start) begin
    delay <= 0;
    first <= 0;
    second <= 0;
    led_status <= 0;
    s1_on <= 0; s2_on <= 0; s3_on <= 0;
    m1_on <= 0; m2_on <= 0; m3_on <= 0;
  end else begin
    delay <= delay + 1;
    
    if (&delay) begin // Esto es equivalente a (delay == {23{1'b1}})
      if (first == 4'd9) begin
        first <= 0;
        if (second == 4'd8) begin
          second <= 0;
        end else begin
          second <= second + 1;
        end
      end else begin
        first <= first + 1;
      end

      // Lógica de control de los LEDs
      case ({second, first})
		  8'h00: led_status <= 1;
        8'h20: s1_on <= 1;
        8'h22: m1_on <= 1;
        8'h45: begin s2_on <= 1; s1_on <= 0; end
        8'h47: begin m2_on <= 1; m1_on <= 0; end
        8'h70: begin s3_on <= 1; s2_on <= 0; end
        8'h72: begin
          m3_on <= 1; m2_on <= 0;
          led_status <= 0; // Apaga el LED en 72
        end
        8'h89: begin
          m3_on <= 0; s3_on <= 0;
        end
      endcase
    end
  end
end

// Asignación de los estados a las salidas
always @(*) begin
  s1 = s1_on;
  s2 = s2_on;
  s3 = s3_on;
  m1 = m1_on;
  m2 = m2_on;
  m3 = m3_on;
end

assign led = led_status;

// Multiplexado para la visualización de 7 segmentos
localparam N = 18;
reg [N-1:0] count;
reg [6:0] sseg;
reg [3:0] an_temp;

always @ (posedge clock)
begin
  count <= count + 1;
end

always @ (*)
begin
  case (count[N-1:N-2])
    2'b00: begin
      sseg = first;
      an_temp = 4'b1110;
    end
    2'b01: begin
      sseg = second;
      an_temp = 4'b1101;
    end
    2'b10, 2'b11: begin
      sseg = 7'h3F; // Enviar "-" para los otros dígitos
      an_temp = 4'b1011;
    end
  endcase
end

assign an = an_temp;

reg [6:0] sseg_temp;
always @ (*)
begin
  case (sseg)
    4'd0: sseg_temp = 7'b1000000; // 0
    4'd1: sseg_temp = 7'b1111001; // 1
    4'd2: sseg_temp = 7'b0100100; // 2
    4'd3: sseg_temp = 7'b0110000; // 3
    4'd4: sseg_temp = 7'b0011001; // 4
    4'd5: sseg_temp = 7'b0010010; // 5
    4'd6: sseg_temp = 7'b0000010; // 6
    4'd7: sseg_temp = 7'b1111000; // 7
    4'd8: sseg_temp = 7'b0000000; // 8
    4'd9: sseg_temp = 7'b0010000; // 9
    default: sseg_temp = 7'b0111111; // "-"
  endcase
end

assign {g, f, e, d, c, b, a} = sseg_temp;
assign dp = 1'b1; // No usar el punto decimal

endmodule
