## Memory Management Unit Emulator Component
##
## Emulates the memory address mapping performed by the MMU portion of the TCC1014 (VC2645QC: ACVC)
## "GIME" component. See page 15 of the TANDY Service Manual for the Color Computer 3 (26-3334)
class_name Mmu
extends Node

# From "Assembly Language Programming for the CoCo3" by Laurence A. Tepolt
#
# Chapter 3
#
# This chapter describes a new way of viewing memory and the much larger memory amount is accessed
# and used. Such concepts as virtual and physical memory and memory mapping and pages are
# described.
#
# NEW VIEW OF MEMORY
#
# Now that the amount of memory available in the CoCo 3 does not match the MPU addressing
# capability, there are two classifications of memory. In the original CoCo the two classifications
# were the same, but they are now disconnected from each other.
#
# Virtual/Physical Memory
#
#     Virtual memory is that memory which a program segment assumes to be available. This includes
# that in which reside the program segment instructions and its local data area. The virtual memory
# extent is limited by the MPU 16-bit address to 0-64K. The virtual memory may be RAM, ROM, or some
# of both.
#
#     Physical memory is the total amount of usable memory in the computer. Not all of it may be in
# use at the same time, but it is available. Physical memory includes RAM and ROM. The reduced
# size, complexity, and cost of memory have resulted in the construction of computers with far more
# physical memory than the MPU addressing extent can cover. A CoCo 3 with 128K of RAM also has an
# internal 32K of ROM; this provides a 160K of physical memory. A 512K CoCo 3 has 544K of physical
# memory.
#
# Memory Pages
#
#     The memory extent, either virtual or physical, is no longer considered as a seamless
# continuum but rather as segmented into pages. A memory page is an 8K block (where each block is a
# continuous range of addresses) of memory that starts on an 8K boundary. For example, addresses
# 0-1FFF and A000-BFFF each constitute a valid memory page. Also, each page is identified by its
# page number.
#
#     PAGE #    0   1   2   3   4   5   6   7
#             |---|---|---|---|---|---|---|---|
#  ADDRESS 0000   | 4000  | 8000  | C000  |   FFF
#                 |       |       |       |
#               2000    6000    A000    E000
#
# Fig. 3-1. Virtual Memory Pagination
#
#     The virtual memory extent is divided into eight 8K pages as shown in Fig. 3-1. They are
# numbered 0-7. The page number that any particular address occupies is determined by the three
# MSBs of that address. For example, DC23 is in page six as shown below.
#
# DC23   = 1101 1100 0010 0011
#          ---
#           |
# Page # =  6
#
#     The 512K physical memory extent is divided into sixty-four 8K pages as shown in Fig. 3-2. The
# pages are numbered 0-3F. The page number of any particular address is determined by the six MSBs
# of that physical address. In the CoCo 3, physical memory is considered to start at the 512K
# address point and extend downward toward zero. Therefore, in a 128K system, the physical memory
# extent proceeds from the 512K point down to 384K. Thus, the physical memory pages available in a
# 128K computer are 30-3F.
#
#          |--------------------------------------------------512K---------------------------------------------------|
#          |                                                                                                         |
#          |                         |--------------------------------------128K-------------------------------------|
#          |                         |                                                                               |
# Page #     0   1   2       2E   2F   30   31   32   33   34   35   36   37   38   39   3A   3B   3C   3D   3E   3F
#          |---|---|---| ~ |----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
# Address  0                       60000                                                                           7FFFF
#
# Fig. 3-2. Physical Memory Pagination
#
# MANAGING MEMORY
#
#     Memory management is a new program responsibility; controlling the virtual and physical
# memory pages. Its purpose is to associate the required virtual memory pages with the appropriate
# physical memory pages. It is done by a program segment (the memory manager) that controls the
# memory management unit.
#
# RAM Memory Mapping
#
#     Memory mapping is the process of associating virtual memory pages with physical pages. That
# is, each virtual page is assigned, or pointed, to a particular physical page. It is in physical
# memory that programs and data are stored. The virtual memory pages are like windows which allow
# viewing or accessing items in physical memory. In a technical sense, the virtual address extent
# is said ot be mapped onto the physical address extent. A mapping example of a 128K computer is
# shown in Fig. 3-3. The memory mapping for a particular program may be static or changed as the
# program proceeds.
#
# Page #                                 0   1       2   3   4   5                6   7 
# Virtual Extent                  0000 |---|---|   |---|---|---|---|            |---|---| FFFF
#                                      |   |   |   |   |   |   |   |            |   |    \
#                                       \ /    /   |   |   |   |   |             \    \    \
#                                       /    / \   |   |   |   \    \              \    \    \
#                                     /    /\    \ |   |   |\    \    \              \    \    \
#                                   /    /    \    \   |   |  \    \    \              \    \    \
#                                   |    |    |    |   |   |    \    \    \              \    \    \
# Page #               30   31   32 | 33 | 34 | 35 | 36| 37| 38 | 39 | 3A | 3B   3C   3D | 3E | 3F |
# Physical Extent    |----|----|----|----|----|----|---|---|----|----|----|----|----|----|----|----|
#                  60000                                                                           7FFFF
#
# Fig. 3-3. Memory Mapping
#
# Memory Management Unit
#
#     The memory management unit (MMU) is a programmable hardware device that assigns virtual pages
# to physical pages. Up to eight virtual pages (a 64K extent) may be assigned to a maximum of eight
# physical pages (a 64K extent) at any one time.
#
#     The MMU is composed of two sets of eight page address registers (PARs) each and its control
# logic. Each PAR is six bits (5-0) long. Each of the eight PARs (numbered 0-7) of either set
# always corresponds with the eight virtual pages (0-7). The two sets of PARs, the executive set
# and the task set, and their dedicated addresses are shown in Table 3-1. A virtual page is mapped
# to a physical page by writing the physical page number into the dedicated address of that virtual
# page's corresponding PAR. For example, virtual page 5 is mapped to physical page 2C by storing
# 2C in FFAD (using the task set).
#
# -------------------------------------------
# |   Executive Set    |      Task Set      |
# -------------------------------------------
# | PAR # | Ded. Addr. | PAR # | Ded. Addr. |
# -------------------------------------------
# |   0   |    FFA0    |   0   |    FFA8    |
# |   1   |    FFA1    |   1   |    FFA9    |
# |   2   |    FFA2    |   2   |    FFAA    |
# |   3   |    FFA3    |   3   |    FFAB    |
# |   4   |    FFA4    |   4   |    FFAC    |
# |   5   |    FFA5    |   5   |    FFAD    |
# |   6   |    FFA6    |   6   |    FFAE    |
# |   7   |    FFA7    |   7   |    FFAF    |
# -------------------------------------------
#
# Table 3-1. PAR Sets
#
#     The MMU converts a virtual address to a physical address by generating a 19-bit address from
# the 16-bit virtual address and the content of a PAR. The three MSBs of the virtual address select
# one of the eight PARs whose content forms the six MSBs of the physical address. The lower
# thirteen bits of the physical address are the same as those of the virtual address. Fig. 3-4
# shows an MMU block diagram and the conversion process.
#
#              ----------------------------------------------
#              |                                            |
#              |                                       MMU  |
#              |                    -----------             |     1  -------
#              |  -------------     |        1|----------------------| Y18
#              |  |          0|-    |         |             |     0  |
#              |  | 1 of 8   1|-    |        0|----------------------|
# ------  1    |  |          2|-    |         |             |     1  |
#  A15 |----------| decoder  3|-    |        1|----------------------|
#      |  0    |  |          4|-    |  PAR    |             |     1  |
#      |----------|          5|-----|   5    1|----------------------|
#      |  1    |  |          6|-    |         |             |     0  |
#      |----------|          7|-    |        0|----------------------|
#      |       |  -------------     |         |             |     0  |
#      |       |                    |        0|----------------------|
#      |  X    |                    -----------             |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#  MPU |-------------------------------------------------------------| RAM
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#      |-------------------------------------------------------------|
#      |  X    |                                            |     X  |
#   A0 |-------------------------------------------------------------| Y0
# ------       |                                            |        -----
#              ----------------------------------------------
#
# Fig. 3-4. MMU Operation
#
#     MMU operation is controlled by two bits in the ACVC control registers. Bit 0 of FF91 selects
# either the executive (bit clear) or task (bit set) set of PARs for use in accessing physical RAM.
# Normally a large program or a system of programs has a controller segment which calls the other
# program segments as required. The CoCo 3 is designed for the controller segment to always be
# mapped by the executive PAR set. The controller, before it is to call another program segment,
# will map that segment with the task PAR set. Then it will switch to the task PAR set and call the
# segment. This arrangement also calls for a small part of the task virtual memory extent to always
# map part (the interface) of the controller. It is through the interface that MPU control is
# either passed to the called segment or returned to the controller. Typically the kernel of an
# operating system is the controller just described. The application or task programs (utilities
# and user programs) are the called segments that run under the task PAR set.
#
#     Bit 6 of FF90 enables (bit set) or disables (bit clear) the operation of the MMU. When
# enabled, the MMU operates as already described. When disabled, the MMU always sets the expanded
# address bits Y18-Y16. This causes the 64K virtual extent to always be mapped onto the uppermost
# 64K of physical memory.
#
#     The exception to the previously described MMU operation is when the virtual address is in the
# range FF00-FFFF. These (the dedicated addresses) are not expanded and sent to RAM but are always
# routed to their appropriate device and/or control register. Therefore, there are 8K minus 256 RAM
# addresses in virtual page 7.
#
#     The 128K CoCo 3 has a physical memory addressing idiosyncracy. The content of physical memory
# is present in all the groups of physical pages. it is present in its normal physical page group
# of 30-3F, and the other page groups of 00-0F, 10-1F, and 20-2F. This is so because the two MSBs
# of the expanded address (Y18 and Y17) are not used.
#
# ROM Memory Mapping
#
#     Physical memory may be selected as all RAM or part RAM and ROM. The all-RAM mode is selected
# by setting the SAM TY bit. It is set by writing anything into dedicated address FFDF.
#
#     The ROM/RAM mode is selected by clearing the SAM TY bit. IT is cleared by writing anything
# into dedicated address FFDE. In the ROM/RAM mode the physical memory of pages 3C-3F are not RAM
# but ROM. The specific ROM assigned to these pages is controlled by bits 0 and 1 of dedicated
# address FF90. The three possible ROM configurations are shown in Fig. 3-5.
#
# Physical Page #        3C       3D         3E             3F           Bit 1    Bit 0
#                  --------------------------------------------------
#                  | Ext BASIC | BASIC |         Cart. ROM          |      0        x
#                  --------------------------------------------------
#                  | Ext BASIC | BASIC | Reset Init | Sup Ext BASIC |      1        0
#                  --------------------------------------------------
#                  |                 Cartridge ROM                  |      1        1
#                  --------------------------------------------------
#
# Fig. 3-5. Physical ROM Configurations


