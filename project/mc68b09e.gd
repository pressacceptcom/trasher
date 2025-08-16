## The Motorola MC68B09E Emulator Component
##
## Emulates the 8-bit microprocessing unit in accordance with the device description given in the
## Motorola catalog pg 4-298.
class_name Mc68b09e
extends Node

# Front Page (4-298):
#
# 8-Bit Microprocessing Unit
#
# The MC6809E is a revolutionary high performance 8-bit mircoprocessor which supports modern
# programming techniques such as position independence, reentrancy, and modular programming.
#
# This third-generation addition to the M6800 family has major architectural improvements which
# include additional registers, instructions and addressing modes.__data__
#
# The basic instructions of any computer are greatly enhanced by the presence of powerful addresing
# modes. The MC6809E has the most complete set of addressing modes available on any 8-bi
# microprocessor today.
#
# The MC6809E has hardware and software features which make it an ideal processor for higher level
# language execution or standard controller applications. External clock inputs are provided to
# allow synchronization with peripherals, systems or other MPUs.
#
# MC6800 COMPATIBLE
# 
# * Hardware - Interfaces with All M6800 Peripherals
# * Software - Upward Source Code Compatible Instruction Set and Addressing Modes
#
# ARCHITECTURAL FEATURES
# 
# * Two 16-bit Index Registers
# * Two 16-bit Indexable Stack Pointers
# * Two 8--bit Accumulators can be Concatenated to Form One 16-Bit Accumulator,
# * Direct Page Register Allows Direct Addressing Throughout Memory
#
# HARDWARE FEATURES
#
# * External Clock Inputs, E and Q, Allow Synchronization
# * TSC Input Controls Internal Bus Buffers
# * LIC Indicates Opcode Fetch
# * AVMA Allows Efficient Use of Common Resources in A Multiprocessor System
# * BUSY is a Status Line for Multiprocessing
# * Fast Interrupt Request Input Stacks Only Condition Code Register and Program Counter
# * Interrupt Acknowledge Output Allows Vectoring By Devices
# * SYNC Acknowledge Output Allows for Synchronization to External Event
# * Single Bus-Cycle RESET
# * Single 5-Volt Supply Operation
# * NMI Inhibited After RESET Until Until After First Load of Stack Pointer
# * Early Address Valid Allows Use With Slower Memories
# * Early Write-Data for Dynamic Memories
#
# SOFTWARE FEATURES
# 
# * 10 Addressing Modes
#     * M6800 Upward Compatible Addressing Modes
#     * Direct Addressing Anywhere in Memory Map
#     * Long Relative Branches
#     * Program Counter Relative
#     * True Indirect Addressing
#     * Expanded Indexed Addressing:
#         * 0, 5, 8, or 16-bit Constant Offsets
#         * 8, or 16-bit Accumulator Offsets
#         * Auto-Increment/Decrement by 1 or 2
# * Improved Stack Manipulation
# * 1464 Instructions with Unique Addressing Modes
# * 8 x 8 Unsigned Multiply
# * 16-bit Arithmetic
# * Transfer/Exchange All Registers
# * Push/Pull Any Registers or Any Set of Registers
# * Load Effective Address


# PIN ASSIGNMENT
#
#       ---\__/---           PIN DESCRIPTIONS
#  VSS [| 1   40 |] HALT
#       |        |           POWER (VSS, VCC)
#  NMI [| 2   39 |] TSC          Two pins are used to supply power to the part: VSS is ground or O
#       |        |               volts, while VCC is +5.0 V ±5%
#  IRQ [| 3   38 |] LIC
#       |        |           ADDRESS BUS (A0-A15)
# FIRQ [| 4   37 |] RESET        Sixteen pins are used to output address information from the MPU
#       |        |               onto the Address Bus. When the processor does not require the bus
#   BS [| 5   36 |] AVMA         for a data transfer, it will output address FFFF (16), R/W = 1,
#       |        |               and BS = 0; this is a"dummy access"or VMA cycle. All address bus
#   BA [| 6   35 |] Q            drivers are made high-impedance when output Bus Available (BA) is
#       |        |               high or when TSC is asserted. Each pin will drive one Schottky TTL
#  VCC [| 7   34 |] E            load or four LS TTL loads, and 90 pF.
#       |        |
#   A0 [| 8   33 |] BUSY     DATA BUS (D0-D7)
#       |        |               These eight pins provide communication with the system
#   A1 [| 9   32 |] R/W          bi-directional data bus. Each pin will drive one Schottky TTL load
#       |        |               or four LS TTL loads, and 130 pF.
#   A2 [| 10  31 |] D0
#       |        |           READ/WRITE (R/W)
#   A3 [| 11  30 |] D1           This signal indicates the direction of data transfer on the data
#       |        |               bus. A low indicates that the MPU is writing data onto the data
#   A4 [| 12  29 |] D2           bus. R/W is made high impedance when BA is high or when TSC is
#       |        |               asserted.
#   A5 [| 13  28 |] D3
#       |        |           RESET
#   A6 [| 14  27 |] D4           A low level on this Schmitt-trigger input for greater than one bus
#       |        |               cycle will reset the MPU, as shown in Figure 7. The Reset vectors
#   A7 [| 15  26 |] D5           are fetched from locations FFFE (16) and FFFF (16) (Table 1) when
#       |        |               Interrupt Acknowledge is true, (BA • BS = 1). During initial
#   A8 [| 16  25 |] D6           power-on, the Reset line should be held low until the clock input
#       |        |               signals are fully operational.
#   A9 [| 17  24 |] D7
#       |        |               Because the MC6809E Reset pin has a Schmitt-trigger input with a
#  A10 [| 18  23 |] A15          threshold voltage higher than that of standard peripherals, a
#       |        |               simple R/C network may be used to reset the entire system. This
#  A11 [| 19  22 |] A14          higher threshold voltage ensures that all peripherals are out of
#       |        |               the reset state before the Processor.
#  A12 [| 20  21 |] A13
#       ----------
#
# HALT
#     A low level on this input pin will cause the MPU to stop running at the end of the present
#     instruction and remain halted indefinitely without loss of data. When halted, the BA output
#     is driven high indicating the buses are high-impedance. BS is also high which indicates the
#     processor is in the Halt state. While halted, the MPU will not respond to external real-time
#     requests (FIRO, IRQ) although NMI or RESET will be latched for later response. During the
#     Halt state Q and E should continue to run normally. A halted state (BA • BS = 1) can be
#     achieved by pulling HALT low while RESET is still low. See Figure 8.
#
# BUS AVAILABLE, BUS STATUS (BA, BS)
#     The Bus Available output is an indication of an internal control signal which makes the MOS
#     buses of the MPU high impedance. When BA goes low, a dead cycle will elapse before the MPU
#     acquires the bus. BA will not be asserted when TSC is active, thus allowing dead cycle
#     consistency.
#
#     The Bus Status output signal, when decoded with BA, represents the MPU state (valid with
#     leading edge of Q).
#
#     ----------------------------------------------
#     | MPU State |           MPU State            |
#     -------------           Definition           |
#     |  BA | BS  |                                |
#     ----------------------------------------------
#     |  0  |  0  | Normal (Running)               |
#     |  0  |  1  | Interrupt or RESET Acknowledge |
#     |  1  |  0  | SYNC Acknowledge               |
#     |  1  |  1  | HALT Acknowledge               |
#     ----------------------------------------------
#
#     Interrupt Acknowledge is indicated during both cycles of a hardware-vector-fetch (RESET, NMI,
#     FIRQ, IRQ, SWI, SWl2, SWl3). This signal, plus decoding of the lower four address lines, can
#     provide the user with an indication of which interrupt level is being serviced and allow
#     vectoring by device. See Table 1.
#
#     TABLE 1 - MEMORY MAP FOR INTERRUPT VECTORS
#
#     ------------------------------------------------------------------
#     | Memory Map For Vector Locations |       Interrupt Vector       |
#     -----------------------------------          Description         |
#     |       MS       |       LS       |                              |
#     ------------------------------------------------------------------
#     |      FFFE      |      FFFF      |            RESET             |
#     ------------------------------------------------------------------
#     |      FFFC      |      FFFD      |             NMI              |
#     ------------------------------------------------------------------
#     |      FFFA      |      FFFB      |             SWI              |
#     ------------------------------------------------------------------
#     |      FFF8      |      FFF9      |             IRQ              |
#     ------------------------------------------------------------------
#     |      FFF6      |      FFF7      |            FIRQ              |
#     ------------------------------------------------------------------
#     |      FFF4      |      FFF5      |            SWI2              |
#     ------------------------------------------------------------------
#     |      FFF2      |      FFF3      |            SWI3              |
#     ------------------------------------------------------------------
#     |      FFF0      |      FFF1      |           Reserved           |
#     ------------------------------------------------------------------
#
#     Sync Acknowledge is indicated while the MPU is waiting for external synchronization on an
#     interrupt line.
#
#     Halt/Acknowledge is indicated when the MC6809E is in a Halt condition.
#
# NON MASKABLE INTERRUPT (NMI)*
#     A negative transition on this input requests that a non-maskable interrupt sequence be
#     generated. A non-maskable interrupt cannot be inhibited by the program, and also has a higher
#     priority than FIRO, IRO or software interrupts. During recognition of an NMI, the entire
#     machine state is saved on the hardware stack. After reset, an NM! will not be recognized
#     until the first program load of the Hardware Stack Pointer (S). The pulse width of NMI low
#     must be at least one E cycle. If the NMI input does not meet the minimum set up with respect
#     to Q, the interrupt will not be recognized until the next cycle. See Figure 9.
#
# FAST-INTERRUPT REQUEST (FIRQ)*
#     A low level on this input pin will initiate a fast interrupt sequence, provided its mask bit
#     (F) in the CC is clear. This sequence has priority over the standard Interrupt Request (IRQ),
#     and is fast in the sense that it stacks only the contents of the condition code register and
#     the program counter. The interrupt service routine should clear the source of the interrupt
#     before doing an RTI. See Figure 10.
#
# INTERRUPT REQUEST (IRQ)*
#     A low level input on this pin will initiate an Interrupt Request sequence provided the mask
#     bit (I) in the CC is clear. Since IRQ stacks the entire machine state it provides a slower
#     response to interrupts than FIRQ. IRQ also has a lower priority than FIRQ. Again, the
#     interrupt service routine should clear the source of the interrupt before doing an RTI. See
#     Figure 9.
#
# *NMI, FIRQ, and IRQ requests are sampled on the falling edge of Q. One cycle is required for
# synchronization before these interrupts are recognized. The pending interrupts will not be
# serviced until completion of the current instruction unless a SYNC or CWAI condition is present.
# If IRQ and FIRQ do not remain low until completion of the current instruction they may not be
# recognized. However, NMI is latched and need only remain low for one cycle. No interrupts are
# recognized or latched between the falling edge of RESET and the rising edge of BS indicating
# RESET acknowledge. See RESET sequence in the MPU flowchart in Figure 15.
#
# CLOCK INPUTS E, Q
#     E and Q are the clock signals required by the MC6809E. Q must lead E; that is, a transition
#     on Q must be followed by a similar transition on E after a minimum delay. Addresses will be
#     valid from the MPU, t(AD) after the falling edge of E, and data will be latched from the bus
#     by the falling edge of E. While the Q input is fully TTL compatible, the E input directly
#     drives internal MOS circuitry and, thus, requires a high level above normal TTL levels. This
#     approach minimizes clock skew inherent with an internal buffer. Timing and waveforms tor E
#     and Q are shown in Figure 2 while Figure 11 shows a simple clock generator tor the MC6809E.
#
# BUSY
#     Busy will be high for the read and modify cycles of a read-modify-write instruction and
#     during the access of the first byte of a double-byte operation (e.g., LDX, STD, ADDD). Busy
#     is also high during the first byte of any indirect or other vector fetch (e.g., jump
#     extended, SWI indirect etc.).
#
#     In a multi-processor system, busy indicates the need to defer the rearbitration of the next
#     bus cycle to insure the integrity of the above operations. This difference provides the
#     indivisible memory access required tor a "test-and-set" primitive, using any one of several
#     read-modify-write instructions.
#
#     Busy does not become active during PSH or PUL operations. A typical read-modify-write
#     instruction (ASL) is shown in Figure 12. Timing information is given in Figure 13. Busy is
#     valid t(CD) after the rising edge of Q.
#
# AVMA
#     AVMA is the Advanced VMA signal and indicates that the MPU will use the bus in the following
#     bus cycle. The predictive nature of the AVMA signal allows efficient shared-bus multiprocessor
#     systems. AVMA is LOW when the MPU is in either a HALT or SYNC state. AVMA is valid t(CD)
#     after the rising edge of Q.
#
# LIC
#     LIC (Last Instruction Cycle) is HIGH during the last cycle of every instruction, and its
#     transition from HIGH to LOW will indicate that the first byte of an opcode will be latched at
#     the end of the present bus cycle. LIC will be HIGH when the MPU is Halted at the end of an
#     instruction, (i.e., not in CWAI or RESET) in SYNC state or while stacking during interrupts.
#     LIC is valid t(CD) after the rising edge of Q.
#
# TSC
#     TSC (Three-State Control) will cause MOS address, data, and R/W buffers to assume a
#     high-impedance state. The control signals (BA, BS, BUSY, AVMA and LIC) will not go to the
#     high-impedance state. TSC is intended to allow a single bus to be shared with other bus
#     masters (processors or OMA controllers).
#
#     While E is low, TSC controls the address buffers and R/W directly. The data bus buffers
#     during a write operation are in a high-impedance state until Q rises at which time, if TSC is
#     true, they will remain in a high-impedance state. It TSC is held beyond the rising edge of E,
#     then it will be internally latched, keeping the bus drivers in a high-impedance state for the
#     remainder of the bus cycle. See Figure 14.


# "Programming Model"
#
# From 4-301: As shown in Figure 5, the MC6809E adds three registers to the set available in the
# MC6800. The added registers include a Direct Page Register, the User Stack pointer and a second
# Index Register.
#
# 15                           0
# ------------------------------  \                      7                      0
# |     X - Index Register     |  |                      ------------------------
# ------------------------------  |                      | Direct Page Register |
# |     Y - Index Register     |  |                      ------------------------
# ------------------------------  |- Pointer Registers
# |   U - User Stack Pointer   |  |                      7    Condition Code Register    0
# ------------------------------  |                      ---------------------------------
# | S - Hardware Stack Pointer |  |                      | E | F | H | I | N | Z | V | C |
# ------------------------------  /                      ---------------------------------
# |       Program Counter      |                           |   |   |   |   |   |   |   |
# ------------------------------  \                   Entire   |   |   |   |   |   |   Carry
# |      A      |      B       |  |- Accumulators              |   |   |   |   |   |
# ------------------------------  /                    FIRQ Mask   |   |   |   |   Overflow
# \____________________________/                                   |   |   |   |
#               |                                         Half Carry   |   |   Zero
#               D                                                      |   |
#                                                               IRQ Mask   Negative
#
# ACCUMULATORS (A, B, D)
#
# The A and B registers are general purpose accumulators which are used for arithmetic calculations
# and manipulation of data.
# 
# Certain instructions concatenate the A and B registers to form a single 16-bit accumulator. This
# is referred to as the D Register, and is formed with the A Register as the most significant byte.
#
# DIRECT PAGE REGISTER (DP)
#
# The Direct Page Register of the MC6809E serves to enhance the Direct Addressing Mode. The content
# of this register appears at the higher address outputs (A8-A15) during direct addressing
# instruction execution. This allows the direct mode to be used at any place in memory, under
# program control. To ensure M6800 compatibility, all bits of this register are cleared during
# Processor Reset.
#
# INDEX REGISTERS (X, Y)
#
# The Index Registers are used in indexed mode of addressing. The 16-bit address in this register
# takes part in the calculation of effective addresses. This address may be used to point to data
# directly or may be modifed by an optional constant or register offset. During some indexed modes,
# the contents of the index register are incremented or decremented to point to the next item of
# tabular type data. All four pointer register (X, Y, U, S) may be used as index registers.
#
# STACK POINTER (U, S)
#
# The Hardware Stack Pointer (S) is used automatically by the processor during subroutine calls and
# interrupts. The User Stack Pointer (U) is controlled exclusively by the programmer thus allowing
# arguments to be passed to and from subroutines with ease. The U-register is frequently used as a
# stack marker. Both Stack Pointers have the same indexed mode addressing capabilities as the X and
# Y registers, but also support Push and Pull instructions. This allows the MC6809E to be used
# efficiently as a stack processor, greatly enhancing its ability to support higher level languages
# and modular programming.
#
# NOTE: The stack pointers of the MC6B09E point to the top of the stack, in contrast to the MC6800
#       stack pointer, which pointed to the next free location on stack.
#
# PROGRAM COUNTER
#
# The Program Counter is used by the processor to point to the address of the next instruction to
# be executed by the processor. Relative Addressing is provided allowing the Program Counter to be
# used like an index register in some situations.
#
# CONDITION CODE REGISTER
#
# The Condition Code Register defines the state of the processor at any given time.
#
# CONDITION CODE REGISTER DESCRIPTION
#
# BIT 0 (C) - Bit O is the carry flag, and is usually the carry from the binary ALU. C is also used
#             to represent a 'borrow' from subtract like instructions (CMP, NEG, SUB, SBC) and is
#             the complement of the carry from the binary ALU.
#
# BIT 1 (V) - Bit 1 is the overflow flag, and is set to a one by an operation which causes a signed
#             two's complement arithmetic overflow. This overflow is detected in an operation in
#             which the carry from the MSB in the ALU does not match the carry from the MSB-1.
#
# BIT 2 (Z) - Bit 2 is the zero flag, and is set to a one if the result of the previous operation
#             was identically zero.
#
# BIT 3 (N) - Bit 3 is the negative flag, which contains exactly the value of the MSB of the result
#             of the preceding operation. Thus, a negative two's-complement result will leave N set
#             to a one.
#
# BIT 4 (I) - Bit 4 is the IRQ mask bit. The processor will not recognize interrupts from the IRQ
#             line if this bit is set to a one. NMI, FIRQ, IRQ, RESET, and SWI all set I to a one;
#             SWl2 and SWl3 do not affect I.
#
# BIT 5 (H) - Bit 5 is the half-carry bit, and is used to indicate a carry from bit 3 in the ALU as
#             a result of an 8-bit addition only (ADC or ADD). This bit is used by the DAA
#             instruction to perform a BCD decimal add adjust operation. The state of this flag is
#             undefined in all subtract-like instructions.
#
# BIT 6 (F) - Bit 6 is the FIRQ mask bit. The processor will not recognize interrupts from the FIRQ
#             line if this bit is a one. NMI, FIRQ, SWI, and RESET all set F to a one. IRQ, SWl2
#             and SWl3 do not affect F.
#
# BIT 7 (E) - Bit 7 is the entire flag, and when set to a one indicates that the complete machine
#             state (all the registers) was stacked, as opposed to the subset state (PC and CC).
#             The E bit of the stacked CC is used on a return from interrupt (RTI) to determine the
#             extent of the unstacking. Therefore, the current E left in the Condition Code
#             Register represents past action.


# MPU OPERATION
#
# During normal operation, the MPU fetches an instruction from memory and then executes the
# requested function. This sequence begins after RESET and is repeated indefinitely unless altered
# by a special instruction or hardware occurrence. Software instructions that alter normal MPU
# operation are: SWI, SWl2, SWI3, CWAI, RTI and SYNC. An interrupt or HALT input can also alter the
# normal execution of instructions. Figure 15 is the flow chart for the MC6809E.


# ADDRESSING MODES (4-312)
#
# The basic instructions of any computer are greatly enhanced by the presence of powerful
# addressing modes. The MC6809E has the most complete set of addressing modes available on any
# microcomputer today. For example, the MC6809E has 59 basic instructions; however, it recognizes
# 1464 different variations of instructions and addressing modes. The addressing modes support
# modern programming techniques. The following addressing modes are available on the MC6809E:
#
# * Inherent (Includes Accumulator)
# * Immediate
# * Extended
#     * Extended Indirect
# * Direct
# * Register
# * Indexed
#     * Zero-Offset
#     * Constant Offset
#     * Accumulator Offset
#     * Auto Increment/Decrement
#     * Indexed Indirect
# * Relative
#     * Short/Long Relative Branching
#     * Program Counter Relative Addressing
#
# INHERENT (INCLUDES ACCUMULATOR)
#
#     In this addressing mode, the opcode of the instruction contains all the address information
# necessary. Examples of Inherent Addressing are: ABX, DAA, SWI, ASRA, and CLRB.
#
# IMMEDIATE ADDRESSING
#
#     In Immediate Addressing, the effective address of the data is the location immediately
# following the opcode {i.e., the data to be used in the instruction immediately follows the opcode
# of the instruction). The MC6809E uses both 8 and 16-bit immediate values depending on the size of
# argument specified by the opcode. Examples of instructions with Immediate Addressing are:
#
#     LDA #$20
#     LDX #$FOOO
#     LDY #CAT
#
# NOTE: # signifies Immediate addressing, $ signifies hexa- decimal value to the MC6809 assembler.
#
# EXTENDED ADDRESSING
#
#     In Extended Addressing, the contents of the two bytes immediately following the opcode fully
# specify the 16-bit effective address used by the instruction. Note that the address generated by
# an extended instruction defines an absolute address and is not position independent. Examples of
# Extended Addressing include:
#
#     LDA CAT
#     STX MOUSE
#     LDD $2000
#
# EXTENDED INDIRECT
#
#     As a special case of indexed addressing {discussed below), one level of indirection may be
# added to Extended Addressing. In Extended Indirect, the two bytes following the postbyte of an
# Indexed instruction contain the address of the data.
#
#     LDA [CAT]
#     LDX [$FFFE]
#     STU [DOG]
#
# DIRECT ADDRESSING
#
#     Direct addressing is similar to extended addressing except that only one byte of address
# follows the opcode. This byte specifies the lower 8 bits of the address to be used. The upper 8
# bits of the address are supplied by the direct page register. Since only one byte of address is
# required in direct addressing, this mode requires less memory and executes faster than extended
# addressing. Of course, only 256 locations (one page) can be accessed without redefining the
# contents of the DP register. Since the DP register is set to $00 on Reset, direct addressing on
# the MC6809E is upward compatible with direct addressing on the M6800. Indirection is not allowed
# in direct addressing. Some examples of direct addressing are:
#
#     LDA where DP = $00
#     LDB where DP = $10
#     LDD <CAT
#
# NOTE: < is an assembler directive which forces direct addressing.
#
# REGISTER ADDRESSING
#
#     Some opcodes are followed by a byte that defines a register or set of registers to be used by
# the instruction. This is called a postbyte. Some examples of register addressing are:
#
#     TFR    X, Y          Transfers X into Y
#     EXG    A, B          Exchanges A with B
#     PSHS   A, B, X, Y    Push Y, X, B, and A onto S stack
#     PULU   X, Y, D       Pull D, X, ad Y from U stack
#
# INDEXED ADDRESSING
#
#     In all indexed addressing, one of the pointer registers {X, Y, U, S, and sometimes PC) is
# used in a calculation of the effective address of the operand to be used by the instruction. Five
# basic types of indexing are available and are discussed below. The postbyte of an indexed
# instruction specifies the basic type and variation of the addressing mode as well as the pointer
# register to be used. Figure 16 lists the legal formats for the postbyte. Table 2 gives the
# assembler form and the number of cycles and bytes added to the basic values for indexed
# addressing for each variation.
#
# FIGURE 16 - INDEXED ADDRESSING POSTBYTE REGISTER BIT ASSIGNMENTS
#
# ------------------------------------------------------------
# |    Post-Byte Register Bit     |         Indexed          |
# ---------------------------------        Addressing        |
# | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |           Mode           |
# ------------------------------------------------------------
# | 0 | R | R | d | d | d | d | d |  EA = ,R + 5 Bit Offset  |
# ------------------------------------------------------------
# | 1 | R | R | 0 | 0 | 0 | 0 | 0 |           ,R+            |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 0 | 0 | 1 |           ,R++           |
# ------------------------------------------------------------
# | 1 | R | R | 0 | 0 | 0 | 1 | 0 |            ,-R           |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 0 | 1 | 1 |           ,--R           |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 0 | 0 |    EA = ,R +0 Offset     |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 0 | 1 |   EA = ,R + ACCB Offset  |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 1 | 0 |   EA = ,R + ACCA Offset  |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 0 | 0 |   EA = ,R + 8 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 0 | 1 |  EA = ,R + 16 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 1 | 1 |    EA = ,R + D Offset    |
# ------------------------------------------------------------
# | 1 | x | x | i | 1 | 1 | 0 | 0 |  EA = ,PC + 9 Bit Offset |
# ------------------------------------------------------------
# | 1 | x | x | i | 1 | 1 | 0 | 1 | EA = ,PC + 16 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 1 | 1 | 1 |      EA = [,Address]     |
# ------------------------------------------------------------
#     \______/\__/\_______________/
#        |     |          |
#        |     |      Addressing Mode Field
#        |     |
#        |  Indirect Field (Sign bit when b(7) = 0)
#        |
#     Register Field: RR
#
#     00 = X  01 = Y            x = Don't Care  d = Offset Bit
#     10 = U  11 = S            i = 0 Not Indirect
#                                   1 Indirect
#
# TABLE 2 - INDEXED ADDRESSING MODE
#
# ----------------------------------------------------------------------------------------------------------------
# |                            |                   |          Non Indirect        |          Indirect            |
# |            Type            |        Forms      ---------------------------------------------------------------
# |                            |                   | Assembler | Postbyte | + | + | Assembler | Postbyte | + | + |
# |                            |                   |    Form   |  OP Code | ~ | # |    Form   |  OP Code | ~ | # |
# ----------------------------------------------------------------------------------------------------------------
# | Constant Offset From R     | No Offset         |     ,R    | 1RR00100 | 0 | 0 |    [,R]   | 1RR10100 | 3 | 0 |
# | (2's Complement Offsets)   -----------------------------------------------------------------------------------
#                              | 5 Bit Offset      |    n, R   | 0RRnnnnn | 1 | 0 |       defaults to 8-bit      |
#                              -----------------------------------------------------------------------------------
#                              | 8 Bit Offset      |    n, R   | 1RR01000 | 1 | 1 |   [n, R]  | 1RR11000 | 4 | 1 |
#                              -----------------------------------------------------------------------------------
#                              | 16 Bit Offset     |    n, R   | 1RR01001 | 4 | 2 |   [n, R]  | 1RR11001 | 7 | 2 |
# ----------------------------------------------------------------------------------------------------------------
# | Accumulator Offset From R  | A Register Offset |    A, R   | 1RR00110 | 1 | 0 |   [A, R]  | 1RR10110 | 4 | 0 |
# | (2's Complement Offsets)   -----------------------------------------------------------------------------------
#                              | B Register Offset |    B, R   | 1RR00101 | 1 | 0 |   [B, R]  | 1RR10101 | 4 | 0 |
#                              -----------------------------------------------------------------------------------
#                              | D Register Offset |    D, R   | 1RR01011 | 4 | 0 |   [D, R]  | 1RR11011 | 7 | 0 |
# ----------------------------------------------------------------------------------------------------------------
# | Auto Increment/Decrement R | Increment By 1    |     ,R+   | 1RR00000 | 2 | 0 |         not allowed          |
#                              -----------------------------------------------------------------------------------
#                              | Increment By 2    |    ,R++   | 1RR00001 | 3 | 0 |   [,R++]  | 1RR10001 | 6 | 0 |
#                              -----------------------------------------------------------------------------------
#                              | Decrement By 1    |     ,-R   | 1RR00010 | 2 | 0 |         not allowed          |
#                              -----------------------------------------------------------------------------------
#                              | Decrement By 2    |    ,--R   | 1RR00011 | 3 | 0 |   [,--R]  | 1RR10011 | 6 | 0 |
# ----------------------------------------------------------------------------------------------------------------
# | Constant Offset From PC    | 8 Bit Offset      |   n, PCR  | 1xx01100 | 1 | 1 |  [n, PCR] | 1xx11100 | 4 | 1 |
# | (2's Complement Offsets)   -----------------------------------------------------------------------------------
#                              | 16 Bit Offset     |   n, PCR  | 1xx01101 | 5 | 2 |  [n, PCR] | 1xx11101 | 8 | 2 |
# ----------------------------------------------------------------------------------------------------------------
# | Extended Indirect          | 16 Bit Address    |     -     |    --    | - | - |     [n]   | 10011111 | 5 | 2 |
# ----------------------------------------------------------------------------------------------------------------
#
# R = X, Y, U, or S    RR: 00 = X  01 = Y  10 = U  11 = S
#
# x = Don't Care       + ~ and + # indicate the number of additional cycles and bytes respectively for the
#                                  particular indexing variation.
#
# Zero-Offset Indexed - In this mode, the selected pointer register contains the effective address
#     of the data to be used by the instruction. This is the fastest indexing mode.
#
#     Examples are:
#
#     LDD 0, X
#     LDA ,S
#
# Constant Offset Indexed - In this mode, a two's-complement offset and the contents of one of the
#     pointer registers are added to form the effective address of the operand. The pointer
#     register's initial content is unchanged by the addition.
#
#     Three sizes of offsets are available:
#
#     5-bit  (-16 to +15)
#     8-bit  (-128 to +127)
#     16-bit (-32768 to +32767)
#
#     The two's complement 5-bit offset is included in the postbyte and, therefore, is most
#     efficient in use of bytes and cycles. The two's complement 8-bit offset is contained in a
#     single byte following the postbyte. The two's complement 16-bit offset is in the two bytes
#     following the postbyte. In most cases the programmer need not be concerned with the size of
#     this offset since the assembler will select the optimal size automatically.
#
#     Examples of constant-offset indexing are:
#
#     LDA 23,X
#     LDX -2,S
#     LDY 300,X
#     LDU CAT,Y
#
# Accumulator-Offset Indexed - This mode is similar to constant offset indexed except that the
#     two's-complement value in one of the accumulators (A, B or D) and the contents of one of the
#     pointer registers are added to form the effective address of the operand. The contents of
#     both the accumulator and the pointer register are unchanged by the addition. The postbyte
#     specifies which accumulator to use as an offset and no additional bytes are required. The
#     advantage of an accumulator offset is that the value of the offset can be calculated by a
#     program at run-time.
#
#     Some examples are:
#
#     LDA  B,Y
#     LDX  D,Y
#     LEAX B,X
#
# Auto Increment/Decrement Indexed - In the auto increment addressing mode, the pointer register
#     contains the address of the operand. Then, after the pointer register is used it is
#     incremented by one or two. This addressing mode is useful in stepping through tables, moving
#     data, or for the creation of software stacks. In auto decrement, the pointer register is
#     decremented prior to use as the address of the data. The use of auto decrement is similar to
#     that of auto increment; but the tables, etc., are scanned from the high to low addresses. The
#     size of the increment/decrement can be either one or two to allow for tables of either 8- or
#     16-bit data to be accessed and is selectable by the programmer. The pre-decrement,
#     post-increment nature of these modes allow them to be used to create additional software
#     stacks that behave identically to the U and S stacks.
#
#     Some examples of the auto increment/decrement addressing modes are:
#
#     LDA ,X+
#     STD ,Y++
#     LDB ,-Y
#     LDX ,--S
#
#     Care should be taken in performing operations on 16-bit pointer registers (X, Y, U, S) where
#     the same register is used to calculate the effective address.
#
#     Consider the following instruction:
#
#     STX 0,X++ (X initialized to 0)
#
#     The desired result is to store a 0 in locations $0000 and $0001 then increment X to point to
#     $0002. In reality, the following occurs:
#
#     0   -> temp      calculate the EA; temp is a holding register
#     X+2 -> X         perform autoincrement
#     X   -> (temp)    do store operation
#
# INDEXED INDIRECT
#
# INDEXED INDIRECT
#
#     All of the indexing modes with the exception of auto increment/decrement by one, or a ±5-bit
# offset may have an additional level of indirection specified. In indirect addressing, the
# effective address is contained at the location specified by the contents of the Index Register
# plus any offset. In the example below, the A accumulator is loaded indirectly using an effective
# address calculated from the Index Register and an offset.
#
# Before Execution
# 
# A=XX (don't care)
# X = $FOOO
#
# $0100 LDA [$10,X]    EA is now $F010
#
# $F010 $Fl            $F150 is now the new EA
# $F011 $50
#
# $F150 $AA
#
# After Execution
#
# A = $AA (Actual Data Loaded)
# X = $FOOO
#
# All modes of indexed indirect are included except those which are meaningless (e.g., auto
# increment/decrement by 1 indirect). Some examples of indexed indirect are:
#
# LDA [,Xl
# LDD [10,Sl]
# LDA [B,Y]
# LDD [,X++]
#
# RELATIVE ADDRESSING
#
#     The byte(s) following the branch opcode is (are) treated as a signed offset which may be
# added to the program counter. If the branch condition is true then the calculated address (PC +
# signed offset) is loaded into the program counter. Program execution continues at the new
# location as indicated by the PC; short (1 byte offset) and long (2 bytes offset) relative
# addressing modes are available. All of memory can be reached in long relative addressing as an
# effective address interpreted modulo 2^16. Some examples of relative ad- dressing are:
#
#        BEQ  CAT    (short)
#        BGT  DOG    (short)
# CAT    LBEQ RAT    (long)
# DOG    LBGT RABBIT (long)
#      *
#      *
# RAT    NOP
# RABBIT NOP
#
# PROGRAM COUNTER RELATIVE
#
#     The PC can be used as the pointer register with 8 or 16-bit signed offsets. As in relative
# addressing, the offset is added to the current PC to create the effective address. The effective
# address is then used as the address of the operand or data. Program Counter Relative Addressing
# is used for writing position independent programs. Tables related to a particular routine will
# maintain the same relationship after the routine is moved, if referenced relative to the Program
# Counter. Examples are:
#
# LDA  CAT,   PCR
# LEAX TABLE, PCR
#
# Since program counter relative is a type of indexing, an additional level of indirection is
# available.
#
# LDA [CAT, PCR]
# LDU [DOG, PCR]


# MC6809E INSTRUCTION SET
#
#     The instruction set of the MC6809E is similar to that of the MC6800 and is upward compatible
# at the source code level. The number of opcodes has been reduced from 72 to 59, but because of
# the expanded architecture and additional addressing modes, the number of available opcodes (with
# different addressing modes) has risen from 197 to 1464.
#
# Some of the new instructions are described in detail below:
#
# PSHU/PSHS
#
#     The push instructions have the capability of pushing onto either the hardware stack (S) or
# user stack (U) any single register, or set of registers with a single instruction.
#
# PULU/PULS
#
#     The pull instructions have the same capability of the push instruction, in reverse order.
#
# The byte immediately following the push or pull opcode determines which register or registers are
# to be pushed or pulled. The actual PUSH/PULL sequence is fixed; each bit defines a unique
# register to push or pull, as shown below.
#
# PUSH/PULL POST BYTE        STACKING ORDER
# -----------------            PULL ORDER
# | | | | | | | | |                 |
# -----------------                 V
#  | | | | | | | |
#  | | | | | | | CCR                CC
#  | | | | | | |                    A
#  | | | | | | A                    B
#  | | | | | |                      DP
#  | | | | | B                     X Hi
#  | | | | |                       X Lo
#  | | | | DPR                     Y Hi
#  | | | |                         Y Lo
#  | | | X                        U/S Hi
#  | | |                          U/S Lo
#  | | Y                          PC Hi
#  | |                            PC Lo
#  | S/U
#  |                                ∧
#  PC                               |
#                              PUSH ORDER
#
#                          INCREASING MEMORY
#                                   |
#                                   V
#
# TFR/EXG
#
#     Within the MC6809E, any register may be transferred to or exchanged with another of
# like-size; i.e., 8-bit to 8-bit or 16-bit to 16-bit. Bits 4-7 of postbyte define the source
# register, while bits 0-3 represent the destination register. These are denoted as follows:
#
# TRANSFER/EXCHANGE POST BYTE        REGISTER FIELD
# ---------------------------        0000 D (AB)    1000 A
# | SOURCE  |  DESTINATION  |        0001 X         1001 B
# ---------------------------        0010 Y         1010 CCR
#                                    0011 U         1011 DPR
#                                    0100 S
#                                    0101 PC
#
# NOTE: All other combinations are undefined and INVALID
#
# LEAX/LEAY/LEAU/LEAS
#
#     The LEA (Load Effective Address) works by calculating the effective address used in an
# indexed instruction and stores that address value, rather than the data at that address, in a
# pointer register. This makes all the features of the internal addressing hardware available to
# the programmer. Some of the implications of this instruction are illustrated in Table 3.
#
# The LEA instruction also allows the user to access data and tables in a position independent
# manner. For example:
#
# LEAX MSG1, PCR
# LBSR PDATA             (Print message routine)
#   *
#   *
# MSG1 FCC   'MESSSAGE'
#
# This sample program prints: 'MESSAGE'. By writing MSG1, PCR, the assembler computes the distance
# between the present address and MSG1. This result is placed as a constant into the LEAX
# instruction which will be indexed from the PC value at the time of execution. No matter where the
# code is located, when it is executed, the computed offset from the PC will put the absolute
# address of MSG1 into the X pointer register. This code is totally position independent.
#
# The LEA instructions are very powerful and use an internal holding register (temp). Care must be
# exercised when using the LEA instructions with the autoincrement and autodecrement addressing
# modes due to the sequence of internal operations. The LEA internal sequence is outlined as
# follows:
#
# LEA a , b+    (any of the 16-bit pointer registers X, Y, U, or S may be substituted for a, and b)
#
# 1. b -> temp    (calculate the EA)
# 2. b+1 -> b     (modify bm, postincrement)
# 3. temp -> a    (load a)
#
# LEA a, -b
#
# 1. b-1 -> temp  (calculate EA with predecrement)
# 2. b-1 -> b     (modify bm, predecrement)
# 3. temp -> a    (load a)
#
# Autoincrement-by-two and autodecrement-by-two instructions work similarly. Note that LEAX ,X+
# does not change X, however LEAX ,-X does decrement X. LEAX 1,X should be used to increment X by
# one.
#
# TABLE 3 - LEA EXAMPLES
# --------------------------------------------------------------
# | Instruction |  Operation   |            Comment            |
# --------------------------------------------------------------
# | LEAX 10, X  | X + 10 -> X  | Adds 5-bit constant 10 to X   |
# --------------------------------------------------------------
# | LEAX 500, X | X + 500 -> X | Adds 16-bit constant 500 to X |
# --------------------------------------------------------------
# | LEAY A, Y   | Y + A -> Y   | Adds 8-bit A accumulator to Y |
# --------------------------------------------------------------
# | LEAU -10, U | U - 10 -> U  | Subtracts 10 from U           |
# --------------------------------------------------------------
# | LEAS -10, S | S - 10 -> S  | Used to reserve area on stack |
# --------------------------------------------------------------
# | LEAS 10, S  | S + 10 -> S  | Used to 'clean up' stack      |
# --------------------------------------------------------------
# | LEAX 5, S   | S + 5 -> X   | Transfers as well as adds     |
# --------------------------------------------------------------
#
# MUL
#
#     Multiplies the unsigned binary numbers in the A and B ac- cumulator and places the unsigned
# result into the 16-bit D accumulator. This unsigned multiply also allows multiple-precision
# multiplications.
#
# Long And Short Relative Branches
#
#     The MC6809E has the capability of program counter relative branching throughout the entire
# memory map. In this mode, if the branch is to be taken, the 8 or 16-bit signed offset is added to
# the value of the program counter to be used as the effective address·. This allows the program to
# branch anywhere in the 64K memory map. Position independent code can be easily generated through
# the use of relative branching. Both short (8-bit) and long (16-bit) branches are available.
#
# SYNC
#
#     After encountering a Sync instruction, the MPU enters a Sync state, stops processing
# instructions and waits for an interrupt. If the pending interrupt is non-maskable (NMI) or
# maskable (FIRQ, IRQ) with its mask bit (F or I) clear, the processor will clear the Sync state
# and perform the normal interrupt stacking and service routine. Since FIRQ and IRQ are not
# edge-triggered, a low level with a minimum duration of three bus cycles is required to assure
# that the interrupt will be taken. If the pending interrupt is maskable (FIRQ, IRQ) with its mask
# bit (F or I) set, the processor will clear the Sync state and continue processing by executing
# the next inline instruction. Figure 17 depicts Sync timing.
#
# Software Interrupts
#
#     A Software Interrupt is an instruction which will cause an interrupt, and its associated
# vector fetch. These Software Interrupts are useful in operating system calls, software debugging,
# trace operations, memory mapping, and software development systems. Three levels of SWI are
# available on this MC6809E, and are prioritized in the following order: SWI, SWl2, SWl3.
#
# 16-Bit Operation
#
#     The MC6809E has the capability of processing 16-bit data. These instructions include loads,
# stores, compares, adds, subtracts, transfers, exchanges, pushes and pulls.


