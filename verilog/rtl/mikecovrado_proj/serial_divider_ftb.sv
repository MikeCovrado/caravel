// Copyright 2021 Mike Thompson (Covrado)
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://solderpad.org/licenses/
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * mikecovrado_proj
 *
 *-------------------------------------------------------------
 */

module serial_divider_ftb #(
    parameter BITS = 32,   // TODO: find out what this is really for...
              WBW  = 32
)();
    // Wishbone Slave ports (WB MI A)
    reg              clk;
    reg              rst;
    wire             wbs_stb_i;
    wire             wbs_cyc_i;
    wire             wbs_we_i;
    wire [WBW/8-1:0] wbs_sel_i;
    wire [WBW-1  :0] wbs_dat_i;
    wire [WBW-1  :0] wbs_adr_i;
    wire             wbs_ack_o;
    wire [WBW-1  :0] wbs_dat_o;

    // Logic Analyzer Signals
    wire [127:0] la_data_out;

    //wire [WBW-1:0] dividend;
    //wire [WBW-1:0] divisor;
    //wire [WBW-1:0] quotient;
    //wire [WBW-1:0] remainder;

    reg f_past_valid = 0;
    initial assume(rst);

    always @(posedge clk) begin
      f_past_valid <= 1;

      // Prevent writes to both args/results and control regs in same cycle
      assume (~( |(wbs_adr_i[WBW-1:WBW-4]) & |(wbs_adr_i[WBW-5:WBW-8]) ));

      // No back-to-back transactions
      if (f_past_valid) begin
        if (wbs_ack_o)
          assume ( (wbs_stb_i == 1'b0) && (wbs_cyc_i == 1'b0) );
      end

      if (f_past_valid) begin
        _set_dividend_: cover( (la_data_out[127:96] == serial_divider_u0.dividend ) &&
                               (la_data_out[127:96] != 32'h0000_0000              ) );

        _set_divisor_:  cover( (la_data_out[ 95:64] == serial_divider_u0.divisor  ) &&
                               (la_data_out[ 95:64] != 32'h0000_0000              ) );

        _set_d_and_d_:  cover( (la_data_out[ 95:64] == serial_divider_u0.divisor  ) &&
                               (la_data_out[127:96] == serial_divider_u0.dividend ) &&
                               (la_data_out[ 95:64] != 32'h0000_0000              ) &&
                               (la_data_out[127:96] != 32'h0000_0000              ) );

        _set_all_:      cover( (la_data_out[127:96] == serial_divider_u0.dividend ) &&
                               (la_data_out[ 95:64] == serial_divider_u0.divisor  ) &&
                               (la_data_out[ 63:32] == serial_divider_u0.quotient ) &&
                               (la_data_out[ 31: 0] == serial_divider_u0.remainder) &&
                               (la_data_out[127:96] != 32'h0000_0000              ) &&
                               (la_data_out[ 95:64] != 32'h0000_0000              ) &&
                               (la_data_out[ 63:32] != 32'h0000_0000              ) &&
                               (la_data_out[ 31: 0] != 32'h0000_0000              ) );
      end
    end

    serial_divider #(
        .WBW  (32), //Wishbone bus width
        .XLEN (32)  //Data width of Dividend, Divisor, Quotient and Remainder
    ) serial_divider_u0 (
        .clk_i      (clk),
        .reset_i    (rst),
        .wbs_stb_i  (wbs_stb_i),
        .wbs_cyc_i  (wbs_cyc_i),
        .wbs_we_i   (wbs_we_i),
        .wbs_sel_i  (wbs_sel_i),
        .wbs_adr_i  (wbs_adr_i),
        .wbs_dat_i  (wbs_dat_i),
        .wbs_ack_o  (wbs_ack_o),
        .wbs_dat_o  (wbs_dat_o),
        .la_data_o  (la_data_out)
    );

endmodule: serial_divider_ftb

`default_nettype wire
