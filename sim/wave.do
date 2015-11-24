onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tst_bench_top/clk
add wave -noupdate /tst_bench_top/scl
add wave -noupdate /tst_bench_top/sda
add wave -noupdate /tst_bench_top/rstn
add wave -noupdate -format Logic /tst_bench_top/myslave/i2c_start
add wave -noupdate -format Logic /tst_bench_top/myslave/i2c_stop
add wave -noupdate -format Logic /tst_bench_top/myslave/sda_out_en
add wave -noupdate -format Logic /tst_bench_top/myslave/i2c_state
add wave -noupdate -format Logic /tst_bench_top/myslave/sda_state
add wave -noupdate -format Logic /tst_bench_top/myslave/sda_out
add wave -noupdate -format Logic /tst_bench_top/myslave/device_addr_match
add wave -noupdate -format Logic /tst_bench_top/myslave/in_data
add wave -noupdate -format Logic /tst_bench_top/myslave/indat_done
add wave -noupdate -format Logic /tst_bench_top/myslave/send_done
add wave -noupdate -format Logic /tst_bench_top/myslave/sram_cs
add wave -noupdate -format Logic /tst_bench_top/myslave/sram_rw
add wave -noupdate -format Logic /tst_bench_top/myslave/reg_address
add wave -noupdate -format Logic /tst_bench_top/myRAM_0/DATA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {789735 ns} 1} {{Cursor 2} {850035 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 191
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
WaveRestoreZoom {401500 ns} {1031500 ns}