# CYCLE-BY-CYCLE OPERATION
#
#     The address bus cycle-by-cycle performance chart illustrates the memory-access sequence
# corresponding to each possible instruction and addressing mode in the MC6809E. Each instruction
# begins with an opcode fetch. While that opcode is being internally decoded, the next program byte
# is always fetched. (Most instructions will use the next byte, so this technique considerably
# speeds throughput.) Next, the operation of each opcode will follow the flow chart. VMA is an
# indication of FFFF (16) on the address bus, R/W = 1 and BS = 0. The following examples illustrate
# the use of the chart; see Figure 18.
#
# Example 1: LBSR (Branch Taken)
#
# Before Execution SP = F000                    CYCLE-BY-CYCLE FLOW
#                                    
#                   *                Cycle #   Address   Data   R/W   Description
#                   *
# $8000           LBSR    CAT          1         8000     17     1    Opcode fetch
#                   *                  2         8001     20     1    Offset High Byte
#                   *                  3         8002     00     1    Offset Low Byte
# $A000    CAT      *                  4         FFFF     *      1    VMA Cycle
#                                      5         FFFF     *      1    VMA Cycle
#                                      6         A000     *      1    Computed Branch Address
#                                      7         FFFF     *      1    VMA Cycle
#                                      8         EFFF     80     0    Stack High Order Byt of Return Address
#                                      9         EFFE     03     0    Stack Low Order Byt of Return Address
#
# Example 2: DEC (Extended)          Cycle #   Address   Data   R/W   Description
#
# $8000    DEC    $A000                1         8000     7A     1    Opcode Fetch
# $A000    FCB    $80                  2         8001     A0     1    Operand Address, High Byte
#                                      3         8002     00     1    Operand Address, Low Byte
#                                      4         FFFF     *      1    VMA Cycle
#                                      5         A000     80     1    Read the Data
#                                      6         FFFF     *      1    VMA Cycle
#                                      7         A000     7F     0    Store the Decremented Data
#
#                                      * The data bus has the data at that particular address.


# MC6809E INSTRUCTION SET TABLES
#
#     The instructions of the MC6809E have been broken down into five different categories. They
# are as follows:
#
# * 8-Bit operation (Table 4)
# * 16-Bit operation (Table 5)
# * Index register/stack pointer instructions (Table 6)
# * Relative branches (long or short) (Table 7)
# * Miscellaneous instructions (Table 8)
# 
# Hexadecimal values for the instructions are given in Table 9.
#
# TABLE 4 - 8-BIT ACCUMULATOR AND MEMORY INSTRUCTIONS
# ------------------------------------------------------------------------
# | Mnemonic(s)     | Operation                                          |
# ------------------------------------------------------------------------
# | ADCA, ADCB      | Add memory to accumulator with carry               |
# ------------------------------------------------------------------------
# | ADDA, ADDB      | Add memory to accumulator                          |
# ------------------------------------------------------------------------
# | ANDA, ANDB      | And memory with accumulator                        |
# ------------------------------------------------------------------------
# | ASL, ASLA, ASLB | Arithmetic shift of accumulator or memory left     |
# ------------------------------------------------------------------------
# | ASR, ASRA, ASRB | Arithmetic shift of accumulator or memory right    |
# ------------------------------------------------------------------------
# | BITA, BITB      | Bit test memory with accumulator                   |
# ------------------------------------------------------------------------
# | CLR, CLRA, CLRB | Clear accumulator or memory location               |
# ------------------------------------------------------------------------
# | CMPA, CMPB      | Compare memory from accumulator                    |
# ------------------------------------------------------------------------
# | COM, COMA, COMB | Complement accumulator or memory location          |
# ------------------------------------------------------------------------
# | DAA             | Decimal adjust A accumulator                       |
# ------------------------------------------------------------------------
# | DEC, DECA, DECB | Decrement accumulator or memory location           |
# ------------------------------------------------------------------------
# | EORA, EORB      | Exclusive or memory with accumulator               |
# ------------------------------------------------------------------------
# | EXG R1, R2      | Exchange R1 with R2 (R1, R2 = A, B, CC, DP)        |
# ------------------------------------------------------------------------
# | INC, INCA, INCB | Increment accumulator or memory location           |
# ------------------------------------------------------------------------
# | LDA, LDB        | Load accumulator from memory                       |
# ------------------------------------------------------------------------
# | LSL, LSLA, LSLB | Logical shift left accumulator or memory location  |
# ------------------------------------------------------------------------
# | LSR, LSRA, LSRB | Logical shift right accumulator or memory location |
# ------------------------------------------------------------------------
# | MUL             | Unsigned multiply (A x B -> D)                     |
# ------------------------------------------------------------------------
# | NEG, NEGA, NEGB | Negate accumulator or memory                       |
# ------------------------------------------------------------------------
# | ORA, ORB        | Or memory with accumulator                         |
# ------------------------------------------------------------------------
# | ROL, ROLA, ROLB | Rotate accumulator or memory left                  |
# ------------------------------------------------------------------------
# | ROR, RORA, RORB | Rotate accumulator or memory right                 |
# ------------------------------------------------------------------------
# | SBCA, SBCB      | Subtract memory from accumulator with borrow       |
# ------------------------------------------------------------------------
# | STA, STB        | Store accumulator to memory                        |
# ------------------------------------------------------------------------
# | SUBA, SUBB      | Subtract memory from accumulator                   |
# ------------------------------------------------------------------------
# | TST, TSTA, TSTB | Test accumulator or memory location                |
# ------------------------------------------------------------------------
# | TFR R1, R2      | Transfer R1 to R2 (R1, R2 = A, B, CC, DP)          |
# ------------------------------------------------------------------------
#
# NOTE: A, B, CC, or DP may be pushed to (pulled from) either stack with
#       PSHS, PSHU (PULS, PULU) instructions.
#
#
# TABLE 5 - 16-BIT ACCUMULATOR AND MEMORY INSTRUCTIONS
# --------------------------------------------------------------
# | Mnemonic(s) | Operation                                    |
# --------------------------------------------------------------
# | ADDD        | Add memory to D accumulator                  |
# --------------------------------------------------------------
# | CMPD        | Compare memory from D accumulator            |
# --------------------------------------------------------------
# | EXG D, R    | Exchange D with X, Y, S, U, or PC            |
# --------------------------------------------------------------
# | LDD         | Load D accumulator from memory               |
# --------------------------------------------------------------
# | SEX         | Sign Extend B accumulator into A accumulator |
# --------------------------------------------------------------
# | STD         | Store D accumulator to memory                |
# --------------------------------------------------------------
# | SUBD        | Subtract memory from D accumulator           |
# --------------------------------------------------------------
# | TFR D, R    | Transfer D to X, Y, S, U, or PC              |
# --------------------------------------------------------------
# | TFR R, D    | Transfer X, Y, S, U, or PC to D              |
# --------------------------------------------------------------
#
# NOTE: D may be pushed (pulled) to either stack with PSHS, PSHU (PULS, PULU) instructions
#
#
# TABLE 6 - INDEX REGISTER/STACK POINTER INSTRUCTIONS
# --------------------------------------------------------------------------
# | Instruction | Description                                              |
# --------------------------------------------------------------------------
# | CMPS, CMPU  | Compare memory from stack pointer                        |
# --------------------------------------------------------------------------
# | CMPX, CMPY  | Compare memory from index register                       |
# --------------------------------------------------------------------------
# | EXG R1, R2  | Exchange D, X, Y, S, U, or PC, with D, X, Y, S, U, or PC |
# --------------------------------------------------------------------------
# | LEAS, LEAU  | Load effective address into stack pointer                |
# --------------------------------------------------------------------------
# | LEAX, LEAY  | Load effective address into index register               |
# --------------------------------------------------------------------------
# | LDS, LDU    | Load stack pointer from memory                           |
# --------------------------------------------------------------------------
# | LDX, LDY    | Load index register from memory                          |
# --------------------------------------------------------------------------
# | PSHS        | Push A, B, CC, DP, D, X, Y, U, or PC onto hardware stack |
# --------------------------------------------------------------------------
# | PSHU        | Push A, B, CC, DP, D, X, Y, U, or PC onto user stack     |
# --------------------------------------------------------------------------
# | PULS        | Pull A, B, CC, DP, D, X, Y, U, or PC from hardware stack |
# --------------------------------------------------------------------------
# | PULU        | Pull A, B, CC, DP, D, X, Y, U, or PC from user stack     |
# --------------------------------------------------------------------------
# | STS, STU    | Store stack pointer to memory                            |
# --------------------------------------------------------------------------
# | STX, STY    | Store index register to memory                           |
# --------------------------------------------------------------------------
# | TFR R1, R2  | Transfer D, X, Y, S, U or PC to D, X, Y, S, U or PC      |
# --------------------------------------------------------------------------
# | ABX         | Add B accumulator to X (unsigned)                        |
# --------------------------------------------------------------------------
#
#
# TABLE 7 - BRANCH INSTRUCTIONS
# --------------------------------------------------------
# | Instruction | Description                            |
# --------------------------------------------------------
# |                   SIMPLE BRANCHES                    |
# --------------------------------------------------------
# | BEQ, LBEQ | Branch if equal                          |
# --------------------------------------------------------
# | BNE, LBNE | Branch if not equal                      |
# --------------------------------------------------------
# | BMI, LBMI | Branch if minus                          |
# --------------------------------------------------------
# | BPL, LBPL | Branch if plus                           |
# --------------------------------------------------------
# | BCS, LBCS | Branch if carry set                      |
# --------------------------------------------------------
# | BCC, LBCC | Branch if carry clear                    |
# --------------------------------------------------------
# | BVS, LBVS | Branch if overflow set                   |
# --------------------------------------------------------
# | BVC, LBVC | Branch if overflow clear                 |
# --------------------------------------------------------
# |                   SIGNED BRANCHES                    |
# --------------------------------------------------------
# | BGT, LBGT | Branch if greater (signed)               |
# --------------------------------------------------------
# | BVS, LBVS | Branch if invalid 2's complement result  |
# --------------------------------------------------------
# | BGE, LBGE | Branch if greater than or equal (signed) |
# --------------------------------------------------------
# | BEQ, LBEQ | Branch if equal                          |
# --------------------------------------------------------
# | BNE, LBNE | Branch if not equal                      |
# --------------------------------------------------------
# | BLE, LBLE | Branch if less than or equal (signed)    |
# --------------------------------------------------------
# | BVC, LBVC | Branch if valid 2's complement result    |
# --------------------------------------------------------
# | BLT, LBLT | Branch if less than (signed)             |
# --------------------------------------------------------
# |                  UNSIGNED BRANCHES                   |
# --------------------------------------------------------
# | BHI, LBHI | Branch if higher (unsigned)              |
# --------------------------------------------------------
# | BCC, LBCC | Branch if higher or same (unsigned)      |
# --------------------------------------------------------
# | BHS, LBHS | Branch if higher or same (unsigned)      |
# --------------------------------------------------------
# | BEQ, LBEQ | Branch if equal                          |
# --------------------------------------------------------
# | BNE, LBNE | Branch if not equal                      |
# --------------------------------------------------------
# | BLS, LBLS | Branch if lower or same (unsigned)       |
# --------------------------------------------------------
# | BCS, LBCS | Branch if lower (unsigned)               |
# --------------------------------------------------------
# | BLO, LBLO | Branch if lower (unsigned)               |
# --------------------------------------------------------
# |                    OTHER BRANCHES                    |
# --------------------------------------------------------
# | BSR, LBSR | Branch to subroutine                     |
# --------------------------------------------------------
# | BRA, LBRA | BRanch always                            |
# --------------------------------------------------------
# | BRN, LBRN | Branch never                             |
# --------------------------------------------------------
#
#
# TABLE 8 - MISCELLANEOUS INSTRUCTIONS
# --------------------------------------------------------------------------
# | Instruction     | Description                                          |
# --------------------------------------------------------------------------
# | ANDCC           | AND condition code register                          |
# --------------------------------------------------------------------------
# | CWAI            | AND condition code register, then wait for interrupt |
# --------------------------------------------------------------------------
# | NOP             | No operation                                         |
# --------------------------------------------------------------------------
# | ORCC            | OR condition code register                           |
# --------------------------------------------------------------------------
# | JMP             | Jump                                                 |
# --------------------------------------------------------------------------
# | JSR             | Jump to subroutine                                   |
# --------------------------------------------------------------------------
# | RTI             | Return from interrupt                                |
# --------------------------------------------------------------------------
# | RTS             | Return from subroutine                               |
# --------------------------------------------------------------------------
# | SWI, SWI2, SWI3 | Software interrupt (absolute indirect)               |
# --------------------------------------------------------------------------
# | SYNC            | Synchronize with interrupt line                      |
# --------------------------------------------------------------------------
#
#
# TABLE 9 - HEXADECIMAL VALUES OF MACHINE CODES
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------    LEGEND:
# | 00 | NEG        |  Direct   | 6    | 2  |
# | 01 | *          |     |     |      |    |    ~ Number of MPU cycles (less possible push pull or indexed-mode cycles)
# | 02 | *          |     |     |      |    |    # Number of program bytes
# | 03 | COM        |     |     | 6    | 2  |    * Denotes unused opcode
# | 04 | LSR        |     |     | 6    | 2  |
# | 05 | *          |     |     |      |    |    NOTE: All unused opcodes are both undefined and illegal
# | 06 | ROR        |     |     | 6    | 2  |
# | 07 | ASR        |     |     | 6    | 2  |
# | 08 | ASL, LSL   |     |     | 6    | 2  |
# | 09 | ROL        |     |     | 6    | 2  |
# | 0A | DEC        |     |     | 6    | 2  |
# | 0B | *          |     |     |      |    |
# | 0C | INC        |     |     | 6    | 2  |
# | 0D | TST        |     |     | 6    | 2  |
# | 0E | JMP        |     V     | 3    | 2  |
# | 0F | CLR        |  Direct   | 6    | 2  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 10 | Page 2                             |
# | 11 | Page 3                             |
# -------------------------------------------
# | 12 | NOP        | Inherent  | 2    | 1  |
# | 13 | SYNC       | Inherent  | >= 4 | 1  |
# | 14 | *          |           |      |    |
# | 15 | *          |           |      |    |
# | 16 | LBRA       | Relative  | 5    | 3  |
# | 17 | LBSR       | Relative  | 9    | 3  |
# | 18 | *          |           |      |    |
# | 19 | DAA        | Inherent  | 2    | 1  |
# | 1A | ORCC       | Immediate | 3    | 2  |
# | 1B | *          |           |      |    |
# | 1C | ANDCC      | Immediate | 3    | 2  |
# | 1D | SEX        | Inherent  | 2    | 1  |
# | 1E | EXG        |     V     | 8    | 2  |
# | 1F | TFR        | Inherent  | 6    | 2  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 20 | BRA        | Relative  | 3    | 2  |
# | 21 | BRN        |     |     | 3    | 2  |
# | 22 | BHI        |     |     | 3    | 2  |
# | 23 | BLS        |     |     | 3    | 2  |
# | 24 | BHS, BCC   |     |     | 3    | 2  |
# | 25 | BLO, BCS   |     |     | 3    | 2  |
# | 26 | BNE        |     |     | 3    | 2  |
# | 27 | BEQ        |     |     | 3    | 2  |
# | 28 | BVC        |     |     | 3    | 2  |
# | 29 | BVS        |     |     | 3    | 2  |
# | 2A | BPL        |     |     | 3    | 2  |
# | 2B | BMI        |     |     | 3    | 2  |
# | 2C | BGE        |     |     | 3    | 2  |
# | 2D | BLT        |     |     | 3    | 2  |
# | 2E | BGT        |     V     | 3    | 2  |
# | 2F | BLE        | Relative  | 3    | 2  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 30 | LEAX       |  Indexed  | 4+   | 2+ |
# | 31 | LEAY       |     |     | 4+   | 2+ |
# | 32 | LEAS       |     V     | 4+   | 2+ |
# | 33 | LEAU       |  Indexed  | 4+   | 2+ |
# | 34 | PSHS       | Inherent  | 5+   | 2  |
# | 35 | PULS       |     |     | 5+   | 2  |
# | 36 | PSHU       |     |     | 5+   | 2  |
# | 37 | PULU       |     |     | 5+   | 2  |
# | 38 | *          |     |     |      |    |
# | 39 | RTS        |     |     | 5    | 1  |
# | 3A | ABX        |     |     | 3    | 1  |
# | 3B | RTI        |     |     | 6/15 | 1  |
# | 3C | CWAI       |     |     | >=20 | 2  |
# | 3D | MUL        |     |     | 11   | 1  |
# | 3E | *          |     V     |      |    |
# | 3F | SWI        | Inherent  | 19   | 1  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 40 | NEGA       | Inherent  | 2    | 1  |
# | 41 | *          |     |     |      |    |
# | 42 | *          |     |     |      |    |
# | 43 | COMA       |     |     | 2    | 1  |
# | 44 | LSRA       |     |     | 2    | 1  |
# | 45 | *          |     |     |      |    |
# | 46 | RORA       |     |     | 2    | 1  |
# | 47 | ASRA       |     |     | 2    | 1  |
# | 48 | ASLA, LSLA |     |     | 2    | 1  |
# | 49 | ROLA       |     |     | 2    | 1  |
# | 4A | DECA       |     |     | 2    | 1  |
# | 4B | *          |     |     |      |    |
# | 4C | INCA       |     |     | 2    | 1  |
# | 4D | TSTA       |     |     | 2    | 1  |
# | 4E | *          |     V     |      |    |
# | 4F | CLRA       | Inherent  | 2    | 1  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 50 | NEGB       | Inherent  | 2    | 1  |
# | 51 | *          |     |     |      |    |
# | 52 | *          |     |     |      |    |
# | 53 | COMB       |     |     | 2    | 1  |
# | 54 | LSRB       |     |     | 2    | 1  |
# | 55 | *          |     |     |      |    |
# | 56 | RORB       |     |     | 2    | 1  |
# | 57 | ASRB       |     |     | 2    | 1  |
# | 58 | ASLB, LSLB |     |     | 2    | 1  |
# | 59 | ROLB       |     |     | 2    | 1  |
# | 5A | DECB       |     |     | 2    | 1  |
# | 5B | *          |     |     |      |    |
# | 5C | INCB       |     |     | 2    | 1  |
# | 5D | TSTB       |     |     | 2    | 1  |
# | 5E | *          |     V     |      |    |
# | 5F | CLRB       | Inherent  | 2    | 1  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 60 | NEG        |  Indexed  | 6+   | 2+ |
# | 61 | *          |     |     |      |    |
# | 62 | *          |     |     |      |    |
# | 63 | COM        |     |     | 6+   | 2+ |
# | 64 | LSR        |     |     | 6+   | 2+ |
# | 65 | *          |     |     |      |    |
# | 66 | ROR        |     |     | 6+   | 2+ |
# | 67 | ASR        |     |     | 6+   | 2+ |
# | 68 | ASL, LSL   |     |     | 6+   | 2+ |
# | 69 | ROL        |     |     | 6+   | 2+ |
# | 6A | DEC        |     |     | 6+   | 2+ |
# | 6B | *          |     |     |      |    |
# | 6C | INC        |     |     | 6+   | 2+ |
# | 6D | TST        |     |     | 6+   | 2+ |
# | 6E | JMP        |     V     | 3+   | 2+ |
# | 6F | CLR        |  Indexed  | 6+   | 2+ |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 70 | NEG        |  Extended | 7    | 3  |
# | 71 | *          |     |     |      |    |
# | 72 | *          |     |     |      |    |
# | 73 | COM        |     |     | 7    | 3  |
# | 74 | LSR        |     |     | 7    | 3  |
# | 75 | *          |     |     |      |    |
# | 76 | ROR        |     |     | 7    | 3  |
# | 77 | ASR        |     |     | 7    | 3  |
# | 78 | ASL, LSL   |     |     | 7    | 3  |
# | 79 | ROL        |     |     | 7    | 3  |
# | 7A | DEC        |     |     | 7    | 3  |
# | 7B | *          |     |     |      |    |
# | 7C | INC        |     |     | 7    | 3  |
# | 7D | TST        |     |     | 7    | 3  |
# | 7E | JMP        |     V     | 4    | 3  |
# | 7F | CLR        |  Extended | 7    | 3  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 80 | SUBA       | Immediate | 2    | 2  |
# | 81 | CMPA       |     |     | 2    | 2  |
# | 82 | SBCA       |     |     | 2    | 2  |
# | 83 | SUBD       |     |     | 4    | 3  |
# | 84 | ANDA       |     |     | 2    | 2  |
# | 85 | BITA       |     |     | 2    | 2  |
# | 86 | LDA        |     |     | 2    | 2  |
# | 87 | *          |     |     |      |    |
# | 88 | EORA       |     |     | 2    | 2  |
# | 89 | ADCA       |     |     | 2    | 2  |
# | 8A | ORA        |     |     | 2    | 2  |
# | 8B | ADDA       |     V     | 2    | 2  |
# | 8C | CMPX       | Immediate | 4    | 3  |
# | 8D | BSR        | Relative  | 7    | 2  |
# | 8E | LDX        | Immediate | 3    | 3  |
# | 8F | *          |           |      |    |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | 90 | SUBA       |  Direct   | 4    | 2  |
# | 91 | CMPA       |     |     | 4    | 2  |
# | 92 | SBCA       |     |     | 4    | 2  |
# | 93 | SUBD       |     |     | 6    | 2  |
# | 94 | ANDA       |     |     | 4    | 2  |
# | 95 | BITA       |     |     | 4    | 2  |
# | 96 | LDA        |     |     | 4    | 2  |
# | 97 | STA        |     |     | 4    | 2  |
# | 98 | EORA       |     |     | 4    | 2  |
# | 99 | ADCA       |     |     | 4    | 2  |
# | 9A | ORA        |     |     | 4    | 2  |
# | 9B | ADDA       |     |     | 4    | 2  |
# | 9C | CMPX       |     |     | 6    | 2  |
# | 9D | JSR        |     |     | 7    | 2  |
# | 9E | LDX        |     V     | 5    | 2  |
# | 9F | STX        |  Direct   | 5    | 2  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | A0 | SUBA       |  Indexed  | 4+   | 2+ |
# | A1 | CMPA       |     |     | 4+   | 2+ |
# | A2 | SBCA       |     |     | 4+   | 2+ |
# | A3 | SUBD       |     |     | 6+   | 2+ |
# | A4 | ANDA       |     |     | 4+   | 2+ |
# | A5 | BITA       |     |     | 4+   | 2+ |
# | A6 | LDA        |     |     | 4+   | 2+ |
# | A7 | STA        |     |     | 4+   | 2+ |
# | A8 | EORA       |     |     | 4+   | 2+ |
# | A9 | ADCA       |     |     | 4+   | 2+ |
# | AA | ORA        |     |     | 4+   | 2+ |
# | AB | ADDA       |     |     | 4+   | 2+ |
# | AC | CMPX       |     |     | 6+   | 2+ |
# | AD | JSR        |     |     | 7+   | 2+ |
# | AE | LDX        |     V     | 5+   | 2+ |
# | AF | STX        |  Indexed  | 5+   | 2+ |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | B0 | SUBA       |  Extended | 5    | 3  |
# | B1 | CMPA       |     |     | 5    | 3  |
# | B2 | SBCA       |     |     | 5    | 3  |
# | B3 | SUBD       |     |     | 7    | 3  |
# | B4 | ANDA       |     |     | 5    | 3  |
# | B5 | BITA       |     |     | 5    | 3  |
# | B6 | LDA        |     |     | 5    | 3  |
# | B7 | STA        |     |     | 5    | 3  |
# | B8 | EORA       |     |     | 5    | 3  |
# | B9 | ADCA       |     |     | 5    | 3  |
# | BA | ORA        |     |     | 5    | 3  |
# | BB | ADDA       |     |     | 5    | 3  |
# | BC | CMPX       |     |     | 7    | 3  |
# | BD | JSR        |     |     | 8    | 3  |
# | BE | LDX        |     V     | 6    | 3  |
# | BF | STX        |  Extended | 6    | 3  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | C0 | SUBB       | Immediate | 2    | 2  |
# | C1 | CMPB       |     |     | 2    | 2  |
# | C2 | SBCB       |     |     | 2    | 2  |
# | C3 | ADDD       |     |     | 4    | 3  |
# | C4 | ANDB       |     |     | 2    | 2  |
# | C5 | BITB       |     |     | 2    | 2  |
# | C6 | LDB        |     |     | 2    | 2  |
# | C7 | *          |     |     |      |    |
# | C8 | EORB       |     |     | 2    | 2  |
# | C9 | ADCB       |     |     | 2    | 2  |
# | CA | ORB        |     |     | 2    | 2  |
# | CB | ADDB       |     |     | 2    | 2  |
# | CC | LDD        |     |     | 3    | 3  |
# | CD | *          |     V     |      |    |
# | CE | LDU        | Immediate | 3    | 3  |
# | CF | *          |           |      |    |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | D0 | SUBB       |  Direct   | 4    | 2  |
# | D1 | CMPB       |     |     | 4    | 2  |
# | D2 | SBCB       |     |     | 4    | 2  |
# | D3 | ADDD       |     |     | 6    | 2  |
# | D4 | ANDB       |     |     | 4    | 2  |
# | D5 | BITB       |     |     | 4    | 2  |
# | D6 | LDB        |     |     | 4    | 2  |
# | D7 | STB        |     |     | 4    | 2  |
# | D8 | EORB       |     |     | 4    | 2  |
# | D9 | ADCB       |     |     | 4    | 2  |
# | DA | ORB        |     |     | 4    | 2  |
# | DB | ADDB       |     |     | 4    | 2  |
# | DC | LDD        |     |     | 5    | 2  |
# | DD | STD        |     |     | 5    | 2  |
# | DE | LDU        |     V     | 5    | 2  |
# | DF | STU        |  Direct   | 5    | 2  |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | E0 | SUBB       |  Indexed  | 4+   | 2+ |
# | E1 | CMPB       |     |     | 4+   | 2+ |
# | E2 | SBCB       |     |     | 4+   | 2+ |
# | E3 | ADDD       |     |     | 6+   | 2+ |
# | E4 | ANDB       |     |     | 4+   | 2+ |
# | E5 | BITB       |     |     | 4+   | 2+ |
# | E6 | LDB        |     |     | 4+   | 2+ |
# | E7 | STB        |     |     | 4+   | 2+ |
# | E8 | EORB       |     |     | 4+   | 2+ |
# | E9 | ADCB       |     |     | 4+   | 2+ |
# | EA | ORB        |     |     | 4+   | 2+ |
# | EB | ADDB       |     |     | 4+   | 2+ |
# | EC | LDD        |     |     | 5+   | 2+ |
# | ED | STD        |     |     | 5+   | 2+ |
# | EE | LDU        |     V     | 5+   | 2+ |
# | EF | STU        |  Indexed  | 5+   | 2+ |
# -------------------------------------------
# | OP | Mnem       |   Mode    | ~    | #  |
# -------------------------------------------
# | F0 | SUBB       |  Extended | 5    | 3  |
# | F1 | CMPB       |     |     | 5    | 3  |
# | F2 | SBCB       |     |     | 5    | 3  |
# | F3 | ADDD       |     |     | 7    | 3  |
# | F4 | ANDB       |     |     | 5    | 3  |
# | F5 | BITB       |     |     | 5    | 3  |
# | F6 | LDB        |     |     | 5    | 3  |
# | F7 | STB        |     |     | 5    | 3  |
# | F8 | EORB       |     |     | 5    | 3  |
# | F9 | ADCB       |     |     | 5    | 3  |
# | FA | ORB        |     |     | 5    | 3  |
# | FB | ADDB       |     |     | 5    | 3  |
# | FC | LDD        |     |     | 6    | 3  |
# | FD | STD        |     |     | 6    | 3  |
# | FE | LDU        |     V     | 6    | 3  |
# | FF | STU        |  Extended | 6    | 3  |
# -------------------------------------------
#
# Page 2 and 3 Machine Codes
# ---------------------------------------------
# |  OP  | Mnem       |   Mode    | ~    | #  |
# ---------------------------------------------
# | 1021 | LBRN       | Relative  | 5    | 4  |
# | 1022 | LBHI       |     |     | 5(6) | 4  |
# | 1023 | LBLS       |     |     | 5(6) | 4  |
# | 1024 | LBHS, LBCC |     |     | 5(6) | 4  |
# | 1025 | LBCS, LBLO |     |     | 5(6) | 4  |
# | 1026 | LBNE       |     |     | 5(6) | 4  |
# | 1027 | LBEQ       |     |     | 5(6) | 4  |
# | 1028 | LBVC       |     |     | 5(6) | 4  |
# | 1029 | LBVS       |     |     | 5(6) | 4  |
# | 102A | LBPL       |     |     | 5(6) | 4  |
# | 102B | LBMI       |     |     | 5(6) | 4  |
# | 102C | LBGE       |     |     | 5(6) | 4  |
# | 102D | LBLT       |     |     | 5(6) | 4  |
# | 102E | LBGT       |     V     | 5(6) | 4  |
# | 102F | LBLE       | Relative  | 5(6) | 4  |
# | 103F | SWI2       | Inherent  | 20   | 2  |
# ---------------------------------------------
# |  OP  | Mnem       |   Mode    | ~    | #  |
# ---------------------------------------------
# | 1083 | CMPD       | Immediate | 5    | 4  |
# | 108C | CMPY       |     V     | 5    | 4  |
# | 108E | LDY        | Immediate | 4    | 4  |
# | 1093 | CMPD       |  Direct   | 7    | 3  |
# | 109C | CMPY       |     |     | 7    | 3  |
# | 109E | LDY        |     V     | 6    | 3  |
# | 109F | STY        |  Direct   | 6    | 3  |
# | 10A3 | CMPD       |  Indexed  | 7+   | 3+ |
# | 10AC | CMPY       |     |     | 7+   | 3+ |
# | 10AE | LDY        |     V     | 6+   | 3+ |
# | 10AF | STY        |  Indexed  | 6+   | 3+ |
# | 10B3 | CMPD       |  Extended | 8    | 4  |
# | 10BC | CMPY       |     |     | 8    | 4  |
# | 10BE | LDY        |     V     | 7    | 4  |
# | 10BF | STY        |  Extended | 7    | 4  |
# | 10CE | LDS        | Immediate | 4    | 4  |
# ---------------------------------------------
# |  OP  | Mnem       |   Mode    | ~    | #  |
# ---------------------------------------------
# | 10DE | LDS        |  Direct   | 6    | 3  |
# | 10DF | STS        |  Direct   | 6    | 3  |
# | 10EE | LDS        |  Indexed  | 6+   | 3+ |
# | 10EF | STS        |  Indexed  | 6+   | 3+ |
# | 10FE | LDS        |  Extended | 7    | 4  |
# | 10FF | STS        |  Extended | 7    | 4  |
# | 113F | SWI3       | Inherent  | 20   | 2  |
# | 1183 | CMPU       | Immediate | 5    | 4  |
# | 118C | CMPS       | Immediate | 7    | 3  |
# | 1193 | CMPU       |  Direct   | 7    | 3  |
# | 119C | CMPS       |  Direct   | 7    | 3  |
# | 11A3 | CMPU       |  Indexed  | 7+   | 3+ |
# | 11AC | CMPS       |  Indexed  | 7+   | 3+ |
# | 11B3 | CMPU       |  Extended | 8    | 4  |
# | 11BC | CMPS       |  Extended | 8    | 4  |
# ---------------------------------------------
#
#
# FIGURE 20 - PROGRAMMING AID
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# |             |        |                              Addressing Modes                                  |                                   |   |   |   |   |   |
# |             |        ----------------------------------------------------------------------------------                                   |   |   |   |   |   |
# |             |        |    Immediate    |    Direct    |    Indexed     |   Extended   |   Inherent    |                                   | 5 | 3 | 2 | 1 | 0 |
# |             |        ----------------------------------------------------------------------------------                                   ---------------------
# | Instruction | Forms  |  Op  | ~    | # |  Op  | ~ | # |  Op  | ~  | #  |  Op  | ~ | # |  Op  | ~  | # |      Description                  | H | N | Z | V | C |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ABX         |        |      |      |   |      |   |   |      |    |    |      |   |   |  3A  | 3  | 1 | B + X -> X (Unsigned)             | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ADC         | ADCA   |  89  |  2   | 2 |  99  | 4 | 2 |  A9  | 4+ | 2+ |  B9  | 5 | 3 |      |    |   | A + M + C -> A                    | | | | | | | | | | |
# |             | ADCB   |  C9  |  2   | 2 |  D9  | 4 | 2 |  E9  | 4+ | 2+ |  F9  | 5 | 3 |      |    |   | B + M + C -> B                    | | | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ADD         | ADDA   |  8B  |  2   | 2 |  9B  | 4 | 2 |  AB  | 4+ | 2+ |  BB  | 5 | 3 |      |    |   | A + M -> A                        | | | | | | | | | | |
# |             | ADDB   |  CB  |  2   | 2 |  DB  | 4 | 2 |  EB  | 4+ | 2+ |  FB  | 5 | 3 |      |    |   | B + M -> B                        | | | | | | | | | | |
# |             | ADDD   |  C3  |  4   | 3 |  D3  | 6 | 2 |  E3  | 6+ | 2+ |  F3  | 7 | 3 |      |    |   | D + M : M + 1 -> D                | * | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | AND         | ANDA   |  84  |  2   | 2 |  94  | 4 | 2 |  A4  | 4+ | 2+ |  B4  | 5 | 3 |      |    |   | A ∧ M -> A                        | * | | | | | 0 | * |
# |             | ANDB   |  C4  |  2   | 2 |  D4  | 4 | 2 |  E4  | 4+ | 2+ |  F4  | 5 | 3 |      |    |   | B ∧ M -> B                        | * | | | | | 0 | * |
# |             | ANDCC  |  1C  |  3   | 2 |      |   |   |      |    |    |      |   |   |      |    |   | CC ∧ |MM -> CC                    |   |   |   |   | 7 |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ASL         | ASLA   |      |      |   |      |   |   |      |    |    |      |   |   |  48  | 2  | 1 | See Diagram 1 Below               | 8 | | | | | | | | |
# |             | ASLB   |      |      |   |      |   |   |      |    |    |      |   |   |  58  | 2  | 1 |                                   | 8 | | | | | | | | |
# |             | ASL    |      |      |   |  08  | 6 | 2 |  68  | 6+ | 2+ |  78  | 7 | 3 |      |    |   |                                   | 8 | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ASR         | ASRA   |      |      |   |      |   |   |      |    |    |      |   |   |  47  | 2  | 1 | See Diagram 2 Below               | 8 | | | | | * | | |
# |             | ASRB   |      |      |   |      |   |   |      |    |    |      |   |   |  57  | 2  | 1 |                                   | 8 | | | | | * | | |
# |             | ASR    |      |      |   |  07  | 6 | 2 |  67  | 6+ | 2+ |  77  | 7 | 3 |      |    |   |                                   | 8 | | | | | * | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | BIT         | BITA   |  85  |  2   | 2 |  95  | 4 | 2 |  A5  | 4+ | 2+ |  B5  | 5 | 3 |      |    |   | Bit Test A (M ∧ A)                | * | | | | | 0 | * |
# |             | BITB   |  C5  |  2   | 2 |  D5  | 4 | 2 |  E5  | 4+ | 2+ |  F5  | 5 | 3 |      |    |   | Bit Test B (M ∧ B)                | * | | | | | 0 | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | CLR         | CLRA   |      |      |   |      |   |   |      |    |    |      |   |   |  4F  | 2  | 1 | 0 -> A                            | * | 0 | 1 | 0 | 0 |
# |             | CLRB   |      |      |   |      |   |   |      |    |    |      |   |   |  5F  | 2  | 1 | 0 -> B                            | * | 0 | 1 | 0 | 0 |
# |             | CLR    |      |      |   |  0F  | 6 | 2 |  6F  | 6+ | 2+ |  7F  | 7 | 3 |      |    |   | 0 -> M                            | * | 0 | 1 | 0 | 0 |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | CMP         | CMPA   |  81  |  2   | 2 |  91  | 4 | 2 |  A1  | 4+ | 2+ |  B1  | 5 | 3 |      |    |   | Compare M from A                  | 8 | | | | | | | | |
# |             | CMPB   |  C1  |  2   | 2 |  D1  | 4 | 2 |  E1  | 4+ | 2+ |  F1  | 5 | 3 |      |    |   | Compare M from B                  | 8 | | | | | | | | |
# |             | CMPD   | 1083 |  5   | 4 | 1093 | 7 | 3 | 10A3 | 7+ | 3+ | 10B3 | 8 | 4 |      |    |   | Compare M : M + 1 from D          | * | | | | | | | | |
# |             | CMPS   | 118C |  5   | 4 | 119C | 7 | 3 | 11AC | 7+ | 3+ | 11BC | 8 | 4 |      |    |   | Compare M : M + 1 from S          | * | | | | | | | | |
# |             | CMPU   | 1183 |  5   | 4 | 1193 | 7 | 3 | 11A3 | 7+ | 3+ | 11B3 | 8 | 4 |      |    |   | Compare M : M + 1 from U          | * | | | | | | | | |
# |             | CMPX   |  8C  |  4   | 3 |  9C  | 6 | 2 |  AC  | 6+ | 2+ |  BC  | 7 | 3 |      |    |   | Compare M : M + 1 from X          | * | | | | | | | | |
# |             | CMPY   | 108C |  5   | 4 | 109C | 7 | 3 | 10AC | 7+ | 3+ | 10BC | 8 | 4 |      |    |   | Compare M : M + 1 from Y          | * | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | COM         | COMA   |      |      |   |      |   |   |      |    |    |      |   |   |  43  | 2  | 1 | (A) -> A                          | * | | | | | 0 | 1 |
# |             | COMB   |      |      |   |      |   |   |      |    |    |      |   |   |  53  | 2  | 1 | (B) -> B                          | * | | | | | 0 | 1 |
# |             | COM    |      |      |   |  03  | 6 | 2 |  63  | 6+ | 2+ |  73  | 7 | 3 |      |    |   | (M) -> M                          | * | | | | | 0 | 1 |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | CWAI        |        |  3C  | >=20 | 2 |      |   |   |      |    |    |      |   |   |      |    |   | CC ∧ |MM -> CC Wait for interrupt |   |   |   |   | 7 |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | DAA         |        |      |      |   |      |   |   |      |    |    |      |   |   |  19  | 2  | 1 | Decimal Adjust A                  | * | | | | | 0 | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | DEC         | DECA   |      |      |   |      |   |   |      |    |    |      |   |   |  4A  | 2  | 1 | A - 1 -> A                        | * | | | | | | | * |
# |             | DECB   |      |      |   |      |   |   |      |    |    |      |   |   |  5A  | 2  | 1 | B - 1 -> B                        | * | | | | | | | * |
# |             | DEC    |      |      |   |  0A  | 6 | 2 |  6A  | 6+ | 2+ |  7A  | 7 | 3 |      |    |   | M - 1 -> M                        | * | | | | | | | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | EOR         | EORA   |  88  |  2   | 2 |  98  | 4 | 2 |  A8  | 4+ | 2+ |  B8  | 5 | 3 |      |    |   | A ⊻ M -> A                        | * | | | | | 0 | * |
# |             | EORB   |  C8  |  2   | 2 |  D8  | 4 | 2 |  E8  | 4+ | 2+ |  F8  | 5 | 3 |      |    |   | B ⊻ M -> B                        | * | | | | | 0 | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | EXG         | R1, R2 |      |      |   |      |   |   |      |    |    |      |   |   |  1E  | 8  | 2 | R1 <-> R2 (2)                     | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | INC         | INCA   |      |      |   |      |   |   |      |    |    |      |   |   |  4C  | 2  | 1 | A + 1 -> A                        | * | | | | | | | * |
# |             | INCB   |      |      |   |      |   |   |      |    |    |      |   |   |  5C  | 2  | 1 | B + 1 -> B                        | * | | | | | | | * |
# |             | INC    |      |      |   |  0C  | 6 | 2 |  6C  | 6+ | 2+ |  7C  | 7 | 3 |      |    |   | M + 1 -> M                        | * | | | | | | | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | JMP         |        |      |      |   |  0E  | 3 | 2 |  6E  | 3+ | 2+ |  7E  | 4 | 3 |      |    |   | EA (3) -> PC                      | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | JSR         |        |      |      |   |  9D  | 7 | 2 |  AD  | 7+ | 2+ |  BD  | 8 | 3 |      |    |   | Jump to Subroutine                | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | LD          | LDA    |  86  |  2   | 2 |  96  | 4 | 2 |  A6  | 4+ | 2+ |  B6  | 5 | 3 |      |    |   | M -> A                            | * | | | | | 0 | * |
# |             | LDB    |  C6  |  2   | 2 |  D6  | 4 | 2 |  E6  | 4+ | 2+ |  F6  | 5 | 3 |      |    |   | M -> B                            | * | | | | | 0 | * |
# |             | LDD    |  CC  |  3   | 3 |  DC  | 5 | 2 |  EC  | 5+ | 2+ |  FC  | 6 | 3 |      |    |   | M : M + 1 -> D                    | * | | | | | 0 | * |
# |             | LDS    | 10CE |  4   | 4 | 10DE | 6 | 3 | 10EE | 6+ | 3+ | 10FE | 7 | 4 |      |    |   | M : M + 1 -> S                    | * | | | | | 0 | * |
# |             | LDU    |  CE  |  3   | 3 |  DE  | 5 | 2 |  EE  | 5+ | 2+ |  FE  | 6 | 3 |      |    |   | M : M + 1 -> U                    | * | | | | | 0 | * |
# |             | LDX    |  8E  |  3   | 3 |  9E  | 5 | 2 |  AE  | 5+ | 2+ |  BE  | 6 | 3 |      |    |   | M : M + 1 -> X                    | * | | | | | 0 | * |
# |             | LDY    | 108E |  4   | 4 | 109E | 6 | 3 | 10AE | 6+ | 3+ | 10BE | 7 | 4 |      |    |   | M : M + 1 => Y                    | * | | | | | 0 | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | LEA         | LEAS   |      |      |   |      |   |   |  32  | 4+ | 2+ |      |   |   |      |    |   | EA (3) -> S                       | * | * | * | * | * |
# |             | LEAU   |      |      |   |      |   |   |  33  | 4+ | 2+ |      |   |   |      |    |   | EA (3) -> U                       | * | * | * | * | * |
# |             | LEAX   |      |      |   |      |   |   |  30  | 4+ | 2+ |      |   |   |      |    |   | EA (3) -> X                       | * | * | | | * | * |
# |             | LEAY   |      |      |   |      |   |   |  31  | 4+ | 2+ |      |   |   |      |    |   | EA (3) -> Y                       | * | * | | | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | LSL         | LSLA   |      |      |   |      |   |   |      |    |    |      |   |   |  48  | 2  | 1 | See Diagram 3 Below               | * | | | | | | | | |
# |             | LSLB   |      |      |   |      |   |   |      |    |    |      |   |   |  58  | 2  | 1 |                                   | * | | | | | | | | |
# |             | LSL    |      |      |   |  08  | 6 | 2 |  68  | 6+ | 2+ |  78  | 7 | 3 |      |    |   |                                   | * | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | LSR         | LSRA   |      |      |   |      |   |   |      |    |    |      |   |   |  44  | 2  | 1 | See Diagram 4 Below               | * | 0 | | | * | | |
# |             | LSRB   |      |      |   |      |   |   |      |    |    |      |   |   |  54  | 2  | 1 |                                   | * | 0 | | | * | | |
# |             | LSR    |      |      |   |  04  | 6 | 2 |  64  | 6+ | 2+ |  74  | 7 | 3 |      |    |   |                                   | * | 0 | | | * | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | MUL         |        |      |      |   |      |   |   |      |    |    |      |   |   |  3D  | 11 | 1 | A x B -> D (Unsigned)             | * | * | | | * | 9 |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | NEG         | NEGA   |      |      |   |      |   |   |      |    |    |      |   |   |  40  | 2  | 1 | (A) + 1 -> A                      | 8 | | | | | | | | |
# |             | NEGB   |      |      |   |      |   |   |      |    |    |      |   |   |  50  | 2  | 1 | (B) + 1 -> B                      | 8 | | | | | | | | |
# |             | NEG    |      |      |   |  00  | 6 | 2 |  60  | 6+ | 2+ |  70  | 7 | 3 |      |    |   | (M) + 1 -> M                      | 8 | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | NOP         |        |      |      |   |      |   |   |      |    |    |      |   |   |  12  | 2  | 1 | No Operation                      | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | OR          | ORA    |  8A  |  2   | 2 |  9A  | 4 | 2 |  AA  | 4+ | 2+ |  BA  | 5 | 3 |      |    |   | A ∨ M -> A                        | * | | | | | 0 | * |
# |             | ORB    |  CA  |  2   | 2 |  DA  | 4 | 2 |  EA  | 4+ | 2+ |  FA  | 5 | 3 |      |    |   | B ∨ M -> B                        | * | | | | | 0 | * |
# |             | ORCC   |  1A  |  3   | 2 |      |   |   |      |    |    |      |   |   |      |    |   | CC ∨ |MM -> CC                    |   |   |   | 7 |   |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | PSH         | PSHS   |  34  | 5+(4)| 2 |      |   |   |      |    |    |      |   |   |      |    |   | Push Registers on S Stack         | * | * | * | * | * |
# |             | PSHU   |  36  | 5+(4)| 2 |      |   |   |      |    |    |      |   |   |      |    |   | Push Registers on U Stack         | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | PUL         | PULS   |  35  | 5+(4)| 2 |      |   |   |      |    |    |      |   |   |      |    |   | Pull Registers from S Stack       | * | * | * | * | * |
# |             | PULU   |  37  | 5+(4)| 2 |      |   |   |      |    |    |      |   |   |      |    |   | Pull Registers from U Stack       | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ROL         | ROLA   |      |      |   |      |   |   |      |    |    |      |   |   |  49  | 2  | 1 | See Diagram 5 Below               | * | | | | | | | | |
# |             | ROLB   |      |      |   |      |   |   |      |    |    |      |   |   |  59  | 2  | 1 |                                   | * | | | | | | | | |
# |             | ROL    |      |      |   |  09  | 6 | 2 |  69  | 6+ | 2+ |  79  | 7 | 3 |      |    |   |                                   | * | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ROR         | RORA   |      |      |   |      |   |   |      |    |    |      |   |   |  46  | 2  | 1 | See Diagram 6 Below               | * | | | | | * | | |
# |             | RORB   |      |      |   |      |   |   |      |    |    |      |   |   |  56  | 2  | 1 |                                   | * | | | | | * | | |
# |             | ROR    |      |      |   |  06  | 6 | 2 |  66  | 6+ | 2+ |  76  | 7 | 3 |      |    |   |                                   | * | | | | | * | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | RTI         |        |      |      |   |      |   |   |      |    |    |      |   |   |  3B  |6/15| 1 | Return From Interrupt             |   |   |   |   | 7 |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | RTS         |        |      |      |   |      |   |   |      |    |    |      |   |   |  39  | 5  | 1 | Return From Subroutine            | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | SBC         | SBCA   |  82  |  2   | 2 |  92  | 4 | 2 |  A2  | 4+ | 2+ |  B2  | 5 | 3 |      |    |   | A - M - C -> A                    | 8 | | | | | | | | |
# |             | SBCB   |  C2  |  2   | 2 |  D2  | 4 | 2 |  E2  | 4+ | 2+ |  F2  | 5 | 3 |      |    |   | B - M - C -> B                    | 8 | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | SEX         |        |      |      |   |      |   |   |      |    |    |      |   |   |  1D  | 2  | 1 | Sign Extend B into A              | * | | | | | 0 | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | ST          | STA    |      |      |   |  97  | 4 | 2 |  A7  | 4+ | 2+ |  B7  | 5 | 3 |      |    |   | A -> M                            | * | | | | | 0 | * |
# |             | STB    |      |      |   |  D7  | 4 | 2 |  E7  | 4+ | 2+ |  F7  | 5 | 3 |      |    |   | B -> M                            | * | | | | | 0 | * |
# |             | STD    |      |      |   |  DD  | 5 | 2 |  ED  | 5+ | 2+ |  FD  | 6 | 3 |      |    |   | D -> M : M + 1                    | * | | | | | 0 | * |
# |             | STS    |      |      |   | 10DF | 6 | 3 | 10EF | 6+ | 3+ | 10FF | 7 | 4 |      |    |   | S -> M : M + 1                    | * | | | | | 0 | * |
# |             | STU    |      |      |   |  DF  | 5 | 2 |  EF  | 5+ | 2+ |  FF  | 6 | 3 |      |    |   | U -> M : M + 1                    | * | | | | | 0 | * |
# |             | STX    |      |      |   |  9F  | 5 | 2 |  AF  | 5+ | 2+ |  BF  | 6 | 3 |      |    |   | X -> M : M + 1                    | * | | | | | 0 | * |
# |             | STY    |      |      |   | 109F | 6 | 3 | 10AF | 6+ | 3+ | 10BF | 7 | 4 |      |    |   | Y -> M : M + 1                    | * | | | | | 0 | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | SUB         | SUBA   |  80  |  2   | 2 |  90  | 4 | 2 |  A0  | 4+ | 2+ |  B0  | 5 | 3 |      |    |   | A - M -> A                        | 8 | | | | | | | | |
# |             | SUBB   |  C0  |  2   | 2 |  D0  | 4 | 2 |  E0  | 4+ | 2+ |  F0  | 5 | 3 |      |    |   | B - M -> B                        | 8 | | | | | | | | |
# |             | SUBD   |  83  |  4   | 3 |  93  | 6 | 2 |  A3  | 6+ | 2+ |  B3  | 7 | 3 |      |    |   | D - M : M + 1 -> D                | * | | | | | | | | |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | SWI         | SWI(6) |      |      |   |      |   |   |      |    |    |      |   |   |  3F  | 19 | 1 | Software Interrupt 1              | * | * | * | * | * |
# |             | SWI(6) |      |      |   |      |   |   |      |    |    |      |   |   | 103F | 20 | 2 | Software Interrupt 2              | * | * | * | * | * |
# |             | SWI(6) |      |      |   |      |   |   |      |    |    |      |   |   | 113F | 20 | 1 | Software Interrupt 3              | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | SYNC        |        |      |      |   |      |   |   |      |    |    |      |   |   |  13  | >=4| 1 | Synchronize to Interrupt          | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | TFR         | R1, R2 |      |      |   |      |   |   |      |    |    |      |   |   |  1F  | 6  | 2 | R1 -> R2 (2)                      | * | * | * | * | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
# | TST         | TSTA   |      |      |   |      |   |   |      |    |    |      |   |   |  4D  | 2  | 1 | Test A                            | * | | | | | 0 | * |
# |             | TSTB   |      |      |   |      |   |   |      |    |    |      |   |   |  5D  | 2  | 1 | Test B                            | * | | | | | 0 | * |
# |             | TST    |      |      |   |  0D  | 6 | 2 |  6D  | 6+ | 2+ |  7D  | 7 | 3 |      |    |   | Test M                            | * | | | | | 0 | * |
# -----------------------------------------------------------------------------------------------------------------------------------------------------------------
#
#
# Diagram 1                              Diagram 3                              Diagram 5
#                   <------                                <------                    ________________________________
# A \   ___    _________________         A \   ___    _________________         A \   |   ___    _________________   |
# B |-  | | <- | | | | | | | | | <- 0    B |-  | | <- | | | | | | | | | <- 0    B |-  --- | | <- | | | | | | | | | <--
# M /   ---    -----------------         M /   ---    -----------------         M /       ---    -----------------
#        C     b7             b0                C     b7             b0                    C     b7             b0
#
#
# Diagram 2                              Diagram 4                              Diagram 6
#       _____       ------>                                ------>                    ________________________________
# A \   |   _________________    ___     A \        _________________    ___    A \   |   ________________________   |
# B |-  --> | | | | | | | | | -> | |     B |-  0 -> | | | | | | | | | -> | |    B |-  --> | | -> | | | | | | | | | ---
# M /       -----------------    ---     M /        -----------------    ---    M /       ---    -----------------
#           b7             b0     C                 b7             b0     C                C     b7             b0
#
# Legend:                          (M) Complement of M             | Test and set if true, cleared otherwise
#
# OP Operation Code (Hexadecimal)   -> Transfer Into               * Not Affected
#
#  ~ Number of MPU Cycles            H Half-carry (from bit 3)    CC Condition Code Register
#
#  # Number of Program Bytes         N Negative (sign bit)         : Concatenation
#
#  + Arithmetic Plus                 Z Zero Result                 ∨ Logical Or
#
#  - Arithmetic Minus                V Overflow, 2's Complement    ∧ Logical And
#
#  * Multiply                        C Carry from ALU              ⊻ Logical Excluside Or
#
# NOTES: 1. This column gives a base cycle and byte count. To obtain total count, add the values
#           obtained from teh INDEXED ADDRESSING MODE table, Table 2.
#
#        2. R1 and R2 may be any pair of 8 bit or any pair of 16 bit registers.
#               The 8 bit registers are: A, B, CC, DP
#               The 16 bit registers are: X, Y, U, S, D, PC
#
#        3. EA is the effective address.
#
#        4. The PSH and PUL instrutions requires 5 cycles plus 1 cycle for each byte pushed or
#           pulled.
#
#        5. 5(6) means: 5 cycles if branch not taken, 6 cycles if taken (Branch instructions).
#
#        6. SWI sets I and F bits. SWI2 and SWI3 do not affect I and F.
#
#        7. Conditions Codes set as a direct result of the instruction.
#
#        8. Value of half-carry flag is undefined.
#
#        9. Special Case - Carry set if b7 is SET.
#
#
# Branch Instructions
# -------------------------------------------------------------------------------------------
# |             |       | Addressing Modes |                            |   |   |   |   |   |
# |             |       ---------------------------------------------------------------------
# |             |       |     Relative     |                            | 5 | 3 | 2 | 1 | 0 |
# |             |       ---------------------------------------------------------------------
# | Instruction | Forms |  Op  |  ~   | #  | Description                | H | N | Z | V | C |
# -------------------------------------------------------------------------------------------
# | BCC         | BCC   |  24  |  3   | 2  | Branch C = 0               | * | * | * | * | * |
# |             | LBCC  | 1024 | 5(6) | 4  | Long Branch C = 0          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BCS         | BCS   |  25  |  3   | 2  | Branch C = 1               | * | * | * | * | * |
# |             | LBCS  | 1025 | 5(6) | 4  | Long Branch C = 1          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BEQ         | BEQ   |  27  |  3   | 2  | Branch Z = 1               | * | * | * | * | * |
# |             | LBEQ  | 1027 | 5(6) | 4  | Long Branch Z = 0          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BGE         | BGE   |  2C  |  3   | 2  | Branch >= Zero             | * | * | * | * | * |
# |             | LBGE  | 102C | 5(6) | 4  | Long Branch >= Zero        | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BGT         | BGT   |  2E  |  3   | 2  | Branch > Zero              | * | * | * | * | * |
# |             | LBGT  | 102E | 5(6) | 4  | Long Branch > Zero         | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BHI         | BHI   |  22  |  3   | 2  | Branch Higher              | * | * | * | * | * |
# |             | LBHI  | 1022 | 5(6) | 4  | Long Branch Higher         | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BHS         | BHS   |  24  |  3   | 2  | Branch Higher or Same      | * | * | * | * | * |
# |             | LBHS  | 1024 | 5(6) | 4  | Long Branch Higher or Same | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BLE         | BLE   |  2F  |  3   | 2  | Branch <= Zero             | * | * | * | * | * |
# |             | LBLE  | 102F | 5(6) | 4  | Long Branch <= Zero        | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BLO         | BLO   |  25  |  3   | 2  | Branch Lower               | * | * | * | * | * |
# |             | LBLO  | 1025 | 5(6) | 4  | Long Branch Lower          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BLS         | BLS   |  23  |  3   | 2  | Branch Lower or Same       | * | * | * | * | * |
# |             | LBLS  | 1023 | 5(6) | 4  | Long Branch Lower or Same  | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BLT         | BLT   |  2D  |  3   | 2  | Branch < Zero              | * | * | * | * | * |
# |             | LBLT  | 102D | 5(6) | 4  | Long Branch < Zero         | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BMI         | BMI   |  2B  |  3   | 2  | Branch Minus               | * | * | * | * | * |
# |             | LBMI  | 102B | 5(6) | 4  | Long Branch Minus          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BNE         | BNE   |  26  |  3   | 2  | Branch Z = 0               | * | * | * | * | * |
# |             | LBNE  | 1026 | 5(6) | 4  | Long Branch Z = 0          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BPL         | BPL   |  2A  |  3   | 2  | Branch Plus                | * | * | * | * | * |
# |             | LBPL  | 102A | 5(6) | 4  | Long Branch Plus           | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BRA         | BRA   |  20  |  3   | 2  | Branch Always              | * | * | * | * | * |
# |             | LBRA  |  16  |  5   | 3  | Long Branch Always         | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BRN         | BRN   |  21  |  3   | 2  | Branch Never               | * | * | * | * | * |
# |             | LBRN  | 1021 |  5   | 4  | Long Branch Never          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BSR         | BSR   |  8D  |  7   | 2  | Branch to Subroutine       | * | * | * | * | * |
# |             | LBSR  |  17  |  9   | 3  | Long Branch to Subroutine  | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BVC         | BVC   |  28  |  3   | 2  | Branch V = 0               | * | * | * | * | * |
# |             | LBVC  | 1028 | 5(6) | 4  | Long Branch V = 0          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
# | BVS         | BVS   |  29  |  3   | 2  | Branch V = 1               | * | * | * | * | * |
# |             | LBVS  | 1029 | 5(6) | 4  | Long Branch V = 1          | * | * | * | * | * |
# -------------------------------------------------------------------------------------------
#
#
# SIMPLE BRANCHES
# -----------------------    NOTES:
# |      |  OP  | ~ | # |
# -----------------------    1. All conditional branches have both short and long variations.
# | BRA  |  20  | 3 | 2 |
# -----------------------    2. All short branches are 2 bytes and require 3 cycles.
# | LBRA |  16  | 5 | 3 |
# -----------------------    3. All conditional long branches are formed by prefixing the short
# | BRN  |  21  | 3 | 2 |       branch opcode with $10 and using a 16-bit destination offset.
# -----------------------
# | LBRN | 1021 | 5 | 4 |    4. All conditional long branches require 4 bytes and 6 cycles if the
# -----------------------       branch is taken or 5 cycles if the branch is not taken.
# | BSR  |  8D  | 7 | 2 |
# -----------------------    5. 5(6) Means: 5 cycles if branch not taken, 6 cycles if taken.
# | LBSR |  17  | 9 | 3 |
# -----------------------
#
# SIMPLE CONDITIONAL BRANCHES (Notes 1-4)    SIGNED CONDITIONAL BRANCHES (Notes 1-4)
# -----------------------------------        ------------------------------------
# | Test  |  True | OP | False | OP |        |  Test  |  True | OP | False | OP |
# -----------------------------------        ------------------------------------
# | N = 1 |  BMI  | 2B |  BPL  | 2A |        | r > m  |  BGT  | 2E |  BLE  | 2F |
# -----------------------------------        ------------------------------------
# | Z = 1 |  BEQ  | 27 |  BNE  | 26 |        | r >= m |  BGE  | 2C |  BLT  | 2D |
# -----------------------------------        ------------------------------------
# | V = 1 |  BVS  | 29 |  BVC  | 28 |        | r = m  |  BEQ  | 27 |  BNE  | 26 |
# -----------------------------------        ------------------------------------
# | C = 1 |  BCS  | 25 |  BCC  | 24 |        | r <= m |  BLE  | 2F |  BGT  | 2E |
# -----------------------------------        ------------------------------------
#                                            | r < m  |  BLT  | 2D |  BGE  | 2C |
#                                            ------------------------------------
#
# UNSIGNED CONDITIONAL BRANCHES (Notes 1-4)
# ------------------------------------
# |  Test  |  True | OP | False | OP |
# ------------------------------------
# | r > m  |  BHI  | 22 |  BLS  | 23 |
# ------------------------------------
# | r >= m |  BHS  | 24 |  BLO  | 25 |
# ------------------------------------
# | r = m  |  BEQ  | 27 |  BNE  | 26 |
# ------------------------------------
# | r <= m |  BLS  | 23 |  BHI  | 22 |
# ------------------------------------
# | r < m  |  BLO  | 25 |  BHS  | 24 |
# ------------------------------------

