module ibufds_util #(
    parameter NUM_INST = 1,
    parameter DIFF_TERM = "FALSE",
    parameter IBUF_LOW_PWR = "TRUE",
    parameter IOSTANDARD = "DEFAULT",
    parameter USE_IBUFDISABLE = "TRUE"
) (
    output [NUM_INST - 1 : 0] O,
    input [NUM_INST - 1 : 0] I,
    input [NUM_INST - 1 : 0] IB,
    input DIS
);
    genvar i;
    generate
        for(i = 0; i < NUM_INST; i = i+1) begin
            IBUFDS_IBUFDISABLE #(
                .DIFF_TERM("FALSE"),      // Differential Termination
                .IBUF_LOW_PWR("TRUE"),    // Low power="TRUE", Highest performance="FALSE"
                .IOSTANDARD("DEFAULT"),   // Specify the input I/O standard
                .USE_IBUFDISABLE("TRUE")  // Set to "TRUE" to enable IBUFDISABLE feature
            ) IBUFDS_IBUFDISABLE_inst (
                .O(O[i]),   // Buffer output
                .I(I[i]),   // Diff_p buffer input (connect directly to top-level port)
                .IB(IB[i]), // Diff_n buffer input (connect directly to top-level port)
                .IBUFDISABLE(DIS) // Buffer disable input, high=disable
            );
        end
    endgenerate
endmodule

module obufds_util #(
    parameter NUM_INST = 1,
    parameter IOSTANDARD = "DEFAULT",
    parameter SLEW = "SLOW"
) (
    output [NUM_INST - 1 : 0] O,
    output [NUM_INST - 1 : 0] OB,
    input [NUM_INST - 1 : 0] I,
    input [NUM_INST - 1 : 0] T
);
    genvar i;
    generate
        for(i = 0; i < NUM_INST; i = i+1) begin
            // OBUFTDS: Differential 3-state Output Buffer
            //          7 Series
            // Xilinx HDL Language Template, version 2026.1

            OBUFTDS #(
                .IOSTANDARD(IOSTANDARD), // Specify the output I/O standard
                .SLEW(SLEW)           // Specify the output slew rate
            ) OBUFTDS_inst (
                .O(O[i]),     // Diff_p output (connect directly to top-level port)
                .OB(OB[i]),   // Diff_n output (connect directly to top-level port)
                .I(I[i]),     // Buffer input
                .T(T)      // 3-state enable input
            );

            // End of OBUFTDS_inst instantiation
        end
    endgenerate
endmodule

module iddr_util #(
    parameter NUM_INST = 1,
    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE",
    parameter [NUM_INST - 1 : 0] INIT_Q1 = 0,
    parameter [NUM_INST - 1 : 0] INIT_Q2 = 0,
    parameter SRTYPE = "SYNC"
) (
    output [NUM_INST - 1 : 0] Q1,
    output [NUM_INST - 1 : 0] Q2,
    input C,
    input CE,
    input [NUM_INST - 1 : 0] D,
    input R,
    input S
);
    genvar i;
    // IDDR: Input Double Data Rate Input Register with Set, Reset
    //       and Clock Enable.
    //       7 Series
    // Xilinx HDL Language Template, version 2026.1
    generate
        for(i = 0; i < NUM_INST; i = i+1) begin
            IDDR #(
                .DDR_CLK_EDGE(DDR_CLK_EDGE), // "OPPOSITE_EDGE", "SAME_EDGE"
                                                //    or "SAME_EDGE_PIPELINED"
                .INIT_Q1(INIT_Q1[i]), // Initial value of Q1: 1'b0 or 1'b1
                .INIT_Q2(INIT_Q2[i]), // Initial value of Q2: 1'b0 or 1'b1
                .SRTYPE(SRTYPE) // Set/Reset type: "SYNC" or "ASYNC"
            ) IDDR_inst (
                .Q1(Q1[i]), // 1-bit output for positive edge of clock
                .Q2(Q2[i]), // 1-bit output for negative edge of clock
                .C(C),   // 1-bit clock input
                .CE(CE), // 1-bit clock enable input
                .D(D[i]),   // 1-bit DDR data input
                .R(R),   // 1-bit reset
                .S(S)    // 1-bit set
            );
        end
    endgenerate
    // End of IDDR_inst instantiation
endmodule