# From page 15 of the TANDY Service Manual for the Color Computer 3 (26-3334)
#
# Memory Management Unit (MMU)
#
# XFFA0 - XFFAF, 6 bits (Write only)
#
# The 8-bit CPU in the Color Computer 3 can directly address only 64K bytes of memory with its 16
# address lines (A0 - A15). The memory management unit (MMU) extends the address lines to 19 (A0 -
# A18). This allows the computer to address up to 512K bytes of memory ($00000 - $7FFFF).
#
# The MMU consists of a multiplexer and a 16 x 6-bit of RAM array. Each of the 6-bit elements in
# this RAM array is an MMU task register, and the task registers are used by the computer to
# determine the proper 8K segment of memory to address. These registers are divided into 2 sets, 8
# registers per set. The TR bit of FF91 (task register select bit) determines which set is
# selected.
#
# The relationship between the data in the task register and the generated address is as follows:
#
# ------------------------------------------------
# | Bit           |  D5   D4   D3   D2   D1   D0 |
# ------------------------------------------------
# | Corresponding |                              |
# |    memory     | A18  A17  A16  A15  A14  A13 |
# |   address     |                              |
# ------------------------------------------------
#
#   D0-D5
# (CPU DATA) ----------------------------
#                                       |   ---------------
#                     ---------------   |   |     RAM     |
# A13 -- A15          | Multiplexer |   |   |             |
#            -------->|             |   |-->|D in         |
#   TR BIT            |             |       |       D out |----- A13 -- A18
#                     |             |------>|RA0-         |      (Extended Address)
#                     |             |       | RA3   __    |
#  A0 -- A3  -------->|             |       |       WE    |
#                     |             |       ---------------
#                     ---------------               o
#                            o                      |
#            SELECT          |          |\          |
#            ---------------------------| >o---------
#                                       |/
#
# When the CPU needs to access memory outside the standard I/O and control range (XFF00 - XFFFF),
# CPU address lines A13 - A15 and the TR bit determine the address of the task register which the
# MMU will access while SELECT is low. When the CPU writes data to the MMU, A0 - A3 determine the
# address of the task register to be written to when SELECT goes high.
#
# The data from the MMU is then used as the upper 6 address lines (A13 - A18) for memory access,
# according to the following:
#
# --------------------------------------------------------------
# |  TR | A15 A14 A13 | (Address range) | MMU location address |
# --------------------------------------------------------------
# |  0  |  0   0   0  |  X0000 - X1FFF  |         FFA0         |
# |  0  |  0   0   1  |  X2000 - X3FFF  |         FFA1         |
# |  0  |  0   1   0  |  X4000 - X5FFF  |         FFA2         |
# |  0  |  0   1   1  |  X6000 - X7FFF  |         FFA3         |
# |  0  |  1   0   0  |  X8000 - X9FFF  |         FFA4         |
# |  0  |  1   0   1  |  XA000 - XBFFF  |         FFA5         |
# |  0  |  1   1   0  |  XC000 - XDFFF  |         FFA6         |
# |  0  |  1   1   1  |  XE000 - XFFFF  |         FFA7         |
# --------------------------------------------------------------
# |  1  |  0   0   0  |  X0000 - X1FFF  |         FFA8         |
# |  1  |  0   0   1  |  X2000 - X3FFF  |         FFA9         |
# |  1  |  0   1   0  |  X4000 - X5FFF  |         FFAA         |
# |  1  |  0   1   1  |  X6000 - X7FFF  |         FFAB         |
# |  1  |  1   0   0  |  X8000 - X9FFF  |         FFAC         |
# |  1  |  1   0   1  |  XA000 - XBFFF  |         FFAD         |
# |  1  |  1   1   0  |  XC000 - XDFFF  |         FFAE         |
# |  1  |  1   1   1  |  XE000 - XFFFF  |         FFAF         |
# --------------------------------------------------------------
#
# It is important to note that, in order for the MMU to function, the COCO bit of FF90 must be
# cleared, and the M/P bit of FF90 must be set. Prior to doing this, the desired addressing
# information for each segment must be loaded into the designated set of task registers. For
# example, if a standard 64K map is desired in the top of 512K RAM, with the TR bit set to 0, the
# the following values should be pre-loaded into the MMUL
#
# ----------------------------------------------------------
# | MMU Location |            |            |               |
# |   address    | Data (Hex) | Data (Bin) | Address range |
# ----------------------------------------------------------
# |     FFA0     |     38     |   111000   | 70000 - 71FFF |
# ----------------------------------------------------------
# |     FFA1     |     39     |   111001   | 72000 - 73FFF |
# ----------------------------------------------------------
# |     FFA2     |     3A     |   111010   | 74000 - 75FFF |
# ----------------------------------------------------------
# |     FFA3     |     3B     |   111011   | 76000 - 77FFF |
# ----------------------------------------------------------
# |     FFA4     |     3C     |   111100   | 78000 - 79FFF |
# ----------------------------------------------------------
# |     FFA5     |     3D     |   111101   | 7A000 - 7BFFF |
# ----------------------------------------------------------
# |     FFA6     |     3E     |   111110   | 7C000 - 7DFFF |
# ----------------------------------------------------------
# |     FFA7     |     3F     |   111111   | 7E000 - 7FFFF |
# ----------------------------------------------------------
#
# NOTE: Data loaded can be selected freely within the range of $00 - $3F.

class PageAddressRegisterSet:
	extends Reference

	var par: Array = [0, 0, 0, 0, 0, 0, 0, 0]

	func set_par(index: int, value: int) -> void:
		par[index] = value & 0x3F

	func get_address(address: int) -> int:
		var index := (address & 0xE0) >> 5
		return (par[index] << 13) & (address & 0x1F)

var executive_set: PageAddressRegisterSet = PageAddressRegisterSet.new()
var task_set: PageAddressRegisterSet = PageAddressRegisterSet.new()