## MPU/CPU Pins
#
# PIN ASSIGNMENT
#
#       ---\__/---
#  VSS [| 1   40 |] HALT
#       |        |
#  NMI [| 2   39 |] TSC
#       |        |
#  IRQ [| 3   38 |] LIC
#       |        |
# FIRQ [| 4   37 |] RESET
#       |        |
#   BS [| 5   36 |] AVMA
#       |        |
#   BA [| 6   35 |] Q
#       |        |
#  VCC [| 7   34 |] E
#       |        |
#   A0 [| 8   33 |] BUSY
#       |        |
#   A1 [| 9   32 |] R/W
#       |        |
#   A2 [| 10  31 |] D0
#       |        |
#   A3 [| 11  30 |] D1
#       |        |
#   A4 [| 12  29 |] D2
#       |        |
#   A5 [| 13  28 |] D3
#       |        |
#   A6 [| 14  27 |] D4
#       |        |
#   A7 [| 15  26 |] D5
#       |        |
#   A8 [| 16  25 |] D6
#       |        |
#   A9 [| 17  24 |] D7
#       |        |
#  A10 [| 18  23 |] A15
#       |        |
#  A11 [| 19  22 |] A14
#       |        |
#  A12 [| 20  21 |] A13
#       ----------
#
enum Pins {
	VSS,
	NMI,
	IRQ,
	FIRQ,
	BS,
	BA,
	VCC,
	A0,
	A1,
	A2,
	A3,
	A4,
	A5,
	A6,
	A7,
	A8,
	A9,
	A10,
	A11,
	A12,
	A13,
	A14,
	A15,
	D7,
	D6,
	D5,
	D4,
	D3,
	D2,
	D1,
	D0,
	RW,
	BUSY,
	E,
	Q,
	AVMA,
	RESET,
	LIC,
	TSC,
	HALT
}

enum MPUState {
	NORMAL,
	INTERRUPT_RESET_ACKNOWLEDGE,
	SYNC_ACKNOWLEDGE,
	HALT_ACKNOLWEDGE,
}

class PinsState:

	var address: int = 0 # A0 - A15
	var data: int = 0 # D0 - D7
	var nmi: bool = false # false = low
	var irq: bool = false
	var firq: bool = false
	var bs: bool = false
	var ba: bool = false
	var a0: bool setget set_a0, get_a0
	var a1: bool setget set_a1, get_a1
	var a2: bool setget set_a2, get_a2
	var a3: bool setget set_a3, get_a3
	var a4: bool setget set_a4, get_a4
	var a5: bool setget set_a5, get_a5
	var a6: bool setget set_a6, get_a6
	var a7: bool setget set_a7, get_a7
	var a8: bool setget set_a8, get_a8
	var a9: bool setget set_a9, get_a9
	var a10: bool setget set_a10, get_a10
	var a11: bool setget set_a11, get_a11
	var a12: bool setget set_a12, get_a12
	var a13: bool setget set_a13, get_a13
	var a14: bool setget set_a14, get_a14
	var a15: bool setget set_a15, get_a15
	var d7: bool setget set_d7, get_d7
	var d6: bool setget set_d6, get_d6
	var d5: bool setget set_d5, get_d5
	var d4: bool setget set_d4, get_d4
	var d3: bool setget set_d3, get_d3
	var d2: bool setget set_d2, get_d2
	var d1: bool setget set_d1, get_d1
	var d0: bool setget set_d0, get_d0
	var rw: bool = false
	var busy: bool = false
	var avma: bool = false
	var reset: bool = false
	var lic: bool = false
	var tsc: bool = false
	var halt: bool = false

	func set_pin(pin: int, new_value: bool) -> void:
		match (pin):
			Pins.NMI:
				nmi = new_value
			Pins.IRQ:
				irq = new_value
			Pins.FIRQ:
				firq = new_value
			Pins.BS:
				bs = new_value
			Pins.BA:
				ba = new_value
			Pins.A0:
				self.a0 = new_value
			Pins.A1:
				self.a1 = new_value
			Pins.A2:
				self.a2 = new_value
			Pins.A3:
				self.a3 = new_value
			Pins.A4:
				self.a4 = new_value
			Pins.A5:
				self.a5 = new_value
			Pins.A6:
				self.a6 = new_value
			Pins.A7:
				self.a7 = new_value
			Pins.A8:
				self.a8 = new_value
			Pins.A9:
				self.a9 = new_value
			Pins.A10:
				self.a10 = new_value
			Pins.A11:
				self.a11 = new_value
			Pins.A12:
				self.a12 = new_value
			Pins.A13:
				self.a13 = new_value
			Pins.A14:
				self.a14 = new_value
			Pins.A15:
				self.a15 = new_value
			Pins.D7:
				self.d7 = new_value
			Pins.D6:
				self.d6 = new_value
			Pins.D5:
				self.d5 = new_value
			Pins.D4:
				self.d4 = new_value
			Pins.D3:
				self.d3 = new_value
			Pins.D2:
				self.d2 = new_value
			Pins.D1:
				self.d1 = new_value
			Pins.D0:
				self.d0 = new_value
			Pins.RW:
				rw = new_value
			Pins.BUSY:
				busy = new_value
			Pins.AVMA:
				avma = new_value
			Pins.RESET:
				reset = new_value
			Pins.LIC:
				lic = new_value
			Pins.TSC:
				tsc = new_value
			Pins.HALT:
				halt = new_value

	func set_a0(new_a: bool) -> void:
		_set_a(new_a, 0x0001)

	func get_a0() -> bool:
		return (address & 0x0001) as bool

	func set_a1(new_a: bool) -> void:
		_set_a(new_a, 0x0002)

	func get_a1() -> bool:
		return (address & 0x0002) as bool

	func set_a2(new_a: bool) -> void:
		_set_a(new_a, 0x0004)

	func get_a2() -> bool:
		return (address & 0x0004) as bool

	func set_a3(new_a: bool) -> void:
		_set_a(new_a, 0x0008)

	func get_a3() -> bool:
		return (address & 0x0008) as bool

	func set_a4(new_a: bool) -> void:
		_set_a(new_a, 0x0010)

	func get_a4() -> bool:
		return (address & 0x0010) as bool

	func set_a5(new_a: bool) -> void:
		_set_a(new_a, 0x0020)

	func get_a5() -> bool:
		return (address & 0x0020) as bool

	func set_a6(new_a: bool) -> void:
		_set_a(new_a, 0x0040)

	func get_a6() -> bool:
		return (address & 0x0040) as bool

	func set_a7(new_a: bool) -> void:
		_set_a(new_a, 0x0080)

	func get_a7() -> bool:
		return (address & 0x0080) as bool

	func set_a8(new_a: bool) -> void:
		_set_a(new_a, 0x0100)

	func get_a8() -> bool:
		return (address & 0x0100) as bool

	func set_a9(new_a: bool) -> void:
		_set_a(new_a, 0x0200)

	func get_a9() -> bool:
		return (address & 0x0200) as bool

	func set_a10(new_a: bool) -> void:
		_set_a(new_a, 0x0400)

	func get_a10() -> bool:
		return (address & 0x0400) as bool

	func set_a11(new_a: bool) -> void:
		_set_a(new_a, 0x0800)

	func get_a11() -> bool:
		return (address & 0x0800) as bool

	func set_a12(new_a: bool) -> void:
		_set_a(new_a, 0x1000)

	func get_a12() -> bool:
		return (address & 0x1000) as bool

	func set_a13(new_a: bool) -> void:
		_set_a(new_a, 0x2000)

	func get_a13() -> bool:
		return (address & 0x2000) as bool

	func set_a14(new_a: bool) -> void:
		_set_a(new_a, 0x4000)

	func get_a14() -> bool:
		return (address & 0x4000) as bool

	func set_a15(new_a: bool) -> void:
		_set_a(new_a, 0x8000)

	func get_a15() -> bool:
		return (address & 0x8000) as bool

	func set_d7(new_d: bool) -> void:
		_set_d(new_d, 0x80)

	func get_d7() -> bool:
		return (data & 0x80) as bool

	func set_d6(new_d: bool) -> void:
		_set_d(new_d, 0x40)

	func get_d6() -> bool:
		return (data & 0x40) as bool

	func set_d5(new_d: bool) -> void:
		_set_d(new_d, 0x20)

	func get_d5() -> bool:
		return (data & 0x20) as bool

	func set_d4(new_d: bool) -> void:
		_set_d(new_d, 0x10)

	func get_d4() -> bool:
		return (data & 0x10) as bool

	func set_d3(new_d: bool) -> void:
		_set_d(new_d, 0x08)

	func get_d3() -> bool:
		return (data & 0x08) as bool

	func set_d2(new_d: bool) -> void:
		_set_d(new_d, 0x04)

	func get_d2() -> bool:
		return (data & 0x04) as bool

	func set_d1(new_d: bool) -> void:
		_set_d(new_d, 0x02)

	func get_d1() -> bool:
		return (data & 0x02) as bool

	func set_d0(new_d: bool) -> void:
		_set_d(new_d, 0x01)

	func get_d0() -> bool:
		return (data & 0x01) as bool

	func getMPUState() -> int:
		var ret := 0

		if bs:
			ret += 1
		if ba:
			ret += 2

		return ret

	func _set_a(new_a: bool, bit: int) -> void:
		if new_a:
			address |= bit
		else:
			address &= 0xFFFF - bit

	func _set_d(new_d: bool, bit: int) -> void:
		if new_d:
			data |= bit
		else:
			data &= 0xFF - bit

var pins: PinsState = PinsState.new()


## CONDITION CODE REGISTER
##
## See pg 4-301 "Programming Model"
#
#    7    Condition Code Register    0
#    ---------------------------------
#    | E | F | H | I | N | Z | V | C |
#    ---------------------------------
#      |   |   |   |   |   |   |   |
# Entire   |   |   |   |   |   |   Carry
#          |   |   |   |   |   |
#  FIRQ Mask   |   |   |   |   Overflow
#              |   |   |   |
#     Half Carry   |   |   Zero
#                  |   |
#           IRQ Mask   Negative
#
enum ConditionCode {
	C_CARRY = 1,
	V_OVERFLOW = 2,
	Z_ZERO = 4,
	N_NEGATIVE = 8,
	I_IRQ_MASK = 16,
	H_HALF_CARRY = 32,
	F_FIRQ_MASK = 64,
	E_ENTIRE = 128
}

## VECTOR TABLE
##
## See TABLE 1 - MEMORY MAP FOR INTERRUPT VECTORS
#
# ------------------------------------------------------------------
# | Memory Map For Vector Locations |       Interrupt Vector       |
# -----------------------------------          Description         |
# |       MS       |       LS       |                              |
# ------------------------------------------------------------------
# |      FFFE      |      FFFF      |            RESET             |
# ------------------------------------------------------------------
# |      FFFC      |      FFFD      |             NMI              |
# ------------------------------------------------------------------
# |      FFFA      |      FFFB      |             SWI              |
# ------------------------------------------------------------------
# |      FFF8      |      FFF9      |             IRQ              |
# ------------------------------------------------------------------
# |      FFF6      |      FFF7      |            FIRQ              |
# ------------------------------------------------------------------
# |      FFF4      |      FFF5      |            SWI2              |
# ------------------------------------------------------------------
# |      FFF2      |      FFF3      |            SWI3              |
# ------------------------------------------------------------------
# |      FFF0      |      FFF1      |           Reserved           |
# ------------------------------------------------------------------
enum VectorTable {
	RESERVED = 0xFFF0,
	SWI3 = 0xFFF2,
	SWI2 = 0xFFF4,
	FIRQ = 0xFFF6,
	IRQ = 0xFFF8,
	SWI = 0xFFFA,
	NMI = 0xFFFC,
	RESET = 0xFFFE,
}

