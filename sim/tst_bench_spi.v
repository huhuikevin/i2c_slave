/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE rev.B2 compliant I2C Master controller Testbench  ////
////                                                             ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/projects/i2c/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: tst_bench_top.v,v 1.8 2006/09/04 09:08:51 rherveille Exp $
//
//  $Date: 2006/09/04 09:08:51 $
//  $Revision: 1.8 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: tst_bench_top.v,v $
//               Revision 1.8  2006/09/04 09:08:51  rherveille
//               fixed (n)ack generation
//
//               Revision 1.7  2005/02/27 09:24:18  rherveille
//               Fixed scl, sda delay.
//
//               Revision 1.6  2004/02/28 15:40:42  rherveille
//               *** empty log message ***
//
//               Revision 1.4  2003/12/05 11:04:38  rherveille
//               Added slave address configurability
//
//               Revision 1.3  2002/10/30 18:11:06  rherveille
//               Added timing tests to i2c_model.
//               Updated testbench.
//
//               Revision 1.2  2002/03/17 10:26:38  rherveille
//               Fixed some race conditions in the i2c-slave model.
//               Added debug information.
//               Added headers.
//

`include "timescale.v"

module tst_bench_spi();

	//
	// wires && regs
	//
	reg  clk;
	reg  rstn;

	wire [3:0] adr;
	wire [ 7:0] dat_i, dat_o;
	wire wr;
	wire rd;
	wire cyc;


	reg [7:0] q, qq;


	
	//////////////////////////////
	wire[7:0] in, out;
	wire[3:0] addr;



	//
	// Module body
	//

	parameter SPI_ADDR_REG = 4'b0010;
	parameter SPI_TX_REG   = 4'b0001;
	parameter SPI_CTRL_REG = 4'b0000;
	parameter SPI_RX_REG   = 4'b0011;
	// generate clock
	always #5 clk = ~clk;
	
	reg miso;
	wire sclk, mosi, scs;
	// hookup wishbone master model
	spi_master_model #(8, 4) u0 (
		.clk(clk),
		.rst(rstn),
		.adr(adr),
		.din(dat_i),
		.dout(dat_o),
		.wr(wr),
		.rd(rd)
	);

	spi_master u1 (
		.i_ck(clk),
		.i_rstn(rstn),
		.o_sclk(sclk),
		.o_csn(ccs),
		.i_miso(miso),
		.o_mosi(mosi),
		.i_address(adr),
		.i_data(dat_o),
		.o_data(dat_i),
		.i_wr(wr),
		.i_rd(rd)
	);

	initial
	  begin
	      $display("\nstatus: %t Testbench started\n\n", $time);

	      // initially values
	      clk = 0;

	      // reset system
	      rstn = 1'b1; // negate reset
	      #10;
	      rstn = 1'b0; // assert reset
	      repeat(1) @(posedge clk);
	      rstn = 1'b1; // negate reset

	      $display("status: %t done reset", $time);

	      @(posedge clk);

	      /////////////////////////////////////////////
	      // program core
	      /////////////////////////////////////////////

	      // program internal registers
	      //u0.wb_write(1, PRER_LO, 8'hfa); // load prescaler lo-byte
	      u0.wb_write(1, SPI_ADDR_REG, 8'h5a); // load prescaler lo-byte
	      u0.wb_write(1, SPI_TX_REG, 8'ha5); // load prescaler hi-byte
	      $display("status: %t programmed registers", $time);

	      u0.wb_write(1, SPI_CTRL_REG, 8'h01); // enable core
	      $display("status: %t core enabled", $time);



	      // check data just received
	      u0.wb_read(1, SPI_RX_REG, qq);

	      $display("status: %t received %x .", $time, qq);

		  
	      #250000; // wait 250us
	      $display("\n\nstatus: %t Testbench done", $time);
	      $finish;
	  end


	  

////////////////////////////////////////////////////////////////////
  
endmodule
