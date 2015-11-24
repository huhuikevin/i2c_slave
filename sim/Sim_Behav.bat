ECHO OFF

set i2c_rtl=..

vlib work

vlog i2c_master_bit_ctrl.v
vlog i2c_master_byte_ctrl.v
vlog i2c_master_top.v
vlog wb_master_model.v

vlog %i2c_rtl%\i2c_slave.v
vlog %i2c_rtl%\dram.v

vlog tst_bench_top.v

vsim -t 1ns -lib work tst_bench_top

ECHO ON
