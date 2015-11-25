ECHO OFF

set i2c_rtl=..

vlib work

vlog spi_master_model.v

vlog %i2c_rtl%\spi_master.v

vlog tst_bench_spi.v

vsim -t 1ns -lib work tst_bench_spi

ECHO ON
