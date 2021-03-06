// ***************************************************************************
// ***************************************************************************
// Copyright 2011(c) Analog Devices, Inc.
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//     - Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     - Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in
//       the documentation and/or other materials provided with the
//       distribution.
//     - Neither the name of Analog Devices, Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//     - The use of this software may or may not infringe the patent rights
//       of one or more patent holders.  This license does not release you
//       from the requirement that you obtain separate licenses from these
//       patent holders to use this software.
//     - Use of the software either in source or binary form, must be run
//       on or directly connected to an Analog Devices Inc. component.
//    
// THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
// PARTICULAR PURPOSE ARE DISCLAIMED.
//
// IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
// RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// ***************************************************************************
// This is the LVDS/DDR interface

`timescale 1ns/100ps

module cf_adc_if_1 (

  // adc data ports

  adc_data_in_p,
  adc_data_in_n,

  // adc clock interface (raw and divided clock)

  adc_clk_in,
  adc_clk,
  adc_rst,
  adc_datasel,
  adc_bitsel,
  adc_pn_oos,
  adc_pn_err,
  adc_data,

  // processor control signals

  up_pn_type);

  // adc data ports

  input           adc_data_in_p;
  input           adc_data_in_n;

  // adc clock interface (raw and divided clock)

  input           adc_clk_in;
  input           adc_clk;
  input           adc_rst;
  input           adc_datasel;
  input   [ 3:0]  adc_bitsel;
  output          adc_pn_oos;
  output          adc_pn_err;
  output  [11:0]  adc_data;

  // processor control signals

  input           up_pn_type;

  reg             adc_pn_type_m1 = 'd0;
  reg             adc_pn_type_m2 = 'd0;
  reg             adc_pn_type = 'd0;
  reg             adc_pn_en = 'd0;
  reg             adc_pn_en_d = 'd0;
  reg     [23:0]  adc_pn_data_in = 'd0;
  reg     [23:0]  adc_pn_data = 'd0;
  reg             adc_pn_match = 'd0;
  reg     [ 6:0]  adc_pn_oos_count = 'd0;
  reg             adc_pn_oos = 'd0;
  reg     [ 4:0]  adc_pn_err_count = 'd0;
  reg             adc_pn_err = 'd0;
  reg     [ 5:0]  adc_data_serdes = 'd0;
  reg     [ 5:0]  adc_data_serdes_d = 'd0;
  reg     [11:0]  adc_data_12 = 'd0;
  reg     [11:0]  adc_data_12_d = 'd0;
  reg     [11:0]  adc_data = 'd0;

  wire            adc_pn_err_s;
  wire    [11:0]  adc_data_s;
  wire            adc_pn_match_s;
  wire    [23:0]  adc_pn_data_s;
  wire    [11:0]  adc_data_12_s;
  wire            adc_data_ibuf_s;
  wire    [ 5:0]  adc_data_serdes_s;

  // pn equations

  function [23:0] pn9;
    input [23:0] din;
    reg   [23:0] dout;
    begin
      dout[23] = din[8] ^ din[4];
      dout[22] = din[7] ^ din[3];
      dout[21] = din[6] ^ din[2];
      dout[20] = din[5] ^ din[1];
      dout[19] = din[4] ^ din[0];
      dout[18] = din[3] ^ din[8] ^ din[4];
      dout[17] = din[2] ^ din[7] ^ din[3];
      dout[16] = din[1] ^ din[6] ^ din[2];
      dout[15] = din[0] ^ din[5] ^ din[1];
      dout[14] = din[8] ^ din[0];
      dout[13] = din[7] ^ din[8] ^ din[4];
      dout[12] = din[6] ^ din[7] ^ din[3];
      dout[11] = din[5] ^ din[6] ^ din[2];
      dout[10] = din[4] ^ din[5] ^ din[1];
      dout[ 9] = din[3] ^ din[4] ^ din[0];
      dout[ 8] = din[2] ^ din[3] ^ din[8] ^ din[4];
      dout[ 7] = din[1] ^ din[2] ^ din[7] ^ din[3];
      dout[ 6] = din[0] ^ din[1] ^ din[6] ^ din[2];
      dout[ 5] = din[8] ^ din[0] ^ din[4] ^ din[5] ^ din[1];
      dout[ 4] = din[7] ^ din[8] ^ din[3] ^ din[0];
      dout[ 3] = din[6] ^ din[7] ^ din[2] ^ din[8] ^ din[4];
      dout[ 2] = din[5] ^ din[6] ^ din[1] ^ din[7] ^ din[3];
      dout[ 1] = din[4] ^ din[5] ^ din[0] ^ din[6] ^ din[2];
      dout[ 0] = din[3] ^ din[8] ^ din[5] ^ din[1];
      pn9 = dout;
    end
  endfunction

  // pn equations

  function [23:0] pn23;
    input [23:0] din;
    reg   [23:0] dout;
    begin
      dout[23] = din[22] ^ din[17];
      dout[22] = din[21] ^ din[16];
      dout[21] = din[20] ^ din[15];
      dout[20] = din[19] ^ din[14];
      dout[19] = din[18] ^ din[13];
      dout[18] = din[17] ^ din[12];
      dout[17] = din[16] ^ din[11];
      dout[16] = din[15] ^ din[10];
      dout[15] = din[14] ^ din[ 9];
      dout[14] = din[13] ^ din[ 8];
      dout[13] = din[12] ^ din[ 7];
      dout[12] = din[11] ^ din[ 6];
      dout[11] = din[10] ^ din[ 5];
      dout[10] = din[ 9] ^ din[ 4];
      dout[ 9] = din[ 8] ^ din[ 3];
      dout[ 8] = din[ 7] ^ din[ 2];
      dout[ 7] = din[ 6] ^ din[ 1];
      dout[ 6] = din[ 5] ^ din[ 0];
      dout[ 5] = din[ 4] ^ din[22] ^ din[17];
      dout[ 4] = din[ 3] ^ din[21] ^ din[16];
      dout[ 3] = din[ 2] ^ din[20] ^ din[15];
      dout[ 2] = din[ 1] ^ din[19] ^ din[14];
      dout[ 1] = din[ 0] ^ din[18] ^ din[13];
      dout[ 0] = din[22] ^ din[12];
      pn23 = dout;
    end
  endfunction

  // prbs pattern check (control signals- just compare stuff)

  assign adc_pn_err_s = ~(adc_pn_oos | adc_pn_match);
  assign adc_data_s = (adc_pn_type == 1'b0) ? adc_data : ~adc_data;
  assign adc_pn_match_s = (adc_pn_data_in == adc_pn_data) ? 1'b1 : 1'b0;
  assign adc_pn_data_s = (adc_pn_oos == 1'b1) ? adc_pn_data_in : adc_pn_data;

  always @(posedge adc_clk) begin
    adc_pn_type_m1 <= up_pn_type;
    adc_pn_type_m2 <= adc_pn_type_m1;
    adc_pn_type <= adc_pn_type_m2;
  end

  // data is qualified by datasel signal- get the input data and the free running
  // sequence generator-
  
  always @(posedge adc_clk) begin
    if (adc_datasel == 1'b1) begin
      adc_pn_en <= ~adc_pn_en;
      adc_pn_en_d <= adc_pn_en;
      adc_pn_data_in <= {adc_pn_data_in[11:0], adc_data_s};
      if (adc_pn_en == 1'b1) begin
        adc_pn_data <= (adc_pn_type == 1'b0) ? pn9(adc_pn_data_s) : pn23(adc_pn_data_s);
      end
    end
  end

  // This PN sequence checking algorithm is commonly used is most applications.
  // It is a simple function generated based on the OOS status.
  // If OOS is asserted (PN is OUT of sync):
  //    The next sequence is generated from the incoming data.
  //    If 16 sequences match CONSECUTIVELY, OOS is cleared (de-asserted).
  // If OOS is de-asserted (PN is IN sync)
  //    The next sequence is generated from the current sequence.
  //    If 64 sequences mismatch CONSECUTIVELY, OOS is set (asserted).
  // If OOS is de-asserted, any spurious mismatches sets the ERROR register.
  // Ideally, processor should make sure both OOS == 0x0 AND ERR == 0x0.

  always @(posedge adc_clk) begin
    if (adc_datasel == 1'b1) begin
      adc_pn_match <= adc_pn_match_s;
      if (adc_pn_en_d == 1'b1) begin
        if (adc_pn_oos == 1'b1) begin
          if (adc_pn_match == 1'b1) begin
            if (adc_pn_oos_count >= 16) begin
              adc_pn_oos_count <= 'd0;
              adc_pn_oos <= 'd0;
            end else begin
              adc_pn_oos_count <= adc_pn_oos_count + 1'b1;
              adc_pn_oos <= 'd1;
            end
          end else begin
            adc_pn_oos_count <= 'd0;
            adc_pn_oos <= 'd1;
          end
        end else begin
          if (adc_pn_match == 1'b0) begin
            if (adc_pn_oos_count >= 64) begin
              adc_pn_oos_count <= 'd0;
              adc_pn_oos <= 'd1;
            end else begin
              adc_pn_oos_count <= adc_pn_oos_count + 1'b1;
              adc_pn_oos <= 'd0;
            end
          end else begin
            adc_pn_oos_count <= 'd0;
            adc_pn_oos <= 'd0;
          end
        end
      end
    end
  end

  // The error state is streched to multiple adc clocks such that processor
  // has enough time to sample the error condition.
    
  always @(posedge adc_clk) begin
    if (adc_datasel == 1'b1) begin
      adc_pn_match <= adc_pn_match_s;
      if (adc_pn_en_d == 1'b1) begin
        if (adc_pn_err_s == 1'b1) begin
          adc_pn_err_count <= 5'h10;
        end else if (adc_pn_err_count[4] == 1'b1) begin
          adc_pn_err_count <= adc_pn_err_count + 1'b1;
        end
        adc_pn_err <= adc_pn_err_count[4];
      end
    end
  end

  // collect 12 bits of adc data - bitselect from FCO controls the alignemnt
  // of parallel data to the correct field-

  assign adc_data_12_s = {adc_data_serdes_d, adc_data_serdes};

  always @(posedge adc_clk) begin
    adc_data_serdes <= adc_data_serdes_s;
    adc_data_serdes_d <= adc_data_serdes;
    if (adc_datasel == 1'b1) begin
      adc_data_12 <= adc_data_12_s;
      adc_data_12_d <= adc_data_12;
    end
    case (adc_bitsel)
      4'b0000: adc_data <= adc_data_12_d;
      4'b0001: adc_data <= {adc_data_12_d[10:0], adc_data_12[11:11]};
      4'b0010: adc_data <= {adc_data_12_d[ 9:0], adc_data_12[11:10]};
      4'b0011: adc_data <= {adc_data_12_d[ 8:0], adc_data_12[11: 9]};
      4'b0100: adc_data <= {adc_data_12_d[ 7:0], adc_data_12[11: 8]};
      4'b0101: adc_data <= {adc_data_12_d[ 6:0], adc_data_12[11: 7]};
      4'b0110: adc_data <= {adc_data_12_d[ 5:0], adc_data_12[11: 6]};
      4'b0111: adc_data <= {adc_data_12_d[ 4:0], adc_data_12[11: 5]};
      4'b1000: adc_data <= {adc_data_12_d[ 3:0], adc_data_12[11: 4]};
      4'b1001: adc_data <= {adc_data_12_d[ 2:0], adc_data_12[11: 3]};
      4'b1010: adc_data <= {adc_data_12_d[ 1:0], adc_data_12[11: 2]};
      4'b1011: adc_data <= {adc_data_12_d[ 0:0], adc_data_12[11: 1]};
    endcase
  end

  // input buffer-

  IBUFDS i_data_ibuf (
    .I (adc_data_in_p),
    .IB (adc_data_in_n),
    .O (adc_data_ibuf_s));

  // input serdes-

  ISERDESE1 # (
    .DATA_RATE ("DDR"),
    .DATA_WIDTH (6),
    .INTERFACE_TYPE ("NETWORKING"), 
    .DYN_CLKDIV_INV_EN ("FALSE"),
    .DYN_CLK_INV_EN ("FALSE"),
    .NUM_CE (2),
    .OFB_USED ("FALSE"),
    .IOBDELAY ("NONE"),
    .SERDES_MODE ("MASTER"))
  i_data_serdes (
    .Q1 (adc_data_serdes_s[0]),
    .Q2 (adc_data_serdes_s[1]),
    .Q3 (adc_data_serdes_s[2]),
    .Q4 (adc_data_serdes_s[3]),
    .Q5 (adc_data_serdes_s[4]),
    .Q6 (adc_data_serdes_s[5]),
    .SHIFTOUT1 (),
    .SHIFTOUT2 (),
    .BITSLIP (1'b0),
    .CE1 (1'b1),
    .CE2 (1'b1),
    .CLK (adc_clk_in),
    .CLKB (~adc_clk_in),
    .CLKDIV (adc_clk),
    .D (adc_data_ibuf_s),
    .DDLY (1'b0),
    .RST (adc_rst),
    .SHIFTIN1 (1'b0),
    .SHIFTIN2 (1'b0),
    .DYNCLKDIVSEL (1'b0),
    .DYNCLKSEL (1'b0),
    .OFB (1'b0),
    .OCLK (1'b0),
    .O ());

endmodule

// ***************************************************************************
// ***************************************************************************

