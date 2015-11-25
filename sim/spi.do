onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tst_bench_spi/clk
add wave -noupdate /tst_bench_spi/wr
add wave -noupdate /tst_bench_spi/rd
add wave -noupdate /tst_bench_spi/adr
add wave -noupdate -format Logic /tst_bench_spi/u1/slave_reg_data_o
add wave -noupdate -format Logic /tst_bench_spi/u1/slave_reg_addr_o
add wave -noupdate -format Logic /tst_bench_spi/u1/slave_reg_data_i
add wave -noupdate -format Logic /tst_bench_spi/u1/spi_ctrl
add wave -noupdate -format Logic /tst_bench_spi/u1/o_csn
add wave -noupdate -format Logic /tst_bench_spi/u1/o_sclk
add wave -noupdate -format Logic /tst_bench_spi/u1/o_mosi
add wave -noupdate -format Logic /tst_bench_spi/u1/spi_state
add wave -noupdate -format Logic /tst_bench_spi/u1/change_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {500 ns}
