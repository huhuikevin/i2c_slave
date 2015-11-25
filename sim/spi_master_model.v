///////////////////////////////////////////////////////////////////////
////                                                               ////
////  WISHBONE rev.B2 Wishbone Master model                        ////
////                                                               ////
////                                                               ////
////  Author: Richard Herveille                                    ////
////          richard@asics.ws                                     ////
////          www.asics.ws                                         ////
////                                                               ////
////  Downloaded from: http://www.opencores.org/projects/mem_ctrl  ////
////                                                               ////
///////////////////////////////////////////////////////////////////////
////                                                               ////
//// Copyright (C) 2001 Richard Herveille                          ////
////                    richard@asics.ws                           ////
////                                                               ////
//// This source file may be used and distributed without          ////
//// restriction provided that this copyright statement is not     ////
//// removed from the file and that any derivative work contains   ////
//// the original copyright notice and the associated disclaimer.  ////
////                                                               ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY       ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR        ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,           ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES      ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE     ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR          ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF    ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT    ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT    ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE           ////
//// POSSIBILITY OF SUCH DAMAGE.                                   ////
////                                                               ////
///////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: wb_master_model.v,v 1.4 2004/02/28 15:40:42 rherveille Exp $
//
//  $Date: 2004/02/28 15:40:42 $
//  $Revision: 1.4 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//
`include "timescale.v"

module spi_master_model(clk, rst, adr, din, dout, wr, rd);

parameter dwidth = 8;
parameter awidth = 4;

input                  clk, rst;
output [awidth   -1:0]	adr;
input  [dwidth   -1:0]	din;
output [dwidth   -1:0]	dout;
output                 wr,rd;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[awidth   -1:0]	adr;
reg	[dwidth   -1:0]	dout;
reg		            wr, rd;


reg [dwidth   -1:0] q;

////////////////////////////////////////////////////////////////////
//
// Memory Logic
//

initial
	begin
		//adr = 32'hxxxx_xxxx;
		//adr = 0;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		wr  = 1'b0;
		rd  = 1'b0;
		#1;
		$display("\nINFO: SPI MASTER MODEL INSTANTIATED (%m)\n");
	end

////////////////////////////////////////////////////////////////////
//
// Wishbone write cycle
//

task wb_write;
	input   delay;
	integer delay;

	input	[awidth -1:0]	a;
	input	[dwidth -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(negedge clk);

		adr  = a;
		dout = d;
		wr  = 1'b1;
		rd  = 1'b0;
		@(negedge clk);

		// negate wishbone signals
		#1;
		wr  = 1'b0;
		rd  = 1'b0;
	end
endtask

////////////////////////////////////////////////////////////////////
//
// Wishbone read cycle
//

task wb_read;
	input   delay;
	integer delay;

	input	 [awidth -1:0]	a;
	output	[dwidth -1:0]	d;

	begin

		// wait initial delay
		repeat(delay) @(negedge clk);

		adr  = a;
		dout = {dwidth{1'bx}};
		wr  = 1'b0;
		rd  = 1'b1;
	
		@(negedge clk);

		// negate wishbone signals
		#1;
		wr  = 1'b0;
		rd  = 1'b0;
		adr  = {awidth{1'bx}};
		dout = {dwidth{1'bx}};
		d    = din;
	end
endtask

endmodule


