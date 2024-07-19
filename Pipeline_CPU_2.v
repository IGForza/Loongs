`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 09:38:30
// Design Name: 
// Module Name: Pipeline_CPU_2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Pipeline_CPU_2(
   //input部分，包括系统时钟与复位信号
   input clk           ,
   input reset         ,
   //output部分，包括与BCD7交互的接口
   output [11:0] leds
    );
    //按照Part3 P49直接封装，不再区分级次
    
    
    /*--------------wire for hazard & forwaiding--------------*/
    wire keep_IF_ID,keep_PC,RF_Comp_rsSrc,RF_Comp_rtSrc,MemWrDataSrc,RF_jrSrc;
    wire [2 -1:0] flush,ALUinASrc,ALUinBSrc;
    wire [32 -1:0] EX_ReadData2_1;
    
    
//IF_stage  
    /*——————----PC----------------*/
    reg [32 -1:0] PC;
    wire [32 -1:0] PC_out;
    wire [32 -1:0] PC_next;
    wire [32 -1:0] PC_plus_4;
    
    always @(posedge reset or posedge clk) begin
        if(reset)
            PC <= 32'h00000000;
        else
            PC <= PC_next;
    end
    
    assign PC_plus_4 = PC_out +32'd4;
    assign PC_out = PC;
    
    //assign PC_next = 
    
    /*---------Instruction Memory---------*/
    wire [32 -1:0] IF_Instruction;
    
    InstructionMemory instruction_memory1(
         .Address        (PC_out), 
         .Instruction    (IF_Instruction)
    );
    
    /*---------------IF/ID----------------*/
    
    wire [32 -1:0] RF_PC,RF_Instruction;
    
    IF_ID if_id1(
    //input
        .clk            (clk),
        .reset          (reset),
        .flush          (flush[1]),
        .keep           (keep_IF_ID),
        .PC_i           (PC_plus_4),
        .Instruction_i  (IF_Instruction),
    //output
        .PC_o           (RF_PC),
        .Instruction_o  (RF_Instruction)
    );
    
//ID/RF_stage
    wire [32 -1:0] RF_ReadData1,RF_ReadData2;
    //WB阶段的一些必需的wire
    wire [32 -1:0] WB_RegWrData;
    wire          WB_RegWrite  ;
    wire [5 -1:0]  WB_RegDstAddr;    
    
    /*------------Regisiter File----------*/
    RegisterFile register_file1(
        .reset          (reset), 
        .clk            (clk),
        .RegWrite       (WB_RegWrite), 
        .Read_register1 (RF_Instruction[25:21]),//rs 
        .Read_register2 (RF_Instruction[20:16]),//rt 
        .Write_register (WB_RegDstAddr),
        .Write_data     (WB_RegWrData), 
        .Read_data1     (RF_ReadData1), 
        .Read_data2     (RF_ReadData2)
   );
    
   /*--------------Control Unit----------*/
   	// Control 
   wire [2 -1:0] RF_RegDst    ;
   wire [2 -1:0] RF_PCSrc2     ;
   wire          RF_Branch    ;
   wire          RF_MemRead   ;
   wire          RF_MemWrite  ;
   wire [2 -1:0] RF_MemtoReg  ;
   wire          RF_ALUSrc1   ;
   wire          RF_ALUSrc2   ;
   wire [4 -1:0] RF_ALUOp     ;
   wire          RF_ExtOp     ;
   wire          RF_LuOp      ;
   wire          RF_RegWrite  ;
   
   Control control1(
        .OpCode     (RF_Instruction[31:26]), 
        .Funct      (RF_Instruction[5:0]),
        .PCSrc2      (RF_PCSrc2), 
        .Branch     (RF_Branch), 
        .RegWrite   (RF_RegWrite), 
        .RegDst     (RF_RegDst), 
        .MemRead    (RF_MemRead),    
        .MemWrite   (RF_MemWrite), 
        .MemtoReg   (RF_MemtoReg),
        .ALUSrc1    (RF_ALUSrc1), 
        .ALUSrc2    (RF_ALUSrc2), 
        .ExtOp      (RF_ExtOp), 
        .LuOp       (RF_LuOp),    
        .ALUOp      (RF_ALUOp)
    );
   
    /*---------------Imm Extend----------------*/
	// Extend
    wire [32 -1:0] RF_Ext_out;
    assign RF_Ext_out = { RF_ExtOp? {16{RF_Instruction[15]}}: 16'h0000, RF_Instruction[15:0]};
    
    wire [32 -1:0] RF_LU_out;
    assign RF_LU_out = RF_LuOp? {RF_Instruction[15:0], 16'h0000}: RF_Ext_out;
    
    /*----------------Branch Judgement------------*/
    wire [32 -1:0] Branch_target;
    assign Branch_target = RF_PC + {RF_LU_out[29:0],2'b00};
    //Comp Unit
    wire [32 -1:0] RF_Comp_rs,RF_Comp_rt;
    wire RF_Comp_eq,RF_PCSrc1;//PCSrc1 for beq
    assign RF_Comp_eq = (RF_Comp_rs == RF_Comp_rt) ? 1'b1 : 1'b0;
    assign RF_PCSrc1 = (RF_Branch && RF_Comp_eq);
    
    /*-----------------Jump Judgement-------------*/
    wire [32 -1:0] Jump_target;
    assign Jump_target = {RF_PC[31:28], RF_Instruction[25:0], 2'b00}; 
    
    /*----------------ID/EX--------------------*/
    wire [2 -1:0] EX_RegDst    ;
    wire          EX_MemRead   ;
    wire          EX_MemWrite  ;
    wire [2 -1:0] EX_MemtoReg  ;
    wire          EX_ALUSrc1   ;
    wire          EX_ALUSrc2   ;
    wire [4 -1:0] EX_ALUOp     ;
    wire          EX_RegWrite  ;
    wire [32 -1:0]EX_ReadData1,EX_ReadData2,EX_32bImm,EX_PC;
    wire [5 -1:0] EX_rs,EX_rt,EX_rd,EX_shamt;
    wire [6 -1:0] EX_Funct; 
    //这里考虑在ID阶段判断beq，故PCSrc指令不继续下行
    ID_EX id_ex1(
//input
        .clk              (clk), 
        .reset            (reset),
        .flush            (flush[0]),
        //ControlUnitOutput
        .RegWr_i          (RF_RegWrite),
        .ALUSrc1_i        (RF_ALUSrc1),
        .ALUSrc2_i        (RF_ALUSrc2),
        .RegDst_i         (RF_RegDst),
        //.Branch_i         (RF_Branch),
        .MemRead_i        (RF_MemRead),
        .MemWr_i          (RF_MemWrite),
        .MemtoReg_i       (RF_MemtoReg),
        .ALUOp_i          (RF_ALUOp),
        //RFData&InstruntionData
        .ReadData1_i      (RF_ReadData1),
        .ReadData2_i      (RF_ReadData2),
        .ExtImm_i         (RF_LU_out),
        .rt_i             (RF_Instruction[20:16]),
        .rd_i             (RF_Instruction[15:11]),
        .rs_i             (RF_Instruction[25:21]),
        .shamt_i          (RF_Instruction[10:6]),
        .Funct_i          (RF_Instruction[5:0]),
        .PC_i             (RF_PC),//for jal
//output
        .RegWr_o          (EX_RegWrite),
        .ALUSrc1_o        (EX_ALUSrc1),
        .AlUSrc2_o        (EX_ALUSrc2),
        .RegDst_o         (EX_RegDst),
        //.Branch_o         (),
        .MemRead_o        (EX_MemRead),
        .MemWr_o          (EX_MemWrite),
        .MemtoReg_o       (EX_MemtoReg),
        .ALUOp_o          (EX_ALUOp),
        .ReadData1_o      (EX_ReadData1),
        .ReadData2_o      (EX_ReadData2),
        .ExtImm_o         (EX_32bImm),
        .rt_o             (EX_rt),
        .rd_o             (EX_rd),
        .rs_o             (EX_rs),
        .shamt_o          (EX_shamt),
        .Funct_o          (EX_Funct),
        .PC_o             (EX_PC)
    );
   
//EX_stage
    /*-----------ALU Control Unit---------*/
    wire [5 -1:0] ALUCtl;
    wire Sign;
	ALUControl alu_control1(
        .ALUOp  (EX_ALUOp), 
        .Funct  (EX_Funct), 
        .ALUCtl (ALUCtl), 
        .Sign   (Sign)
    );

    /*---------------ALU---------------*/
    wire [32 -1:0] ALUin1,ALUin2,EX_ALUOut,ALUA_in1,ALUB_out;
    assign ALUA_in1 = EX_ALUSrc1? {27'h00000, EX_shamt}:EX_ReadData1;//shamt
    assign ALUin2 = EX_ALUSrc2 ? EX_32bImm : ALUB_out;
    
    //考虑在ID阶段提前判断，则ALU中不需要判断分支，没有zero输出
	ALU alu1(
        .in1    (ALUin1), 
        .in2    (ALUin2), 
        .ALUCtl (ALUCtl), 
        .Sign   (Sign), 
        .out    (EX_ALUOut) 
    );
    
    /*--------------RegDst Judgement------*/
    wire [5 -1:0] EX_RegDstAddr;
    assign EX_RegDstAddr = (EX_RegDst == 2'b00)? EX_rt: (EX_RegDst == 2'b01)? EX_rd: 5'b11111;
    
    /*---------------EX/MEM--------------*/
    wire          MEM_MemRead   ;
    wire          MEM_MemWrite  ;
    wire [2 -1:0] MEM_MemtoReg  ;
    wire          MEM_RegWrite  ;
    wire [32 -1:0]MEM_ALUOut,MEM_ReadData2,MEM_PC;
    wire [5 -1:0] MEM_RegDstAddr,MEM_rt;
    
    EX_MEM ex_mem1(
//input
        .clk              (clk), 
        .reset            (reset),
        .flush            (1'b0),
        //ControlSignals
        .RegWr_i          (EX_RegWrite),
        .MemRead_i        (EX_MemRead),
        .MemWr_i          (EX_MemWrite),
        .MemtoReg_i       (EX_MemtoReg),
        //ALUData&RegDst&MemWriteData
        .ALUOut_i         (EX_ALUOut),
        .MemWrData_i      (EX_ReadData2_1),
        .RegDstAddr_i     (EX_RegDstAddr),
        .EX_rt            (EX_rt),
        .PC_i             (EX_PC),
//output
        .RegWr_o          (MEM_RegWrite),
        .MemRead_o        (MEM_MemRead),
        .MemWr_o          (MEM_MemWrite),
        .MemtoReg_o       (MEM_MemtoReg),
        .ALUOut_o         (MEM_ALUOut),
        .MemWrData_o      (MEM_ReadData2),
        .RegDstAddr_o     (MEM_RegDstAddr),
        .MEM_rt           (MEM_rt),
        .PC_o             (MEM_PC)   //for jal
    );
    
//MEM_stage
    /*--------------Data Memory---------------*/
    wire [32 -1:0] MemReadData,MemWrData;
	DataMemory data_memory1(
        .reset      (reset), 
        .clk        (clk), 
        .Address    (MEM_ALUOut), 
        .Write_data (MemWrData), 
        .Read_data  (MemReadData), 
        .MemRead    (MEM_MemRead), 
        .MemWrite   (MEM_MemWrite),
//        .button     (button),
        .LEDS       (leds)   //与外设交互接口
    );
    
    /*-----------------MEM/WB---------------*/
    wire [2 -1:0] WB_MemtoReg  ;
    wire [32 -1:0]WB_MemReadData,WB_ALUOut,WB_PC;

    MEM_WB mem_wb1(
//input
    .clk            (clk),
    .reset          (reset),
    //ControlSignal
    .MemtoReg_i     (MEM_MemtoReg),
    .RegWr_i        (MEM_RegWrite),
    //MemReadData&ALUOutData&RegDstAddr
    .MemReadData_i  (MemReadData),
    .ALUOut_i       (MEM_ALUOut),
    .RegDstAddr_i   (MEM_RegDstAddr),
    .PC_i           (MEM_PC),
//output
    .MemtoReg_o     (WB_MemtoReg),
    .RegWr_o        (WB_RegWrite),
    .MemReadData_o  (WB_MemReadData),
    .ALUOut_o       (WB_ALUOut),
    .RegDstAddr_o   (WB_RegDstAddr),
    .PC_o           (WB_PC)
    );
    
    //RegWB Data
    assign WB_RegWrData = (WB_MemtoReg == 2'b00)? WB_ALUOut: (WB_MemtoReg == 2'b01)? WB_MemReadData: WB_PC;//jal
    
    /*------------Hazard Unit------------------*/
    //hazard unit：load-use,J,beq，均是flush1个周期，还应该支持beq的数据冒险要求的stall 1个周期
    Hazard_Unit hz1(
    //input
        //for load-use
        .EX_MemRead     (EX_MemRead),
        .RF_Instruction (RF_Instruction),
        //.EX_rt          (EX_rt), //这似乎应该由EX_RegDstAddr代替
        //for beq RAW
        .RF_Branch      (RF_Branch),
        .EX_RegWr       (EX_RegWrite),
        .EX_RegDstAddr  (EX_RegDstAddr),
        //for beq load-use
        .MEM_RegWr       (MEM_RegWrite),
        .MEM_RegDstAddr  (MEM_RegDstAddr),
        .MEM_MemRead     (MEM_MemRead),
        //for beq&j-type
        .RF_PCSrc1      (RF_PCSrc1),//beq?
        .RF_PCSrc2      (RF_PCSrc2),//j?,0代表不jump
    //output
        .keep_IF_ID     (keep_IF_ID),
        .keep_PC        (keep_PC),
        .flush          (flush)
    );
    
    /*---------------Forwarding Unit A-------------*/
    //处理RF阶段beq提前造成的数据冒险
    Forward_UnitA ForwUA(
    //input
        .MEM_RegDstAddr     (MEM_RegDstAddr),
        .RF_Instruction     (RF_Instruction),
        .MEM_RegWr          (MEM_RegWrite),
    //output
        .RF_Comp_rsSrc      (RF_Comp_rsSrc),
        .RF_Comp_rtSrc      (RF_Comp_rtSrc),
        .RF_jrSrc           (RF_jrSrc)
    );
    
     /*---------------Forwarding Unit B-------------*/
    //处理EX阶段ALU的数据冒险
    Forward_UnitB ForwUB(
    //input
        .MEM_RegDstAddr     (MEM_RegDstAddr),
        .MEM_RegWr          (MEM_RegWrite),
        .WB_RegDstAddr      (WB_RegDstAddr),
        .WB_RegWr           (WB_RegWrite),
        .EX_rt              (EX_rt),
        .EX_rs              (EX_rs),
    //output
        .ALUinASrc          (ALUinASrc),
        .ALUinBSrc          (ALUinBSrc)
    );
    
   /*---------------Forwarding Unit C-------------*/
   //处理load-store冒险
   Forward_UnitC ForwUC(
   //input
        .WB_RegDstAddr      (WB_RegDstAddr),
        .WB_RegWr           (WB_RegWrite),
        .MEM_MemWr          (MEM_MemWrite),
        .MEM_rt             (MEM_rt),//此处应是rt,因为这里考虑的是存储要写入内存的寄存器是否被改写
   //output
        .MemWrDataSrc       (MemWrDataSrc)
   );
   
   //需要转发的Muxs:
   //PC_next,RF.Comp_in1/2,EX.ALUin1,ALUB_out
   //jal改写PC在这里实现,Hazard Unit,2个Forwarding Unit
   //注意，PC_keep优先级高于改写，这是因为我们优先处理load-use问题
   
   /*-----------RF_stage:Comp Unit----------------*/
   assign RF_Comp_rs = RF_Comp_rsSrc ? MEM_ALUOut :RF_ReadData1;
   assign RF_Comp_rt = RF_Comp_rtSrc ? MEM_ALUOut :RF_ReadData2;
    
   /*------------EX_stage:ALU input--------------*/
   assign ALUin1 = (ALUinASrc == 2'b10) ? MEM_ALUOut : (ALUinASrc == 2'b01) ? WB_RegWrData : ALUA_in1;
   assign ALUB_out = (ALUinBSrc == 2'b10) ? MEM_ALUOut : (ALUinBSrc == 2'b01) ? WB_RegWrData : EX_ReadData2;
   assign EX_ReadData2_1 = (ALUinBSrc == 2'b10) ? MEM_ALUOut : (ALUinBSrc == 2'b01) ? WB_RegWrData : EX_ReadData2;
   
   /*-----------MEM_stage:MEM input--------------*/
   assign MemWrData = MemWrDataSrc ? WB_RegWrData : MEM_ReadData2;
   
   /*----------IF_stage:PC_next------------------*/
   wire [32 -1:0] Branch_or_plus;
   assign Branch_or_plus = RF_PCSrc1 ? Branch_target : PC_plus_4;
   assign PC_next = keep_PC ? PC :
            (RF_PCSrc2 == 2'b00) ? Branch_or_plus ://beq or +4
            (RF_PCSrc2 == 2'b01) ? Jump_target : //j,jal
            (RF_jrSrc)? MEM_PC :RF_ReadData1; //jr
    
//   /*---------PDC----------*/
//   PDC pdc(
//    .reset  (reset),
//    .clk    (clk),
//    .num    (leds),
//    .LEDS   (LEDS)
//   ); 
    
endmodule