module oddr_util #(
    parameter NUM_INST = 1,
    parameter DDR_CLK_EDGE = "OPPOSITE_EDGE",
    parameter [NUM_INST - 1 : 0] INIT = 0,
    parameter SRTYPE = "SYNC"
) (
    output [NUM_INST - 1 : 0] Q,
    input C,
    input CE,
    input [NUM_INST - 1 : 0] D1,
    input [NUM_INST - 1 : 0] D2,
    input R,
    input S
);
    genvar i;
    // ODDR: Output Double Data Rate Output Register with Set, Reset
    //       and Clock Enable.
    //       7 Series
    // Xilinx HDL Language Template, version 2026.1
    generate
        for(i = 0; i < NUM_INST; i = i+1) begin
            ODDR #(
                .DDR_CLK_EDGE(DDR_CLK_EDGE), // "OPPOSITE_EDGE" or "SAME_EDGE"
                .INIT(INIT[i]),    // Initial value of Q: 1'b0 or 1'b1
                .SRTYPE(SRTYPE) // Set/Reset type: "SYNC" or "ASYNC"
            ) ODDR_inst (
                .Q(Q[i]),   // 1-bit DDR output
                .C(C),   // 1-bit clock input
                .CE(CE), // 1-bit clock enable input
                .D1(D1[i]), // 1-bit data input (positive edge)
                .D2(D2[i]), // 1-bit data input (negative edge)
                .R(R),   // 1-bit reset
                .S(S)    // 1-bit set
            );
        end
    endgenerate
    // End of ODDR_inst instantiation
endmodule

module in_fifo_util(
    output ALMOSTEMPTY,
    output ALMOSTFULL,
    output EMPTY,
    output FULL,
    input RDCLK,RDEN,RESET,WRCLK,WREN,
    output [7:0] Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,
    input [3:0] D0,D1,D2,D3,D4,D5,D6,D7,D8,D9
    );
    parameter ALMOST_EMPTY_VALUE = 1;
    parameter ALMOST_FULL_VALUE = 1;
    parameter ARRAY_MODE = "ARRAY_MODE_4_X_8";
    parameter SYNCHRONOUS_MODE = "FALSE";
    parameter PLACEMENT_LOCATION = "UNPLACED";

    // IN_FIFO: Input First-In, First-Out (FIFO)
    //          7 Series
    // Xilinx HDL Language Template, version 2026.1

    initial begin
        if(PLACEMENT_LOCATION == "UNPLACED") begin
            $error("Must choose a placement for IN_FIFO");
        end
    end

    (* BEL = "IN_FIFO" *)
    (* LOC = PLACEMENT_LOCATION *)
    IN_FIFO #(
        .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE),          // Almost empty offset (1-2)
        .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE),           // Almost full offset (1-2)
        .ARRAY_MODE(ARRAY_MODE), // ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
        .SYNCHRONOUS_MODE(SYNCHRONOUS_MODE)       // Clock synchronous (FALSE)
    )
    IN_FIFO_inst (
        // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
        .ALMOSTEMPTY(ALMOSTEMPTY), // 1-bit output: Almost empty
        .ALMOSTFULL(ALMOSTFULL),   // 1-bit output: Almost full
        .EMPTY(EMPTY),             // 1-bit output: Empty
        .FULL(FULL),               // 1-bit output: Full
        // Q0-Q9: 8-bit (each) output: FIFO Outputs
        .Q0(Q0),                   // 8-bit output: Channel 0
        .Q1(Q1),                   // 8-bit output: Channel 1
        .Q2(Q2),                   // 8-bit output: Channel 2
        .Q3(Q3),                   // 8-bit output: Channel 3
        .Q4(Q4),                   // 8-bit output: Channel 4
        .Q5(Q5),                   // 8-bit output: Channel 5
        .Q6(Q6),                   // 8-bit output: Channel 6
        .Q7(Q7),                   // 8-bit output: Channel 7
        .Q8(Q8),                   // 8-bit output: Channel 8
        .Q9(Q9),                   // 8-bit output: Channel 9
        // D0-D9: 4-bit (each) input: FIFO inputs
        .D0(D0),                   // 4-bit input: Channel 0
        .D1(D1),                   // 4-bit input: Channel 1
        .D2(D2),                   // 4-bit input: Channel 2
        .D3(D3),                   // 4-bit input: Channel 3
        .D4(D4),                   // 4-bit input: Channel 4
        .D5(D5),                   // 8-bit input: Channel 5
        .D6(D6),                   // 8-bit input: Channel 6
        .D7(D7),                   // 4-bit input: Channel 7
        .D8(D8),                   // 4-bit input: Channel 8
        .D9(D9),                   // 4-bit input: Channel 9
        // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
        .RDCLK(RDCLK),             // 1-bit input: Read clock
        .RDEN(RDEN),               // 1-bit input: Read enable
        .RESET(RESET),             // 1-bit input: Reset
        .WRCLK(WRCLK),             // 1-bit input: Write clock
        .WREN(WREN)                // 1-bit input: Write enable
    );

    // End of IN_FIFO_inst instantiation
endmodule