## PUSH/PULL POST BYTE
##
## See PULU/PULS
#
# PUSH/PULL POST BYTE
# -----------------
# | | | | | | | | |
# -----------------
#  | | | | | | | |
#  | | | | | | | CCR
#  | | | | | | |
#  | | | | | | A
#  | | | | | |
#  | | | | | B
#  | | | | |
#  | | | | DPR
#  | | | |
#  | | | X
#  | | |
#  | | Y
#  | |
#  | S/U
#  |
#  PC
enum PushPullPostByte {
	CCR = 0x1,
	A = 0x2,
	B = 0x4,
	DPR = 0x8,
	X = 0x10,
	Y = 0x20,
	S_U = 0x40,
	PC = 0x80
}

## TRANSFER/EXCHANGE POST BYTE
##
## See TFR/EXG
#
# TRANSFER/EXCHANGE POST BYTE        REGISTER FIELD
# ---------------------------        0000 D (AB)    1000 A
# | SOURCE  |  DESTINATION  |        0001 X         1001 B
# ---------------------------        0010 Y         1010 CCR
#                                    0011 U         1011 DPR
#                                    0100 S
#                                    0101 PC
enum TransferExchangePostByte {
	D,
	X,
	Y,
	U,
	S,
	PC,
	A = 8,
	B,
	CCR,
	DPR
}

## OPCODE DEFINITIONS
##
## See TABLE 9 - HEXADECIMAL VALUES OF MACHINE CODES
enum Opcodes {
	NEG_DIRECT,
	COM_DIRECT = 0x3,
	LSR_DIRECT,
	ROR_DIRECT = 0x6,
	ASR_DIRECT,
	ASL_DIRECT,
	ROL_DIRECT,
	DEC_DIRECT,
	INC_DIRECT = 0xC,
	TST_DIRECT,
	JMP_DIRECT,
	CLR_DIRECT,
	PAGE2,
	PAGE3,
	NOP_INHERENT,
	SYNC_INHERENT,
	LBRA_RELATIVE = 0x16,
	LBSR_RELATIVE,
	DAA_INHERENT = 0x19,
	ORCC_IMMEDIATE,
	ANDCC_IMMEDIATE = 0x1C,
	SEX_INHERENT,
	EXG_INHERENT,
	TFR_INHERENT,
	BRA_RELATIVE,
	BRN_RELATIVE,
	BHI_RELATIVE,
	BLS_RELATIVE,
	BHS_RELATIVE,
	BLO_RELATIVE,
	BNE_RELATIVE,
	BEQ_RELATIVE,
	BVC_RELATIVE,
	BVS_RELATIVE,
	BPL_RELATIVE,
	BMI_RELATIVE,
	BGE_RELATIVE,
	BLT_RELATIVE,
	BGT_RELATIVE,
	BLE_RELATIVE,
	LEAX_INDEXED,
	LEAY_INDEXED,
	LEAS_INDEXED,
	LEAU_INDEXED,
	PSHS_INHERENT,
	PULS_INHERENT,
	PSHU_INHERENT,
	PULU_INHERENT,
	RTS_INHERENT = 0x39,
	ABX_INHERENT,
	RTI_INHERENT,
	CWAI_INHERENT,
	MUL_INHERENT,
	RESET, # undocumented instruction
	SWI_INHERENT,
	NEGA_INHERENT,
	COMA_INHERENT = 0x43,
	LSRA_INHERENT,
	RORA_INHERENT = 0x46,
	ASRA_INHERENT,
	ASLA_INHERENT,
	ROLA_INHERENT,
	DECA_INHERENT,
	INCA_INHERENT = 0x4C,
	TSTA_INHERENT,
	CLRA_INHERENT = 0x4F,
	NEGB_INHERENT,
	COMB_INHERENT = 0x53,
	LSRB_INHERENT,
	RORB_INHERENT = 0x56,
	ASRB_INHERENT,
	ASLB_INHERENT,
	ROLB_INHERENT,
	DECB_INHERENT,
	INCB_INHERENT = 0x5C,
	TSTB_INHERENT,
	CLRB_INHERENT = 0x5F,
	NEG_INDEXED,
	COM_INDEXED = 0x63,
	LSR_INDEXED,
	ROR_INDEXED = 0x66,
	ASR_INDEXED,
	ASL_INDEXED,
	ROL_INDEXED,
	DEC_INDEXED,
	INC_INDEXED = 0x6C,
	TST_INDEXED,
	JMP_INDEXED,
	CLR_INDEXED,
	NEG_EXTENDED,
	COM_EXTENDED = 0x73,
	LSR_EXTENDED,
	ROR_EXTENDED = 0x76,
	ASR_EXTENDED,
	ASL_EXTENDED = 0x78,
	ROL_EXTENDED,
	DEC_EXTENDED,
	INC_EXTENDED = 0x7C,
	TST_EXTENDED,
	JMP_EXTENDED,
	CLR_EXTENDED,
	SUBA_IMMEDIATE,
	CMPA_IMMEDIATE,
	SBCA_IMMEDIATE,
	SUBD_IMMEDIATE,
	ANDA_IMMEDIATE,
	BITA_IMMEDIATE,
	LDA_IMMEDIATE,
	EORA_IMMEDIATE = 0x88,
	ADCA_IMMEDIATE,
	ORA_IMMEDIATE,
	ADDA_IMMEDIATE,
	CMPX_IMMEDIATE,
	BSR_RELATIVE,
	LDX_IMMEDIATE,
	SUBA_DIRECT = 0x90,
	CMPA_DIRECT,
	SBCA_DIRECT,
	SUBD_DIRECT,
	ANDA_DIRECT,
	BITA_DIRECT,
	LDA_DIRECT,
	STA_DIRECT,
	EORA_DIRECT,
	ADCA_DIRECT,
	ORA_DIRECT,
	ADDA_DIRECT,
	CMPX_DIRECT,
	JSR_DIRECT,
	LDX_DIRECT,
	STX_DIRECT,
	SUBA_INDEXED,
	CMPA_INDEXED,
	SBCA_INDEXED,
	SUBD_INDEXED,
	ANDA_INDEXED,
	BITA_INDEXED,
	LDA_INDEXED,
	STA_INDEXED,
	EORA_INDEXED,
	ADCA_INDEXED,
	ORA_INDEXED,
	ADDA_INDEXED,
	CMPX_INDEXED,
	JSR_INDEXED,
	LDX_INDEXED,
	STX_INDEXED,
	SUBA_EXTENDED,
	CMPA_EXTENDED,
	SBCA_EXTENDED,
	SUBD_EXTENDED,
	ANDA_EXTENDED,
	BITA_EXTENDED,
	LDA_EXTENDED,
	STA_EXTENDED,
	EORA_EXTENDED,
	ADCA_EXTENDED,
	ORA_EXTENDED,
	ADDA_EXTENDED,
	CMPX_EXTENDED,
	JSR_EXTENDED,
	LDX_EXTENDED,
	STX_EXTENDED,
	SUBB_IMMEDIATE,
	CMPB_IMMEDIATE,
	SBCB_IMMEDIATE,
	ADDD_IMMEDIATE,
	ANDB_IMMEDIATE,
	BITB_IMMEDIATE,
	LDB_IMMEDIATE,
	EORB_IMMEDIATE = 0xC8,
	ADCB_IMMEDIATE,
	ORB_IMMEDIATE,
	ADDB_IMMEDIATE,
	LDD_IMMEDIATE,
	LDU_IMMEDIATE = 0xCE,
	SUBB_DIRECT = 0xD0,
	CMPB_DIRECT,
	SBCB_DIRECT,
	ADDD_DIRECT,
	ANDB_DIRECT,
	BITB_DIRECT,
	LDB_DIRECT,
	STB_DIRECT,
	EORB_DIRECT,
	ADCB_DIRECT,
	ORB_DIRECT,
	ADDB_DIRECT,
	LDD_DIRECT,
	STD_DIRECT,
	LDU_DIRECT,
	STU_DIRECT,
	SUBB_INDEXED,
	CMPB_INDEXED,
	SBCB_INDEXED,
	ADDD_INDEXED,
	ANDB_INDEXED,
	BITB_INDEXED,
	LDB_INDEXED,
	STB_INDEXED,
	EORB_INDEXED,
	ADCB_INDEXED,
	ORB_INDEXED,
	ADDB_INDEXED,
	LDD_INDEXED,
	STD_INDEXED,
	LDU_INDEXED,
	STU_INDEXED,
	SUBB_EXTENDED,
	CMPB_EXTENDED,
	SBCB_EXTENDED,
	ADDD_EXTENDED,
	ANDB_EXTENDED,
	BITB_EXTENDED,
	LDB_EXTENDED,
	STB_EXTENDED,
	EORB_EXTENDED,
	ADCB_EXTENDED,
	ORB_EXTENDED,
	ADDB_EXTENDED,
	LDD_EXTENDED,
	STD_EXTENDED,
	LDU_EXTENDED,
	STU_EXTENDED,
	LBRN_RELATIVE = 0x1021,
	LBHI_RELATIVE,
	LBLS_RELATIVE,
	LBHS_RELATIVE,
	LBCS_RELATIVE,
	LBNE_RELATIVE,
	LBEQ_RELATIVE,
	LBVC_RELATIVE,
	LBVS_RELATIVE,
	LBPL_RELATIVE,
	LBMI_RELATIVE,
	LBGE_RELATIVE,
	LBLT_RELATIVE,
	LBGT_RELATIVE,
	LBLE_RELATIVE,
	SWI2_INHERENT = 0x103F,
	CMPD_IMMEDIATE = 0x1083,
	CMPY_IMMEDIATE = 0x108C,
	LDY_IMMEDIATE = 0x108E,
	CMPD_DIRECT = 0x1093,
	CMPY_DIRECT = 0x109C,
	LDY_DIRECT = 0x109E,
	STY_DIRECT,
	CMPD_INDEXED = 0x10A3,
	CMPY_INDEXED = 0x10AC,
	LDY_INDEXED = 0x10AE,
	STY_INDEXED,
	CMPD_EXTENDED = 0x10B3,
	CMPY_EXTENDED = 0x10BC,
	LDY_EXTENDED = 0x10BE,
	STY_EXTENDED,
	LDS_IMMEDIATE = 0x10CE,
	LDS_DIRECT = 0x10DE,
	STS_DIRECT,
	LDS_INDEXED = 0x10EE,
	STS_INDEXED,
	LDS_EXTENDED = 0x10FE,
	STS_EXTENDED,
	SWI3_INHERENT = 0x113F,
	CMPU_IMMEDIATE = 0x1183,
	CMPS_IMMEDIATE = 0x118C,
	CMPU_DIRECT = 0x1193,
	CMPS_DIRECT = 0x119C,
	CMPU_INDEXED = 0x11A3,
	CMPS_INDEXED = 0x11AC,
	CMPU_EXTENDED = 0x11B3,
	CMPS_EXTENDED = 0x11BC
}

## INDEXED ADDRESSING POSTBYTE REGISTER BIT
##
## See FIGURE 16
#
# ------------------------------------------------------------
# |    Post-Byte Register Bit     |         Indexed          |
# ---------------------------------        Addressing        |
# | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |           Mode           |
# ------------------------------------------------------------
# | 0 | R | R | d | d | d | d | d |  EA = ,R + 5 Bit Offset  |
# ------------------------------------------------------------
# | 1 | R | R | 0 | 0 | 0 | 0 | 0 |           ,R+            |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 0 | 0 | 1 |           ,R++           |
# ------------------------------------------------------------
# | 1 | R | R | 0 | 0 | 0 | 1 | 0 |            ,-R           |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 0 | 1 | 1 |           ,--R           |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 0 | 0 |    EA = ,R +0 Offset     |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 0 | 1 |   EA = ,R + ACCB Offset  |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 1 | 0 |   EA = ,R + ACCA Offset  |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 0 | 0 |   EA = ,R + 8 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 0 | 1 |  EA = ,R + 16 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 1 | 1 |    EA = ,R + D Offset    |
# ------------------------------------------------------------
# | 1 | x | x | i | 1 | 1 | 0 | 0 |  EA = ,PC + 9 Bit Offset |
# ------------------------------------------------------------
# | 1 | x | x | i | 1 | 1 | 0 | 1 | EA = ,PC + 16 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 1 | 1 | 1 |      EA = [,Address]     |
# ------------------------------------------------------------
#     \______/\__/\_______________/
#        |     |          |
#        |     |      Addressing Mode Field
#        |     |
#        |  Indirect Field (Sign bit when b(7) = 0)
#        |
#     Register Field: RR
#
#     00 = X  01 = Y            x = Don't Care  d = Offset Bit
#     10 = U  11 = S            i = 0 Not Indirect
#                                   1 Indirect
const REGISTER_FIELD_MASK = 0x60
const INDIRECT_FIELD_MASK = 0x10
const OFFSET_BITS_MASK = 0x1F
const ADDRESSING_MODE_MASK = 0x0F

enum RegisterField {
	X = 0x00,
	Y = 0x20,
	U = 0x40,
	S = 0x60,
}

enum AddressingMode {
	INCREMENT_BY_1 = 0x0,
	INCREMENT_BY_2,
	DECREMENT_BY_1,
	DECREMENT_BY_2,
	NO_OFFSET,
	B_REGISTER_OFFSET,
	A_REGISTER_OFFSET,
	EIGHT_BIT_OFFSET = 0x8,
	SIXTEEN_BIT_OFFSET,
	D_REGISTER_OFFSET = 0xB,
	CONSTANT_PC_8_BIT_OFFSET,
	CONSTANT_PC_16_BIT_OFFSET,
	EXTENDED_INDIRECT = 0xF
}

## PROGRAMMING MODEL
##
## See 4-301
#
#
# 15                           0
# ------------------------------  \                      7                      0
# |     X - Index Register     |  |                      ------------------------
# ------------------------------  |                      | Direct Page Register |
# |     Y - Index Register     |  |                      ------------------------
# ------------------------------  |- Pointer Registers
# |   U - User Stack Pointer   |  |                      7    Condition Code Register    0
# ------------------------------  |                      ---------------------------------
# | S - Hardware Stack Pointer |  |                      | E | F | H | I | N | Z | V | C |
# ------------------------------  /                      ---------------------------------
# |       Program Counter      |                           |   |   |   |   |   |   |   |
# ------------------------------  \                   Entire   |   |   |   |   |   |   Carry
# |      A      |      B       |  |- Accumulators              |   |   |   |   |   |
# ------------------------------  /                    FIRQ Mask   |   |   |   |   Overflow
# \____________________________/                                   |   |   |   |
#               |                                         Half Carry   |   |   Zero
#               D                                                      |   |
#                                                               IRQ Mask   Negative


class DirectPageRegister:

	var dp: int = 0 setget , get_dp

	func get_dp() -> int:
		return dp << 8

	func get_real_dp() -> int:
		return dp


class Accumulator:

	var d: int = 0 setget set_d, get_d
	var a: int = 0 setget set_a, get_a
	var b: int = 0 setget set_b, get_b

	var _dirty_d: bool = false
	var _dirty_a: bool = false
	var _dirty_b: bool = false

	func set_d(new_d: int) -> void:
		d = new_d
		_dirty_d = false
		_dirty_a = true
		_dirty_b = true

	func get_d() -> int:
		if _dirty_d:
			d = (a << 8) + b
			_dirty_d = false
		return d

	func set_a(new_a: int) -> void:
		a = new_a
		_dirty_a = false
		_dirty_d = true
		d = (a << 8) + (d & 0xFF)

	func get_a() -> int:
		if _dirty_a:
			a = (d & 0xFF00) >> 8
			_dirty_a = false
		return a

	func set_b(new_b: int) -> void:
		b = new_b
		_dirty_b = false
		_dirty_d = true
		d = (d & 0xFF00) + b

	func get_b() -> int:
		if _dirty_b:
			b = d & 0xFF
			_dirty_b = false
		return b


class ConditionCodeRegister:

	signal entire_toggled(current)
	signal firq_mask_toggled(current)
	signal half_carry_toggled(current)
	signal irq_mask_toggled(current)
	signal negative_toggled(current)
	signal zero_toggled(current)
	signal overflow_toggled(current)
	signal carry_toggled(current)

	var register: int = 0 setget set_register

	var e: bool = false setget set_e
	var f: bool = false setget set_f
	var h: bool = false setget set_h
	var i: bool = false setget set_i
	var n: bool = false setget set_n
	var z: bool = false setget set_z
	var v: bool = false setget set_v
	var c: bool = false setget set_c

	var entire: bool setget set_e, get_e
	var firq_mask: bool = false setget set_f, get_f
	var half_carry: bool = false setget set_h, get_h
	var irq_mask: bool = false setget set_i, get_i
	var negative: bool = false setget set_n, get_n
	var zero: bool = false setget set_z, get_z
	var overflow: bool = false setget set_v, get_v
	var carry: bool = false setget set_c, get_c

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		refresh_e()
		refresh_f()
		refresh_h()
		refresh_i()
		refresh_n()
		refresh_z()
		refresh_v()
		refresh_c()

	func get_e() -> bool:
		return e

	func refresh_e() -> void:
		self.e = register & ConditionCode.E_ENTIRE

	func set_e(new_e: bool) -> void:
		var old_e := e
		e = new_e
		_set_register_bit(new_e, ConditionCode.E_ENTIRE)
		if old_e != new_e:
			emit_signal('entire_toggled', new_e)

	func set_entire(new_e: bool) -> void:
		self.e = new_e

	func get_entire() -> bool:
		return self.e

	func get_f() -> bool:
		return f

	func refresh_f() -> void:
		self.f = register & ConditionCode.F_FIRQ_MASK

	func set_f(new_f: bool) -> void:
		var old_f := f
		f = new_f
		_set_register_bit(new_f, ConditionCode.F_FIRQ_MASK)
		if old_f != new_f:
			emit_signal('firq_mask_toggled', new_f)

	func set_firq_mask(new_f: bool) -> void:
		self.f = new_f

	func get_firq_mask() -> bool:
		return self.f

	func get_h() -> bool:
		return h

	func refresh_h() -> void:
		self.h = register & ConditionCode.H_HALF_CARRY

	func set_h(new_h: bool) -> void:
		var old_h := h
		h = new_h
		_set_register_bit(new_h, ConditionCode.H_HALF_CARRY)
		if old_h != new_h:
			emit_signal('half_carry_toggled', new_h)

	func set_half_carry(new_h: bool) -> void:
		self.f = new_h

	func get_half_carry() -> bool:
		return self.h

	func get_i() -> bool:
		return i

	func refresh_i() -> void:
		self.i = register & ConditionCode.I_IRQ_MASK

	func set_i(new_i: bool) -> void:
		var old_i := i
		i = new_i
		_set_register_bit(new_i, ConditionCode.I_IRQ_MASK)
		if old_i != new_i:
			emit_signal('irq_mask_toggled', new_i)

	func set_irq_mask(new_i: bool) -> void:
		self.i = new_i

	func get_irq_mask() -> bool:
		return self.i

	func get_n() -> bool:
		return n

	func refresh_n() -> void:
		self.n = register & ConditionCode.N_NEGATIVE

	func set_n(new_n: bool) -> void:
		var old_n := n
		n = new_n
		_set_register_bit(new_n, ConditionCode.N_NEGATIVE)
		if old_n != new_n:
			emit_signal('negative_toggled', new_n)

	func set_negative(new_n: bool) -> void:
		self.n = new_n

	func get_negative() -> bool:
		return self.n

	func get_z() -> bool:
		return z

	func refresh_z() -> void:
		self.z = register & ConditionCode.Z_ZERO

	func set_z(new_z: bool) -> void:
		var old_z := z
		z = new_z
		_set_register_bit(new_z, ConditionCode.Z_ZERO)
		if old_z != new_z:
			emit_signal('zero_toggled', new_z)

	func set_zero(new_z: bool) -> void:
		self.z = new_z

	func get_zero() -> bool:
		return self.z

	func get_v() -> bool:
		return v

	func refresh_v() -> void:
		self.v = register & ConditionCode.V_OVERFLOW

	func set_v(new_v: bool) -> void:
		var old_v := v
		v = new_v
		_set_register_bit(new_v, ConditionCode.V_OVERFLOW)
		if old_v != new_v:
			emit_signal('overflow_toggled', new_v)

	func set_overflow(new_v: bool) -> void:
		self.v = new_v

	func get_overflow() -> bool:
		return self.v

	func get_c() -> bool:
		return c

	func refresh_c() -> void:
		self.c = register & ConditionCode.C_CARRY

	func set_c(new_c: bool) -> void:
		var old_c := c
		c = new_c
		_set_register_bit(new_c, ConditionCode.C_CARRY)
		if old_c != new_c:
			emit_signal('carry_toggled', new_c)

	func set_carry(new_c: bool) -> void:
		self.c = new_c

	func get_carry() -> bool:
		return self.c

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

## CPU REGISTERS
##
## (PROGRAMMING MODEL)
var x_index_register: int = 0
var y_index_register: int = 0
var user_stack_pointer: int = 0
var hardware_stack_pointer: int = 0
var program_counter: int = 0
var direct_page_register: DirectPageRegister = DirectPageRegister.new()
var accumulators: Accumulator = Accumulator.new()
var condition_code_register: ConditionCodeRegister = \
	ConditionCodeRegister.new(ConditionCode.I_IRQ_MASK & ConditionCode.F_FIRQ_MASK)

## Emulator specific statuses
var cycle_counter: int = 0
var cwai: bool = false
var syncing: bool = false
var delay_irq: bool = false # timing consideration for FF03 bit 7

## Access the bus
##
## When this signal fires the CPU is accessing the bus to read/write data with the A0-A15 and D0-D7
## pins. The handler of the signal should place the appropriate values in pins.data
signal bus_accessed(pins)


func _init() -> void:
	condition_code_register.irq_mask = true
	condition_code_register.firq_mask = true


## Microchip PIN controls
#
# From The MC6809 Cookbook by Carl D. Warren
#
#     When a SYNC instruction is executed, the MPU enters a SYNCING state, stops processing
# instructions and waits on an interrupt. When an interrupt occurs, the SYNCING state is cleared
# and processing continues. IF the interrupt is enabled, and the interrupt lasts 3 cycles or more,
# the processor will perform the interrupt routine. If the interrupt is masked or is shorter than 3
# cycles long, the processor simply continues to the next instruction (without stacking
# registers). While SYNCING, the address and data buses are tri-state.
#
# -- ??
#
func reset() -> void:
	accumulators.d = 0
	x_index_register = 0
	y_index_register = 0
	user_stack_pointer = 0
	hardware_stack_pointer = 0
	direct_page_register.dp = 0
	condition_code_register.register = 0
	condition_code_register.irq_mask = true
	condition_code_register.firq_mask = true
	syncing = false
	# Interrupt or RESET acknowledge
	pins.set_pin(Pins.BA, false)
	pins.set_pin(Pins.BS, true)
	program_counter = _read2(VectorTable.RESET)


func trigger_nmi() -> void:
	pins.set_pin(Pins.NMI, true)


func handle_nmi() -> void:
	if not cwai:
		condition_code_register.entire = true
		_push_machine_state()
	condition_code_register.irq_mask = true
	condition_code_register.firq_mask = true
	# Interrupt or RESET acknowledge
	pins.set_pin(Pins.BA, false)
	pins.set_pin(Pins.BS, true)
	program_counter = _read2(VectorTable.NMI)
	pins.set_pin(Pins.NMI, false)


func trigger_irq(delay: bool = false) -> void:
	delay_irq = delay
	pins.set_pin(Pins.IRQ, true)


func handle_irq() -> void:
	if not condition_code_register.irq_mask:
		if not cwai:
			condition_code_register.entire = true
			_push_machine_state()
		condition_code_register.irq_mask = true
		# Interrupt or RESET acknowledge
		pins.set_pin(Pins.BA, false)
		pins.set_pin(Pins.BS, true)
		program_counter = _read2(VectorTable.IRQ)
	pins.set_pin(Pins.IRQ, false)


func trigger_firq() -> void:
	pins.set_pin(Pins.FIRQ, true)


func handle_firq():
	if not condition_code_register.firq_mask:
		if not cwai:
			condition_code_register.entire = false
			_push_program_counter()
			_push_onto_hardware_stack(condition_code_register.register)
		condition_code_register.irq_mask = true
		condition_code_register.firq_mask = true
		# Interrupt or RESET acknowledge
		pins.set_pin(Pins.BA, false)
		pins.set_pin(Pins.BS, true)
		program_counter = _read2(VectorTable.FIRQ)
	pins.set_pin(Pins.FIRQ, false)


