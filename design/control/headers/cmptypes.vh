`ifndef _CMPTYPES_H_
`define _CMPTYPES_H_

/**
 * CMPTYPES - Constant values for defining the different types of comparison operators.
 * Used for both IF(EQ/NE/LT/LE/GE/GT) and IF_ICMP(EQ/NE/LT/LE/GE/GT) operations.
 * These are used in both decoder and control unit, so they're in this header file.
 */

localparam EQ = 3'b000;
localparam NE = 3'b001;
localparam LT = 3'b010;
localparam LE = 3'b011;
localparam GE = 3'b100;
localparam GT = 3'b101;

`endif