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

module serial_divider #(
    parameter WBW  =  32, // Wishbone bus width
              LAW  = 128, // Logic Analyzer width
              XLEN =  32  // Data width of Dividend, Divisor and Quotient
)(
    input              clk_i,
    input              reset_i,
    // Wishbone
    input              wbs_stb_i,
    input              wbs_cyc_i,
    input              wbs_we_i,
    input  [WBW/8-1:0] wbs_sel_i,
    input  [ WBW-1:0]  wbs_adr_i,
    input  [ WBW-1:0]  wbs_dat_i,
    output             wbs_ack_o,
    output [ WBW-1:0]  wbs_dat_o,
    // Logic Analyser
    output [ LAW-1:0]  la_data_o
);
    // Module outputs
    wire            wbs_ack_o;
    wire [ WBW-1:0] wbs_dat_o;
    wire [ LAW-1:0] la_data_o;

    reg             ack;
    reg  [ WBW-1:0] rdata;

    assign wbs_ack_o = ack;
    assign wbs_dat_o = rdata;
    assign la_data_o = {dividend, divisor, quotient, remainder};

    // Control Regs
    reg start;
    reg debug;

    // Function arguments and results
    reg  [XLEN-1:0] dividend;
    reg  [XLEN-1:0] divisor;
    reg  [XLEN-1:0] quotient;
    reg  [XLEN-1:0] remainder;

    always @(posedge clk_i) begin
      if (reset_i) begin
        dividend  <= {XLEN{1'b0}};
        divisor   <= {XLEN{1'b0}};
        quotient  <= {XLEN{1'b0}};
        remainder <= {XLEN{1'b0}};
        rdata     <= { WBW{1'b0}};
        ack       <= 1'b0;
        start     <= 1'b0;
        debug     <= 1'b0;
      end
      else begin
        // Single-cycle WB write/reads
        // TODO: support b2b cycles
        ack   <= 1'b0;
        start <= 1'b0;
        if (wbs_stb_i && wbs_cyc_i && !ack) begin
          ack <= 1'b1;
          // Top nibble addresses args/results
          case (wbs_adr_i[WBW-1:WBW-4])
            4'h8: begin
              if (wbs_we_i) begin
                if (wbs_sel_i[0]) dividend[ 7: 0] <= wbs_dat_i[ 7: 0];
                if (wbs_sel_i[1]) dividend[15: 8] <= wbs_dat_i[15: 8];
                if (wbs_sel_i[2]) dividend[23:16] <= wbs_dat_i[23:16];
                if (wbs_sel_i[3]) dividend[31:24] <= wbs_dat_i[31:24];
              end
              else begin
                if (wbs_sel_i[3]) rdata[31:24] <= dividend[31:24];
                if (wbs_sel_i[2]) rdata[23:16] <= dividend[23:16];
                if (wbs_sel_i[1]) rdata[15: 8] <= dividend[15: 8];
                if (wbs_sel_i[0]) rdata[ 7: 0] <= dividend[ 7: 0];
              end
            end
            4'h4: begin
              if (wbs_we_i) begin
                divisor <= wbs_dat_i;
              end
              else begin
                rdata <= divisor;
              end
            end
            4'h2: begin
              if (wbs_we_i) begin
                if (debug) quotient <= wbs_dat_i;
              end
              else begin
                 rdata <= quotient;
              end
            end
            4'h1: begin
              if (wbs_we_i) begin
                if (debug) remainder <= wbs_dat_i;
              end
              else begin
                rdata <= remainder;
              end
            end
            default: begin
              rdata <= rdata;  // TODO: set an error?
            end
          endcase // (wbs_adr_i[WBW-1:WBW-4])

          // Next nibble addresses control regs
          case (wbs_adr_i[WBW-5:WBW-8])
            4'h8: begin
                debug <= 1'b1;
            end
            4'h4: begin
                debug <= 1'b0;
            end
            4'h2: begin
                start <= 1'b1;
            end
            default: begin
              rdata <= rdata;  // TODO: set an error?
            end
          endcase // (wbs_adr_i[WBW-5:WBW-8])
        end //if (wbs_stb_i && !ack)
      end // if (reset_i)
    end // always @(posedge clk_i)

endmodule: serial_divider

`default_nettype wire