func execute(num_cycles_to_run: float) -> float:
	var opcode1: int
	var opcode2: int

	while (cycle_counter < num_cycles_to_run):

		if pins.halt:
			pins.set_pin(Pins.BA, true)
			pins.set_pin(Pins.BS, true)
			return 0.0

		pins.set_pin(Pins.BA, false)
		pins.set_pin(Pins.BS, false)

		if pins.nmi:
			handle_nmi()

		if pins.firq:
			handle_firq()

		if pins.irq and not delay_irq:
			handle_irq()

		if syncing:
			return 0.0

		# opcode information taken from The MC6809 Cookbook by Carl D. Warren

		opcode1 = _read_and_advance_program_counter()
		match (opcode1):
			# NEG    Negate
			# Source Form: NEG Q
			# Operation: M' <- 0 - M (i.e. M' <- ~M + 1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Set if the operation did not cause a cary from bit 7 in the ALU.
			# Description:
			#     Replaces the operand with its two's complement. The C-flag represents a borrow
			#     and is set inverse to the resulting binary carry. Not that 80 (16) is replaced by
			#     itself and only in this case is V Set. The value 00 (16) is also replaced by
			#     itself, and only in this case is C cleared.
			#
			# NEG - Direct - Opcode: 00 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.NEG_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _neg(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# COM    Complement
			# Source Form: COM Q; COMA; COMB
			# Operation: M' (R') <- 0 + ~M (~R)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Set
			# Description:
			#     Replaces the contents of M or ACCX with its one's complement (also called the
			#     logical complement). The carry flag is set for 6800 compatibility.
			# Comments:
			#     When operating on unsigned values, only BEQ and MBE branches can be expected to
			#     behave properly. When operating on two's complement values, all signed branches
			#     are available.
			#
			# COM - Direct - Opcode: 03 - MPY Cycles: 6 - No of bytes: 2
			Opcodes.COM_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _com(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# LSR    Logical shift right
			# Source Form: LSR Q; LSRA; LSRB
			# Operation:
			#      _________________    _____
			# 0 -> | | | | | | | | | -> | C |
			#      -----------------    -----
			#      b7             b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Performs a logical shift right on the operand. Shifts a zero into bit 7 and bit 0
			#     into the carry flag. The 6800 processor also affects the V flag.
			#
			# LSR - Direct - Opcode: 04 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.LSR_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _lsr(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ROR    Rotate right
			# Source Form: ROR Q; RORA; RORB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      ->     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Rotates all bits of the operand right one place through the carry flag; this is
			#     a nine-bit rotation. The 6800 processor also affects the V flag.
			#
			# ROR - Direct - Opcode: 06 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.ROR_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _ror(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ASR    Arithmetic shift right
			# Source Form: ASR Q
			# Operation:
			# _____
			# |   |
			# |  _________________    _____
			# -->| | | | | | | | | -> | C |
			#    -----------------    -----
			#    b7             b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of result are clear
			#     V: Not affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Shifts all bits of the operand right one place. Bit 7 is held constant. Bit 0 is
			#     shifted into the carry flag. The 6800/01/02/03/08 processors do affect the V
			#     flag.
			#
			# ASR - Direct - Opcode: 07 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.ASR_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _asr(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ASL    Arithmetic shift left
			# Source Form: ASL Q
			# Operation:
			# _____    _________________
			# | C | <- | | | | | | | | | <- 0
			# -----    -----------------
			#          b7      <-     b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of the result are clear
			#     V: Loaded with the result of b7 ^ b0 of the original operand.
			#     C: Loaded with bit 7 of the original operand.
			# Description:
			#     Shifts all bits of the operand one place to the left. Bit 0 is loaded with a
			#     zero. Bit 7 of the operand is shifted into the carry flag.
			#
			# ASL - Direct - Opcode: 08 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.ASL_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _asl(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ROL    Rotate left
			# Source Form: ROL Q; ROLA; ROLB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      <-     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Loaded with the result of (b7 ^ b6) of the original operand.
			#     C: Loaded with bit 7 of the original operand
			# Description:
			#     Rotate all bits of the operand one place left through the carry flag; this is a
			#     9-bit rotation.
			#
			# ROL - Direct - Opcode: 09 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.ROL_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _rol(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# DEC    Decrement
			# Source Form: DEC Q; DECA; DECB
			# Operation: M' (R') <- M-1 (R-1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Not affected
			# Description:
			#     Subtract one from the operand. The carry flag is not affected, thus allowing DEC
			#     to be a loopcounter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values only BEQ and BNE branches can be expected to
			#     behave consistently. When operating on two's complement values, all signed
			#     branches are available.
			#
			# DEC - Direct - Opcode: 0A - MPU Cycles: 6 - No of bytes: 2
			Opcodes.DEC_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _dec(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# INC    Increment
			# Source Form: INC Q; INCA, INCB
			# Operation: M' (R') <- M + 1 (R + 1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the original operand was 01111111
			#     C: Not Affected
			# Description:
			#     Add one to the operand. The carry flag is not affected, thus allowing INC to be
			#     used as a loop-counter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values, only the BEQ and BNE branches can be expected
			#     to behave consistently. When operating on two's complement values, all signed
			#     branches are correctly available.
			#
			# INC - Direct - Opcode: 0C - MPU Cycles: 6 - No of bytes: 2
			Opcodes.INC_DIRECT:
				var address := _retrieve_direct_address()
				var byte := _inc(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# TST    Test
			# Source Form: TST Q; TSTA; TSTB
			# Operation: TEMP <- M - 0
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Set condition code flags N and Z according to the contents of M, and clear the V
			#     flag. The 6800 processor clears the C flag.
			# Comments:
			#     The TST instruction provides only minimum information when testing unsigned
			#     values; since no unsigned value is less than zero, BLO and BLS have no utility.
			#     While BHI could be used after TST, it provides exactly the same control as BNE,
			#     which is preferred. The signed branches are available.
			#
			# TST - Direct - Opcode: 0D - MPU Cycles: 6 - No of bytes: 2
			Opcodes.TST_DIRECT:
				_tst(_read(_retrieve_direct_address()))
				cycle_counter += 6

			# JMP    Jump to effective address
			# Source Form: JMP
			# Operation: PC <- EA
			# Condition Codes: Not Affected
			# Description:
			#     Program control is transferred to the location equivalent to the effective
			#     address
			#
			# JMP - Direct - Opcode: 0E - MPU Cycles: 3 - No of bytes: 2
			Opcodes.JMP_DIRECT:
				program_counter = direct_page_register.dp | _read(program_counter)
				cycle_counter += 3

			# CLR    Clear
			# Source Form: CLR Q, CLRA, CLRB
			# Operation: TEMP <- M
			#            M <- 00 (16)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set
			#     V: Cleared
			#     C: Cleared
			# Description:
			#     ACCX or M is loaded with 00000000. The C-flag is cleared for 6800 compatibility.
			#
			# CLR - Direct - Opcode: 0F - MPU Cycles: 6 - No of bytes: 2
			Opcodes.CLR_DIRECT:
				_write(_retrieve_direct_address(), 0)
				_clr()
				cycle_counter += 6

			Opcodes.PAGE2:
				opcode1 = _read_and_advance_program_counter()
				match ((opcode1 << 8) | opcode2):
					# BRN    Branch never
					# Source Form: BRN DD; LBRN DDDD
					# Operation: TEMP <- MI
					# Condition Codes: Not Affected
					# Description:
					#     Does not cause a branch. This instruction is essentially a NO-OP, but has
					#     a bit pattern logically related to BRA.
					#
					# LBRN - Relative - Opcode: 1021 - MPU Cycles: 5 - No of bytes: 4
					Opcodes.LBRN_RELATIVE:
						program_counter += 2
						cycle_counter += 5

					# BHI    Branch if higher
					# Source Forms: BHI DD; LBHI DDDD
					# Operaiton: TEMP <- MI
					#            if C ∨ Z = 0 then PC <- PC + TEMP
					# Condition Codes: Not affected
					# Description:
					#     Causes a branch if the previous operation caused neither a carry nor a
					#     zero result.
					# Comments:
					#     Used after a subtract or compare operation on unsigned binary values,
					#     this instruction will "branch" if the register was higher than the memory
					#     operand. Not useful, in general, after INC/DEC, LD/ST, TST/CLR/COM.
					#
					# LBHI - Relative - Opcode: 1022 - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBHI_RELATIVE:
						if (condition_code_register.carry == false
								&& condition_code_register.zero == false
								):
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BLS    Branch on lower or same
					# Source Forms: BLS DD; LBLS DDDD
					# Operation: TEMP <- MI
					#            if C ∨ Z = 1 then PC <- PC + TEMP
					# Condition Codes: Not affected
					# Description:
					#     Causes a branch if the previous operation caused either a carry or a zero
					#     result.
					# Comments:
					#     Used after a subtract or compare operation on unsigned binary values,
					#     this instruction will "branch" if the register was lower than or the same
					#     as the memory operand. Not useful, in general, after INC/DEC, LD/ST,
					#     TST/CLR/COM.
					#
					# LBLS - Relative - Opcode: 1023 - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBLS_RELATIVE:
						if condition_code_register.carry or condition_code_register.zero:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BCC    Branch on carry clear
					# Source Form: BCC DD; LBCC DDDD
					# Operation: TEMP <- MI
					#            if C = 0 then PC <- PC + TEMP
					# Condition Codes: Not affected
					# Description:
					#     Tests the state of the C bit and causes a branch if C is clear.
					# Comments:
					#     When used after a subtract or compare on unsigned binary values, this
					#     instruction could be called "branch" if the register was higher or the
					#     same as the memory operand.
					#
					# Comments (BHS):
					#     ... This is a duplicate assembly-language mnemonic for the single machine
					#     instruction BCC. Not useful, in general, after INC/DEC, LD/ST,
					#     TST/CLR/COM.
					#
					# LBCC - Relative - Opcode: 1024 - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBHS_RELATIVE:
						if not condition_code_register.carry:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 6

					# BCS    Branch on carry set
					# Source Form: BCS DD; LBCS DDDD
					# Operation: TEMP <- MI
					#            if C = 1 then PC <- PC + TEMP
					# Condition Codes: Not affected
					# Description:
					#     Tests the state of the C bit and causes a branch if C is set.
					# Comments:
					#     When used after a subtract or compare, on unsigned binary values, this
					#     instruction could be called "branch" if the register was lower than the
					#     memory operand.
					# Comments on BLO:
					#     Note that this is a duplicate assembly-language mnemonic for the single
					#     machine instruction BCS. Not useful, in general, after INC/DEC, LD/ST,
					#     TST/CLR/COM.
					#
					# LBCS - Relative - Opcode: 1025 - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBCS_RELATIVE:
						if condition_code_register.carry:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BNE    Branch not equal
					# Source Forms: BNE DD; LBNE DDDD
					# Operation: TEMP <- MI
					#            if Z = 0 then PC <- PC + TEMP
					# Condition Codes: Not Affected
					# Description:
					#     Tests the state of the Z bit and causes a branch if the Z bit is clear.
					# Comments:
					#     Used after a subtract or compare operation on any binary values, this
					#     instruction will "branch if the register is (or would be) not equal to
					#     the memory operand."
					#
					# LBNE - Relative - Opcode: 1026 - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBNE_RELATIVE:
						if not condition_code_register.zero:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BEQ    Branch on equal
					# Source Forms: BEQ DD; LBEQ DDDD;
					# Operation: TEMP <- MI
					#            if Z = 1 then PC <- PC + TEMP
					# Condition Codes: Not affected.
					# Description:
					#     Tests the state of the Z bit and causes a branch if the Z bit is set.
					# Comments:
					#     Used after a subtract or compare operation, this instruction will branch
					#     if the compared values - signed or unsigned - were exactly the same.
					#
					# LBEQ - Relative - Opcode: 1027 - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBEQ_RELATIVE:
						if condition_code_register.zero:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BVC    Branch on overflow clear
					# Source Form: BVC DD; LBVC DDDD
					# Operation: TEMP <- MI
					#            if V = 0 then PC <- PC + TEMP
					# Condition Codes: Not Affected
					# Description:
					#     Tests the state of the V bit and causes a branch if the V bit is clear.
					#     That is, branch if the two's complement result was valid.
					# Comments:
					#     Used after an operation on two's complement binary values, this
					#     instruction will "branch if there was no overflow."
					#
					# LBVC - Relative - Opcode: 1028 - MPU Cycles 5(6) - No of bytes: 4
					Opcodes.LBVC_RELATIVE:
						if not condition_code_register.overflow:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BVS    Branch on overflow set
					# Source Form: BVS DD; LBVS DDDD
					# Operation: TEMP <- MI
					#            if V = 1 then PC <- PC + TEMP
					# Condition Codes: Not Affected
					# Description:
					#     Tests the state of the V bit and causes a branch if the V bit is set.
					#     That is, branch if the two's complement result was invalid.
					# Comments:
					#     Used after an operation on two's complement binary values, this
					#     instruction will "branch if there was an overflow." This instruction is
					#     also used after ASL or LSL to detect binary floating-point normalization.
					#
					# LBVS - Relative - Opcode: 1029 - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBVS_RELATIVE:
						if condition_code_register.overflow:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BPL    Branch if plus
					# Source Form: BPL DD; LBPL DDDD
					# Operation: TEMP <- MI
					#            if N = 0 then PC <- PC + TEMP
					# Condition Codes: Not Affected
					# Description:
					#     Tests the state of the N bit and causes a branch if N is clear. That is,
					#     branch if the sign of the two's complement result is positive.
					# Comments:
					#     Used after an operation on two's complement binary values, this
					#     instruction will "branch if the possibly invalid result is positive."
					#
					# LBPL - Relative - Opcode: 102A - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBPL_RELATIVE:
						if not condition_code_register.negative:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BMI    Branch on minus
					# Source Form: BMI DD; LBMI DDDD
					# Operation: TEMP <- MI
					#            if N = 1 then PC <- PC + TEMP
					# Condition Codes: Not Affected
					# Description:
					#     Tests the state of the N bit and causes a branch if N is set. That is,
					#     branch if the sign of the two's complement result is negative.
					# Comments:
					#     Used after an operation on two's complement binary values, this
					#     instruction will "branch if the (possibly invalid) result is minus."
					#
					# LBMI - Relative - Opcode: 102B - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBMI_RELATIVE:
						if condition_code_register.negative:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5
					
					# BGE    Branch on greater than or equal to zero
					# Source Forms: BGE DD; LBGE DDDD;
					# Operation: TEMP <- MI
					#            if N ^ V = 0 then PC <- PC + TEMP
					# Condition Codes: Not affected
					# Description:
					#     Causes a branch if N and V are either both set or both clear. For
					#     example, branch if the sign of a valid two's complement result is, or
					#     would be, positive.
					# Comments:
					#     Used after a subtract or compare operation on two's complement values,
					#     this instruction will branch if the register was greater than or equal to
					#     the memory operand.
					#
					# LBGE - Relative - Opcode: 102C - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBGE_RELATIVE:
						if condition_code_register.negative == condition_code_register.overflow:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BLT    Branch on less than zero
					# Source Forms: BLT DD; LBLT DDDD;
					# Operation: Temp <- MI
					#            if N ^ V = 1 then PC <- PC + TEMP
					# Condition Codes: Not affected
					# Description:
					#     Causes a branch if either, but not both, of the N or V bits is 1. That
					#     is, branch if the sign of a valid two's complement result is - or would
					#     be - negative.
					# Comments:
					#     Used after a subtract or compare operation on two's complement binary
					#     values, this instruction will "branch if the register was less than the
					#     memory operand."
					#
					# LBLT - Relative - Opcode: 102D - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBLT_RELATIVE:
						if condition_code_register.negative != condition_code_register.overflow:
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BGT    Branch on greater
					# Source Forms: BGT DD; LBGT DDDD;
					# Operation: TEMP <- MI
					#            if Z ∨ (N ^ V) = 0 then PC <- PC + TEMP
					# Condition Codes: Not affected
					# Description:
					#     Causes a branch if (N and V are either both set or both clear) and Z is
					#     clear. In other words, branch if the sign of a valid two's complemet
					#     result is, or would be, positive and non-zero.
					# Comments:
					#     Used after a subtract or compare operation on two's complement values,
					#     this instruction will "branch" if the register was greater than the
					#     memory operand.
					#
					# LBGT - Relative - Opcode: 102E - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBGT_RELATIVE:
						if condition_code_register.zero == false \
								and (condition_code_register.negative == condition_code_register.overflow):
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# BLE    Branch on less than or equal to zero
					# Source Form: BLE DD; LBLE DDDD;
					# Operation: TEMP <- MI
					#            if Z ∨ (N ^ V) = 1 then PC = PC + TEMP
					# Condition Codes: Not Affected
					# Description:
					#     Causes a branch if the "Exclusive OR" of the N and V bits is 1 or if
					#     Z = 1. That is, branch if the sign of a valid two's complement result is
					#     - or would be - negative.
					# Comments:
					#     Used after a subtract or compare operation on two's complement values,
					#     this instruction will "branch" if the register was less then or equal to
					#     the memory operand.
					#
					# LBLE - Relative - Opcode: 102F - MPU Cycles: 5(6) - No of bytes: 4
					Opcodes.LBLE_RELATIVE:
						if condition_code_register.zero \
								or (condition_code_register.negative != condition_code_register.overflow):
							_lb_relative_offset()
							cycle_counter += 1
						program_counter += 2
						cycle_counter += 5

					# SWI2    Software Interrupt 2
					# Source Form: SWI2
					# Operation: Set E (entire state saved)
					#            SP' <- SP - 1, (SP) <- PCL
					#            SP' <- SP - 1, (SP) <- PCH
					#            SP' <- SP - 1, (SP) <- USL
					#            SP' <- SP - 1, (SP) <- USH
					#            SP' <- SP - 1, (SP) <- IYL
					#            SP' <- SP - 1, (SP) <- IYH
					#            SP' <- SP - 1, (SP) <- IXL
					#            SP' <- SP - 1, (SP) <- IXH
					#            SP' <- SP - 1, (SP) <- DPR
					#            SP' <- SP - 1, (SP) <- ACCB
					#            SP' <- SP - 1, (SP) <- ACCA
					#            SP' <- SP - 1, (SP) <- CCR
					#            PC' <- (FFF4):(FFF5)
					# Condition Codes: Not Affected
					# Description:
					#     All of the MPU registers are pushed onto the hardware stack (excepting
					#     only the hardware stack pointer itself), and control is transferred
					#     through the SWI2 vector. SWI2 is available to the end user and must not
					#     be used in packaged software.
					#
					#     SWI2 DOES NOT AFFECT I AND F BITS
					#
					# SWI2 - Inherent - Opcode: 103F - MPU Cycles: 20 - No of bytes: 2
					Opcodes.SWI2_INHERENT:
						condition_code_register.entire = true
						_push_machine_state()
						program_counter = _read2(VectorTable.SWI2)
						cycle_counter += 20

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPD - Immediate - Opcode: 1083 - MPU Cycles: 5 - No of bytes: 4
					Opcodes.CMPD_IMMEDIATE:
						_cmpd(_read2_and_advance_program_counter())
						cycle_counter += 5

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPY - Immediate - Opcode: 108C - MPU Cycles: 5 - No of bytes: 4
					Opcodes.CMPY_IMMEDIATE:
						_cmpy(_read2_and_advance_program_counter())
						cycle_counter += 5

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDY - Immediate - Opcode: 108E - MPU Cycles: 4 - No of bytes: 4
					Opcodes.LDY_IMMEDIATE:
						y_index_register = _read2(program_counter)
						_reg_cc16(y_index_register)
						program_counter += 2
						cycle_counter += 5

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPD - Direct - Opcode: 1093 - MPU Cycles: 7 - No of bytes: 3
					Opcodes.CMPD_DIRECT:
						_cmpd(_read2(_retrieve_direct_address()))
						cycle_counter += 7

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPY - Direct - Opcode: 109C - MPU Cycles: 7 - No of bytes: 3
					Opcodes.CMPY_DIRECT:
						_cmpy(_read2(_retrieve_direct_address()))
						cycle_counter += 7

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDY - Direct - Opcode: 109E - MPU Cycles: 6 - No of bytes: 3
					Opcodes.LDY_DIRECT:
						y_index_register = _read2(_retrieve_direct_address())
						_reg_cc16(y_index_register)
						cycle_counter += 6

					# ST    Store register into memory
					# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
					# Operation: M'(:M+1') <- R
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of stored data was Set
					#     Z: Set if all bits of stored data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Writes the contents of an MPU register into a memory location.
					#
					# STY - Direct - Opcode: 109F - MPU Cycles: 6 - No of bytes: 3
					Opcodes.STY_DIRECT:
						_st_reg16(_retrieve_direct_address(), y_index_register)
						cycle_counter += 6

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPD - Indexed - Opcode: 10A3 - MPU Cycles: 7+ - No of bytes: 3+
					Opcodes.CMPD_INDEXED:
						_cmpd(_read2(_retrieve_effective_address()))
						cycle_counter += 7

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPY - Indexed - Opcode: 10AC - MPU Cycles: 7+ - No of bytes: 3+
					Opcodes.CMPY_INDEXED:
						_cmpy(_read2(_retrieve_effective_address()))
						cycle_counter += 7

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDY - Indexed - Opcode: 10AE - MPU Cycles: 6+ - No of bytes: 3+
					Opcodes.LDY_INDEXED:
						y_index_register = _read2(_retrieve_effective_address())
						_reg_cc16(y_index_register)
						cycle_counter += 6

					# ST    Store register into memory
					# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
					# Operation: M'(:M+1') <- R
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of stored data was Set
					#     Z: Set if all bits of stored data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Writes the contents of an MPU register into a memory location.
					#
					# STY - Indexed - Opcode: 10AF - MPU Cycles: 6+ - No of bytes: 3+
					Opcodes.STY_INDEXED:
						_st_reg16(_retrieve_effective_address(), y_index_register)
						cycle_counter += 6

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPD - Extended - Opcode: 10B3 - MPU Cycles: 8 - No of bytes: 4
					Opcodes.CMPD_EXTENDED:
						_cmpd(_read2(_read2_and_advance_program_counter()))
						cycle_counter += 8

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPY - Extended - Opcode: 10BC - MPU Cycles: 8 - No of bytes: 4
					Opcodes.CMPY_EXTENDED:
						_cmpy(_read2(_read2_and_advance_program_counter()))
						cycle_counter += 8

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDY - Extended - Opcode: 10BE - MPU Cycles: 7 - No of bytes: 4
					Opcodes.LDY_EXTENDED:
						y_index_register = _read2(_read2_and_advance_program_counter())
						_reg_cc16(y_index_register)
						cycle_counter += 7

					# ST    Store register into memory
					# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
					# Operation: M'(:M+1') <- R
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of stored data was Set
					#     Z: Set if all bits of stored data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Writes the contents of an MPU register into a memory location.
					#
					# STY - Extended - Opcode: 10DF - MPU Cycles: 7 - No of bytes: 4
					Opcodes.STY_EXTENDED:
						_st_reg16(_read2_and_advance_program_counter(), y_index_register)
						cycle_counter += 7

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDS - Immediate - Opcode: 10CE - MPU Cycles: 4 - No of bytes: 4
					Opcodes.LDS_IMMEDIATE:
						hardware_stack_pointer = _read2_and_advance_program_counter()
						_reg_cc16(hardware_stack_pointer)
						cycle_counter += 4

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDS - Direct - Opcode: 10DE - MPU Cycles: 6 - No of bytes: 3
					Opcodes.LDS_DIRECT:
						hardware_stack_pointer = _read2(_retrieve_direct_address())
						_reg_cc16(hardware_stack_pointer)
						cycle_counter += 6

					# ST    Store register into memory
					# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
					# Operation: M'(:M+1') <- R
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of stored data was Set
					#     Z: Set if all bits of stored data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Writes the contents of an MPU register into a memory location.
					#
					# STS - Direct - Opcode: 10DF - MPU Cycles: 6 - No of bytes: 3
					Opcodes.STS_DIRECT:
						_st_reg16(_retrieve_direct_address(), hardware_stack_pointer)
						cycle_counter += 6

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDS - Indexed - Opcode: 10EE - MPU Cycles: 6+ - No of bytes: 3+
					Opcodes.LDS_INDEXED:
						hardware_stack_pointer = _read2(_retrieve_effective_address())
						_reg_cc16(hardware_stack_pointer)
						cycle_counter += 6

					# ST    Store register into memory
					# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
					# Operation: M'(:M+1') <- R
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of stored data was Set
					#     Z: Set if all bits of stored data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Writes the contents of an MPU register into a memory location.
					#
					# STS - Indexed - Opcode: 10EF - MPU Cycles: 6+ - No of bytes: 3+
					Opcodes.STS_INDEXED:
						_st_reg16(_retrieve_effective_address(), hardware_stack_pointer)
						cycle_counter += 6

					# LD    Load register from memory
					# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
					# Operation: R' <- M(:M+1)
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of loaded data is Set
					#     Z: Set if all bits of loaded data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Load the contents of the addressed memory into the register.
					#
					# LDS - Extended - Opcode: 10FE - MPU Cycles: 7 - No of bytes: 4
					Opcodes.LDS_EXTENDED:
						hardware_stack_pointer = _read2(_read2_and_advance_program_counter())
						_reg_cc16(hardware_stack_pointer)
						cycle_counter += 7

					# ST    Store register into memory
					# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
					# Operation: M'(:M+1') <- R
					# Condition Codes:
					#     H: Not Affected
					#     N: Set if bit 7 (15) of stored data was Set
					#     Z: Set if all bits of stored data are Clear
					#     V: Cleared
					#     C: Not Affected
					# Description:
					#     Writes the contents of an MPU register into a memory location.
					#
					# STS - Extended - Opcode: 10FF - MPU Cycles: 7 - No of bytes: 4
					Opcodes.STS_EXTENDED:
						_st_reg16(_read2_and_advance_program_counter(), hardware_stack_pointer)
						cycle_counter += 7

					_:
						pass
			
			Opcodes.PAGE3:
				opcode2 = _read(program_counter)
				program_counter += 1
				match ((opcode1 << 8) | opcode2):
					# SWI3    Software Interrupt 3
					# Source Form: SWI3
					# Operation: Set E (entire state saved)
					#            SP' <- SP - 1, (SP) <- PCL
					#            SP' <- SP - 1, (SP) <- PCH
					#            SP' <- SP - 1, (SP) <- USL
					#            SP' <- SP - 1, (SP) <- USH
					#            SP' <- SP - 1, (SP) <- IYL
					#            SP' <- SP - 1, (SP) <- IYH
					#            SP' <- SP - 1, (SP) <- IXL
					#            SP' <- SP - 1, (SP) <- IXH
					#            SP' <- SP - 1, (SP) <- DPR
					#            SP' <- SP - 1, (SP) <- ACCB
					#            SP' <- SP - 1, (SP) <- ACCA
					#            SP' <- SP - 1, (SP) <- CCR
					#            PC' <- (FFF2):(FFF3)
					# Condition Codes: Not Affected
					# Description:
					#     All of the MPU registers are pushed onto the hardware stack (excepting
					#     only the hardware stack pointer itself), and control is transferred
					#     through the SWI3 vector.
					#
					#     SWI3 DOES NOT AFFECT I AND F BITS
					#
					# SWI3 - Inherent - Opcode: 113F - MPU Cycles: 20 - No of bytes: 2
					Opcodes.SWI3_INHERENT:
						condition_code_register.entire = true
						_push_machine_state()
						program_counter = _read2(VectorTable.SWI3)
						cycle_counter += 20

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPU - Immediate - Opcode: 1183 - MPU Cycles: 5 - No of bytes: 4
					Opcodes.CMPU_IMMEDIATE:
						_cmpu(_read2_and_advance_program_counter())
						cycle_counter += 5

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPS - Immediate - Opcode: 118C - MPU Cycles: 5 - No of bytes: 4
					Opcodes.CMPS_IMMEDIATE:
						_cmps(_read2_and_advance_program_counter())
						cycle_counter += 5

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPU - Direct - Opcode: 1193 - MPU Cycles: 7 - No of bytes: 3
					Opcodes.CMPU_DIRECT:
						_cmpu(_read2(_retrieve_direct_address()))
						cycle_counter += 7

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPS - Direct - Opcode: 119C - MPU Cycles: 7 - No of bytes: 3
					Opcodes.CMPS_DIRECT:
						_cmps(_read2(_retrieve_direct_address()))
						cycle_counter += 7

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPU - Indexed - Opcode: 11A3 - MPU Cycles: 7+ - No of bytes: 3+
					Opcodes.CMPU_INDEXED:
						_cmpu(_read2(_retrieve_effective_address()))
						cycle_counter += 7

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPS - Indexed - Opcode: 11AC - MPU Cycles: 7+ - No of bytes: 3+
					Opcodes.CMPS_INDEXED:
						_cmps(_read2(_retrieve_effective_address()))
						cycle_counter += 7

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPU - Extended - Opcode: 11B3 - MPU Cycles: 8 - No of bytes: 4
					Opcodes.CMPU_EXTENDED:
						_cmpu(_read2(_read2_and_advance_program_counter()))
						cycle_counter += 8

					# CMP    Compare memory from a register
					# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
					# Operation: TEMP <- R - M(:M+1)
					# Condition Codes:
					#     H: Undefined
					#     N: Set if bit 7 (15) of the result is Set.
					#     Z: Set if all bits of the result are Clear
					#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
					#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
					# Description:
					#     Compares the contents of M from teh contents of the specified register
					#     and sets appropriate condition codes. Neither M nor R is modified. The C
					#     flag represents a borrow and is set inverse to the resulting binary
					#     carry.
					#
					# CMPS - Extended - Opcode: 11BC - MPU Cycles: 8 - No of bytes: 4
					Opcodes.CMPS_EXTENDED:
						_cmps(_read2(_read2_and_advance_program_counter()))
						cycle_counter += 8

					_:
						pass

			# NOP    No operation
			# Source Form: NOP
			# Condition CodeS: Not Affected
			# Description:
			#     This is a single-byte instruction that causes only the program counter to be
			#     incremented. No other registers or memory contents are affected.
			#
			# NOP - Inherent - Opcode: 12 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.NOP_INHERENT:
				cycle_counter += 2

			# SYNC    Synchronize to external event
			# Source Form: SYNC
			# Operation: Stop processing instructions
			# Condition CodeS: Unaffected
			# Description:
			#     Whan a SYNC instruction is executed, the MPU enters a SYNCING state, stops
			#     processing instructions and waits on an interrupt. When an interrupt occurs, the
			#     SYNCING state is cleared and processing continues. IF the interrupt is enabled,
			#     and the interrupt lasts 3 cycles or more, the processor will perform the
			#     interrupt routine. If the interrupt is masked or is shorter than 3 cycles long,
			#     the processor simply continues to the next instruction (without stacking
			#     registers). While SYNCING, the address and data buses are tri-state.
			# Comments:
			#     This instruction provides software synchronization with a hardware process.
			#     Consider the high-speed acquisition of data:
			#
			#           FOR DATA
			#     FAST  SYNC         WAIT FOR DATA
			#           <--------------------- interrupt!
			#           LDA  DISC    DATA FORM DISC AND CLEAR INTERRUPT
			#           STA  ,X+     PUT IN BUFFER
			#           DECB         COUNT IT, DONE?
			#           BNE  FAST    GO AGAIN IF NOT.
			#
			#     The SYNCING state is cleared by any interrupt, and any enabled interrupt will
			#     probably destroy the transfer (this may be used to provide MPU response to an
			#     emergency condition).
			#
			#     The same connection used for interrupt-driven I/O service may thus be used for
			#     high-speed data transfers by setting the interrupt mask and using SYNC.
			#
			# SYNC - Inherent - Opcode: 13 - MPU Cycles >= 2 - No of bytes: 1
			Opcodes.SYNC_INHERENT:
				cycle_counter = num_cycles_to_run
				# Interrupt or RESET acknowledge
				pins.set_pin(Pins.BA, true)
				pins.set_pin(Pins.BS, false)
				syncing = true

			# BRA    Branch always
			# Source Forms: BRA DD; LBRA DDDD
			# Operation: TEMP <- MI
			#            PC <- PC + TEMP
			# Condition CodeS: Not Affected
			# Description:
			#     Causes an unconditional branch.
			#
			# LBRA - Relative - Opcode: 16 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.LBRA_RELATIVE:
				_lb_relative_offset()
				program_counter += 2
				cycle_counter += 5

			# BSR    Branch to subroutine
			# Source Forms: BSR DD; LBSR DDDD
			# Operation: TEMP <- MI
			#            SP' <- SP - 1, (SP) <- PCL
			#            SP' <- SP - 1, (SP) <- PCH
			#            PC <- PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     The program counter is pushed onto the stack. The program counter is then loaded
			#     with the sum of the program counter and the memory immediate offset.
			#
			# LBSR - Relative - Opcode: 17 - MPU Cycles: 9 - No of bytes: 3
			Opcodes.LBSR_RELATIVE:
				var address := _read2_and_advance_program_counter()
				_push_program_counter()
				program_counter = address
				cycle_counter += 9

			# DA    Decimal Addition Adjust
			# Source Form: DAA
			# Operation: ACCA' <- Acca + CF(MSN):CF(LSN)
			#            where CF is a Correction Factor, as follows:
			#
			#            The CF for each nybble (BCD Digit) is determined separately, and is either
			#            6 or 0.
			#
			#            Least Significant Nybble: CF(LSN) = 6 if 1) H = 1
			#                                                     or 2) LSN > 9
			#            Most Sifnigicant Nybble: CF(MSN) = 6 if 1) C = 1
			#                                                    or 2) MSN > 9
			#                                                    or 3) MSN > 8 and LSN > 9
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if MSB of result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Not defined
			#     C: Set if the operation caused a carry from bit 7 in the ALU, or if the carry
			#        flag was Set before the operation.
			# Description:
			#     The sequence of a single-byte add instruction on ACCA (either ADDA or ADCA) and a
			#     following DAA instruction results in a BCD addition with appropriate carry flag.
			#     Both values to be added must be in proper BCD form (each nybble such that 0 <=
			#     nybble <= 9). Multiple-precision additions must add the carry generated by this
			#     DA into the next higher digit during the add operation immediately prior to the
			#     next DA.
			#
			# DAA - Inherent - Opcode: 19 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.DAA_INHERENT:
				var most_significant_nibble := (accumulators.a >> 4) & 0xF
				var least_significant_nibble := accumulators.a & 0xF
				var addition: int = 0

				if condition_code_register.half_carry or least_significant_nibble > 9:
					addition |= 0x06

				if condition_code_register.carry \
						or most_significant_nibble > 9 \
						or (most_significant_nibble > 8 and least_significant_nibble > 9):
					addition |= 0x60

				addition += accumulators.a
				accumulators.a = addition & 0xFF
				condition_code_register.negative = accumulators.a & 0x80
				condition_code_register.zero = accumulators.a == 0
				condition_code_register.carry = addition & 0x100
				cycle_counter += 2

			# OR    Inclusive OR memory-immediate into CCR
			# Source Form: ORCC #XX
			# Operation: R <- R ∨ MI
			# Condition Codes: CCR' <- CCR ∨ MI
			# Description:
			#     Performs an "inclusive OR" operation between the contents of CCR and the contents
			#     of MI, and the result is placed in CCR. This instruction may be used to Set
			#     interrupt masks (disable interrupts) or any other flag(s).
			#
			# ORCC - Immediate - Opcode: 1A - MPU Cycles: 3 - No of bytes: 2
			Opcodes.ORCC_IMMEDIATE:
				condition_code_register.register |= _read_and_advance_program_counter()
				cycle_counter += 3

			# AND    Logical AND immediate memory into CCR
			# Source Form: ANDCC #XX
			# Operation: R' <- R ∧ MI
			# Condition Codes:
			#     CCR' <- CCR ∧ MI
			# Description:
			#     Performs a logical "AND" between the CCR and the MI byte and places the result in
			#     the CCR.
			#
			# ANDCC - Immediate - Opcode: 1C - MPU Cycles: 3 - No of bytes 2
			Opcodes.ANDCC_IMMEDIATE:
				condition_code_register.register &= _read_and_advance_program_counter()
				cycle_counter += 3

			# SEX    Sign extended
			# Source Form: SEX
			# Operation: if bit 7 of ACCB is set then ACCA' <- FF (16) else ACCA' <- 00 (16)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if the MSB of the result is Set
			#     Z: Set if all bits of ACCD are Clear
			#     V: Not Affected
			#     C: Not Affected
			# Description:
			#     This instruction transformes a two's complement 8-bit value in ACCB into a two's
			#     complement 16-bit value in the double accumulator.
			#
			# SEX - Inherent - Opcode: 1D - MPU Cycles: 2 - No of bytes: 1
			Opcodes.SEX_INHERENT:
				if (accumulators.b & 0x80):
					accumulators.a = 0xFF
				else:
					accumulators.a = 0x00
				condition_code_register.negative = accumulators.d & 0x8000
				condition_code_register.zero = accumulators.d == 0
				cycle_counter += 2

			# EXG    Exchange registers
			# Source Form: EXG R1,R2
			# Operation: R1 <-> R2
			# Condition Codes: Not Affected (unless one of the registres is CCR)
			# Description:
			#     Bits 3-0 of the immediate byte of the instruction define one register, while bits
			#     7-4 define the other, as follows:
			#
			#     0000 = A:B          1000 = A
			#     0001 = X            1001 = B
			#     0010 = Y            1010 = CCR
			#     0011 = US           1011 = DPR
			#     0100 = SP           1100 = Undefined
			#     0101 = PC           1101 = Undefined
			#     0110 = Undefined    1110 = Undefined
			#     0111 = Undefined    1111 = Undefined
			#
			#     Registers may only be exchanged with registers of like size; i.e., 8-bit with
			#     8-bit, or 16 with 16.
			#
			# EXG - Inherent - Opcode: 1E - MPU Cycles: 7 - No of bytes: 2
			Opcodes.EXG_INHERENT:
				var post := _read_and_advance_program_counter()
				var source := post >> 4
				var destination := post & 0xF
				if ((source & 0x8) and (destination & 0x8)):
					_exg_registers(source, destination)
				cycle_counter += 8

			# TFR    Transfer register to register
			# Source Form: TFR R1,R2
			# Operation: R1 <- R2
			# Condition Codes: Not Affected (unless R2 = CCR)
			# Description:
			#     Bits 7-4 of the immediate byte of the instruction define the source register,
			#     while bits 3-0 define the destination register, as follows:
			#
			#     0000 = A:B          1000 = A
			#     0001 = X            1001 = B
			#     0010 = Y            1010 = CCR
			#     0011 = US           1011 = DPR
			#     0100 = SP           1100 = Undefined
			#     0101 = PC           1101 = Undefined
			#     0110 = Undefined    1110 = Undefined
			#     0111 = Undefined    1111 = Undefined
			#
			#     Registers may only be transferred between registers of like size; i.e., 8-bit
			#     with 8-bit, or 16 with 16.
			#
			# TFR - Inherent - Opcode: 1F - MPU Cycles: 7 - No of bytes: 2
			Opcodes.TFR_INHERENT:
				var post := _read_and_advance_program_counter()
				var source := post >> 4
				var destination := post & 0xF
				if ((source & 0x8) and (destination & 0x8)):
					_write_to_register(destination, _read_from_register(source))
				cycle_counter += 6

			# BRA    Branch always
			# Source Forms: BRA DD; LBRA DDDD
			# Operation: TEMP <- MI
			#            PC <- PC + TEMP
			# Condition CodeS: Not Affected
			# Description:
			#     Causes an unconditional branch.
			#
			# BRA - Relative - Opcode: 20 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BRA_RELATIVE:
				var post := _make_signed_8(_read_and_advance_program_counter())
				program_counter += post
				cycle_counter += 3

			# BRN    Branch never
			# Source Form: BRN DD; LBRN DDDD
			# Operation: TEMP <- MI
			# Condition Codes: Not Affected
			# Description:
			#     Does not cause a branch. This instruction is essentially a NO-OP, but has a bit
			#     pattern logically related to BRA.
			#
			# BRN - Relative - Opcode: 21 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BRN_RELATIVE:
				program_counter += 1
				cycle_counter += 3

			# BHI    Branch if higher
			# Source Forms: BHI DD; LBHI DDDD
			# Operaiton: TEMP <- MI
			#            if C ∨ Z = 0 then PC <- PC + TEMP
			# Condition Codes: Not affected
			# Description:
			#     Causes a branch if the previous operation caused neither a carry nor a zero
			#     result.
			# Comments:
			#     Used after a subtract or compare operation on unsigned binary values, this
			#     instruction will "branch" if the register was higher than the memory operand. Not
			#     useful, in general, after INC/DEC, LD/ST, TST/CLR/COM.
			#
			# BHI - Relative - Opcode: 22 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BHI_RELATIVE:
				if (condition_code_register.carry == false
						&& condition_code_register.zero == false
						):
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BLS    Branch on lower or same
			# Source Forms: BLS DD; LBLS DDDD
			# Operation: TEMP <- MI
			#            if C ∨ Z = 1 then PC <- PC + TEMP
			# Condition Codes: Not affected
			# Description:
			#     Causes a branch if the previous operation caused either a carry or a zero result.
			# Comments:
			#     Used after a subtract or compare operation on unsigned binary values, this
			#     instruction will "branch" if the register was lower than or the same as the
			#     memory operand. Not useful, in general, after INC/DEC, LD/ST, TST/CLR/COM.
			#
			# BLS - Relative - Opcode: 23 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BLS_RELATIVE:
				if condition_code_register.carry or condition_code_register.zero:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BCC    Branch on carry clear
			# Source Form: BCC DD; LBCC DDDD
			# Operation: TEMP <- MI
			#            if C = 0 then PC <- PC + TEMP
			# Condition Codes: Not affected
			# Description:
			#     Tests the state of the C bit and causes a branch if C is clear.
			# Comments:
			#     When used after a subtract or compare on unsigned binary values, this instruction
			#     could be called "branch" if the register was higher or the same as the memory
			#     operand.
			#
			# Comments (BHS):
			#     ... This is a duplicate assembly-language mnemonic for the single machine
			#     instruction BCC. Not useful, in general, after INC/DEC, LD/ST, TST/CLR/COM.
			#
			# BCC - Relative - Opcode: 24 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BHS_RELATIVE:
				if not condition_code_register.carry:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BCS    Branch on carry set
			# Source Form: BCS DD; LBCS DDDD
			# Operation: TEMP <- MI
			#            if C = 1 then PC <- PC + TEMP
			# Condition Codes: Not affected
			# Description:
			#     Tests the state of the C bit and causes a branch if C is set.
			# Comments:
			#     When used after a subtract or compare, on unsigned binary values, this
			#     instruction could be called "branch" if the register was lower than the memory
			#     operand.
			# Comments on BLO:
			#     Note that this is a duplicate assembly-language mnemonic for the single machine
			#     instruction BCS. Not useful, in general, after INC/DEC, LD/ST, TST/CLR/COM.
			#
			# BCS - Relative - Opcode: 25 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BLO_RELATIVE:
				if condition_code_register.carry:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BNE    Branch not equal
			# Source Forms: BNE DD; LBNE DDDD
			# Operation: TEMP <- MI
			#            if Z = 0 then PC <- PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     Tests the state of the Z bit and causes a branch if the Z bit is clear.
			# Comments:
			#     Used after a subtract or compare operation on any binary values, this instruction
			#     will "branch if the register is (or would be) not equal to the memory operand."
			#
			# BNE - Relative - Opcode: 26 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BNE_RELATIVE:
				if not condition_code_register.zero:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BEQ    Branch on equal
			# Source Forms: BEQ DD; LBEQ DDDD;
			# Operation: TEMP <- MI
			#            if Z = 1 then PC <- PC + TEMP
			# Condition Codes: Not affected.
			# Description:
			#     Tests the state of the Z bit and causes a branch if the Z bit is set.
			# Comments:
			#     Used after a subtract or compare operation, this instruction will branch if the
			#     compared values - signed or unsigned - were exactly the same.
			#
			# BEQ - Relative - Opcode: 27 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BEQ_RELATIVE:
				if condition_code_register.zero:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BVC    Branch on overflow clear
			# Source Form: BVC DD; LBVC DDDD
			# Operation: TEMP <- MI
			#            if V = 0 then PC <- PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     Tests the state of the V bit and causes a branch if the V bit is clear. That is,
			#     branch if the two's complement result was valid.
			# Comments:
			#     Used after an operation on two's complement binary values, this instruction will
			#     "branch if there was no overflow."
			#
			# BVC - Relative - Opcode: 28 - MPU Cycles 3 - No of bytes: 2
			Opcodes.BVC_RELATIVE:
				if not condition_code_register.overflow:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BVS    Branch on overflow set
			# Source Form: BVS DD; LBVS DDDD
			# Operation: TEMP <- MI
			#            if V = 1 then PC <- PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     Tests the state of the V bit and causes a branch if the V bit is set. That is,
			#     branch if the two's complement result was invalid.
			# Comments:
			#     Used after an operation on two's complement binary values, this instruction will
			#     "branch if there was an overflow." This instruction is also used after ASL or LSL
			#     to detect binary floating-point normalization.
			#
			# BVS - Relative - Opcode: 29 - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BVS_RELATIVE:
				if condition_code_register.overflow:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BPL    Branch if plus
			# Source Form: BPL DD; LBPL DDDD
			# Operation: TEMP <- MI
			#            if N = 0 then PC <- PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     Tests the state of the N bit and causes a branch if N is clear. That is, branch
			#     if the sign of the two's complement result is positive.
			# Comments:
			#     Used after an operation on two's complement binary values, this instruction will
			#     "branch if the possibly invalid result is positive."
			#
			# BPL - Relative - Opcode: 2A - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BPL_RELATIVE:
				if not condition_code_register.negative:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BMI    Branch on minus
			# Source Form: BMI DD; LBMI DDDD
			# Operation: TEMP <- MI
			#            if N = 1 then PC <- PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     Tests the state of the N bit and causes a branch if N is set. That is, branch if
			#     the sign of the two's complement result is negative.
			# Comments:
			#     Used after an operation on two's complement binary values, this instruction will
			#     "branch if the (possibly invalid) result is minus."
			#
			# BMI - Relative - Opcode: 2B - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BMI_RELATIVE:
				if condition_code_register.negative:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BGE    Branch on greater than or equal to zero
			# Source Forms: BGE DD; LBGE DDDD;
			# Operation: TEMP <- MI
			#            if N ^ V = 0 then PC <- PC + TEMP
			# Condition Codes: Not affected
			# Description:
			#     Causes a branch if N and V are either both set or both clear. For example, branch
			#     if the sign of a valid two's complement result is, or would be, positive.
			# Comments:
			#     Used after a subtract or compare operation on two's complement values, this
			#     instruction will branch if the register was greater than or equal to the memory
			#     operand.
			#
			# BGE - Relative - Opcode: 2C - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BGE_RELATIVE:
				if condition_code_register.negative == condition_code_register.overflow:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BLT    Branch on less than zero
			# Source Forms: BLT DD; LBLT DDDD;
			# Operation: Temp <- MI
			#            if N ^ V = 1 then PC <- PC + TEMP
			# Condition Codes: Not affected
			# Description:
			#     Causes a branch if either, but not both, of the N or V bits is 1. That is, branch
			#     if the sign of a valid two's complement result is - or would be - negative.
			# Comments:
			#     Used after a subtract or compare operation on two's complement binary values,
			#     this instruction will "branch if the register was less than the memory operand."
			#
			# BLT - Relative - Opcode: 2D - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BLT_RELATIVE:
				if condition_code_register.negative != condition_code_register.overflow:
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BGT    Branch on greater
			# Source Forms: BGT DD; LBGT DDDD;
			# Operation: TEMP <- MI
			#            if Z ∨ (N ^ V) = 0 then PC <- PC + TEMP
			# Condition Codes: Not affected
			# Description:
			#     Causes a branch if (N and V are either both set or both clear) and Z is clear. In
			#     other words, branch if the sign of a valid two's complemet result is, or would
			#     be, positive and non-zero.
			# Comments:
			#     Used after a subtract or compare operation on two's complement values, this
			#     instruction will "branch" if the register was greater than the memory operand.
			#
			# BGT - Relative - Opcode: 2E - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BGT_RELATIVE:
				if condition_code_register.zero == false \
						and (condition_code_register.negative == condition_code_register.overflow):
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# BLE    Branch on less than or equal to zero
			# Source Form: BLE DD; LBLE DDDD;
			# Operation: TEMP <- MI
			#            if Z ∨ (N ^ V) = 1 then PC = PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     Causes a branch if the "Exclusive OR" of the N and V bits is 1 or if Z = 1. That
			#     is, branch if the sign of a valid two's complement result is - or would be -
			#     negative.
			# Comments:
			#     Used after a subtract or compare operation on two's complement values, this
			#     instruction will "branch" if the register was less then or equal to the memory
			#     operand.
			#
			# BLE - Relative - Opcode: 2F - MPU Cycles: 3 - No of bytes: 2
			Opcodes.BLE_RELATIVE:
				if condition_code_register.zero \
						or (condition_code_register.negative != condition_code_register.overflow):
					_b_relative_offset()
				program_counter += 1
				cycle_counter += 3

			# LEA    Load effective address
			# Source Form: LEAX; LEAY; LEAS; LEAU
			# Operation: R' <- EA
			# Condition Codes:
			#     H: Not Affected
			#     N: Not Affected
			#     Z: LEAX, LEAY: Set if all bits of the result are Clear
			#        LEAS, LEAU: Not Affected
			#     V: Not Affected
			#     C: Not Affected
			# Description:
			#     Form the effective address to data using the memory addressing mode. Load that
			#     address, not the data itself, into the pointer register.
			#
			#     LEAX and LEAY affect Z to allow use as counters and for 6800 INX/DEX compatibilty
			#     LEAU and LEAS do not affect Z to allow for cleaning up the stack while returning
			#     Z as a parameter to a calling routine, and for 6800 INS/DES compatibility.
			#
			# LEAX - Indexed - Opcode: 30 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.LEAX_INDEXED:
				x_index_register = _retrieve_effective_address()
				condition_code_register.zero = x_index_register == 0
				cycle_counter += 4

			# LEA    Load effective address
			# Source Form: LEAX; LEAY; LEAS; LEAU
			# Operation: R' <- EA
			# Condition Codes:
			#     H: Not Affected
			#     N: Not Affected
			#     Z: LEAX, LEAY: Set if all bits of the result are Clear
			#        LEAS, LEAU: Not Affected
			#     V: Not Affected
			#     C: Not Affected
			# Description:
			#     Form the effective address to data using the memory addressing mode. Load that
			#     address, not the data itself, into the pointer register.
			#
			#     LEAX and LEAY affect Z to allow use as counters and for 6800 INX/DEX compatibilty
			#     LEAU and LEAS do not affect Z to allow for cleaning up the stack while returning
			#     Z as a parameter to a calling routine, and for 6800 INS/DES compatibility.
			#
			# LEAY - Indexed - Opcode: 31 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.LEAY_INDEXED:
				y_index_register = _retrieve_effective_address()
				condition_code_register.zero = y_index_register == 0
				cycle_counter += 4

			# LEA    Load effective address
			# Source Form: LEAX; LEAY; LEAS; LEAU
			# Operation: R' <- EA
			# Condition Codes:
			#     H: Not Affected
			#     N: Not Affected
			#     Z: LEAX, LEAY: Set if all bits of the result are Clear
			#        LEAS, LEAU: Not Affected
			#     V: Not Affected
			#     C: Not Affected
			# Description:
			#     Form the effective address to data using the memory addressing mode. Load that
			#     address, not the data itself, into the pointer register.
			#
			#     LEAX and LEAY affect Z to allow use as counters and for 6800 INX/DEX compatibilty
			#     LEAU and LEAS do not affect Z to allow for cleaning up the stack while returning
			#     Z as a parameter to a calling routine, and for 6800 INS/DES compatibility.
			#
			# LEAS - Indexed - Opcode: 32 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.LEAS_INDEXED:
				hardware_stack_pointer = _retrieve_effective_address()
				cycle_counter += 4

			# LEA    Load effective address
			# Source Form: LEAX; LEAY; LEAS; LEAU
			# Operation: R' <- EA
			# Condition Codes:
			#     H: Not Affected
			#     N: Not Affected
			#     Z: LEAX, LEAY: Set if all bits of the result are Clear
			#        LEAS, LEAU: Not Affected
			#     V: Not Affected
			#     C: Not Affected
			# Description:
			#     Form the effective address to data using the memory addressing mode. Load that
			#     address, not the data itself, into the pointer register.
			#
			#     LEAX and LEAY affect Z to allow use as counters and for 6800 INX/DEX compatibilty
			#     LEAU and LEAS do not affect Z to allow for cleaning up the stack while returning
			#     Z as a parameter to a calling routine, and for 6800 INS/DES compatibility.
			#
			# LEAU - Indexed - Opcode: 33 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.LEAU_INDEXED:
				user_stack_pointer = _retrieve_effective_address()
				cycle_counter += 4
	
			# PSHS    Push registers on the hardware stack
			# Source Form: PSHS register list
			#              PSHS #Label | PC | U | Y | X | DP | B | A | CC
			#                          push order ->
			# Operation:
			#     if b7 of MI set, then: SP' <- SP - 1, (SP) <- PCL
			#                            SP' <- SP - 1, (SP) <- PCH
			#     if b6 of MI set, then: SP' <- SP - 1, (SP) <- USL
			#                            SP' <- SP - 1, (SP) <- USH
			#     if b5 of MI set, then: SP' <- SP - 1, (SP) <- IYL
			#                            SP' <- SP - 1, (SP) <- IYH
			#     if b4 of MI set, then: SP' <- SP - 1, (SP) <- IXL
			#                            SP' <- SP - 1, (SP) <- IXH
			#     if b3 of MI set, then: SP' <- SP - 1, (SP) <- DPR
			#     if b2 of MI set, then: SP' <- SP - 1, (SP) <- ACCB
			#     if b1 of MI set, then: SP' <- SP - 1, (SP) <- ACCA
			#     if b0 of MI set, then: SP' <- SP - 1, (SP) <- CCR
			# Condition Codes: Not Affected
			# Description:
			#     Any, all, any subset, or none of the MPU registers are pushed onto the hardware
			#     stack, (excepting only the hardware stack pointer itself).
			#
			# PSHS - Inherent - Opcode: 34 - MPU Cycles: 5+ - No of bytes: 2
			Opcodes.PSHS_INHERENT:
				var post := _read_and_advance_program_counter()

				if post & PushPullPostByte.PC:
					_push_onto_hardware_stack(program_counter & 0xFF)
					_push_onto_hardware_stack((program_counter >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.S_U:
					_push_onto_hardware_stack(user_stack_pointer & 0xFF)
					_push_onto_hardware_stack((user_stack_pointer >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.Y:
					_push_onto_hardware_stack(y_index_register & 0xFF)
					_push_onto_hardware_stack((y_index_register >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.X:
					_push_onto_hardware_stack(x_index_register & 0xFF)
					_push_onto_hardware_stack((x_index_register >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.DPR:
					_push_onto_hardware_stack(direct_page_register.get_real_dp())
					cycle_counter += 1

				if post & PushPullPostByte.B:
					_push_onto_hardware_stack(accumulators.b)
					cycle_counter += 1

				if post & PushPullPostByte.A:
					_push_onto_hardware_stack(accumulators.a)
					cycle_counter += 1

				if post & PushPullPostByte.CCR:
					_push_onto_hardware_stack(condition_code_register.register)
					cycle_counter += 1

				cycle_counter += 5

			# PULS    Pull registers from the hardware stack
			# Source Form: PULS register list
			#              PULS #Label | PC | U | Y | X | DP | B | A | CC
			#                          <- pull order
			# Operation:
			#     if b0 of MI set, then: CCR' <- (SP), SP' <- SP + 1
			#     if b1 of MI set, then: ACCA' <- (SP), SP' <- SP + 1
			#     if b2 of MI set, then: ACCB' <- (SP), SP' <- SP + 1
			#     if b3 of MI set, then: DP' <- (SP), SP' <- SP + 1
			#     if b4 of MI set, then: IXH' <- (SP), SP' <- SP + 1
			#                            IXL' <- (SP), SP' <- SP + 1
			#     if b5 of MI set, then: IYH' <- (SP), SP' <- SP + 1
			#                            IYL' <- (SP), SP' <- SP + 1
			#     if b6 of MI set, then: USH' <- (SP), SP' <- SP + 1
			#                            USL' <- (SP), SP' <- SP + 1
			#     if b7 of MI set, then: PCH' <- (SP), SP' <- SP + 1
			#                            PCL' <- (SP), SP' <- SP + 1
			# Condition Codes: May be pulled from stack, otherwise unaffected.
			# Description:
			#     Any, all, any subset, or none of the MPU registers are pulled form the hardware
			#     stack, (excepting only the hardware stack pointer itself). A single register may
			#     be "pulled" with condition-flags set by loading auto-increment from stack.
			#     (EX: LDA, S+)
			#
			# PULS - Inherent - Opcode: 35 - MPU Cycles: 5+ - No of bytes: 2
			Opcodes.PULS_INHERENT:
				var post := _read_and_advance_program_counter()

				if post & PushPullPostByte.CCR:
					condition_code_register.register = _pull_from_hardware_stack()
					cycle_counter += 1

				if post & PushPullPostByte.A:
					accumulators.a = _pull_from_hardware_stack()
					cycle_counter += 1

				if post & PushPullPostByte.B:
					accumulators.b = _pull_from_hardware_stack()
					cycle_counter += 1

				if post & PushPullPostByte.DPR:
					direct_page_register.dp = _pull_from_hardware_stack()
					cycle_counter += 1

				if post & PushPullPostByte.X:
					x_index_register = _pull_from_hardware_stack()
					x_index_register <<= 8
					x_index_register |= _pull_from_hardware_stack()
					cycle_counter += 2

				if post & PushPullPostByte.Y:
					y_index_register = _pull_from_hardware_stack()
					y_index_register <<= 8
					y_index_register |= _pull_from_hardware_stack()
					cycle_counter += 2

				if post & PushPullPostByte.S_U:
					user_stack_pointer = _pull_from_hardware_stack()
					user_stack_pointer <<= 8
					user_stack_pointer |= _pull_from_hardware_stack()
					cycle_counter += 2

				if post & PushPullPostByte.PC:
					program_counter = _pull_from_hardware_stack()
					program_counter <<= 8
					program_counter |= _pull_from_hardware_stack()
					cycle_counter += 2

				cycle_counter += 5

			# PSHU    Push registers on the user stack
			# Source Form: PSHU register list
			#              PSHU #Label | PC | U | Y | X | DP | B | A | CC
			#                          push order ->
			# Operation:
			#     if b7 of MI set, then: UP' <- UP - 1, (UP) <- PCL
			#                            UP' <- UP - 1, (UP) <- PCH
			#     if b6 of MI set, then: UP' <- UP - 1, (UP) <- USL
			#                            UP' <- UP - 1, (UP) <- USH
			#     if b5 of MI set, then: UP' <- UP - 1, (UP) <- IYL
			#                            UP' <- UP - 1, (UP) <- IYH
			#     if b4 of MI set, then: UP' <- UP - 1, (UP) <- IXL
			#                            UP' <- UP - 1, (UP) <- IXH
			#     if b3 of MI set, then: UP' <- UP - 1, (UP) <- DPR
			#     if b2 of MI set, then: UP' <- UP - 1, (UP) <- ACCB
			#     if b1 of MI set, then: UP' <- UP - 1, (UP) <- ACCA
			#     if b0 of MI set, then: UP' <- UP - 1, (UP) <- CCR
			# Condition CodeS: Not Affected
			# Description:
			#     Any, all, any subset, or none of the MPU registers are pushed onto the user stack
			#     (excepting only the user stack pointer itself).
			#
			# PSHU - Inherent - Opcode: 36 - MPU Cycles: 5+ - No of bytes: 2
			Opcodes.PSHU_INHERENT:
				var post := _read_and_advance_program_counter()

				if post & PushPullPostByte.PC:
					_push_onto_user_stack(program_counter & 0xFF)
					_push_onto_user_stack((program_counter >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.S_U:
					_push_onto_user_stack(user_stack_pointer & 0xFF)
					_push_onto_user_stack((user_stack_pointer >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.Y:
					_push_onto_user_stack(y_index_register & 0xFF)
					_push_onto_user_stack((y_index_register >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.X:
					_push_onto_user_stack(x_index_register & 0xFF)
					_push_onto_user_stack((x_index_register >> 8) & 0xFF)
					cycle_counter += 2

				if post & PushPullPostByte.DPR:
					_push_onto_user_stack(direct_page_register.get_real_dp())
					cycle_counter += 1

				if post & PushPullPostByte.B:
					_push_onto_user_stack(accumulators.b)
					cycle_counter += 1

				if post & PushPullPostByte.A:
					_push_onto_user_stack(accumulators.a)
					cycle_counter += 1

				if post & PushPullPostByte.CCR:
					_push_onto_user_stack(condition_code_register.register)
					cycle_counter += 1

				cycle_counter += 5

			# PULU    Pull registers from the user stack
			# Source Form: PULU register list
			#              PULU #Label | PC | U | Y | X | DP | B | A | CC
			#                          <- pull order
			# Operation:
			#     if b0 of MI set, then: CCR' <- (UP), UP' <- UP + 1
			#     if b1 of MI set, then: ACCA' <- (UP), UP' <- UP + 1
			#     if b2 of MI set, then: ACCB' <- (UP), UP' <- UP + 1
			#     if b3 of MI set, then: DP' <- (UP), UP' <- UP + 1
			#     if b4 of MI set, then: IXH' <- (UP), UP' <- UP + 1
			#                            IXL' <- (UP), UP' <- UP + 1
			#     if b5 of MI set, then: IYH' <- (UP), UP' <- UP + 1
			#                            IYL' <- (UP), UP' <- UP + 1
			#     if b6 of MI set, then: USH' <- (UP), UP' <- UP + 1
			#                            USL' <- (UP), UP' <- UP + 1
			#     if b7 of MI set, then: PCH' <- (UP), UP' <- UP + 1
			#                            PCL' <- (UP), UP' <- UP + 1
			# Condition Codes: May be pulled from stack, otherwise unaffected.
			# Description:
			#     Any, all, any subset, or none of the MPU registers are pulled form the hardware
			#     stack, (excepting only the hardware stack pointer itself). A single register may
			#     be "pulled" with condition-flags set by loading auto-increment from stack.
			#     (EX: LDA, S+)
			#
			# PULU - Inherent - Opcode: 37 - MPU Cycles: 5+ - No of bytes: 2
			Opcodes.PULU_INHERENT:
				var post := _read_and_advance_program_counter()

				if post & PushPullPostByte.CCR:
					condition_code_register.register = _pull_from_user_stack()
					cycle_counter += 1

				if post & PushPullPostByte.A:
					accumulators.a = _pull_from_user_stack()
					cycle_counter += 1

				if post & PushPullPostByte.B:
					accumulators.b = _pull_from_user_stack()
					cycle_counter += 1

				if post & PushPullPostByte.DPR:
					direct_page_register.dp = _pull_from_user_stack()
					cycle_counter += 1

				if post & PushPullPostByte.X:
					x_index_register = _pull_from_user_stack()
					x_index_register <<= 8
					x_index_register |= _pull_from_user_stack()
					cycle_counter += 2

				if post & PushPullPostByte.Y:
					y_index_register = _pull_from_user_stack()
					y_index_register <<= 8
					y_index_register |= _pull_from_user_stack()
					cycle_counter += 2

				if post & PushPullPostByte.S_U:
					user_stack_pointer = _pull_from_user_stack()
					user_stack_pointer <<= 8
					user_stack_pointer |= _pull_from_user_stack()
					cycle_counter += 2

				if post & PushPullPostByte.PC:
					program_counter = _pull_from_user_stack()
					program_counter <<= 8
					program_counter |= _pull_from_user_stack()
					cycle_counter += 2

				cycle_counter += 5

			Opcodes.RTS_INHERENT:
				program_counter = _pull_from_hardware_stack()
				program_counter <<= 8
				program_counter |= _pull_from_hardware_stack()
				cycle_counter += 5

			# ABX    Add ACCB into IX
			# Source Form: ABX
			# Operation: IX' <- IX + ACCB
			# Condition Codes: Not affected
			# Description:
			#     Add the 8-bit unsigned value in Accumulator B into the X index register.
			#
			# ABX - Inherent - Opcode: 3A - MPU Cycles: 3 - No of bytes: 1
			Opcodes.ABX_INHERENT:
				x_index_register = (x_index_register + accumulators.b) & 0xFF
				cycle_counter += 3

			# RTI    Return from interrupt
			# Source Form: RTI
			# Operation: CCR' (SP), SP' <- SP + 1
			#     if CCR bit E is SET then: ACCA' <- (SP), SP' <- SP + 1
			#                               ACCB' <- (SP), SP' <- SP + 1
			#                               DPR' <- (SP), SP' <- SP + 1
			#                               IXH' <- (SP), SP' <- SP + 1
			#                               IXL' <- (SP), SP' <- SP + 1
			#                               IYH' <- (SP), SP' <- SP + 1
			#                               IYL' <- (SP), SP' <- SP + 1
			#                               USH' <- (SP), SP' <- SP + 1
			#                               USL' <- (SP), SP' <- SP + 1
			#                               PCH' <- (SP), SP' <- SP + 1
			#                               PCL' <- (SP), SP' <- SP + 1
			#     if CCR bit E is CLEAR then: PCH' <- (SP), SP' <- SP + 1
			#                                 PCL' <- (SP), SP' <- SP + 1
			# Condition Codes: Recovered from stack
			# Description:
			#     The saved machine state is recovered from the hardware stack and control is
			# returned to the interrupted program. If the recovered E bit is CLEAR, it indicates
			# that only a subset of the machine state was saved (return address and condition
			# codes) and only that subset is to be recovered.
			#
			# RTI - Inherent - Opcode: 3B - MPU Cycles: 6(15) - No of bytes: 1
			Opcodes.RTI_INHERENT:
				condition_code_register.register = _pull_from_hardware_stack()
				if condition_code_register.entire:
					_pull_machine_state()

					cycle_counter += 9
				
				program_counter = _pull_from_hardware_stack()
				program_counter <<= 8
				program_counter |= _pull_from_hardware_stack()

				cycle_counter += 6

			# CWAI    Clear and wait for interrupt
			# Source Form: CWAI #$XX
			# Operation: CCR <- CCR ∧ MI (Possibly clear masks)
			#            Set E (entire state saved)
			#            SP' <- SP - 1, (SP) <- PCL    FF = enable neither
			#            SP' <- SP - 1, (SP) <- PCH    EF = enable IRQ
			#            SP' <- SP - 1, (SP) <- USL    BF = enable FIRQ
			#            SP' <- SP - 1, (SP) <- USH    AF = enable both
			#            SP' <- SP - 1, (SP) <- IYL
			#            SP' <- SP - 1, (SP) <- IYH
			#            SP' <- SP - 1, (SP) <- IXL
			#            SP' <- SP - 1, (SP) <- IXH
			#            SP' <- SP - 1, (SP) <- DPR
			#            SP' <- SP - 1, (SP) <- ACCB
			#            SP' <- SP - 1, (SP) <- ACCA
			#            SP' <- SP - 1, (SP) <- CCR
			# Condition Codes: Possible cleared by the immediate byte
			# Description:
			#     The CWAI instruction ANDs an immediate byte with the condition code register
			#     which may clear interrupt maskbit(s). It stacks the entire machine state on the
			#     hardware stack and then looks for an interrupt. When a nonmasked interrupt
			#     occurs, no further machine state will be saved before vectoring to the interrupt
			#     handling routine. This instruction replaced the 6800's CLI WAI sequence, but does
			#     not tri-state the buses.
			# Comments:
			#     An FIRQ interrupt may enter its interrupt handler with its entire machine state
			#     saved. The RTI will automatically return the entire machine state after testing
			#    the E bit of the recovered CCR.
			#
			# CWAI - Inherent - Opcode: 3C - MPU Cycles: 20 - No of bytes: 2
			Opcodes.CWAI_INHERENT:
				var post := _read_and_advance_program_counter()
				condition_code_register.register &= post
				condition_code_register.entire = true
				_push_machine_state()
				cycle_counter = num_cycles_to_run
				cwai = true
				syncing = true

			# MUL    Multiply accumulators
			# Source Form: MUL
			# Operation: ACCA':ACCB' <- ACCA x ACCB
			# Condition Codes:
			#     H: Not Affected
			#     N: Not Affected
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Set if ACCB bit 7 of result is Set
			# Description:
			#     Multiply the unsigned binary numbers in the accumulators and place the result in
			#     both accumulators. Unsigned multiply allows multiple-precision operations. The
			#     Carry flag allows rounding the MS byte through the sequence MUL, ADCA #0
			#
			# MUL - Inherent - Opcode: 3D - MPU Cycles: 11 - No of bytes: 1
			Opcodes.MUL_INHERENT:
				accumulators.d = accumulators.a * accumulators.b
				condition_code_register.zero = accumulators.d == 0
				condition_code_register.carry = accumulators.d & 0x0080
				cycle_counter += 11

			Opcodes.RESET: # undocumented instruction
				pass

			# SWI    Software Interrupt
			# Source Form: SWI2
			# Operation: Set E (entire state saved)
			#            SP' <- SP - 1, (SP) <- PCL
			#            SP' <- SP - 1, (SP) <- PCH
			#            SP' <- SP - 1, (SP) <- USL
			#            SP' <- SP - 1, (SP) <- USH
			#            SP' <- SP - 1, (SP) <- IYL
			#            SP' <- SP - 1, (SP) <- IYH
			#            SP' <- SP - 1, (SP) <- IXL
			#            SP' <- SP - 1, (SP) <- IXH
			#            SP' <- SP - 1, (SP) <- DPR
			#            SP' <- SP - 1, (SP) <- ACCB
			#            SP' <- SP - 1, (SP) <- ACCA
			#            SP' <- SP - 1, (SP) <- CCR
			#            Set I, F (mask interrupts)
			#            PC' <- (FFFA):(FFFB)
			# Condition Codes: Not Affected
			# Description:
			#     All of the MPU registers are pushed onto the hardware stack (excepting only the
			#     hardware stack pointer itself), and control is transferred through the SWI
			#     vector.
			#
			#     SWI SETS I AND F BITS
			#
			# SWI - Inherent - Opcode: 3F - MPU Cycles: 19 - No of bytes: 1
			Opcodes.SWI_INHERENT:
				condition_code_register.entire = true
				_push_machine_state()
				condition_code_register.irq_mask = true
				condition_code_register.firq_mask = true
				program_counter = _read2(VectorTable.SWI)
				cycle_counter += 19

			# NEG   Negate
			# Source Form: NEG Q
			# Operation: M' <- 0 - M (i.e. M' <- ~M + 1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Set if the operation did not cause a cary from bit 7 in the ALU.
			# Description:
			#     Replaces the operand with its two's complement. The C-flag represents a borrow
			#     and is set inverse to the resulting binary carry. Not that 80 (16) is replaced by
			#     itself and only in this case is V Set. The value 00 (16) is also replaced by
			#     itself, and only in this case is C cleared.
			#
			# NEGA - Inherent - Opcode: 50 - MPU Cycles 2 - No of bytes: 1
			Opcodes.NEGA_INHERENT:
				accumulators.a = _neg(accumulators.a)
				cycle_counter += 2

			# COM    Complement
			# Source Form: COM Q; COMA; COMB
			# Operation: M' (R') <- 0 + ~M (~R)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Set
			# Description:
			#     Replaces the contents of M or ACCX with its one's complement (also called the
			#     logical complement). The carry flag is set for 6800 compatibility.
			# Comments:
			#     When operating on unsigned values, only BEQ and MBE branches can be expected to
			#     behave properly. When operating on two's complement values, all signed branches
			#     are available.
			#
			# COMA - Inherent - Opcode: 43 - MPY Cycles: 2 - No of bytes: 1
			Opcodes.COMA_INHERENT:
				accumulators.a = _com(accumulators.a)
				cycle_counter += 2

			# LSR    Logical shift right
			# Source Form: LSR Q; LSRA; LSRB
			# Operation:
			#      _________________    _____
			# 0 -> | | | | | | | | | -> | C |
			#      -----------------    -----
			#      b7             b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Performs a logical shift right on the operand. Shifts a zero into bit 7 and bit 0
			#     into the carry flag. The 6800 processor also affects the V flag.
			#
			# LSRA - Inherent - Opcode: 44 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.LSRA_INHERENT:
				accumulators.a = _lsr(accumulators.a)
				cycle_counter += 2

			# ROR    Rotate right
			# Source Form: ROR Q; RORA; RORB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      ->     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Rotates all bits of the operand right one place through the carry flag; this is
			#     a nine-bit rotation. The 6800 processor also affects the V flag.
			#
			# RORA - Inherent - Opcode: 46 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.RORA_INHERENT:
				accumulators.a = _ror(accumulators.a)
				cycle_counter += 2

			# ASR    Arithmetic shift right
			# Source Form: ASR Q
			# Operation:
			# _____
			# |   |
			# |  _________________    _____
			# -->| | | | | | | | | -> | C |
			#    -----------------    -----
			#    b7             b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of result are clear
			#     V: Not affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Shifts all bits of the operand right one place. Bit 7 is held constant. Bit 0 is
			#     shifted into the carry flag. The 6800/01/02/03/08 processors do affect the V
			#     flag.
			#
			# ASRA - Inherent - Opcode: 47 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.ASRA_INHERENT:
				accumulators.a = _asr(accumulators.a)
				cycle_counter += 2

			# ASL    Arithmetic shift left
			# Source Form: ASL Q
			# Operation:
			# _____    _________________
			# | C | <- | | | | | | | | | <- 0
			# -----    -----------------
			#          b7      <-     b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of the result are clear
			#     V: Loaded with the result of b7 ^ b0 of the original operand.
			#     C: Loaded with bit 7 of the original operand.
			# Description:
			#     Shifts all bits of the operand one place to the left. Bit 0 is loaded with a
			#     zero. Bit 7 of the operand is shifted into the carry flag.
			#
			# ASLA - Inherent - Opcode: 48 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.ASLA_INHERENT:
				accumulators.a = _asl(accumulators.a)
				cycle_counter += 2

			# ROL    Rotate left
			# Source Form: ROL Q; ROLA; ROLB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      <-     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Loaded with the result of (b7 ^ b6) of the original operand.
			#     C: Loaded with bit 7 of the original operand
			# Description:
			#     Rotate all bits of the operand one place left through the carry flag; this is a
			#     9-bit rotation
			#
			# ROLA - Inherent - Opcode: 49 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.ROLA_INHERENT:
				accumulators.a = _rol(accumulators.a)
				cycle_counter += 2

			# DEC    Decrement
			# Source Form: DEC Q; DECA; DECB
			# Operation: M' (R') <- M-1 (R-1)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Not affected
			# Description:
			#     Subtract one from the operand. The carry flag is not affected, thus allowing DEC
			#     to be a loopcounter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values only BEQ and BNE branches can be expected to
			#     behave consistently. When operating on two's complement values, all signed
			#     branches are available.
			#
			# DECA - Inherent - Opcode: 4A - MPU Cycles: 2 - No of bytes: 1
			Opcodes.DECA_INHERENT:
				accumulators.a = _dec(accumulators.a)
				cycle_counter += 2

			# INC    Increment
			# Source Form: INC Q; INCA, INCB
			# Operation: M' (R') <- M + 1 (R + 1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the original operand was 01111111
			#     C: Not Affected
			# Description:
			#     Add one to the operand. The carry flag is not affected, thus allowing INC to be
			#     used as a loop-counter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values, only the BEQ and BNE branches can be expected
			#     to behave consistently. When operating on two's complement values, all signed
			#     branches are correctly available.
			#
			# INCA - Inherent - Opcode: 4C - MPU Cycles: 2 - No of bytes: 1
			Opcodes.INCA_INHERENT:
				accumulators.a = _inc(accumulators.a)
				cycle_counter += 2

			# TST    Test
			# Source Form: TST Q; TSTA; TSTB
			# Operation: TEMP <- M - 0
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Set condition code flags N and Z according to the contents of M, and clear the V
			#     flag. The 6800 processor clears the C flag.
			# Comments:
			#     The TST instruction provides only minimum information when testing unsigned
			#     values; since no unsigned value is less than zero, BLO and BLS have no utility.
			#     While BHI could be used after TST, it provides exactly the same control as BNE,
			#     which is preferred. The signed branches are available.
			#
			# TSTA - Inherent - Opcode: 4D - MPU Cycles: 2 - No of bytes: 1
			Opcodes.TSTA_INHERENT:
				_tst(accumulators.a)
				cycle_counter += 2

			# CLR    Clear
			# Source Form: CLR Q, CLRA, CLRB
			# Operation: TEMP <- M
			#            M <- 00 (16)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set
			#     V: Cleared
			#     C: Cleared
			# Description:
			#     ACCX or M is loaded with 00000000. The C-flag is cleared for 6800 compatibility.
			#
			# CLRA - Inherent - Opcode: 4F - MPU Cycles: 2 - No of bytes: 1
			Opcodes.CLRA_INHERENT:
				accumulators.a = 0
				_clr()
				cycle_counter += 2

			# NEG   Negate
			# Source Form: NEG Q
			# Operation: M' <- 0 - M (i.e. M' <- ~M + 1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Set if the operation did not cause a cary from bit 7 in the ALU.
			# Description:
			#     Replaces the operand with its two's complement. The C-flag represents a borrow
			#     and is set inverse to the resulting binary carry. Not that 80 (16) is replaced by
			#     itself and only in this case is V Set. The value 00 (16) is also replaced by
			#     itself, and only in this case is C cleared.
			#
			# NEGB - Inherent - Opcode: 50 - MPU Cycles 2 - No of bytes: 1
			Opcodes.NEGB_INHERENT:
				accumulators.b = _neg(accumulators.b)
				cycle_counter += 2

			# COM    Complement
			# Source Form: COM Q; COMA; COMB
			# Operation: M' (R') <- 0 + ~M (~R)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Set
			# Description:
			#     Replaces the contents of M or ACCX with its one's complement (also called the
			#     logical complement). The carry flag is set for 6800 compatibility.
			# Comments:
			#     When operating on unsigned values, only BEQ and MBE branches can be expected to
			#     behave properly. When operating on two's complement values, all signed branches
			#     are available.
			#
			# COMB - Inherent - Opcode: 53 - MPY Cycles: 2 - No of bytes: 1
			Opcodes.COMB_INHERENT:
				accumulators.b = _com(accumulators.b)
				cycle_counter += 2

			# LSR    Logical shift right
			# Source Form: LSR Q; LSRA; LSRB
			# Operation:
			#      _________________    _____
			# 0 -> | | | | | | | | | -> | C |
			#      -----------------    -----
			#      b7             b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Performs a logical shift right on the operand. Shifts a zero into bit 7 and bit 0
			#     into the carry flag. The 6800 processor also affects the V flag.
			#
			# LSRB - Inherent - Opcode: 54 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.LSRB_INHERENT:
				accumulators.b = _lsr(accumulators.b)
				cycle_counter += 2

			# ROR    Rotate right
			# Source Form: ROR Q; RORA; RORB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      ->     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Rotates all bits of the operand right one place through the carry flag; this is
			#     a nine-bit rotation. The 6800 processor also affects the V flag.
			#
			# RORB - Inherent - Opcode: 56 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.RORB_INHERENT:
				accumulators.b = _ror(accumulators.b)
				cycle_counter += 2

			# ASR    Arithmetic shift right
			# Source Form: ASR Q
			# Operation:
			# _____
			# |   |
			# |  _________________    _____
			# -->| | | | | | | | | -> | C |
			#    -----------------    -----
			#    b7             b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of result are clear
			#     V: Not affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Shifts all bits of the operand right one place. Bit 7 is held constant. Bit 0 is
			#     shifted into the carry flag. The 6800/01/02/03/08 processors do affect the V
			#     flag.
			#
			# ASRB - Direct - Opcode: 57 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.ASRB_INHERENT:
				accumulators.b = _asr(accumulators.b)
				cycle_counter += 2

			# ASL    Arithmetic shift left
			# Source Form: ASL Q
			# Operation:
			# _____    _________________
			# | C | <- | | | | | | | | | <- 0
			# -----    -----------------
			#          b7      <-     b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of the result are clear
			#     V: Loaded with the result of b7 ^ b0 of the original operand.
			#     C: Loaded with bit 7 of the original operand.
			# Description:
			#     Shifts all bits of the operand one place to the left. Bit 0 is loaded with a
			#     zero. Bit 7 of the operand is shifted into the carry flag.
			#
			# ASLB - Inherent - Opcode: 58 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.ASLB_INHERENT:
				accumulators.b = _asl(accumulators.b)
				cycle_counter += 2

			# ROL    Rotate left
			# Source Form: ROL Q; ROLA; ROLB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      <-     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Loaded with the result of (b7 ^ b6) of the original operand.
			#     C: Loaded with bit 7 of the original operand
			# Description:
			#     Rotate all bits of the operand one place left through the carry flag; this is a
			#     9-bit rotation
			#
			# ROLB - Inherent - Opcode: 59 - MPU Cycles: 2 - No of bytes: 1
			Opcodes.ROLB_INHERENT:
				accumulators.b = _rol(accumulators.b)
				cycle_counter += 2

			# DEC    Decrement
			# Source Form: DEC Q; DECA; DECB
			# Operation: M' (R') <- M-1 (R-1)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Not affected
			# Description:
			#     Subtract one from the operand. The carry flag is not affected, thus allowing DEC
			#     to be a loopcounter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values only BEQ and BNE branches can be expected to
			#     behave consistently. When operating on two's complement values, all signed
			#     branches are available.
			#
			# DECB - Inherent - Opcode: 5A - MPU Cycles: 2 - No of bytes: 1
			Opcodes.DECB_INHERENT:
				accumulators.b = _dec(accumulators.b)
				cycle_counter += 2

			# INC    Increment
			# Source Form: INC Q; INCA, INCB
			# Operation: M' (R') <- M + 1 (R + 1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the original operand was 01111111
			#     C: Not Affected
			# Description:
			#     Add one to the operand. The carry flag is not affected, thus allowing INC to be
			#     used as a loop-counter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values, only the BEQ and BNE branches can be expected
			#     to behave consistently. When operating on two's complement values, all signed
			#     branches are correctly available.
			#
			# INCB - Inherent - Opcode: 5C - MPU Cycles: 2 - No of bytes: 1
			Opcodes.INCB_INHERENT:
				accumulators.b = _inc(accumulators.b)
				cycle_counter += 2

			# TST    Test
			# Source Form: TST Q; TSTA; TSTB
			# Operation: TEMP <- M - 0
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Set condition code flags N and Z according to the contents of M, and clear the V
			#     flag. The 6800 processor clears the C flag.
			# Comments:
			#     The TST instruction provides only minimum information when testing unsigned
			#     values; since no unsigned value is less than zero, BLO and BLS have no utility.
			#     While BHI could be used after TST, it provides exactly the same control as BNE,
			#     which is preferred. The signed branches are available.
			#
			# TSTB - Inherent - Opcode: 5D - MPU Cycles: 2 - No of bytes: 1
			Opcodes.TSTB_INHERENT:
				_tst(accumulators.b)
				cycle_counter += 2

			# CLR    Clear
			# Source Form: CLR Q, CLRA, CLRB
			# Operation: TEMP <- M
			#            M <- 00 (16)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set
			#     V: Cleared
			#     C: Cleared
			# Description:
			#     ACCX or M is loaded with 00000000. The C-flag is cleared for 6800 compatibility.
			#
			# CLRB - Inherent - Opcode: 5F - MPU Cycles: 2 - No of bytes: 1
			Opcodes.CLRB_INHERENT:
				accumulators.b = 0
				_clr()
				cycle_counter += 2

			# NEG   Negate
			# Source Form: NEG Q
			# Operation: M' <- 0 - M (i.e. M' <- ~M + 1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Set if the operation did not cause a cary from bit 7 in the ALU.
			# Description:
			#     Replaces the operand with its two's complement. The C-flag represents a borrow
			#     and is set inverse to the resulting binary carry. Not that 80 (16) is replaced by
			#     itself and only in this case is V Set. The value 00 (16) is also replaced by
			#     itself, and only in this case is C cleared.
			#
			# NEG - Indexed - Opcode: 60 - MPU Cycles 6+ - No of bytes: 2+
			Opcodes.NEG_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _neg(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# COM    Complement
			# Source Form: COM Q; COMA; COMB
			# Operation: M' (R') <- 0 + ~M (~R)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Set
			# Description:
			#     Replaces the contents of M or ACCX with its one's complement (also called the
			#     logical complement). The carry flag is set for 6800 compatibility.
			# Comments:
			#     When operating on unsigned values, only BEQ and MBE branches can be expected to
			#     behave properly. When operating on two's complement values, all signed branches
			#     are available.
			#
			# COM - Indexed - Opcode: 63 - MPY Cycles: 6+ - No of bytes: 2+
			Opcodes.COM_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _com(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# LSR    Logical shift right
			# Source Form: LSR Q; LSRA; LSRB
			# Operation:
			#      _________________    _____
			# 0 -> | | | | | | | | | -> | C |
			#      -----------------    -----
			#      b7             b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Performs a logical shift right on the operand. Shifts a zero into bit 7 and bit 0
			#     into the carry flag. The 6800 processor also affects the V flag.
			#
			# LSR - Indexed - Opcode: 64 - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.LSR_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _lsr(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ROR    Rotate right
			# Source Form: ROR Q; RORA; RORB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      ->     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Rotates all bits of the operand right one place through the carry flag; this is
			#     a nine-bit rotation. The 6800 processor also affects the V flag.
			#
			# ROR - Indexed - Opcode: 66 - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.ROR_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _ror(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ASR    Arithmetic shift right
			# Source Form: ASR Q
			# Operation:
			# _____
			# |   |
			# |  _________________    _____
			# -->| | | | | | | | | -> | C |
			#    -----------------    -----
			#    b7             b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of result are clear
			#     V: Not affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Shifts all bits of the operand right one place. Bit 7 is held constant. Bit 0 is
			#     shifted into the carry flag. The 6800/01/02/03/08 processors do affect the V
			#     flag.
			#
			# ASR - Indexed - Opcode: 67 - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.ASR_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _asr(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ASL    Arithmetic shift left
			# Source Form: ASL Q
			# Operation:
			# _____    _________________
			# | C | <- | | | | | | | | | <- 0
			# -----    -----------------
			#          b7      <-     b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of the result are clear
			#     V: Loaded with the result of b7 ^ b0 of the original operand.
			#     C: Loaded with bit 7 of the original operand.
			# Description:
			#     Shifts all bits of the operand one place to the left. Bit 0 is loaded with a
			#     zero. Bit 7 of the operand is shifted into the carry flag.
			#
			# ASL - Indexed - Opcode: 68 - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.ASL_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _asl(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# ROL    Rotate left
			# Source Form: ROL Q; ROLA; ROLB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      <-     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Loaded with the result of (b7 ^ b6) of the original operand.
			#     C: Loaded with bit 7 of the original operand
			# Description:
			#     Rotate all bits of the operand one place left through the carry flag; this is a
			#     9-bit rotation
			#
			# ROL - Indexed - Opcode: 69 - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.ROL_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _rol(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# DEC    Decrement
			# Source Form: DEC Q; DECA; DECB
			# Operation: M' (R') <- M-1 (R-1)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Not affected
			# Description:
			#     Subtract one from the operand. The carry flag is not affected, thus allowing DEC
			#     to be a loopcounter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values only BEQ and BNE branches can be expected to
			#     behave consistently. When operating on two's complement values, all signed
			#     branches are available.
			#
			# DEC - Indexed - Opcode: 6A - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.DEC_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _dec(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# INC    Increment
			# Source Form: INC Q; INCA, INCB
			# Operation: M' (R') <- M + 1 (R + 1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the original operand was 01111111
			#     C: Not Affected
			# Description:
			#     Add one to the operand. The carry flag is not affected, thus allowing INC to be
			#     used as a loop-counter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values, only the BEQ and BNE branches can be expected
			#     to behave consistently. When operating on two's complement values, all signed
			#     branches are correctly available.
			#
			# INC - Indexed - Opcode: 6C - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.INC_INDEXED:
				var address := _retrieve_effective_address()
				var byte := _inc(_read(address))
				_write(address, byte)
				cycle_counter += 6

			# TST    Test
			# Source Form: TST Q; TSTA; TSTB
			# Operation: TEMP <- M - 0
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Set condition code flags N and Z according to the contents of M, and clear the V
			#     flag. The 6800 processor clears the C flag.
			# Comments:
			#     The TST instruction provides only minimum information when testing unsigned
			#     values; since no unsigned value is less than zero, BLO and BLS have no utility.
			#     While BHI could be used after TST, it provides exactly the same control as BNE,
			#     which is preferred. The signed branches are available.
			#
			# TST - Indexed - Opcode: 6D - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.TST_INDEXED:
				_tst(_read(_retrieve_effective_address()))
				cycle_counter += 6

			# JMP    Jump to effective address
			# Source Form: JMP
			# Operation: PC <- EA
			# Condition Codes: Not Affected
			# Description:
			#     Program control is transferred to the location equivalent to the effective
			#     address
			#
			# JMP - Indexed - Opcode: 6E - MPU Cycles: 3+ - No of bytes: 2+
			Opcodes.JMP_INDEXED:
				program_counter = _retrieve_effective_address()
				cycle_counter += 3

			# CLR    Clear
			# Source Form: CLR Q, CLRA, CLRB
			# Operation: TEMP <- M
			#            M <- 00 (16)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set
			#     V: Cleared
			#     C: Cleared
			# Description:
			#     ACCX or M is loaded with 00000000. The C-flag is cleared for 6800 compatibility.
			#
			# CLR - Indexed - Opcode: 7F - MPU Cycles: 7 - No of bytes: 3
			Opcodes.CLR_INDEXED:
				_write(_retrieve_effective_address(), 0)
				_clr()
				cycle_counter += 6

			# NEG   Negate
			# Source Form: NEG Q
			# Operation: M' <- 0 - M (i.e. M' <- ~M + 1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Set if the operation did not cause a cary from bit 7 in the ALU.
			# Description:
			#     Replaces the operand with its two's complement. The C-flag represents a borrow
			#     and is set inverse to the resulting binary carry. Not that 80 (16) is replaced by
			#     itself and only in this case is V Set. The value 00 (16) is also replaced by
			#     itself, and only in this case is C cleared.
			#
			# NEG - Extended - Opcode: 70 - MPU Cycles 7 - No of bytes: 3
			Opcodes.NEG_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _neg(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# COM    Complement
			# Source Form: COM Q; COMA; COMB
			# Operation: M' (R') <- 0 + ~M (~R)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Set
			# Description:
			#     Replaces the contents of M or ACCX with its one's complement (also called the
			#     logical complement). The carry flag is set for 6800 compatibility.
			# Comments:
			#     When operating on unsigned values, only BEQ and MBE branches can be expected to
			#     behave properly. When operating on two's complement values, all signed branches
			#     are available.
			#
			# COM - Extended - Opcode: 73 - MPY Cycles: 7 - No of bytes: 3
			Opcodes.COM_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _com(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# LSR    Logical shift right
			# Source Form: LSR Q; LSRA; LSRB
			# Operation:
			#      _________________    _____
			# 0 -> | | | | | | | | | -> | C |
			#      -----------------    -----
			#      b7             b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Performs a logical shift right on the operand. Shifts a zero into bit 7 and bit 0
			#     into the carry flag. The 6800 processor also affects the V flag.
			#
			# LSR - Extended - Opcode: 74 - MPU Cycles: 7 - No of bytes: 3
			Opcodes.LSR_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _lsr(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# ROR    Rotate right
			# Source Form: ROR Q; RORA; RORB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      ->     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Not Affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Rotates all bits of the operand right one place through the carry flag; this is
			#     a nine-bit rotation. The 6800 processor also affects the V flag.
			#
			# ROR - Extended - Opcode: 76 - MPU Cycles: 7 - No of bytes: 3
			Opcodes.ROR_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _ror(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# ASR    Arithmetic shift right
			# Source Form: ASR Q
			# Operation:
			# _____
			# |   |
			# |  _________________    _____
			# -->| | | | | | | | | -> | C |
			#    -----------------    -----
			#    b7             b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of result are clear
			#     V: Not affected
			#     C: Loaded with bit 0 of the original operand
			# Description:
			#     Shifts all bits of the operand right one place. Bit 7 is held constant. Bit 0 is
			#     shifted into the carry flag. The 6800/01/02/03/08 processors do affect the V
			#     flag.
			#
			# ASR - Extended - Opcode: 77 - MPU Cycles: 7 - No of bytes: 3
			Opcodes.ASR_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _asr(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# ASL    Arithmetic shift left
			# Source Form: ASL Q
			# Operation:
			# _____    _________________
			# | C | <- | | | | | | | | | <- 0
			# -----    -----------------
			#          b7      <-     b0
			#
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set
			#     Z: Set if all bits of the result are clear
			#     V: Loaded with the result of b7 ^ b0 of the original operand.
			#     C: Loaded with bit 7 of the original operand.
			# Description:
			#     Shifts all bits of the operand one place to the left. Bit 0 is loaded with a
			#     zero. Bit 7 of the operand is shifted into the carry flag.
			#
			# ASL - Extended - Opcode: 78 - MPU Cycles: 7 - No of bytes: 3
			Opcodes.ASL_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _asl(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# ROL    Rotate left
			# Source Form: ROL Q; ROLA; ROLB
			# Operation:
			#       _____
			#  -----| C |-----
			#  |    -----    |
			# _________________
			# | | | | | | | | |
			# -----------------
			# b7      <-     b0
			#
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Loaded with the result of (b7 ^ b6) of the original operand.
			#     C: Loaded with bit 7 of the original operand
			# Description:
			#     Rotate all bits of the operand one place left through the carry flag; this is a
			#     9-bit rotation
			#
			# ROL - Extended - Opcode: 79 - MPU Cycles: 7 - No of bytes: 3
			Opcodes.ROL_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _rol(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# DEC    Decrement
			# Source Form: DEC Q; DECA; DECB
			# Operation: M' (R') <- M-1 (R-1)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Set if the original operand was 10000000
			#     C: Not affected
			# Description:
			#     Subtract one from the operand. The carry flag is not affected, thus allowing DEC
			#     to be a loopcounter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values only BEQ and BNE branches can be expected to
			#     behave consistently. When operating on two's complement values, all signed
			#     branches are available.
			#
			# DEC - Extended - Opcode: 7A - MPU Cycles: 7 - No of bytes: 3
			Opcodes.DEC_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _dec(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# INC    Increment
			# Source Form: INC Q; INCA, INCB
			# Operation: M' (R') <- M + 1 (R + 1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the original operand was 01111111
			#     C: Not Affected
			# Description:
			#     Add one to the operand. The carry flag is not affected, thus allowing INC to be
			#     used as a loop-counter in multiple-precision computations.
			# Comments:
			#     When operating on unsigned values, only the BEQ and BNE branches can be expected
			#     to behave consistently. When operating on two's complement values, all signed
			#     branches are correctly available.
			#
			# INC - Extended - Opcode: 7C - MPU Cycles: 7 - No of bytes: 3
			Opcodes.INC_EXTENDED:
				var address := _read2_and_advance_program_counter()
				var byte := _inc(_read(address))
				_write(address, byte)
				cycle_counter += 7

			# TST    Test
			# Source Form: TST Q; TSTA; TSTB
			# Operation: TEMP <- M - 0
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Set condition code flags N and Z according to the contents of M, and clear the V
			#     flag. The 6800 processor clears the C flag.
			# Comments:
			#     The TST instruction provides only minimum information when testing unsigned
			#     values; since no unsigned value is less than zero, BLO and BLS have no utility.
			#     While BHI could be used after TST, it provides exactly the same control as BNE,
			#     which is preferred. The signed branches are available.
			#
			# TST - Extended - Opcode: 7D - MPU Cycles: 7 - No of bytes: 3
			Opcodes.TST_EXTENDED:
				_tst(_read(_read2_and_advance_program_counter()))
				cycle_counter += 7

			# JMP    Jump to effective address
			# Source Form: JMP
			# Operation: PC <- EA
			# Condition Codes: Not Affected
			# Description:
			#     Program control is transferred to the location equivalent to the effective
			#     address
			#
			# JMP - Extended - Opcode: 7E - MPU Cycles: 4 - No of bytes: 3
			Opcodes.JMP_EXTENDED:
				program_counter = _read2(program_counter)
				cycle_counter += 4

			# CLR    Clear
			# Source Form: CLR Q, CLRA, CLRB
			# Operation: TEMP <- M
			#            M <- 00 (16)
			# Condition CodeS:
			#     H: Not Affected
			#     N: Cleared
			#     Z: Set
			#     V: Cleared
			#     C: Cleared
			# Description:
			#     ACCX or M is loaded with 00000000. The C-flag is cleared for 6800 compatibility.
			#
			# CLR - Extended - Opcode: 6F - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.CLR_EXTENDED:
				_write(_read2_and_advance_program_counter(), 0)
				_clr()
				cycle_counter += 7

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBA - Immediate - Opcode: 80 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.SUBA_IMMEDIATE:
				accumulators.a = _sub8(accumulators.a, _read_and_advance_program_counter())
				cycle_counter += 2

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPA - Immediate - Opcode: 81 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.CMPA_IMMEDIATE:
				_cmpa(_read_and_advance_program_counter())
				cycle_counter += 2

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCA - Immediate - Opcode: 82 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.SBCA_IMMEDIATE:
				accumulators.a = _sub8(
					accumulators.a,
					_read_and_advance_program_counter()
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 2

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBD - Immediate - Opcode: 83 - MPU Cycles: 4 - No of bytes: 3
			Opcodes.SUBD_IMMEDIATE:
				accumulators.d = _sub16(accumulators.d, _read2_and_advance_program_counter())
				cycle_counter += 4

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDA - Immediate - Opcode: 84 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ANDA_IMMEDIATE:
				accumulators.a &= _read_and_advance_program_counter()
				_reg_cc8(accumulators.a)
				cycle_counter += 2

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITA - Immediate - Opcode: 85 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.BITA_IMMEDIATE:
				var temp := accumulators.a & _read_and_advance_program_counter()
				_reg_cc8(temp)
				cycle_counter += 2

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDA - Immediate - Opcode: 86 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.LDA_IMMEDIATE:
				accumulators.a = _read_and_advance_program_counter()
				_reg_cc8(accumulators.a)
				cycle_counter += 2

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORA - Immediate - Opcode: 88 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.EORA_IMMEDIATE:
				accumulators.a = accumulators.a ^ _read_and_advance_program_counter()
				_reg_cc8(accumulators.a)
				cycle_counter += 2

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCA - Immediate - Opcode: 89 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ADCA_IMMEDIATE:
				accumulators.a = _add8(
					accumulators.a,
					_read_and_advance_program_counter()
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 2

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORA - Immediate - Opcode: 8A - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ORA_IMMEDIATE:
				accumulators.a |= _read_and_advance_program_counter()
				_reg_cc8(accumulators.a)
				cycle_counter += 2

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDA - Immediate - Opcode: 8B - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ADDA_IMMEDIATE:
				accumulators.a = _add8(accumulators.a, _read_and_advance_program_counter())
				cycle_counter += 2

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPX - Immediate - Opcode: 8C - MPU Cycles: 4 - No of bytes: 3
			Opcodes.CMPX_IMMEDIATE:
				_cmpx(_read2_and_advance_program_counter())
				cycle_counter += 4

			# BSR    Branch to subroutine
			# Source Forms: BSR DD; LBSR DDDD
			# Operation: TEMP <- MI
			#            SP' <- SP - 1, (SP) <- PCL
			#            SP' <- SP - 1, (SP) <- PCH
			#            PC <- PC + TEMP
			# Condition Codes: Not Affected
			# Description:
			#     The program counter is pushed onto the stack. The program counter is then loaded
			#     with the sum of the program counter and the memory immediate offset.
			#
			# BSR - Relative - Opcode: 8D - MPU Cycles: 7 - No of bytes: 2
			Opcodes.BSR_RELATIVE:
				var offset := _make_signed_8(_read_and_advance_program_counter())
				_push_program_counter()
				program_counter += offset
				cycle_counter += 7

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDX - Immediate - Opcode: 8E - MPU Cycles: 3 - No of bytes: 3
			Opcodes.LDX_IMMEDIATE:
				x_index_register = _read2_and_advance_program_counter()
				_reg_cc16(x_index_register)
				cycle_counter += 3

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBA - Direct - Opcode: 90 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.SUBA_DIRECT:
				accumulators.a = _sub8(
					accumulators.a,
					_read(_retrieve_direct_address())
				)
				cycle_counter += 4

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPA - Direct - Opcode: 91 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.CMPA_DIRECT:
				_cmpa(_read(_retrieve_direct_address()))
				cycle_counter += 4

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCA - Direct - Opcode: 92 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.SBCA_DIRECT:
				accumulators.a = _sub8(
					accumulators.a,
					_read(_retrieve_direct_address())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 4

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBD - Direct - Opcode: 93 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.SUBD_DIRECT:
				accumulators.d = _sub16(
					accumulators.d,
					_read(_retrieve_direct_address())
				)
				cycle_counter += 6

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are clear
			#     V: Cleared
			#     C: Not affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDA - Direct - Opcode: 94 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ANDA_DIRECT:
				accumulators.a &= _read(_retrieve_direct_address())
				_reg_cc8(accumulators.a)
				cycle_counter += 4

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITA - Direct - Opcode: 95 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.BITA_DIRECT:
				var temp := accumulators.a & _read(_retrieve_direct_address())
				_reg_cc8(temp)
				cycle_counter += 4

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDA - Direct - Opcode: 96 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.LDA_DIRECT:
				accumulators.a = _read(_retrieve_direct_address())
				_reg_cc8(accumulators.a)
				cycle_counter += 4

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STA - Direct - Opcode: 97 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.STA_DIRECT:
				_st_reg8(_retrieve_direct_address(), accumulators.a)
				cycle_counter += 4

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORA - Direct - Opcode: 9B - MPU Cycles: 4 - No of bytes: 2
			Opcodes.EORA_DIRECT:
				accumulators.a = accumulators.a ^ _read(_retrieve_direct_address())
				_reg_cc8(accumulators.a)
				cycle_counter += 4

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCA - Direct - Opcode: 99 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ADCA_DIRECT:
				accumulators.a = _add8(
					accumulators.a,
					_read(_retrieve_direct_address())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 4

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORA - Direct - Opcode: 9A - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ORA_DIRECT:
				accumulators.a |= _read(_retrieve_direct_address())
				_reg_cc8(accumulators.a)
				cycle_counter += 4

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDA - Direct - Opcode: 9B - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ADDA_DIRECT:
				accumulators.a = _add8(
					accumulators.a,
					_read(_retrieve_direct_address())
				)
				cycle_counter += 4

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPX - Direct - Opcode: 9C - MPU Cycles: 6 - No of bytes: 2
			Opcodes.CMPX_DIRECT:
				_cmpx(_read2(_retrieve_direct_address()))
				cycle_counter += 6

			# JSR    Jump to subroutine at effective address
			# Source Form: JSR
			# Operation: SP' <- SP - 1, (SP) <- PCL
			#            SP' <- SP - 1, (SP) <- PCH
			#            PC <- EA
			# Condition Codes: Not Affected
			# Description:
			#     Program control is transferred to the effective address after storing the return
			#     address on the hardware stack.
			#
			# JSR - Direct - Opcode: 9D - MPU Cycles: 7 - No of bytes: 2
			Opcodes.JSR_DIRECT:
				var address := _retrieve_direct_address()
				_push_program_counter()
				program_counter = address
				cycle_counter += 7

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDX - Direct - Opcode: 9E - MPU Cycles: 5 - No of bytes: 2
			Opcodes.LDX_DIRECT:
				x_index_register = _read2(_retrieve_direct_address())
				_reg_cc16(x_index_register)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STX - Direct - Opcode: 9F - MPU Cycles: 5 - No of bytes: 2
			Opcodes.STX_DIRECT:
				_st_reg16(_retrieve_direct_address(), x_index_register)
				cycle_counter += 5

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBA - Indexed - Opcode: A0 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.SUBA_INDEXED:
				accumulators.a = _sub8(
					accumulators.a,
					_read(_retrieve_effective_address())
				)
				cycle_counter += 4

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPA - Indexed - Opcode: A1 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.CMPA_INDEXED:
				_cmpa(_read(_retrieve_effective_address()))
				cycle_counter += 5

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCA - Indexed - Opcode: A2 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.SBCA_INDEXED:
				accumulators.a = _sub8(
					accumulators.a,
					_read(_retrieve_effective_address())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 4

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBD - Indexed - Opcode: A3 - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.SUBD_INDEXED:
				accumulators.d = _sub16(
					accumulators.d,
					_read2(_retrieve_effective_address())
				)
				cycle_counter += 6

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are clear
			#     V: Cleared
			#     C: Not affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDA - Indexed - Opcode: A4 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ANDA_INDEXED:
				accumulators.a &= _read(_retrieve_effective_address())
				_reg_cc8(accumulators.a)
				cycle_counter += 4

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITA - Indexed - Opcode: A5 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.BITA_INDEXED:
				var temp := _read(_retrieve_effective_address())
				_reg_cc8(temp)
				cycle_counter += 4

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDA - Indexed - Opcode: A6 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.LDA_INDEXED:
				accumulators.a = _read(_retrieve_effective_address())
				_reg_cc8(accumulators.a)
				cycle_counter += 4

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STA - Indexed - Opcode: A7 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.STA_INDEXED:
				_st_reg8(_retrieve_effective_address(), accumulators.a)
				cycle_counter += 4

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORA - Indexed - Opcode: A8 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.EORA_INDEXED:
				accumulators.a = accumulators.a \
					^ _read(_retrieve_effective_address())
				cycle_counter += 4

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCA - Indexed - Opcode: A9 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ADCA_INDEXED:
				accumulators.a = _add8(
					accumulators.a,
					_read(_retrieve_effective_address())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 4

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORA - Indexed - Opcode: AA - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ORA_INDEXED:
				accumulators.a |= _read(_retrieve_effective_address())
				_reg_cc8(accumulators.a)
				cycle_counter += 4

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDA - Indexed - Opcode: AB - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ADDA_INDEXED:
				accumulators.a = _add8(
					accumulators.a,
					_read(_retrieve_effective_address())
				)
				cycle_counter += 4

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPX - Indexed - Opcode: AC - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.CMPX_INDEXED:
				_cmpx(_read2(_retrieve_effective_address()))
				cycle_counter += 6

			# JSR    Jump to subroutine at effective address
			# Source Form: JSR
			# Operation: SP' <- SP - 1, (SP) <- PCL
			#            SP' <- SP - 1, (SP) <- PCH
			#            PC <- EA
			# Condition Codes: Not Affected
			# Description:
			#     Program control is transferred to the effective address after storing the return
			#     address on the hardware stack.
			#
			# JSR - Indexed - Opcode: AD - MPU Cycles: 7+ - No of bytes: 2+
			Opcodes.JSR_INDEXED:
				var address := _retrieve_effective_address()
				_push_program_counter()
				program_counter = address
				cycle_counter += 7

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDX - Indexed - Opcode: AE - MPU Cycles: 5+ - No of bytes: 2+
			Opcodes.LDX_INDEXED:
				x_index_register = _read2(_retrieve_effective_address())
				_reg_cc16(x_index_register)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STX - Indexed - Opcode: AF - MPU Cycles: 5+ - No of bytes: 2+
			Opcodes.STX_INDEXED:
				_st_reg16(_retrieve_effective_address(), x_index_register)
				cycle_counter += 5

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBA - Extended - Opcode: B0 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.SUBA_EXTENDED:
				accumulators.a = _sub8(
					accumulators.a,
					_read(_read2_and_advance_program_counter())
				)
				cycle_counter += 5

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPA - Extended - Opcode: B1 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.CMPA_EXTENDED:
				_cmpa(_read(_read2_and_advance_program_counter()))
				cycle_counter += 5

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCA - Extended - Opcode: B2 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.SBCA_EXTENDED:
				accumulators.a = _sub8(
					accumulators.a,
					_read(_read2_and_advance_program_counter())
					 + (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 5

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBD - Extended - Opcode: B3 - MPU Cycles: 7 - No of bytes: 3
			Opcodes.SUBD_EXTENDED:
				accumulators.d = _sub16(
					accumulators.d,
					_read2(_read2_and_advance_program_counter())
				)
				cycle_counter += 7

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are clear
			#     V: Cleared
			#     C: Not affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDA - Extended - Opcode: B4 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ANDA_EXTENDED:
				accumulators.a &= _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.a)
				cycle_counter += 5

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITA - Extended - Opcode: B5 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.BITA_EXTENDED:
				var temp := accumulators.a & _read(_read2_and_advance_program_counter())
				_reg_cc8(temp)
				cycle_counter += 5

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDA - Extended - Opcode: B6 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.LDA_EXTENDED:
				accumulators.a = _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.a)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STA - Extended - Opcode: B7 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.STA_EXTENDED:
				_st_reg8(_read2_and_advance_program_counter(), accumulators.a)
				cycle_counter += 5

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORA - Extended - Opcode: B8 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.EORA_EXTENDED:
				accumulators.a = accumulators.a ^ _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.a)
				cycle_counter += 5

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCA - Extended - Opcode: B9 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ADCA_EXTENDED:
				accumulators.a = _add8(
					accumulators.a,
					_read(_read2_and_advance_program_counter())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 5

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORA - Extended - Opcode: BA - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ORA_EXTENDED:
				accumulators.a |= _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.a)
				cycle_counter += 5

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDA - Extended - Opcode: BB - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ADDA_EXTENDED:
				accumulators.a = _add8(
					accumulators.a,
					_read(_read2_and_advance_program_counter())
				)
				_reg_cc8(accumulators.a)
				cycle_counter += 5

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPX - Extended - Opcode: BC - MPU Cycles: 7 - No of bytes: 3
			Opcodes.CMPX_EXTENDED:
				_cmpx(_read2(_read2_and_advance_program_counter()))
				cycle_counter += 7

			# JSR    Jump to subroutine at effective address
			# Source Form: JSR
			# Operation: SP' <- SP - 1, (SP) <- PCL
			#            SP' <- SP - 1, (SP) <- PCH
			#            PC <- EA
			# Condition Codes: Not Affected
			# Description:
			#     Program control is transferred to the effective address after storing the return
			#     address on the hardware stack.
			#
			# JSR - Extended - Opcode: BD - MPU Cycles: 8 - No of bytes: 3
			Opcodes.JSR_EXTENDED:
				var address := _read2_and_advance_program_counter()
				_push_program_counter()
				program_counter = address
				cycle_counter += 8

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDX - Extended - Opcode: BE - MPU Cycles: 6 - No of bytes: 3
			Opcodes.LDX_EXTENDED:
				x_index_register = _read2(_read2_and_advance_program_counter())
				_reg_cc16(x_index_register)
				cycle_counter += 6

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STX - Extended - Opcode: BF - MPU Cycles: 6 - No of bytes: 3
			Opcodes.STX_EXTENDED:
				_st_reg16(_read2_and_advance_program_counter(), x_index_register)
				cycle_counter += 6

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBB - Immediate - Opcode: C0 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.SUBB_IMMEDIATE:
				accumulators.b = _sub8(
					accumulators.b,
					_read_and_advance_program_counter()
				)
				cycle_counter += 2

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPB - Immediate - Opcode: C1 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.CMPB_IMMEDIATE:
				_cmpb(_read_and_advance_program_counter())
				cycle_counter += 2

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCB - Immediate - Opcode: C2 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.SBCB_IMMEDIATE:
				accumulators.b = _sub8(
					accumulators.b,
					_read_and_advance_program_counter()
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 2

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDD - Immediate - Opcode: C3 - MPU Cycles: 4 - No of bytes: 3
			Opcodes.ADDD_IMMEDIATE:
				accumulators.d = _add16(
					accumulators.d,
					_read2_and_advance_program_counter()
				)
				_reg_cc16(accumulators.d)
				cycle_counter += 4

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are clear
			#     V: Cleared
			#     C: Not affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDB - Immediate - Opcode: C4 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ANDB_IMMEDIATE:
				accumulators.b &= _read_and_advance_program_counter()
				_reg_cc8(accumulators.b)
				cycle_counter += 2

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITB - Immediate - Opcode: C5 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.BITB_IMMEDIATE:
				var temp := _read_and_advance_program_counter()
				_reg_cc8(temp)
				cycle_counter += 2

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDB - Immediate - Opcode: C6 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.LDB_IMMEDIATE:
				accumulators.b = _read_and_advance_program_counter()
				_reg_cc8(accumulators.b)
				cycle_counter += 2

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORB - Immediate - Opcode: C8 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.EORB_IMMEDIATE:
				accumulators.b = accumulators.b ^ _read_and_advance_program_counter()
				_reg_cc8(accumulators.b)
				cycle_counter += 2

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCB - Immediate - Opcode: C9 - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ADCB_IMMEDIATE:
				accumulators.b = _add8(
					accumulators.b,
					_read_and_advance_program_counter()
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 2

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORB - Immediate - Opcode: CA - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ORB_IMMEDIATE:
				accumulators.b |= _read_and_advance_program_counter()
				_reg_cc8(accumulators.b)
				cycle_counter += 2

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDB - Immediate - Opcode: CB - MPU Cycles: 2 - No of bytes: 2
			Opcodes.ADDB_IMMEDIATE:
				accumulators.b = _add8(
					accumulators.b,
					_read_and_advance_program_counter()
				)
				cycle_counter += 2

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDD - Immediate - Opcode: CC - MPU Cycles: 3 - No of bytes: 3
			Opcodes.LDD_IMMEDIATE:
				accumulators.d = _read2_and_advance_program_counter()
				_reg_cc16(accumulators.d)
				cycle_counter += 3

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDU - Immediate - Opcode: CE - MPU Cycles: 3 - No of bytes: 3
			Opcodes.LDU_IMMEDIATE:
				user_stack_pointer = _read2_and_advance_program_counter()
				_reg_cc16(user_stack_pointer)
				cycle_counter += 3

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBB - Direct - Opcode: D0 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.SUBB_DIRECT:
				accumulators.b = _sub8(
					accumulators.b,
					_read(_retrieve_direct_address())
				)
				cycle_counter += 4

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPB - Direct - Opcode: D1 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.CMPB_DIRECT:
				_cmpb(_read(_retrieve_direct_address()))
				cycle_counter += 4

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCB - Direct - Opcode: D2 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.SBCB_DIRECT:
				accumulators.b = _sub8(
					accumulators.b,
					_read(_retrieve_direct_address())
						+ (1 if condition_code_register.carry else 0)
				)
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDD - Direct - Opcode: D3 - MPU Cycles: 6 - No of bytes: 2
			Opcodes.ADDD_DIRECT:
				accumulators.d = _add16(
					accumulators.d,
					_read2(_retrieve_direct_address())
				)
				cycle_counter += 6

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are clear
			#     V: Cleared
			#     C: Not affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDB - Direct - Opcode: D4 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ANDB_DIRECT:
				accumulators.b &= _read(_retrieve_direct_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITB - Direct - Opcode: D5 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.BITB_DIRECT:
				var temp := accumulators.b & _read(_retrieve_direct_address())
				_reg_cc8(temp)
				cycle_counter += 4

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDB - Direct - Opcode: D6 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.LDB_DIRECT:
				accumulators.b = _read(_retrieve_direct_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STB - Direct - Opcode: D7 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.STB_DIRECT:
				_st_reg8(_retrieve_direct_address(), accumulators.b)
				cycle_counter += 4

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORB - Direct - Opcode: D8 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.EORB_DIRECT:
				accumulators.b = accumulators.b ^ _read(_retrieve_direct_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCB - Direct - Opcode: D9 - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ADCB_DIRECT:
				accumulators.b = _add8(
					accumulators.b,
					_read(_retrieve_direct_address())
						+ (1 if condition_code_register else 0)
				)
				cycle_counter += 4

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORB - Direct - Opcode: DA - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ORB_DIRECT:
				accumulators.b |= _read(_retrieve_direct_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDB - Direct - Opcode: DB - MPU Cycles: 4 - No of bytes: 2
			Opcodes.ADDB_DIRECT:
				accumulators.b = _add8(
					accumulators.b,
					_read(_retrieve_direct_address())
				)
				cycle_counter += 4

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDD - Direct - Opcode: DC - MPU Cycles: 5 - No of bytes: 2
			Opcodes.LDD_DIRECT:
				accumulators.d = _read2(_retrieve_direct_address())
				_reg_cc16(accumulators.d)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STD - Direct - Opcode: DD - MPU Cycles: 5 - No of bytes: 2
			Opcodes.STD_DIRECT:
				_st_reg16(_retrieve_direct_address(), accumulators.d)
				cycle_counter += 5

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDU - Direct - Opcode: DE - MPU Cycles: 5 - No of bytes: 2
			Opcodes.LDU_DIRECT:
				user_stack_pointer = _read2(_retrieve_direct_address())
				_reg_cc16(user_stack_pointer)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STU - Direct - Opcode: DF - MPU Cycles: 5 - No of bytes: 2
			Opcodes.STU_DIRECT:
				_st_reg16(_retrieve_direct_address(), user_stack_pointer)
				cycle_counter += 5

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBB - Indexed - Opcode: E0 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.SUBB_INDEXED:
				accumulators.b = _sub8(
					accumulators.b,
					_read(_retrieve_effective_address())
				)
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPB - Indexed - Opcode: E1 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.CMPB_INDEXED:
				_cmpb(_read(_retrieve_effective_address()))
				cycle_counter += 4

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCB - Indexed - Opcode: E2 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.SBCB_INDEXED:
				accumulators.b = _sub8(
					accumulators.b,
					_read(_retrieve_effective_address())
				)
				cycle_counter += 4

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDD - Indexed - Opcode: E3 - MPU Cycles: 6+ - No of bytes: 2+
			Opcodes.ADDD_INDEXED:
				accumulators.d = _add16(
					accumulators.d,
					_read(_retrieve_effective_address())
				)
				cycle_counter += 6

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are clear
			#     V: Cleared
			#     C: Not affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDB - Indexed - Opcode: E4 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ANDB_INDEXED:
				accumulators.b &= _read(_retrieve_effective_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITB - Indexed - Opcode: E5 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.BITB_INDEXED:
				var temp := accumulators.b \
					& _read(_retrieve_effective_address())
				_reg_cc8(temp)
				cycle_counter += 4

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDB - Indexed - Opcode: E6 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.LDB_INDEXED:
				accumulators.b = _read(_retrieve_effective_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STB - Indexed - Opcode: E7 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.STB_INDEXED:
				_st_reg8(_retrieve_effective_address(), accumulators.b)
				cycle_counter += 4

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORB - Indexed - Opcode: E8 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.EORB_INDEXED:
				accumulators.b = accumulators.b \
					^ _read(_retrieve_effective_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCB - Indexed - Opcode: E9 - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ADCB_INDEXED:
				accumulators.b = _add8(
					accumulators.b,
					_read(_retrieve_effective_address())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 4

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORB - Indexed - Opcode: EA - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ORB_INDEXED:
				accumulators.b |= _read(_retrieve_effective_address())
				_reg_cc8(accumulators.b)
				cycle_counter += 4

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDB - Indexed - Opcode: EB - MPU Cycles: 4+ - No of bytes: 2+
			Opcodes.ADDB_INDEXED:
				accumulators.b = _add8(
					accumulators.b,
					_read(_retrieve_effective_address())
				)
				cycle_counter += 4

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDD - Indexed - Opcode: EC - MPU Cycles: 5+ - No of bytes: 2+
			Opcodes.LDD_INDEXED:
				accumulators.d = _read2(_retrieve_effective_address())
				_reg_cc16(accumulators.d)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STD - Indexed - Opcode: ED - MPU Cycles: 5+ - No of bytes: 2+
			Opcodes.STD_INDEXED:
				_st_reg16(_retrieve_effective_address(), accumulators.d)
				cycle_counter += 5

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDU - Indexed - Opcode: EE - MPU Cycles: 5+ - No of bytes: 2+
			Opcodes.LDU_INDEXED:
				user_stack_pointer = _read2(_retrieve_effective_address())
				_reg_cc16(user_stack_pointer)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STU - Indexed - Opcode: EF - MPU Cycles: 5+ - No of bytes: 2+
			Opcodes.STU_INDEXED:
				_st_reg16(_retrieve_effective_address(), user_stack_pointer)
				cycle_counter += 5

			# SUB    Subtract memory from register
			# Source Forms: SUBA P; SUBB P; SUBD P
			# Operation: R' <- R - M
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
			#     C: Set if the operation did not cause a carry from bit 7 in the ALU
			# Description:
			#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag
			#     represents a borrow and is set inverse to the resulting carry.
			#
			# SUBB - Extended - Opcode: F0 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.SUBB_EXTENDED:
				accumulators.b = _sub8(
					accumulators.b,
					_read(_read2_and_advance_program_counter())
				)
				cycle_counter += 5

			# CMP    Compare memory from a register
			# Source Form: CMPA P; CMPB P; CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
			# Operation: TEMP <- R - M(:M+1)
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 (15) of the result is Set.
			#     Z: Set if all bits of the result are Clear
			#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
			#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
			# Description:
			#     Compares the contents of M from teh contents of the specified register and sets
			#     appropriate condition codes. Neither M nor R is modified. The C flag represents a
			#     borrow and is set inverse to the resulting binary carry.
			#
			# CMPB - Extended - Opcode: F1 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.CMPB_EXTENDED:
				_cmpb(_read(_read2_and_advance_program_counter()))
				cycle_counter += 5

			# SBC    Subtract with carry memory into register
			# Source Form: SBCA P; SBCB P
			# Operation: R' <- R - M - C
			# Condition Codes:
			#     H: Undefined
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Subtracts the contents of the carry flag and the memory byte into an 8-bit
			#     register.
			#
			# SBCB - Extended - Opcode: F2 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.SBCB_EXTENDED:
				accumulators.b = _sub8(
					accumulators.b,
					_read(_read2_and_advance_program_counter())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 5

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDD - Extended - Opcode: F3 - MPU Cycles: 7 - No of bytes: 3
			Opcodes.ADDD_EXTENDED:
				accumulators.d = _add16(
					accumulators.d,
					_read2(_read2_and_advance_program_counter())
				)
				cycle_counter += 7

			# AND    Logical AND memory into register
			# Source Forms: ANDA P; ANDB P
			# Operation: R' <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is set
			#     Z: Set if all bits of result are clear
			#     V: Cleared
			#     C: Not affected
			# Description:
			#     Performs the logical "AND" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ANDB - Extended - Opcode: F4 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ANDB_EXTENDED:
				accumulators.b &= _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.b)
				cycle_counter += 5

			# BIT    Bit test
			# Source Form: BITA P; BITB P
			# Operation: TEMP <- R ∧ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of the result is Set
			#     Z: Set if all bits of the result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs the logical "AND" of the contents of ACCX and the contents of M and
			#     modifies condition codes accordingly. The contents of ACCX or M are not affected.
			#
			# BITB - Extended - Opcode: F5 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.BITB_EXTENDED:
				var temp := accumulators.b & _read(_read2_and_advance_program_counter())
				_reg_cc8(temp)
				cycle_counter += 5

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDB - Extended - Opcode: F6 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.LDB_EXTENDED:
				accumulators.b = _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.b)
				cycle_counter += 5

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STB - Extended - Opcode: F7 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.STB_EXTENDED:
				_st_reg8(_read2_and_advance_program_counter(), accumulators.b)
				cycle_counter += 5

			# EOR    Exclusive or
			# Source Forms: EORA P; EORB P
			# Operation: R' <- R ^ M
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 of result is Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     The contents of memory is exclusive-ORed into an 8-bit register
			#
			# EORB - Extended - Opcode: F8 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.EORB_EXTENDED:
				accumulators.b = accumulators.b ^ _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.b)
				cycle_counter += 5

			# ADC    Add with carry memory into register
			# Source Form: ADCA P; ADCB P
			# Operation: R' <- R + M + C
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 of the result is set.
			#     Z: Set if all bits of hte result are clear.
			#     V: Set if the operation caused an 8-bit two's complement arithmetic overflow
			#     C: Set if the operation caused a carry from bit 7 in the ALU.
			# Description:
			#     Adds the contents of the carry flag and the memory byte into an 8-bit register.
			#
			# ADCB - Extended - Opcode: F9 - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ADCB_EXTENDED:
				accumulators.b = _add8(
					accumulators.b,
					_read(_read2_and_advance_program_counter())
						+ (1 if condition_code_register.carry else 0)
				)
				cycle_counter += 5

			# OR    Inclusive OR memory into register
			# Source Form: ORA P; ORB P
			# Operation: R' <- R ∨ M
			# Condition CodeS:
			#     H: Not Affected
			#     N: Set if high order bit of result Set
			#     Z: Set if all bits of result are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Performs an "inclusive OR" operation between the contents of ACCX and the
			#     contents of M and the result is stored in ACCX.
			#
			# ORB - Extended - Opcode: FA - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ORB_EXTENDED:
				accumulators.b |= _read(_read2_and_advance_program_counter())
				_reg_cc8(accumulators.b)
				cycle_counter += 5

			# ADD    Add memory into register
			# Source Forms: ADDA P; ADDB P; ADDD P;
			# Operation: R' <- R + M
			# Condition Codes:
			#     H: Set if the operation caused a carry from bit 3 in the ALU.
			#     N: Set if bit 7 (15) of the result is set.
			#     Z: Set if all bits of the result are clear.
			#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
			#        overflow.
			#     C: Set if the operation caused a carry from bit 7 in the ALU
			# Description:
			#     Adds the memory byte into an 8 (16) - bit register
			#
			# ADDB - Extended - Opcode: FB - MPU Cycles: 5 - No of bytes: 3
			Opcodes.ADDB_EXTENDED:
				accumulators.b = _add8(
					accumulators.b,
					_read(_read2_and_advance_program_counter())
				)
				cycle_counter += 5

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDD - Extended - Opcode: FC - MPU Cycles: 6 - No of bytes: 3
			Opcodes.LDD_EXTENDED:
				accumulators.d = _read2(_read2_and_advance_program_counter())
				_reg_cc16(accumulators.d)
				cycle_counter += 6

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STD - Extended - Opcode: FD - MPU Cycles: 6 - No of bytes: 3
			Opcodes.STD_EXTENDED:
				_st_reg16(_read2_and_advance_program_counter(), accumulators.d)
				cycle_counter += 6

			# LD    Load register from memory
			# Source Forms: LDA P; LDB P; LDD P; LDX P; LDY P; LDS P; LDU P
			# Operation: R' <- M(:M+1)
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of loaded data is Set
			#     Z: Set if all bits of loaded data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Load the contents of the addressed memory into the register.
			#
			# LDU - Extended - Opcode: FE - MPU Cycles: 6 - No of bytes: 3
			Opcodes.LDU_EXTENDED:
				user_stack_pointer = _read2(_read2_and_advance_program_counter())
				_reg_cc16(user_stack_pointer)
				cycle_counter += 6

			# ST    Store register into memory
			# Source Form: STA P; STB P; STD P; STX P; STY P; STS P; STU P
			# Operation: M'(:M+1') <- R
			# Condition Codes:
			#     H: Not Affected
			#     N: Set if bit 7 (15) of stored data was Set
			#     Z: Set if all bits of stored data are Clear
			#     V: Cleared
			#     C: Not Affected
			# Description:
			#     Writes the contents of an MPU register into a memory location.
			#
			# STU - Extended - Opcode: FF - MPU Cycles: 6 - No of bytes: 3
			Opcodes.STU_EXTENDED:
				_st_reg16(_read2_and_advance_program_counter(), user_stack_pointer)
				cycle_counter += 6

			_:
				pass

		if pins.irq and delay_irq:
			delay_irq = false
			handle_irq()

	pins.set_pin(Pins.LIC, true)

	var ret := num_cycles_to_run - cycle_counter
	cycle_counter = 0.0
	return ret


# NEG    Negate
# Operation: M' <- 0 - M (i.e. M' <- ~M + 1)
# Condition Codes:
#     H: Undefined
#     N: Set if bit 7 of result is set
#     Z: Set if all bits of result are Clear
#     V: Set if the original operand was 10000000
#     C: Set if the operation did not cause a cary from bit 7 in the ALU.
# Description:
#     Replaces the operand with its two's complement. The C-flag represents a borrow and is set
#     inverse to the resulting binary carry. Not that 80 (16) is replaced by itself and only in
#     this case is V Set. The value 00 (16) is also replaced by itself, and only in this case is C
#     cleared.
func _neg(byte: int) -> int:
	var new_byte := (~byte + 1) & 0xFF
	condition_code_register.negative = new_byte & 0x80
	condition_code_register.zero = new_byte == 0
	condition_code_register.overflow = byte == 0x80
	condition_code_register.carry = new_byte > 0
	return new_byte


# COM    Complement
# Operation: M' (R') <- 0 + ~M (~R)
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 of the result is Set
#     Z: Set if all bits of the result are Clear
#     V: Cleared
#     C: Set
# Description:
#     Replaces the contents of M or ACCX with its one's complement (also called the logical
#     complement). The carry flag is set for 6800 compatibility.
# Comments:
#     When operating on unsigned values, only BEQ and MBE branches can be expected to behave
#     properly. When operating on two's complement values, all signed branches are available.
func _com(byte: int) -> int:
	byte = ~byte
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	condition_code_register.overflow = false
	condition_code_register.carry = true
	return byte


# LSR    Logical shift right
# Operation:
#      _________________    _____
# 0 -> | | | | | | | | | -> | C |
#      -----------------    -----
#      b7             b0
#
# Condition Codes:
#     H: Not Affected
#     N: Cleared
#     Z: Set if all bits of the result are Clear
#     V: Not Affected
#     C: Loaded with bit 0 of the original operand
# Description:
#     Performs a logical shift right on the operand. Shifts a zero into bit 7 and bit 0 into the
#     carry flag. The 6800 processor also affects the V flag.
func _lsr(byte: int) -> int:
	condition_code_register.carry = byte & 0x01
	byte >>= 1
	condition_code_register.negative = false
	condition_code_register.zero = byte == 0
	return byte


# ROR    Rotate right
# Operation:
#       _____
#  -----| C |-----
#  |    -----    |
# _________________
# | | | | | | | | |
# -----------------
# b7      ->     b0
#
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 of the result is Set
#     Z: Set if all bits of the result are Clear
#     V: Not Affected
#     C: Loaded with bit 0 of the original operand
# Description:
#     Rotates all bits of the operand right one place through the carry flag; this is a nine-bit
#     rotation. The 6800 processor also affects the V flag.
func _ror(byte: int) -> int:
	var temp_c: bool = byte & 0x01
	byte >>= 1
	if condition_code_register.carry:
		byte |= 0x80
	condition_code_register.carry = temp_c
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	return byte


# ASR    Arithmetic shift right
# Operation:
# _____
# |   |
# |  _________________    _____
# -->| | | | | | | | | -> | C |
#    -----------------    -----
#    b7             b0
#
# Condition Codes:
#     H: Undefined
#     N: Set if bit 7 of the result is set
#     Z: Set if all bits of result are clear
#     V: Not affected
#     C: Loaded with bit 0 of the original operand
# Description:
#     Shifts all bits of the operand right one place. Bit 7 is held constant. Bit 0 is shifted into
#     the carry flag. The 6800/01/02/03/08 processors do affect the V flag.
func _asr(byte: int) -> int:
	condition_code_register.carry = byte & 0x01
	byte = (byte & 0x80) | (byte >> 1)
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	return byte


# ASL    Arithmetic shift left
# Operation:
# _____    _________________
# | C | <- | | | | | | | | | <- 0
# -----    -----------------
#          b7      <-     b0
#
# Condition Codes:
#     H: Undefined
#     N: Set if bit 7 of the result is set
#     Z: Set if all bits of the result are clear
#     V: Loaded with the result of b7 ^ b0 of the original operand.
#     C: Loaded with bit 7 of the original operand.
# Description:
#     Shifts all bits of the operand one place to the left. Bit 0 is loaded with a zero. Bit 7 of
#     the operand is shifted into the carry flag.
func _asl(byte: int) -> int:
	condition_code_register.carry = byte & 0x80
	condition_code_register.overflow = ((byte & 0x80) >> 1) ^ (byte & 0x40)
	byte <<= 1
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	return byte


# ROL    Rotate left
# Operation:
#       _____
#  -----| C |-----
#  |    -----    |
# _________________
# | | | | | | | | |
# -----------------
# b7      <-     b0
#
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 of the result is Set
#     Z: Set if all bits of the result are Clear
#     V: Loaded with the result of (b7 ^ b6) of the original operand.
#     C: Loaded with bit 7 of the original operand
# Description:
#     Rotate all bits of the operand one place left through the carry flag; this is a 9-bit
#     rotation.
func _rol(byte: int) -> int:
	var temp_c: bool = byte & 0x80
	condition_code_register.overflow = ((byte & 0x80) >> 1) ^ (byte & 0x40)
	byte <<= 1
	if condition_code_register.carry:
		byte |= 0x01
	condition_code_register.carry = temp_c
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	return byte


# DEC    Decrement
# Operation: M' (R') <- M-1 (R-1)
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 of result is Set
#     Z: Set if all bits of result are Clear
#     V: Set if the original operand was 10000000
#     C: Not affected
# Description:
#     Subtract one from the operand. The carry flag is not affected, thus allowing DEC to be a
#     loopcounter in multiple-precision computations.
# Comments:
#     When operating on unsigned values only BEQ and BNE branches can be expected to behave
#     consistently. When operating on two's complement values, all signed branches are available.
func _dec(byte: int) -> int:
	var neg := byte & 0x80
	byte = (byte - 1) & 0xFF
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	condition_code_register.overflow = true if neg and neg != byte & 0x80 else false
	return byte


# INC    Increment
# Operation: M' (R') <- M + 1 (R + 1)
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 of the result is Set
#     Z: Set if all bits of the result are Clear
#     V: Set if the original operand was 01111111
#     C: Not Affected
# Description:
#     Add one to the operand. The carry flag is not affected, thus allowing INC to be used as a
#     loop-counter in multiple-precision computations.
# Comments:
#     When operating on unsigned values, only the BEQ and BNE branches can be expected to behave
#     consistently. When operating on two's complement values, all signed branches are correctly
#     available.
func _inc(byte: int) -> int:
	var neg := byte & 0x80
	byte = (byte + 1) & 0xFF
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	condition_code_register.overflow = true if not neg and neg != byte & 0x80 else false
	return byte


# TST    Test
# Operation: TEMP <- M - 0
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 of the result is Set
#     Z: Set if all bits of the result are Clear
#     V: Cleared
#     C: Not Affected
# Description:
#     Set condition code flags N and Z according to the contents of M, and clear the V flag. The
#     6800 processor clears the C flag.
# Comments:
#     The TST instruction provides only minimum information when testing unsigned values; since no
#     unsigned value is less than zero, BLO and BLS have no utility. While BHI could be used after
#     TST, it provides exactly the same control as BNE, which is preferred. The signed branches are
#     available.
func _tst(byte: int) -> void:
	condition_code_register.negative = byte & 0x80
	condition_code_register.zero = byte == 0
	condition_code_register.overflow = false
	return


# CLR    Clear
# Operation: TEMP <- M
#            M <- 00 (16)
# Condition CodeS:
#     H: Not Affected
#     N: Cleared
#     Z: Set
#     V: Cleared
#     C: Cleared
# Description:
#     ACCX or M is loaded with 00000000. The C-flag is cleared for 6800 compatibility.
func _clr() -> void:
	condition_code_register.negative = false
	condition_code_register.zero = true
	condition_code_register.overflow = false
	condition_code_register.carry = false
	return


# SUB    Subtract memory from register
# Operation: R' <- R - M
# Condition Codes:
#     H: Undefined
#     N: Set if bit 7 (15) of the result is Set
#     Z: Set if all bits of the result are Clear
#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
#     C: Set if the operation did not cause a carry from bit 7 in the ALU
# Description:
#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag represents a
#     borrow and is set inverse to the resulting carry.
func _sub16(minuend: int, subtrahend: int) -> int:
	var neg := minuend & 0x8000
	var difference := (minuend - subtrahend) & 0xFFFF
	condition_code_register.negative = difference & 0x8000
	condition_code_register.zero = difference == 0
	condition_code_register.overflow = true if neg and neg != difference & 0x8000 else false
	condition_code_register.carry = difference > minuend
	return minuend


# SUB    Subtract memory from register
# Operation: R' <- R - M
# Condition Codes:
#     H: Undefined
#     N: Set if bit 7 (15) of the result is Set
#     Z: Set if all bits of the result are Clear
#     V: Set if the operation caused an 8 (16)-bit two's complement overflow
#     C: Set if the operation did not cause a carry from bit 7 in the ALU
# Description:
#     Subtracts the value in M from teh contents of an 8 (16)-bit register. The C flag represents a
#     borrow and is set inverse to the resulting carry.
func _sub8(minuend: int, subtrahend: int) -> int:
	var neg := minuend & 0x80
	var difference := (minuend - subtrahend) & 0xFF
	condition_code_register.negative = difference & 0x80
	condition_code_register.zero = difference == 0
	condition_code_register.overflow = true if neg and neg != difference & 0x80 else false
	condition_code_register.carry = difference > minuend
	return difference


# ADD    Add memory into register
# Operation: R' <- R + M
# Condition Codes:
#     H: Set if the operation caused a carry from bit 3 in the ALU.
#     N: Set if bit 7 (15) of the result is set.
#     Z: Set if all bits of the result are clear.
#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
#        overflow.
#     C: Set if the operation caused a carry from bit 7 in the ALU
# Description:
#     Adds the memory byte into an 8 (16) - bit register
func _add8(augend: int, addend: int) -> int:
	var neg := augend & 0x80
	var sum := augend + addend
	condition_code_register.half_carry = (augend & 0x8) and (addend & 0x8)
	condition_code_register.negative = sum & 0x80
	condition_code_register.zero = sum == 0
	condition_code_register.overflow = true if neg and neg != sum & 0x80 else false
	condition_code_register.carry = sum & 0x100
	return sum & 0xFF


# ADD    Add memory into register
# Operation: R' <- R + M
# Condition Codes:
#     H: Set if the operation caused a carry from bit 3 in the ALU.
#     N: Set if bit 7 (15) of the result is set.
#     Z: Set if all bits of the result are clear.
#     V: Set if the operation caused an 8 (16) -bit two's complement arithmetic
#        overflow.
#     C: Set if the operation caused a carry from bit 7 in the ALU
# Description:
#     Adds the memory byte into an 8 (16) - bit register
func _add16(augend: int, addend: int) -> int:
	var neg := augend & 0x8000
	var sum := augend + addend
	condition_code_register.negative = sum & 0x8000
	condition_code_register.zero = sum == 0
	condition_code_register.overflow = true if neg and neg != sum & 0x8000 else false
	condition_code_register.carry = sum & 0x10000
	return sum & 0xFFFF

# SP' <- SP - 1, (SP) <- Byte
func _push_onto_hardware_stack(byte: int) -> void:
	hardware_stack_pointer -= 1
	_write(hardware_stack_pointer, byte)


# ret <- (SP), SP' <- SP + 1
func _pull_from_hardware_stack() -> int:
	var ret := _read(hardware_stack_pointer)
	hardware_stack_pointer += 1
	return ret


# UP' <- UP - 1, (UP) <- Byte
func _push_onto_user_stack(byte: int) -> void:
	user_stack_pointer -= 1
	_write(user_stack_pointer, byte)


# ret <- (UP), UP' <- UP + 1
func _pull_from_user_stack() -> int:
	var ret := _read(user_stack_pointer)
	user_stack_pointer += 1
	return ret


# SP' <- SP - 1, (SP) <- PCL
# SP' <- SP - 1, (SP) <- PCH
func _push_program_counter() -> void:
	_push_onto_hardware_stack(program_counter && 0xFF)
	_push_onto_hardware_stack((program_counter >> 8) & 0xFF)


# SP' <- SP - 1, (SP) <- PCL
# SP' <- SP - 1, (SP) <- PCH
# SP' <- SP - 1, (SP) <- USL
# SP' <- SP - 1, (SP) <- USH
# SP' <- SP - 1, (SP) <- IYL
# SP' <- SP - 1, (SP) <- IYH
# SP' <- SP - 1, (SP) <- IXL
# SP' <- SP - 1, (SP) <- IXH
# SP' <- SP - 1, (SP) <- DPR
# SP' <- SP - 1, (SP) <- ACCA
# SP' <- SP - 1, (SP) <- ACCB
# SP' <- SP - 1, (SP) <- CCR
func _push_machine_state() -> void:
	_push_onto_hardware_stack(program_counter & 0xF)
	_push_onto_hardware_stack((program_counter >> 8) & 0xFF)

	_push_onto_hardware_stack(user_stack_pointer & 0xF)
	_push_onto_hardware_stack((user_stack_pointer >> 8) & 0xFF)

	_push_onto_hardware_stack(y_index_register & 0xF)
	_push_onto_hardware_stack((y_index_register >> 8) & 0xFF)

	_push_onto_hardware_stack(x_index_register & 0xF)
	_push_onto_hardware_stack((x_index_register >> 8) & 0xFF)

	_push_onto_hardware_stack(direct_page_register.get_real_dp())

	_push_onto_hardware_stack(accumulators.b)

	_push_onto_hardware_stack(accumulators.a)

	_push_onto_hardware_stack(condition_code_register.register)


# NOTE: Does NOT pull CCR, nor PC
#
# ACCA <- (SP), SP' <- SP + 1
# ACCB <- (SP), SP' <- SP + 1
# DPR <- (SP), SP' <- SP + 1
# IXH <- (SP), SP' <- SP + 1
# IXL <- (SP), SP' <- SP + 1
# IYH <- (SP), SP' <- SP + 1
# IYL <- (SP), SP' <- SP + 1
# USH <- (SP), SP' <- SP + 1
# USL <- (SP), SP' <- SP + 1
func _pull_machine_state() -> void:
	accumulators.a = _pull_from_hardware_stack()
	
	accumulators.b = _pull_from_hardware_stack()
	
	direct_page_register.dp = _pull_from_hardware_stack()
	
	x_index_register = _pull_from_hardware_stack()
	x_index_register <<= 8
	x_index_register |= _pull_from_hardware_stack()

	y_index_register = _pull_from_hardware_stack()
	y_index_register <<= 8
	y_index_register |= _pull_from_hardware_stack()

	user_stack_pointer = _pull_from_hardware_stack()
	user_stack_pointer <<= 8
	user_stack_pointer |= _pull_from_hardware_stack()


# CMP    Compare memory from a register
# Operation: TEMP <- R - M(:M+1)
# Condition Codes:
#     H: Undefined
#     N: Set if bit 7 (15) of the result is Set.
#     Z: Set if all bits of the result are Clear
#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
# Description:
#     Compares the contents of M from teh contents of the specified register and sets appropriate
#     condition codes. Neither M nor R is modified. The C flag represents a borrow and is set
#     inverse to the resulting binary carry.
func _cmp16(register: int, post: int):
	var neg := register & 0x8000
	var difference := (register - post) & 0xFFFF
	condition_code_register.negative = difference & 0x8000
	condition_code_register.zero = difference == 0
	condition_code_register.overflow = true if neg and neg != difference & 0x8000 else false
	condition_code_register.carry = difference > register


# CMP    Compare memory from a register
# Operation: TEMP <- R - M(:M+1)
# Condition Codes:
#     H: Undefined
#     N: Set if bit 7 (15) of the result is Set.
#     Z: Set if all bits of the result are Clear
#     V: Set if the operation caused an 8 (16) bit two's complement overflow.
#     C: Set if the subtraction did not cause a carry from bit 7 in the ALU.
# Description:
#     Compares the contents of M from teh contents of the specified register and sets appropriate
#     condition codes. Neither M nor R is modified. The C flag represents a borrow and is set
#     inverse to the resulting binary carry.
func _cmp8(register: int, post: int):
	var neg := register & 0x80
	var difference := (register - post) & 0xFF
	condition_code_register.negative = difference & 0x80
	condition_code_register.zero = difference == 0
	condition_code_register.overflow = true if neg and neg != difference & 0x80 else false
	condition_code_register.carry = difference > register


# CMPA P;
func _cmpa(post: int) -> void:
	_cmp8(accumulators.a, post)


# CMPB P;
func _cmpb(post: int) -> void:
	_cmp8(accumulators.b, post)


# CMPD P;
func _cmpd(post: int) -> void:
	_cmp16(accumulators.d, post)


# CMPY P;
func _cmpy(post: int) -> void:
	_cmp16(y_index_register, post)


# CMPX P;
func _cmpx(post: int) -> void:
	_cmp16(x_index_register, post)


# CMPU P;
func _cmpu(post: int) -> void:
	_cmp16(user_stack_pointer, post)


# CMPS P;
func _cmps(post: int) -> void:
	_cmp16(hardware_stack_pointer, post)


# ST    Store register into memory
# Operation: M'(:M+1') <- R
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 (15) of stored data was Set
#     Z: Set if all bits of stored data are Clear
#     V: Cleared
#     C: Not Affected
# Description:
#     Writes the contents of an MPU register into a memory location.
func _st_reg16(address: int, register: int) -> void:
	_write2(address, register)
	_reg_cc16(register)


# ST    Store register into memory
# Operation: M'(:M+1') <- R
# Condition Codes:
#     H: Not Affected
#     N: Set if bit 7 (15) of stored data was Set
#     Z: Set if all bits of stored data are Clear
#     V: Cleared
#     C: Not Affected
# Description:
#     Writes the contents of an MPU register into a memory location.
func _st_reg8(address: int, register: int) -> void:
	_write(address, register)
	_reg_cc8(register)


# Set the condition code register based on the contents of an 8-bit register.
func _reg_cc8(register: int) -> void:
	condition_code_register.negative = register & 0x80
	condition_code_register.zero = register == 0
	condition_code_register.overflow = false


# Set the condition code register based on the contents of a 16-bit register.
func _reg_cc16(register: int) -> void:
	condition_code_register.negative = register & 0x8000
	condition_code_register.zero = register == 0
	condition_code_register.overflow = false


# NOTE: Does not check sizes
#
# EXG    Exchange registers
# Operation: R1 <-> R2
# Condition Codes: Not Affected (unless one of the registres is CCR)
# Description:
#     Bits 3-0 of the immediate byte of the instruction define one register, while bits 7-4 define
#     the other, as follows:
#
#     0000 = A:B          1000 = A
#     0001 = X            1001 = B
#     0010 = Y            1010 = CCR
#     0011 = US           1011 = DPR
#     0100 = SP           1100 = Undefined
#     0101 = PC           1101 = Undefined
#     0110 = Undefined    1110 = Undefined
#     0111 = Undefined    1111 = Undefined
#
#     Registers may only be exchanged with registers of like size; i.e., 8-bit with 8-bit, or 16
#     with 16.
func _exg_registers(source: int, destination: int) -> void:
	var temp := _read_from_register(destination)
	_write_to_register(destination, _read_from_register(source))
	_write_to_register(source, temp)


func _read_from_register(source: int) -> int:
	match source:
		TransferExchangePostByte.D:
			return accumulators.d

		TransferExchangePostByte.X:
			return x_index_register

		TransferExchangePostByte.Y:
			return y_index_register

		TransferExchangePostByte.U:
			return user_stack_pointer

		TransferExchangePostByte.S:
			return hardware_stack_pointer

		TransferExchangePostByte.PC:
			return program_counter

		TransferExchangePostByte.A:
			return accumulators.a

		TransferExchangePostByte.B:
			return accumulators.b

		TransferExchangePostByte.CCR:
			return condition_code_register.register

		TransferExchangePostByte.DPR:
			return direct_page_register.get_real_dp()

		_:
			pass

	return 0


func _write_to_register(destination: int, value: int) -> void:
	match destination:
		TransferExchangePostByte.D:
			accumulators.d = value

		TransferExchangePostByte.X:
			x_index_register = value

		TransferExchangePostByte.Y:
			y_index_register = value

		TransferExchangePostByte.U:
			user_stack_pointer = value

		TransferExchangePostByte.S:
			hardware_stack_pointer = value

		TransferExchangePostByte.PC:
			program_counter = value

		TransferExchangePostByte.A:
			accumulators.a = value
		
		TransferExchangePostByte.B:
			accumulators.b = value

		TransferExchangePostByte.CCR:
			condition_code_register.register = value

		TransferExchangePostByte.DPR:
			direct_page_register.dp = value

		_:
			pass


# Offset the program counter by a twos-complement signed byte
func _b_relative_offset() -> void:
	var post := _make_signed_8(_read(program_counter))
	program_counter += post


# Offset the program counter by a twos-complement signed word (2 bytes)
func _lb_relative_offset() -> void:
	var post := _make_signed_16(_read2(program_counter))
	program_counter += post


# NOTE: Advances program counter
#
# Compute the direct address by concatenating the DPR with the value at PC
func _retrieve_direct_address() -> int:
	return direct_page_register.dp | _read_and_advance_program_counter()


# Read one byte at PC and advance PC
func _read_and_advance_program_counter() -> int:
	var ret := _read(program_counter)
	program_counter += 1
	return ret


# Read two bytes at PC and advance PC by two
func _read2_and_advance_program_counter() -> int:
	var ret := _read2(program_counter)
	program_counter += 2
	return ret


# Set up the processor pins for a memory read, then access the bus
func _read(address: int) -> int:
	if pins.address != address:
		pins.address = address
	pins.rw = true
	emit_signal('bus_accessed', pins)
	return pins.data


# Reads and shifts bits appropriately to return a 16-bit integer
#
# NOTE: Accesses bus twice
func _read2(address: int) -> int:
	var ret := _read(address)
	ret = (ret << 8) | _read(address+1)
	return ret


# Set up the processor pins for a memory write, then access the bus
func _write(address: int, byte: int) -> void:
	pins.data = byte
	if pins.address != address:
		pins.address = address
	pins.rw = false
	emit_signal('bus_accessed', pins)


# Writes and shifts bits appropriately to write a 16-bit integer
#
# NOTE: Accesses bus twice
func _write2(address: int, bytes: int) -> void:
	_write(address, (bytes >> 8) & 0xFF)
	_write(address + 1, bytes & 0xFF)


# NOTE: Advances PC
#
# Calculate the effective address indicated by the byte read from the program counter in accordance
# with these charts:
#
# INDEXED ADDRESSING
#
#     In all indexed addressing, one of the pointer registers {X, Y, U, S, and sometimes PC) is
# used in a calculation of the effective address of the operand to be used by the instruction. Five
# basic types of indexing are available and are discussed below. The postbyte of an indexed
# instruction specifies the basic type and variation of the addressing mode as well as the pointer
# register to be used. Figure 16 lists the legal formats for the postbyte. Table 2 gives the
# assembler form and the number of cycles and bytes added to the basic values for indexed
# addressing for each variation.
#
# FIGURE 16 - INDEXED ADDRESSING POSTBYTE REGISTER BIT ASSIGNMENTS
#
# ------------------------------------------------------------
# |    Post-Byte Register Bit     |         Indexed          |
# ---------------------------------        Addressing        |
# | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |           Mode           |
# ------------------------------------------------------------
# | 0 | R | R | d | d | d | d | d |  EA = ,R + 5 Bit Offset  |
# ------------------------------------------------------------
# | 1 | R | R | 0 | 0 | 0 | 0 | 0 |           ,R+            |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 0 | 0 | 1 |           ,R++           |
# ------------------------------------------------------------
# | 1 | R | R | 0 | 0 | 0 | 1 | 0 |            ,-R           |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 0 | 1 | 1 |           ,--R           |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 0 | 0 |    EA = ,R +0 Offset     |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 0 | 1 |   EA = ,R + ACCB Offset  |
# ------------------------------------------------------------
# | 1 | R | R | i | 0 | 1 | 1 | 0 |   EA = ,R + ACCA Offset  |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 0 | 0 |   EA = ,R + 8 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 0 | 1 |  EA = ,R + 16 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 0 | 1 | 1 |    EA = ,R + D Offset    |
# ------------------------------------------------------------
# | 1 | x | x | i | 1 | 1 | 0 | 0 |  EA = ,PC + 9 Bit Offset |
# ------------------------------------------------------------
# | 1 | x | x | i | 1 | 1 | 0 | 1 | EA = ,PC + 16 Bit Offset |
# ------------------------------------------------------------
# | 1 | R | R | i | 1 | 1 | 1 | 1 |      EA = [,Address]     |
# ------------------------------------------------------------
#     \______/\__/\_______________/
#        |     |          |
#        |     |      Addressing Mode Field
#        |     |
#        |  Indirect Field (Sign bit when b(7) = 0)
#        |
#     Register Field: RR
#
#     00 = X  01 = Y            x = Don't Care  d = Offset Bit
#     10 = U  11 = S            i = 0 Not Indirect
#                                   1 Indirect
#
# TABLE 2 - INDEXED ADDRESSING MODE
#
# ----------------------------------------------------------------------------------------------------------------
# |                            |                   |          Non Indirect        |          Indirect            |
# |            Type            |        Forms      ---------------------------------------------------------------
# |                            |                   | Assembler | Postbyte | + | + | Assembler | Postbyte | + | + |
# |                            |                   |    Form   |  OP Code | ~ | # |    Form   |  OP Code | ~ | # |
# ----------------------------------------------------------------------------------------------------------------
# | Constant Offset From R     | No Offset         |     ,R    | 1RR00100 | 0 | 0 |    [,R]   | 1RR10100 | 3 | 0 |
# | (2's Complement Offsets)   -----------------------------------------------------------------------------------
# |                            | 5 Bit Offset      |    n, R   | 0RRnnnnn | 1 | 0 |       defaults to 8-bit      |
# |                            -----------------------------------------------------------------------------------
# |                            | 8 Bit Offset      |    n, R   | 1RR01000 | 1 | 1 |   [n, R]  | 1RR11000 | 4 | 1 |
# |                            -----------------------------------------------------------------------------------
# |                            | 16 Bit Offset     |    n, R   | 1RR01001 | 4 | 2 |   [n, R]  | 1RR11001 | 7 | 2 |
# ----------------------------------------------------------------------------------------------------------------
# | Accumulator Offset From R  | A Register Offset |    A, R   | 1RR00110 | 1 | 0 |   [A, R]  | 1RR10110 | 4 | 0 |
# | (2's Complement Offsets)   -----------------------------------------------------------------------------------
# |                            | B Register Offset |    B, R   | 1RR00101 | 1 | 0 |   [B, R]  | 1RR10101 | 4 | 0 |
# |                            -----------------------------------------------------------------------------------
# |                            | D Register Offset |    D, R   | 1RR01011 | 4 | 0 |   [D, R]  | 1RR11011 | 7 | 0 |
# ----------------------------------------------------------------------------------------------------------------
# | Auto Increment/Decrement R | Increment By 1    |     ,R+   | 1RR00000 | 2 | 0 |         not allowed          |
# |                            -----------------------------------------------------------------------------------
# |                            | Increment By 2    |    ,R++   | 1RR00001 | 3 | 0 |   [,R++]  | 1RR10001 | 6 | 0 |
# |                            -----------------------------------------------------------------------------------
# |                            | Decrement By 1    |     ,-R   | 1RR00010 | 2 | 0 |         not allowed          |
# |                            -----------------------------------------------------------------------------------
# |                            | Decrement By 2    |    ,--R   | 1RR00011 | 3 | 0 |   [,--R]  | 1RR10011 | 6 | 0 |
# ----------------------------------------------------------------------------------------------------------------
# | Constant Offset From PC    | 8 Bit Offset      |   n, PCR  | 1xx01100 | 1 | 1 |  [n, PCR] | 1xx11100 | 4 | 1 |
# | (2's Complement Offsets)   -----------------------------------------------------------------------------------
# |                            | 16 Bit Offset     |   n, PCR  | 1xx01101 | 5 | 2 |  [n, PCR] | 1xx11101 | 8 | 2 |
# ----------------------------------------------------------------------------------------------------------------
# | Extended Indirect          | 16 Bit Address    |     -     |    --    | - | - |     [n]   | 10011111 | 5 | 2 |
# ----------------------------------------------------------------------------------------------------------------
#
# R = X, Y, U, or S    RR: 00 = X  01 = Y  10 = U  11 = S
#
# x = Don't Care       + ~ and + # indicate the number of additional cycles and bytes respectively for the
#                                  particular indexing variation.
#
# SEE INDEXED ADDRESSING section at beginning of file (taken from MC68B09E Catalog Entry)
func _retrieve_effective_address() -> int:
	var post := _read_and_advance_program_counter()
	var register := post & REGISTER_FIELD_MASK
	if not (post & 0x80):
		var offset := post & OFFSET_BITS_MASK
		if offset & 0x10: # negative
			offset |= -32
		cycle_counter += 1
		return _retrieve_register(register) + offset
	else:
		if not (post & INDIRECT_FIELD_MASK):
			match (post & ADDRESSING_MODE_MASK):
				AddressingMode.INCREMENT_BY_1:
					cycle_counter += 2
					return _increment_register(register, 1)

				AddressingMode.INCREMENT_BY_2:
					cycle_counter += 3
					return _increment_register(register, 2)

				AddressingMode.DECREMENT_BY_1:
					cycle_counter += 2
					return _decrement_register(register, 1)

				AddressingMode.DECREMENT_BY_2:
					cycle_counter += 3
					return _decrement_register(register, 2)

				AddressingMode.NO_OFFSET:
					return _retrieve_register(register)

				AddressingMode.B_REGISTER_OFFSET:
					var offset := _make_signed_8(accumulators.b)
					cycle_counter += 1
					return _retrieve_register(register) + offset

				AddressingMode.A_REGISTER_OFFSET:
					var offset := _make_signed_8(accumulators.a)
					cycle_counter += 1
					return _retrieve_register(register) + offset

				AddressingMode.EIGHT_BIT_OFFSET:
					var offset := _make_signed_8(_read_and_advance_program_counter())
					cycle_counter += 1
					return _retrieve_register(register) + offset

				AddressingMode.SIXTEEN_BIT_OFFSET:
					var offset := _make_signed_16(_read2_and_advance_program_counter())
					cycle_counter += 4
					return _retrieve_register(register) + offset

				AddressingMode.D_REGISTER_OFFSET:
					var offset := _make_signed_16(accumulators.d)
					cycle_counter += 4
					return _retrieve_register(register) + offset

				AddressingMode.CONSTANT_PC_8_BIT_OFFSET:
					var offset := _make_signed_8(_read_and_advance_program_counter())
					cycle_counter += 1
					return program_counter + offset

				AddressingMode.CONSTANT_PC_16_BIT_OFFSET:
					var offset := _make_signed_16(_read2_and_advance_program_counter())
					cycle_counter += 5
					return program_counter + offset

				_:
					pass
		else:
			# INDIRECT
			match (post & ADDRESSING_MODE_MASK):
				AddressingMode.INCREMENT_BY_2:
					cycle_counter += 6
					return _read2(_increment_register(register, 2))

				AddressingMode.DECREMENT_BY_2:
					cycle_counter += 6
					return _read2(_decrement_register(register, 2))

				AddressingMode.NO_OFFSET:
					cycle_counter += 3
					return _read2(_retrieve_register(register))

				AddressingMode.B_REGISTER_OFFSET:
					var offset := _make_signed_8(accumulators.b)
					cycle_counter += 4
					return _read2(_retrieve_register(register) + offset)

				AddressingMode.A_REGISTER_OFFSET:
					var offset := _make_signed_8(accumulators.b)
					cycle_counter += 4
					return _read2(_retrieve_register(register) + offset)

				AddressingMode.EIGHT_BIT_OFFSET:
					var offset := _make_signed_8(_read_and_advance_program_counter())
					cycle_counter += 4
					return _read2(_retrieve_register(register) + offset)

				AddressingMode.SIXTEEN_BIT_OFFSET:
					var offset := _make_signed_16(_read2_and_advance_program_counter())
					cycle_counter += 7
					return _read2(_retrieve_register(register) + offset)

				AddressingMode.D_REGISTER_OFFSET:
					var offset := _make_signed_16(accumulators.d)
					cycle_counter += 7
					return _read2(_retrieve_register(register) + offset)

				AddressingMode.CONSTANT_PC_8_BIT_OFFSET:
					var offset := _make_signed_8(_read_and_advance_program_counter())
					cycle_counter += 4
					return _read2(program_counter + offset)

				AddressingMode.CONSTANT_PC_16_BIT_OFFSET:
					var offset := _make_signed_16(_read2_and_advance_program_counter())
					cycle_counter += 8
					return _read2(program_counter + offset)

				AddressingMode.EXTENDED_INDIRECT:
					cycle_counter += 8
					return _read2(_read2_and_advance_program_counter())

				_:
					pass

	return 0


# Retrieve a register in accordance with the following table:
#
#    X??XXXXX
#     00 = X
#     01 = Y
#     10 = U
#     11 = S
func _retrieve_register(register_bits: int) -> int:
	match register_bits:
		RegisterField.X:
			return x_index_register

		RegisterField.Y:
			return y_index_register

		RegisterField.U:
			return user_stack_pointer

		RegisterField.S:
			return hardware_stack_pointer

		_:
			pass

	return 0


# Increment a register in accordance with the following table:
#
#    X??XXXXX
#     00 = X
#     01 = Y
#     10 = U
#     11 = S
func _increment_register(register_bits: int, amount: int) -> int:
	var ret: int

	match register_bits:
		RegisterField.X:
			ret = x_index_register
			x_index_register += amount

		RegisterField.Y:
			ret = y_index_register
			y_index_register += amount

		RegisterField.U:
			ret = user_stack_pointer
			user_stack_pointer += amount

		RegisterField.S:
			ret = hardware_stack_pointer
			hardware_stack_pointer += amount

	return ret


# Decrement a register in accordance with the following table:
#
#    X??XXXXX
#     00 = X
#     01 = Y
#     10 = U
#     11 = S
func _decrement_register(register_bits: int, amount: int) -> int:
	match register_bits:
		RegisterField.X:
			x_index_register -= amount
			return x_index_register

		RegisterField.Y:
			y_index_register -= amount
			return y_index_register

		RegisterField.U:
			user_stack_pointer -= amount
			return user_stack_pointer

		RegisterField.S:
			hardware_stack_pointer -= amount
			return hardware_stack_pointer

		_:
			pass

	return 0


# Godot specific function to turn a binary representation in a 64-bit integer into it's appropriate
# signed value (through sign-extension)
func _make_signed_8(byte: int) -> int:
	if byte & 0x80:
		return byte | -256

	return byte


# Godot specific function to turn a binary representation in a 64-bit integer into it's appropriate
# signed value (through sign-extension)
func _make_signed_16(word: int) -> int:
	if word & 0x8000:
		return word | -65536

	return word


func _on_ACVC_cpu_cycles_requested(num_of_cycles, acvc) -> void:
	acvc['drift'] = execute(num_of_cycles)


func _on_ACVC_horizontal_irq():
	trigger_irq()


func _on_ACVC_horizontal_firq():
	trigger_firq()
