## Peripheral Interface Adapter (PIA) Emulator Component
##
##
class_name Mc6821
extends Node

# From page 8 of the TANDY Service Manual for the Color Computer 3 (26-3334)
#
# 1.3 Memory MAp
#
# Figure 1-2 shows the breakdown of the large blocks of memory in the Color Computer 3.
#
# The rest of the section itemizes the following registers:
#
# * I/O Control Register
# * Chip Control Register
# * 68B09E Vector Register
#
# ...
#
# 1.4 I/O Control Registers
#
# ---------------------------
# | FF00 - FF03 | PIA | IC5 |
# ---------------------------
#
# FF00:
#        BIT 0 = KEYBOARD ROW 1 and right joystick switch 1
#        BIT 1 = KEYBOARD ROW 2 and left joystick switch 1
#        BIT 2 = KEYBOARD ROW 3 and right joystick switch 2
#        BIT 3 = KEYBOARD ROW 4 and left joystick switch 2
#        BIT 4 = KEYBOARD ROW 5
#        BIT 5 = KEYBOARD ROW 6
#        BIT 6 = KEYBOARD ROW 7
#        BIT 7 = JOYSTICK COMPARISON INPUT
#
# FF01:
#        BIT 0   Control of HSYNC (63.5µs)  / 0 = IRQ* to CPU Disabled
#                Interrupt                  \ 1 = IRQ* to CPU Enabled
#
#        BIT 1   Control of Interrupt       / 0 = Flag set on falling edge of HS
#                Polarity                   \ 1 = Flag set on the rising edge of HS
#
#        BIT 2 = Normally 1:  0 = Changes FF00 to the Data Direction Register
#        BIT 3 = SEL 1:  LSB of the two analog MUX select lines
#        BIT 4 = 1 Always
#        BIT 5 = 1 Always
#        BIT 6 = Not used
#        BIT 7 = Horizontal sync interrupt flag
#
# FF02:
#        BIT 0 = KEYBOARD COLUMN 1
#        BIT 1 = KEYBOARD COLUMN 2
#        BIT 2 = KEYBOARD COLUMN 3
#        BIT 3 = KEYBOARD COLUMN 4
#        BIT 4 = KEYBOARD COLUMN 5
#        BIT 5 = KEYBOARD COLUMN 6
#        BIT 6 = KEYBOARD COLUMN 7 / RAM SIZE OUTPUT
#        BIT 7 = KEYBOARD OCLUMN 8
#
# FF03:
#        BIT 0   Control of VSYNC (16.667ms)  / 0 = IRQ* to CPU Disabled
#                Interrupt                    \ 1 = IRQ* to CPU Enabled
#
#        BIT 1   Control of Interrupt         / 0 = sets flag on falling edge FS
#                Polarity                     \ 1 = sets flag on rising edge FS
#
#        BIT 2 = NORMALLY 1:  0 = Changes FF02 to the Data Direction Register
#        BIT 3 = SEL 2:  MSB of the two analog MUX select lines
#        BIT 4 = 1 Always
#        BIT 5 = 1 Always
#        BIT 6 = Not used
#        BIT 7 = Field sync interrupt flag
#
# ---------------------------
# | FF20 - FF23 | PIA | IC4 |
# ---------------------------
#
# FF20:
#        BIT 0 = CASSETTE DATA INPUT
#        BIT 1 = RS-232C DATA OUTPUT
#        BIT 2 = 6 BIT D/A LSB
#        BIT 3 = 6 BIT D/A
#        BIT 4 = 6 BIT D/A
#        BIT 5 = 6 BIT D/A
#        BIT 6 = 6 BIT D/A
#        BIT 7 = 6 BIT D/A MSB
#
# FF21:
#        BIT 0   Control of the CD  / 0 = FIRQ* to CPU Disabled
#                (RS-232C status)   \ 1 = FIRQ* to CPU Enabled
#                Interrupt
#
#        BIT 1   Control of Interrupt  / 0 = sets flag on falling edge CD
#                Polarity              \ 1 = sets flag on rising edge CD
#
#        BIT 2 = Normally 1:  0 = Changes FF20 to the Data Direction Register
#        BIT 3 = Cassette Motor Control:  0 = OFF  1 = ON
#        BIT 4 = 1 Always
#        BIT 5 = 1 Always
#        BIT 6 = Not Used
#        BIT 7 = CD Interrupt Flag
#
# FF22:
#        BIT 0 = RS-232C DATA INPUT
#        BIT 1 = SINGLE BIT SOUND OUTPUT
#        BIT 2 = RAM SIZE INPUT
#        BIT 3 = RGB Monitor Sensing INPUT    CSS
#        BIT 4 = VDG CONTROL OUTPUT           GMO & UPPER/LOWER CASE*
#        BIT 5 = VDG CONTROL OUTPUT           GM1 & INVERT
#        BIT 6 = VDG CONTROL OUTPUT           GM2
#        BIT 7 = VDG CONTROL OUTPUT           A*/G
#
# FF23:
#        BIT 0   Control of the Cartridge  / 0 = FIRQ* to CPU Disabled
#                Interrupt                 \ 1 = FIRQ* to CPU Enabled
#
#        BIT 1   Control of Interrupt      / 0 = sets flag on falling edge CART*
#                Polarity                  \ 1 = sets flag on rising edge CART*
#
#        BIT 2 = Normally 1:  0 = Changes FF22 to the Data Direction Register
#        BIT 3 = Sound Enable
#        BIT 4 = 1 Always
#        BIT 5 = 1 Always
#        BIT 6 = Not used
#        BIT 7 = Cartridge Interrupt Flag
#
# FF40 - FFBF: Not used
#
# NOTE: FF22, FF23 are duplicated in TCC1014 (VC2645QC), and V.D.G. Control Bit (Bit 3 through Bit
#       7) affects this IC (TCC1014) only.

