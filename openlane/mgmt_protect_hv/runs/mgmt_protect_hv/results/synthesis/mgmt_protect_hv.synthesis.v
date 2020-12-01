/* Generated by Yosys 0.9+3621 (git sha1 84e9fa7, gcc 8.3.1 -fPIC -Os) */

module mgmt_protect_hv(mprj_vdd_logic1, mprj2_vdd_logic1);
  output mprj2_vdd_logic1;
  wire mprj2_vdd_logic1_h;
  output mprj_vdd_logic1;
  wire mprj_vdd_logic1_h;
  sky130_fd_sc_hvl__conb_1 mprj2_logic_high_hvl (
    .HI(mprj2_vdd_logic1_h),
    .LO()
  );
  sky130_fd_sc_hvl__lsbufhv2lv_1 mprj2_logic_high_lv (
    .A(mprj2_vdd_logic1_h),
    .X(mprj2_vdd_logic1)
  );
  sky130_fd_sc_hvl__conb_1 mprj_logic_high_hvl (
    .HI(mprj_vdd_logic1_h),
    .LO()
  );
  sky130_fd_sc_hvl__lsbufhv2lv_1 mprj_logic_high_lv (
    .A(mprj_vdd_logic1_h),
    .X(mprj_vdd_logic1)
  );
endmodule