## The TCC1014 (VC2645QC: ACVC) "GIME" Emulator Component
##
## Emulates the ACVC
class_name Tcc1014
extends TextureRect

# From page 8 of the TANDY Service Manual for the Color Computer 3 (26-3334)
#
# 1.3 Memory Map
#
# Figure 1-2 shows the breakdown of the large blocks of memory in the Color Computer 3.
#
# The rest of the section itemizes the following registers:
#
# * I/O Control Register
# * Chip Control Register
# * 68B09E Vector Register
#
# ----------
# ... In the CoCo 3, physical memory is considered to start at the 512K address point and extend
# downward toward zero. ...
#
# ... The exception ... is when the virtual address is in the range FF00-FFFF. These (the dedicated
# addresses) are not expanded and sent to RAM but are always routed to their appropriate device
# and/or control register. ...
# |
# |
# ---From "Assembly Language Programming for the CoCo3" by Laurence A. Tepolt
#
# $7FFFF ----------------------------
#            |                      | 68B09E VECTOR
#            |                      | CONTROL
#            |                      | REGISTER, I/O
# $7FF00 ----------------------------
#            |                      |
#            | SUPER EXTENDED BASIC |
#            |                      |
# $7E000 ----------------------------
#            |                      |
#            | CARTRIDGE ROM        |
#            |                      |
# $7C000 ----------------------------
#            |                      |
#            | COLOR BASIC          |
#            |                      |
# $7A000 ----------------------------
#            |                      |
#            | EXTEND COLOR BASIC   |
#            |                      |
# $78000 ----------------------------
#            |                      |
#            |                      |
#            |                      |
# $70600 ----------------------------
#            | STANDARD TEXT SCREEN |
# $70400 ----------------------------
#            |                      |
# $70000 ----------------------------
#            |                      |
#            |                      |
#            |                      |
# $6E000 ----------------------------
#            |                      |
#            | HIGH RESOLUTION      |
#            | TEXT SCREEN          |
#            |                      |
# $6C000 ----------------------------
#            |                      |
#            |                      |
#            |                      |
# $68000 ----------------------------
#            |                      |
#            | HIGH RESOLUTION      |
#            | GRAPHIC SCREEN       |
#            |                      |
# $60000 ----------------------------
#            |                      |
#            |                      |
#            |                      |
#
#            ~~~~~~~~~~~~~~~~~~~~~~~~
#
#            |                      |
#            |                      |
#            |                      |
# $00000 ----------------------------
#
# Figure 1-2. Color Computer 3 Memory Map
#
# ... [See mc6821.gd for this material]
#
# 1.5 Chip Control Registers
#
# ----------------------------
# | FF90 - FFDF | ACVC | IC6 |
# ----------------------------
#
# FF90:       Initialization Register 0 (INIT0)
#
#        BIT 7 = COCO        1 = Color Computer 1 and 2 Compatible
#        BIT 6 = M/P         1 = MMU enabled
#        BIT 5 = IEN         1 = Chip IRQ output enabled
#        BIT 4 = FEN         1 = Chip FIRQ output enabled
#        BIT 3 = MC3         1 = DRAM at XFEXX is constant
#        BIT 2 = MC2         1 = Standard SCS
#        BIT 1 = MC1         ROM map control (See table below)
#        BIT 0 = MC0         ROM map control (See table below)
#
# -------------------------------------------------
# | MC1 | MC0 | ROM mapping                       |
# |  0  |  x  | 16K Internal, 16K External        |
# |  1  |  0  | 32K Internal                      |
# |  1  |  1  | 32K External (except for vectors) |
# -------------------------------------------------
#
# -----------
# | ROM Memory Mapping
# |
# |     Physical memory may be selected as all RAM or part RAM and ROM. The all-RAM mode is selected
# | by setting the SAM TY bit. It is set by writing anything into dedicated address FFDF.
# |
# |     The ROM/RAM mode is selected by clearing the SAM TY bit. IT is cleared by writing anything
# | into dedicated address FFDE. In the ROM/RAM mode the physical memory of pages 3C-3F are not RAM
# | but ROM. The specific ROM assigned to these pages is controlled by bits 0 and 1 of dedicated
# | address FF90. The three possible ROM configurations are shown in Fig. 3-5.
# |
# | Physical Page #        3C       3D         3E             3F           Bit 1    Bit 0
# |                  --------------------------------------------------
# |                  | Ext BASIC | BASIC |         Cart. ROM          |      0        x
# |                  --------------------------------------------------
# |                  | Ext BASIC | BASIC | Reset Init | Sup Ext BASIC |      1        0
# |                  --------------------------------------------------
# |                  |                 Cartridge ROM                  |      1        1
# |                  --------------------------------------------------
# |
# | Fig. 3-5. Physical ROM Configurations
# |
# |
# ---From "Assembly Language Programming for the CoCo3" by Laurence A. Tepolt
#
# FF91:       Initialization Register 1 (INIT1)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = TINS        Timer Input Select: 1 = 70 nsec / 0 = 63 µsec
#        BIT 4   -
#        BIT 3   -
#        BIT 2   -
#        BIT 1   -
#        BIT 0 = TR          MMU Task Register Select
#
# FF92:       Interrupt Request Enable Register (IRQENR)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = TMR         Interrupt from Timer enabled
#        BIT 4 = HBORD       Horizontal Border IRQ enabled
#        BIT 3 = VBORD       Vertical Border IRQ enabled
#        BIT 2 = EI2         Serial Data IRQ enabled
#        BIT 1 = EI1         Keyboard IRQ enabled
#        BIT 0 = EI0         Cartridge IRQ enabled
#
# FF93:       Fast Interrupt Request Enable Register (FIRQENR)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = TMR         Interrupt from Timer enabled
#        BIT 4 = HBORD       Horizontal Border IRQ enabled
#        BIT 3 = VBORD       Vertical Border IRQ enabled
#        BIT 2 = EI2         Serial Data IRQ enabled
#        BIT 1 = EI1         Keyboard IRQ enabled
#        BIT 0 = EI0         Cartridge IRQ enabled
#
# FF94:       Timer Most Significant Nibble
# FF95:       Timer Least Significant Byte
#
#        TIMER: This is a 12-bit interval timer. When a value is loaded into the MSB, the count is
#               begun. The input clock is either 14 MHz or horizontal sync, as selected by TINS
#               (bit 5 of FF91). As the count falls through zero, an interrupt is generated (if
#               enabled), and the count is automatically reloaded.
#
# FF96:       Reserved
# FF97:       Reserved
# FF98:       Video Mode Register
#
#        BIT 7 = BP          0 = alphanumeric, 1 = bit plane
#        BIT 6   -
#        BIT 5 = BPI         1 = Burst phase inverted
#        BIT 4 = MOCH        1 = monochrome (on composite)
#        BIT 3 = H50         1 = 50 Hz vertical sync
#        BIT 2 = LPR2        Lines per row (See table below)
#        BIT 1 = LPR1        Lines per row (See table below)
#        BIT 0 = LPR0        Lines per row (See table below)
#
# -------
# |
# | Alternate Color Set
# |
# |     Setting bit 5 of dedicated address FF98 invokes the alternate color set. In this set all
# | the same colors are available; they are just specified by a different color code. Enabling the
# | alternate color set has the effect of shifting all the colors, except gray, half way around the
# | hue wheel in Fig. 2-4. Thus the hue angle specifies a different color than with the normal
# | color set. The purpose of the alternate color set is to simulate the original artifact effect
# | on a TV. With the original CoCo, sometimes the artifact colors woul dbe of one set and other
# | times of another set.
# |
# - From Assembly Language Programming For The COCO 3 by Laurence A. Tepolt
#
# ------------------------------------------------------------
# | LPR2 | LPR1 | LPR0 | Lines per character row             |
# ------------------------------------------------------------
# |  0   |  0   |  0   | one        (Graphics modes)         |
# |  0   |  0   |  1   | two        (CoCo 1 and CoCo 2 only) |
# |  0   |  1   |  0   | three      (CoCo 1 and CoCo 2 only) |
# |  0   |  1   |  1   | eight                               |
# |  1   |  0   |  0   | nine                                |
# |  1   |  0   |  1   | (reserved)                          |
# |  1   |  1   |  0   | twelve     (CoCo 1 and CoCo 2 only) |
# |  1   |  1   |  1   | (reserved)                          |
# ------------------------------------------------------------
#
# FF99:       Video Resolution Register
#
#        BIT 7   -
#        BIT 6 = LPF1        Lines per field (See table below)    [VRES1]
#        BIT 5 = LPF0        Lines per field                      [VRES0]
#        BIT 4 = HRES2       Horizontal resolution (See Video resolution on page 17)
#        BIT 3 = HRES1       Horizontal resolution
#        BIT 2 = HRES0       Horizontal resolution
#        BIT 1 = CRES1       Color resolution (See Video resolution)
#        BIT 0 = CRES0       Color resolution
#
# ---------------------------------
# | LPF1 | LPF0 | Lines per field |
# ---------------------------------
# |  0   |  0   |       192       |
# |  0   |  1   |       200       |
# |  1   |  0   |     Reserved    |
# |  1   |  1   |       225       |
# ---------------------------------
#
# From page 18:
#
# VIDEO RESOLUTION
#
# The combination of HRES and CRES bits determine the resolution of the screen. The following
# resolutions are supported:
#
# Alphanumerics: BP = 0, CoCo = 0
#
# --------------------------------------------------------
# |              |       |       |       |       |       |
# | \    RES bit |       |       |       |       |       |
# |     \        | HRES2 | HRES1 | HRES0 | CRES1 | CRES0 |
# |         \    |       |       |       |       |       |
# |  MODE      \ |       |       |       |       |       |
# |              |       |       |       |       |       |
# --------------------------------------------------------
# |              |       |       |       |       |       |
# | 32 character |   0   |   -   |   0   |   -   |   1   |
# |              |       |       |       |       |       |
# | 40 character |   0   |   -   |   1   |   -   |   1   |
# |              |       |       |       |       |       |
# | 80 character |   1   |   -   |   1   |   -   |   1   |
# --------------------------------------------------------
#
# Graphics: BP = 1, CoCo = 0
#
# -----------------------------------------------------------
# | Pixels | Colors | HRES2 | HRES1 | HRES0 | CRES1 | CRES0 |
# -----------------------------------------------------------
# |  640   |   4    |   1   |   1   |   1   |   0   |   1   |
# |  640   |   2    |   1   |   0   |   1   |   0   |   0   |
# -----------------------------------------------------------
# |  512   |   4    |   1   |   1   |   0   |   0   |   1   |
# |  512   |   2    |   1   |   0   |   0   |   0   |   0   |
# -----------------------------------------------------------
# |  320   |   16   |   1   |   1   |   1   |   1   |   0   |
# |  320   |   4    |   1   |   0   |   1   |   0   |   1   |
# -----------------------------------------------------------
# |  256   |   16   |   1   |   1   |   0   |   1   |   0   |
# |  256   |   4    |   1   |   0   |   0   |   0   |   1   |
# |  256   |   2    |   0   |   1   |   0   |   0   |   0   |
# -----------------------------------------------------------
# |  160   |   16   |   1   |   0   |   1   |   1   |   0   |
# -----------------------------------------------------------
#
# In addition to the above modes, the previous CoCo modes are available.
#
# -------------------------------------------------------------
# |                          | MC6883 (SAM) |                 |
# |                          | DISPLAY MODE |                 |
# |                          |              | Reg. FF22       |
# |                          |   V2 V1 V0   | 7  6  5  4  3   |
# -------------------------------------------------------------
# | Alphanumerics            |   0  0  0    | 0  X  X  0  CSS |
# | Alphanumerics Inverted   |   0  0  0    | 0  X  X  0  CSS |
# -------------------------------------------------------------
# | Semigraphics - 4         |   0  0  0    | 0  X  X  0  X   |
# -------------------------------------------------------------
# | 64 x 64 Color Graphics   |   0  0  1    | 1  0  0  0  CSS |
# -------------------------------------------------------------
# | 128 x 64 Graphics        |   0  0  1    | 1  0  0  1  CSS |
# | 128 x 64 Color Graphics  |   0  1  0    | 1  0  1  0  CSS |
# -------------------------------------------------------------
# | 128 x 96 Graphics        |   0  1  1    | 1  0  1  1  CSS |
# | 128 x 96 Color Graphics  |   1  0  0    | 1  1  0  0  CSS |
# -------------------------------------------------------------
# | 128 x 192 Graphics       |   1  0  1    | 1  1  0  1  CSS |
# | 128 x 192 Color Graphics |   1  1  0    | 1  1  1  0  CSS |
# -------------------------------------------------------------
# | 256 x 192 Graphics       |   1  1  0    | 1  1  1  1  CSS |
# -------------------------------------------------------------
#
# FF9A:       Border Register (All bits are 0 for CoCo 1 and CoCo 2 compatibility)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = RED1        Most significant red bit
#        BIT 4 = GRN1        Most significant green bit
#        BIT 3 = BLU1        Most significant blue bit
#        BIT 2 = RED0        Least significant red bit
#        BIT 1 = GRN0        Least significant green bit
#        BIT 0 = BLU0        Least significant blue bit
#
# FF9B:       Reserved
#
# FF9C:       Vertical Scroll Register
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5   -
#        BIT 4   -
#        BIT 3 = VSC3        (Vert. Scroll)
#        BIT 2 = VSC2
#        BIT 1 = VSC1
#        BIT 0 = VSC0
#
#        NOTE: In the CoCo mode, the VSC's must be initialized to 0F hex.
#
# FF9D:       Vertical Offset 1 Register
#
#        BIT 7 = Y18         (Vert. Offset)
#        BIT 6 = Y17
#        BIT 5 = Y16
#        BIT 4 = Y15
#        BIT 3 = Y14
#        BIT 2 = Y13
#        BIT 1 = Y12
#        BIT 0 = Y11
#
# FF9E:       Vertical Offset 0 Register
#
#        BIT 7 = Y10         (Vert. Offset)
#        BIT 6 = Y9
#        BIT 5 = Y8
#        BIT 4 = Y7
#        BIT 3 = Y6
#        BIT 2 = Y5
#        BIT 1 = Y4
#        BIT 0 = Y3
#
#        NOTE: In CoCo mode, Y15 - Y9 are not effective, and are controlled by SAM bits F6 - F0.
#              Also in CoCo mode, Y18 - Y16 should be 1, all others 0.
#
# -------
# |
# | Vertical Offset Registers 0 & 1
# |
# |     The starting address of a buffer area is indicated to the ACVC via these registers. This is
# | done by writing the upper sixteen bits (Y18-Y3) of the starting physical address into these
# | registers. Y18-Y11 are written to vertical offset 1 and Y10-Y3 are written to vertical offset
# | 0. Thus, a buffer is limited to starting on an 8-bit boundary, or the starting address is
# | limited to the binary form: xxx xxxx xxxx xxxx x000
# |
# - From Assembly Language Programming For The COCO 3 by Laurence A. Tepolt
#
# FF9F:       Horizontal Offset 0 Register
#
#        BIT 7 = HVEN        Horizontal Virtual Enable
#        BIT 6 = X6          Horizontal Offset address
#        BIT 5 = X5          Horizontal Offset address
#        BIT 4 = X4          Horizontal Offset address
#        BIT 3 = X3          Horizontal Offset address
#        BIT 2 = X2          Horizontal Offset address
#        BIT 1 = X1          Horizontal Offset address
#        BIT 0 = X0          Horizontal Offset address
#
#        NOTE: HVEN enables a horizontal screen width of 128 bytes regardless of the HRES bits and
#              CRES bits selected. This will allow a "virtual" screen somewhat larger than the
#              displayed screen. The user can move the "window" (the displayed screen) by means of
#              the horizontal offset bits. In character mode, the screen width is 128 characters
#              regardless of attribute (or 64, if double-wide is selected).


# FF90:       Initialization Register 0 (INIT0)
#
#        BIT 7 = COCO        1 = Color Computer 1 and 2 Compatible
#        BIT 6 = M/P         1 = MMU enabled
#        BIT 5 = IEN         1 = Chip IRQ output enabled
#        BIT 4 = FEN         1 = Chip FIRQ output enabled
#        BIT 3 = MC3         1 = DRAM at XFEXX is constant
#        BIT 2 = MC2         1 = Standard SCS
#        BIT 1 = MC1         ROM map control (See table below)
#        BIT 0 = MC0         ROM map control (See table below)
#
# -------------------------------------------------
# | MC1 | MC0 | ROM mapping                       |
# |  0  |  x  | 16K Internal, 16K External        |
# |  1  |  0  | 32K Internal                      |
# |  1  |  1  | 32K External (except for vectors) |
# -------------------------------------------------

enum Init0 {
	MC0 = 0x01,
	MC1 = 0x02,
	MC2 = 0x04,
	MC3 = 0x08,
	FEN = 0x10,
	IEN = 0x20,
	M_P = 0x40,
	COCO = 0x80
}

class InitializationRegister0:

	signal coco_toggled(current)
	signal mmu_toggled(current)
	signal irq_enabled_toggled(current)
	signal firq_enabled_toggled(current)
	signal mc3_toggled(current)
	signal mc2_toggled(current)
	signal mc1_toggled(current)
	signal mc0_toggled(current)
	signal rom_map_set(current)

	var register: int setget set_register

	var coco: bool = false setget set_coco # 1 = Color Computer 1 and 2 Compatible
	var m_p: bool = false setget set_m_p   # 1 = MMU Enabled
	var ien: bool = false setget set_ien   # 1 = Chip IRQ output enabled
	var fen: bool = false setget set_fen   # 1 = Chip FIRQ output enabled
	var mc3: bool = false setget set_mc3   # 1 = DRAM at XFEXX is constant
	var mc2: bool = false setget set_mc2   # 1 = Standard SCS
	var mc1: bool = false setget set_mc1   # ROM map control (See table below)
	var mc0: bool = false setget set_mc0   # ROM map control (See table below)

	var coco_enabled: bool setget set_coco, get_coco
	var mmu_enabled: bool setget set_m_p, get_m_p
	var irq_output_enabled: bool setget set_ien, get_ien
	var firq_output_enabled: bool setget set_fen, get_fen
	var dram_at_xfexx_is_constant: bool setget set_mc3, get_mc3
	var standarc_scs: bool setget set_mc2, get_mc2
	var rom_map_control: int setget set_rom_map_control, get_rom_map_control

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		refresh_coco()
		refresh_m_p()
		refresh_ien()
		refresh_fen()
		refresh_mc3()
		refresh_mc2()
		self.rom_map_control = register

	func get_coco() -> bool:
		return coco

	func refresh_coco() -> void:
		self.coco = register & Init0.COCO

	func set_coco(new_coco: bool) -> void:
		var old_coco := coco
		coco = new_coco
		_set_register_bit(new_coco, Init0.COCO)
		if old_coco != new_coco:
			emit_signal('coco_toggled', new_coco)

	func get_m_p() -> bool:
		return m_p

	func refresh_m_p() -> void:
		self.m_p = register & Init0.M_P

	func set_m_p(new_m_p: bool) -> void:
		var old_m_p := m_p
		m_p = new_m_p
		_set_register_bit(new_m_p, Init0.M_P)
		if old_m_p != new_m_p:
			emit_signal('mmu_toggled', new_m_p)

	func set_mmu(new_mmu: bool) -> void:
		self.m_p = new_mmu

	func get_mmu() -> bool:
		return m_p

	func get_ien() -> bool:
		return ien

	func refresh_ien() -> void:
		self.ien = register & Init0.IEN

	func set_ien(new_ien: bool) -> void:
		var old_ien := ien
		ien = new_ien
		_set_register_bit(new_ien, Init0.IEN)
		if old_ien != new_ien:
			emit_signal('irq_enabled_toggled', new_ien)

	func set_irq(new_irq: bool) -> void:
		self.ien = new_irq

	func get_irq() -> bool:
		return ien

	func get_fen() -> bool:
		return fen

	func refresh_fen() -> void:
		self.fen = register & Init0.FEN

	func set_fen(new_fen: bool) -> void:
		var old_fen := fen
		fen = new_fen
		_set_register_bit(new_fen, Init0.FEN)
		if old_fen != new_fen:
			emit_signal('firq_enabled_toggled', new_fen)

	func get_firq() -> bool:
		return fen

	func set_firq(new_firq: bool) -> void:
		self.fen = new_firq

	func get_mc3() -> bool:
		return mc3

	func refresh_mc3() -> void:
		self.mc3 = register & Init0.MC3

	func set_mc3(new_mc3: bool) -> void:
		var old_mc3 := mc3
		mc3 = new_mc3
		_set_register_bit(new_mc3, Init0.MC3)
		if old_mc3 != new_mc3:
			emit_signal('mc3_toggled', new_mc3)

	func get_dram_constant() -> bool:
		return mc3

	func set_dram_constant(new_dram_constant: bool) -> void:
		self.mc3 = new_dram_constant

	func get_mc2() -> bool:
		return mc2

	func refresh_mc2() -> void:
		self.mc2 = register & Init0.MC2

	func set_mc2(new_mc2: bool) -> void:
		var old_mc2 := mc2
		mc2 = new_mc2
		_set_register_bit(new_mc2, Init0.MC2)
		if old_mc2 != new_mc2:
			emit_signal('mc2_toggled', new_mc2)

	func set_scs(new_scs: bool) -> void:
		self.mc2 = new_scs

	func get_scs() -> bool:
		return mc2

	func get_mc1() -> bool:
		return mc1

	func set_mc1(new_mc1: bool, delay_signals: bool = false) -> bool:
		var old_mc1 := mc1
		mc1 = new_mc1
		_set_register_bit(new_mc1, Init0.MC1)
		if old_mc1 != new_mc1:
			emit_signal('mc1_toggled', new_mc1)
			if not delay_signals:
				emit_signal('rom_map_set', self.rom_map_control)
			return true
		return false

	func get_mc0() -> bool:
		return mc0

	func set_mc0(new_mc0: bool, delay_signals: bool = false) -> bool:
		var old_mc0 := mc0
		mc0 = new_mc0
		_set_register_bit(new_mc0, Init0.MC0)
		if old_mc0 != new_mc0:
			emit_signal('mc0_toggled', new_mc0)
			if not delay_signals:
				emit_signal('rom_map_set', self.rom_map_control)
			return true
		return false

	func set_rom_map_control(new_rom_map_control: int) -> void:
		register = (register & (255 - (Init0.MC0 | Init0.MC1))) \
			| (new_rom_map_control & (Init0.MC0 | Init0.MC1))
		var _signal := set_mc0(new_rom_map_control & Init0.MC0, true)
		_signal = set_mc1(new_rom_map_control & Init0.MC1, true) or _signal
		if _signal:
			emit_signal('rom_map_set', self.rom_map_control)

	func get_rom_map_control() -> int:
		return register & (Init0.MC0 | Init0.MC1)

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var init0: InitializationRegister0 = InitializationRegister0.new()

# FF91:       Initialization Register 1 (INIT1)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = TINS        Timer Input Select: 1 = 70 nsec / 0 = 63 µsec
#        BIT 4   -
#        BIT 3   -
#        BIT 2   -
#        BIT 1   -
#        BIT 0 = TR          MMU Task Register Select

enum Init1 {
	TR = 0x00,
	TINS = 0x20
}

class InitializationRegister1:

	signal timer_input_toggled(current)
	signal mmu_task_register_toggled(current)

	var register: int setget set_register

	var tins: bool = false setget set_tins # Timer Input Select: 1 = 70 nsec / 0 = 63 μs
	var tr: bool = false setget set_tr     # MMU Task Register Select

	var timer_input_select: bool setget set_tins, get_tins
	var task_register_select: bool setget set_tr, get_tr

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		refresh_tins()
		refresh_tr()

	func get_tins() -> bool:
		return tins

	func refresh_tins() -> void:
		self.tins = register & Init1.TINS

	func set_tins(new_tins: bool) -> void:
		var old_tins := tins
		tins = new_tins
		_set_register_bit(new_tins, Init1.TINS)
		if old_tins != new_tins:
			emit_signal('timer_input_toggled', new_tins)

	func set_timer_input_select(new_timer_input_select: bool) -> void:
		self.tins = new_timer_input_select

	func get_timer_input_select() -> bool:
		return tins

	func get_tr() -> bool:
		return tr

	func refresh_tr() -> void:
		self.tr = register & Init1.TR

	func set_tr(new_tr: bool) -> void:
		var old_tr := tr
		tr = new_tr
		_set_register_bit(new_tr, Init1.TR)
		if old_tr != new_tr:
			emit_signal('mmu_task_register_toggled', new_tr)

	func set_mmu_task_register(new_mmu_task_register: bool) -> void:
		self.tr = new_mmu_task_register

	func get_mmu_task_register() -> bool:
		return tr

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var init1: InitializationRegister1 = InitializationRegister1.new()

# FF92:       Interrupt Request Enable Register (IRQENR)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = TMR         Interrupt from Timer enabled
#        BIT 4 = HBORD       Horizontal Border IRQ enabled
#        BIT 3 = VBORD       Vertical Border IRQ enabled
#        BIT 2 = EI2         Serial Data IRQ enabled
#        BIT 1 = EI1         Keyboard IRQ enabled
#        BIT 0 = EI0         Cartridge IRQ enabled

enum Irqenr {
	EI0 = 0x01,
	EI1 = 0x02,
	EI2 = 0x04,
	VBORD = 0x08,
	HBORD = 0x10,
	TMR = 0x20
}

class InterruptRequestEnableRegister:

	signal timer_toggled(current)
	signal horizontal_border_toggled(current)
	signal vertical_border_toggled(current)
	signal serial_data_toggled(current)
	signal keyboard_toggled(current)
	signal cartridge_toggled(current)

	var register: int setget set_register

	var tmr: bool = false setget set_tmr     # Interrupt from Timer enabled
	var hbord: bool = false setget set_hbord # Horizontal Border IRQ enabled
	var vbord: bool = false setget set_vbord # Vertical Border IRQ enabled
	var ei2: bool = false setget set_ei2     # Serial Data IRQ enabled
	var ei1: bool = false setget set_ei1     # Keyboard IRQ enabled
	var ei0: bool = false setget set_ei0     # Cartridge IRQ enabled

	var timer: bool setget set_tmr, get_tmr
	var horizontal_border: bool setget set_hbord, get_hbord
	var vertical_border: bool setget set_vbord, get_vbord
	var serial_data: bool setget set_ei2, get_ei2
	var keyboard: bool setget set_ei1, get_ei1
	var cartridge: bool setget set_ei0, get_ei0

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		refresh_tmr()
		refresh_hbord()
		refresh_vbord()
		refresh_ei2()
		refresh_ei1()
		refresh_ei0()

	func get_tmr() -> bool:
		return tmr

	func refresh_tmr() -> void:
		self.tmr = register & Irqenr.TMR

	func set_tmr(new_tmr: bool) -> void:
		var old_tmr := tmr
		tmr = new_tmr
		_set_register_bit(new_tmr, Irqenr.TMR)
		if old_tmr != new_tmr:
			emit_signal('timer_toggled', new_tmr)

	func set_timer(new_timer: bool) -> void:
		self.tmr = new_timer

	func get_timer() -> bool:
		return tmr

	func get_hbord() -> bool:
		return hbord

	func refresh_hbord() -> void:
		self.hbord = register & Irqenr.HBORD

	func set_hbord(new_hbord: bool) -> void:
		var old_hbord := hbord
		hbord = new_hbord
		_set_register_bit(new_hbord, Irqenr.HBORD)
		if old_hbord != new_hbord:
			emit_signal('horizontal_border_toggled', new_hbord)

	func set_horizontal_border(new_horizontal_border: bool) -> void:
		self.hbord = new_horizontal_border

	func get_horizontal_border() -> bool:
		return hbord

	func get_vbord() -> bool:
		return vbord

	func refresh_vbord() -> void:
		self.vbord = register & Irqenr.VBORD

	func set_vbord(new_vbord: bool) -> void:
		var old_vbord := vbord
		vbord = new_vbord
		_set_register_bit(new_vbord, Irqenr.VBORD)
		if old_vbord != new_vbord:
			emit_signal('vertical_border_toggled', new_vbord)

	func set_vertical_border(new_vertical_border: bool) -> void:
		self.vbord = new_vertical_border

	func get_vertical_border() -> bool:
		return vbord

	func get_ei2() -> bool:
		return ei2

	func refresh_ei2() -> void:
		self.ei2 = register & Irqenr.EI2

	func set_ei2(new_ei2: bool) -> void:
		var old_ei2 := ei2
		ei2 = new_ei2
		_set_register_bit(new_ei2, Irqenr.EI2)
		if old_ei2 != new_ei2:
			emit_signal('serial_data_toggled', new_ei2)

	func set_serial_data(new_serial_data: bool) -> void:
		self.ei2 = new_serial_data

	func get_serial_data() -> bool:
		return ei2

	func get_ei1() -> bool:
		return ei1

	func refresh_ei1() -> void:
		self.ei1 = register & Irqenr.EI1

	func set_ei1(new_ei1: bool) -> void:
		var old_ei1 := ei1
		ei1 = new_ei1
		_set_register_bit(new_ei1, Irqenr.EI1)
		if old_ei1 != new_ei1:
			emit_signal('keyboard_toggled', new_ei1)

	func set_keyboard(new_keyboard: bool) -> void:
		self.ei1 = new_keyboard

	func get_keyboard() -> bool:
		return ei1

	func get_ei0() -> bool:
		return ei0

	func refresh_ei0() -> void:
		self.ei0 = register & Irqenr.EI0

	func set_ei0(new_ei0: bool) -> void:
		var old_ei0 := ei0
		ei0 = new_ei0
		_set_register_bit(new_ei0, Irqenr.EI0)
		if old_ei0 != new_ei0:
			emit_signal('cartridge_toggled', new_ei0)

	func set_cartridge(new_cartridge: bool) -> void:
		self.ei0 = new_cartridge

	func get_cartridge() -> bool:
		return ei0

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var irqenr: InterruptRequestEnableRegister = InterruptRequestEnableRegister.new()

# FF93:       Fast Interrupt Request Enable Register (FIRQENR)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = TMR         Interrupt from Timer enabled
#        BIT 4 = HBORD       Horizontal Border IRQ enabled
#        BIT 3 = VBORD       Vertical Border IRQ enabled
#        BIT 2 = EI2         Serial Data IRQ enabled
#        BIT 1 = EI1         Keyboard IRQ enabled
#        BIT 0 = EI0         Cartridge IRQ enabled
var firqenr: InterruptRequestEnableRegister = InterruptRequestEnableRegister.new()

# FF94:       Timer Most Significant Nibble
# FF95:       Timer Least Significant Byte
#
#        TIMER: This is a 12-bit interval timer. When a value is loaded into the MSB, the count is
#               begun. The input clock is either 14 MHz or horizontal sync, as selected by TINS
#               (bit 5 of FF91). As the count falls through zero, an interrupt is generated (if
#               enabled), and the count is automatically reloaded.

class IntervalTimer:

	signal hit_zero

	var enabled: bool = false

	var interval: int = 0 setget set_interval
	var timer: int = 0

	var most_significant_nibble: int setget set_msn, get_msn
	var least_significant_byte: int setget set_lsb, get_lsb

	func set_msn(new_msn: int) -> void:
		interval = ((new_msn & 0xFF) << 8) | (interval & 0xFF)
		enabled = interval != 0
		timer = ((new_msn & 0xFF) << 8) | (timer & 0xFF)

	func get_msn() -> int:
		return (timer & 0xF00) >> 8

	func set_lsb(new_lsb: int) -> void:
		interval = (interval & 0xF00) | (new_lsb & 0xFF)
		enabled = interval != 0
		timer = (timer & 0xF00) | (new_lsb & 0xFF)

	func get_lsb() -> int:
		return timer & 0xFF

	func set_interval(value: int) -> void:
		interval = value
		timer = value

	func decrement_timer() -> void:
		if not enabled:
			return
		timer -= 1
		if timer == 0:
			emit_signal('hit_zero')
		timer = interval

	func decrease_timer(value: int) -> void:
		if not enabled:
			return
		timer -= value
		if timer <= 0:
			emit_signal('hit_zero')
		timer = interval - (timer if timer < 0 else 0)

var timer: IntervalTimer = IntervalTimer.new()

# FF98:       Video Mode Register
#
#        BIT 7 = BP          0 = alphanumeric, 1 = bit plane
#        BIT 6   -
#        BIT 5 = BPI         1 = Burst phase inverted
#        BIT 4 = MOCH        1 = monochrome (on composite)
#        BIT 3 = H50         1 = 50 Hz vertical sync
#        BIT 2 = LPR2        Lines per row (See table below)
#        BIT 1 = LPR1        Lines per row (See table below)
#        BIT 0 = LPR0        Lines per row (See table below)
#
# -------
# |
# | Alternate Color Set
# |
# |     Setting bit 5 of dedicated address FF98 invokes the alternate color set. In this set all
# | the same colors are available; they are just specified by a different color code. Enabling the
# | alternate color set has the effect of shifting all the colors, except gray, half way around the
# | hue wheel in Fig. 2-4. Thus the hue angle specifies a different color than with the normal
# | color set. The purpose of the alternate color set is to simulate the original artifact effect
# | on a TV. With the original CoCo, sometimes the artifact colors woul dbe of one set and other
# | times of another set.
# |
# - From Assembly Language Programming For The COCO 3 by Laurence A. Tepolt
#
# ------------------------------------------------------------
# | LPR2 | LPR1 | LPR0 | Lines per character row             |
# ------------------------------------------------------------
# |  0   |  0   |  0   | one        (Graphics modes)         |
# |  0   |  0   |  1   | two        (CoCo 1 and CoCo 2 only) |
# |  0   |  1   |  0   | three      (CoCo 1 and CoCo 2 only) |
# |  0   |  1   |  1   | eight                               |
# |  1   |  0   |  0   | nine                                |
# |  1   |  0   |  1   | (reserved)                          |
# |  1   |  1   |  0   | twelve     (CoCo 1 and CoCo 2 only) |
# |  1   |  1   |  1   | (reserved)                          |
# ------------------------------------------------------------

enum VideoMode {
	LPR0 = 0x01,
	LPR1 = 0x02,
	LPR2 = 0x04,
	H50 = 0x08,
	MOCH = 0x10,
	BPI = 0x20,
	BP = 0x80
}

enum LinesPerRow {
	ONE = 0,   # one (Graphics modes)
	TWO,       # two (CoCo 1 and CoCo 2 only)
	THREE,     # three (CoCo 1 and CoCo 2 only)
	EIGHT,     # eight
	NINE,      # nine
	TWELVE = 6 # twelve (CoCo 1 and CoCo 2 only)
}

class VideoModeRegister:

	signal plane_toggled(current)
	signal burst_phase_toggled(current)
	signal monochrome_toggled(current)
	signal vertical_sync_toggled(current)
	signal lines_per_row_2_toggled(current)
	signal lines_per_row_1_toggled(current)
	signal lines_per_row_0_toggled(current)
	signal lines_per_row_set(current)

	var register: int = 0 setget set_register

	var bp: bool = false setget set_bp     # 0 = alphanumeric, 1 = bit plane
	var bpi: bool = false setget set_bpi   # 1 = Burst phase inverted
	var moch: bool = false setget set_moch # 1 = monochrome (on composite)
	var h50: bool = false setget set_h50   # 1 = 50 Hz vertical sync
	var lpr2: bool = false setget set_lpr2 # Lines per row (See table)
	var lpr1: bool = false setget set_lpr1 # Lines per row (See table)
	var lpr0: bool = false setget set_lpr0 # Lines per row (See table)

	var graphics_plane: bool setget set_bp, get_bp
	var burst_phase: bool setget set_bpi, get_bpi
	var monochrome: bool setget set_moch, get_moch
	var vertical_sync: bool setget set_h50, get_h50
	var lines_per_row: int setget set_lines_per_row, get_lines_per_row

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		refresh_bp()
		refresh_bpi()
		refresh_moch()
		refresh_h50()
		self.lines_per_row = register

	func get_bp() -> bool:
		return bp

	func refresh_bp() -> void:
		self.bp = register & VideoMode.BP

	func set_bp(new_bp: bool) -> void:
		var old_bp := bp
		bp = new_bp
		_set_register_bit(new_bp, VideoMode.BP) 
		if old_bp != new_bp:
			emit_signal('plane_toggled', new_bp)

	func set_graphics_plane(new_plane: bool) -> void:
		self.bp = new_plane

	func get_graphics_plane() -> bool:
		return bp

	func get_bpi() -> bool:
		return bpi

	func refresh_bpi() -> void:
		self.bpi = register & VideoMode.BPI

	func set_bpi(new_bpi: bool) -> void:
		var old_bpi := bpi
		bpi = new_bpi
		_set_register_bit(new_bpi, VideoMode.BPI)
		if old_bpi != new_bpi:
			emit_signal('burst_phase_toggled', new_bpi)

	func set_burst_phase(new_burst_phase: bool) -> void:
		self.bpi = new_burst_phase

	func get_burst_phase() -> bool:
		return bpi

	func get_moch() -> bool:
		return moch

	func refresh_moch() -> void:
		self.moch = register & VideoMode.MOCH

	func set_moch(new_moch: bool) -> void:
		var old_moch := moch
		moch = new_moch
		_set_register_bit(new_moch, VideoMode.MOCH)
		if old_moch != new_moch:
			emit_signal('monochrome_toggled', new_moch)

	func set_monochrome(new_monochrome: bool) -> void:
		self.moch = new_monochrome

	func get_monochrome() -> bool:
		return moch

	func get_h50() -> bool:
		return h50

	func refresh_h50() -> void:
		self.h50 = register & VideoMode.H50

	func set_h50(new_h50: bool) -> void:
		var old_h50 := h50
		h50 = new_h50
		_set_register_bit(new_h50, VideoMode.H50)
		if old_h50 != new_h50:
			emit_signal('vertical_sync_toggled', new_h50)

	func set_vertical_sync(new_vertical_sync: bool) -> void:
		self.h50 = new_vertical_sync

	func get_vertical_sync() -> bool:
		return h50

	func get_lpr2() -> bool:
		return lpr2

	func set_lpr2(new_lpr2: bool, delay_signals: bool = false) -> bool:
		var old_lpr2 := lpr2
		lpr2 = new_lpr2
		_set_register_bit(new_lpr2, VideoMode.LPR2)
		if old_lpr2 != new_lpr2:
			emit_signal('lines_per_row_2_toggled', new_lpr2)
			if not delay_signals:
				emit_signal('lines_per_row_set', self.lines_per_row)
			return true
		return false

	func set_lines_per_row_2(new_lines_per_row_2: bool) -> void:
		self.lpr2 = new_lines_per_row_2

	func get_lines_per_row_2() -> bool:
		return lpr2

	func get_lpr1() -> bool:
		return lpr1

	func set_lpr1(new_lpr1: bool, delay_signals: bool = false) -> bool:
		var old_lpr1 := lpr1
		lpr1 = new_lpr1
		_set_register_bit(new_lpr1, VideoMode.LPR1)
		if old_lpr1 != new_lpr1:
			emit_signal('lines_per_row_1_toggled', new_lpr1)
			if not delay_signals:
				emit_signal('lines_per_row_set', self.lines_per_row)
			return true
		return false

	func set_lines_per_row_1(new_lines_per_row_1: bool) -> void:
		self.lpr1 = new_lines_per_row_1

	func get_lines_per_row_1() -> bool:
		return lpr1

	func get_lpr0() -> bool:
		return lpr0

	func set_lpr0(new_lpr0: bool, delay_signals: bool = false) -> bool:
		var old_lpr0 := lpr0
		lpr0 = new_lpr0
		_set_register_bit(new_lpr0, VideoMode.LPR0)
		if old_lpr0 != new_lpr0:
			emit_signal('lines_per_row_0_toggled', new_lpr0)
			if not delay_signals:
				emit_signal('lines_per_row_set', self.lines_per_row)
			return true
		return false

	func set_lines_per_row_0(new_lines_per_row_0: bool) -> void:
		self.lpr0 = new_lines_per_row_0

	func get_lines_per_row_0() -> bool:
		return lpr0

	func set_lines_per_row(new_lines_per_row: int) -> void:
		register = (register & (255 - (VideoMode.LPR0 | VideoMode.LPR1 | VideoMode.LPR2))) \
			| (new_lines_per_row & (VideoMode.LPR0 | VideoMode.LPR1 | VideoMode.LPR2))
		var _signal := set_lpr0(new_lines_per_row & VideoMode.LPR0, true)
		_signal = set_lpr1(new_lines_per_row & VideoMode.LPR1, true) or _signal
		_signal = set_lpr2(new_lines_per_row & VideoMode.LPR2, true) or _signal
		if _signal:
			emit_signal('lines_per_row_set', self.lines_per_row)

	func get_lines_per_row() -> int:
		return register & (VideoMode.LPR0 | VideoMode.LPR1 | VideoMode.LPR2)

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var video_mode_register: VideoModeRegister = VideoModeRegister.new()

# FF99:       Video Resolution Register
#
#        BIT 7   -
#        BIT 6 = LPF1        Lines per field (See table below)
#        BIT 5 = LPF0        Lines per field
#        BIT 4 = HRES2       Horizontal resolution (See Video resolution on page 17)
#        BIT 3 = HRES1       Horizontal resolution
#        BIT 2 = HRES0       Horizontal resolution
#        BIT 1 = CRES1       Color resolution (See Video resolution)
#        BIT 0 = CRES0       Color resolution
#
# ---------------------------------
# | LPF1 | LPF0 | Lines per field |
# ---------------------------------
# |  0   |  0   |       192       |
# |  0   |  1   |       200       |
# |  1   |  0   |     Reserved    |
# |  1   |  1   |       225       |
# ---------------------------------
#
# From page 18:
#
# VIDEO RESOLUTION
#
# The combination of HRES and CRES bits determine the resolution of the screen. The following
# resolutions are supported:
#
# Alphanumerics: BP = 0, CoCo = 0
#
# --------------------------------------------------------
# |              |       |       |       |       |       |
# | \    RES bit |       |       |       |       |       |
# |     \        | HRES2 | HRES1 | HRES0 | CRES1 | CRES0 |
# |         \    |       |       |       |       |       |
# |  MODE      \ |       |       |       |       |       |
# |              |       |       |       |       |       |
# --------------------------------------------------------
# |              |       |       |       |       |       |
# | 32 character |   0   |   -   |   0   |   -   |   1   |
# |              |       |       |       |       |       |
# | 40 character |   0   |   -   |   1   |   -   |   1   |
# |              |       |       |       |       |       |
# | 80 character |   1   |   -   |   1   |   -   |   1   |
# --------------------------------------------------------
#
# Graphics: BP = 1, CoCo = 0
#
# -----------------------------------------------------------
# | Pixels | Colors | HRES2 | HRES1 | HRES0 | CRES1 | CRES0 |
# -----------------------------------------------------------
# |  640   |   4    |   1   |   1   |   1   |   0   |   1   |
# |  640   |   2    |   1   |   0   |   1   |   0   |   0   |
# -----------------------------------------------------------
# |  512   |   4    |   1   |   1   |   0   |   0   |   1   |
# |  512   |   2    |   1   |   0   |   0   |   0   |   0   |
# -----------------------------------------------------------
# |  320   |   16   |   1   |   1   |   1   |   1   |   0   |
# |  320   |   4    |   1   |   0   |   1   |   0   |   1   |
# -----------------------------------------------------------
# |  256   |   16   |   1   |   1   |   0   |   1   |   0   |
# |  256   |   4    |   1   |   0   |   0   |   0   |   1   |
# |  256   |   2    |   0   |   1   |   0   |   0   |   0   |
# -----------------------------------------------------------
# |  160   |   16   |   1   |   0   |   1   |   1   |   0   |
# -----------------------------------------------------------

enum VideoResolution {
	CRES0 = 0x01,
	CRES1 = 0x02,
	HRES0 = 0x04,
	HRES1 = 0x08,
	HRES2 = 0x10,
	LPF0 = 0x20,
	LPF1 = 0x40
}

enum LinesPerField {
	ONE_NINETY_TWO,
	TWO_HUNDRED = 0x20,
	TWO_TWENTY_FIVE = 0x60
}

enum AlphanumericsWidth {
	THIRTY_TWO_CHARACTER = 0x01, # xxx0x0x1
	FORTY_CHARACTER = 0x05,      # xxx0x1x1
	EIGHTY_CHARACTER = 0x15      # xxx1x1x1
}

enum GraphicsResolution {
	TWO_FIFTY_SIX_2 = 0x08,  # xxx01000
	FIVE_TWELVE_2 = 0x10,    # xxx10000
	TWO_FIFTY_SIX_4 = 0x11,  # xxx10001
	SIX_FORTY_2 = 0x14,      # xxx10100
	THREE_TWENTY_4 = 0x15,   # xxx10101
	ONE_SIXTY_16 = 0x16,     # xxx10110
	FIVE_TWELVE_4 = 0x19,    # xxx11001
	TWO_FIFTY_SIX_16 = 0x1A, # xxx11010
	SIX_FORTY_4 = 0x1D,      # xxx11101
	THREE_TWENTY_16 = 0x1E   # xxx11110
}

enum ColorResolution {
	TWO = 0x00,
	FOUR,
	SIXTEEN
}

class VideoResolutionRegister:

	signal lines_per_field_1_toggled(current)
	signal lines_per_field_0_toggled(current)
	signal lines_per_field_set(current)

	signal horizontal_resolution_2_toggled(current)
	signal horizontal_resolution_1_toggled(current)
	signal horizontal_resolution_0_toggled(current)
	signal horizontal_resolution_set(current)

	signal color_resolution_1_toggled(current)
	signal color_resolution_0_toggled(current)
	signal color_resolution_set(current)

	signal register_set(current)

	var register: int = 0 setget set_register

	var lpf1: bool = false setget set_lpf1   # Lines per field (see table)
	var lpf0: bool = false setget set_lpf0   # Lines per field
	var hres2: bool = false setget set_hres2 # Horizontal resolution
	var hres1: bool = false setget set_hres1 # Horizontal resolution
	var hres0: bool = false setget set_hres0 # Horizontal resolution
	var cres1: bool = false setget set_cres1 # Color resolution (see Video rseolution)
	var cres0: bool = false setget set_cres0 # Color resolution

	var lines_per_field: int setget set_lines_per_field, get_lines_per_field
	var horizontal_resolution: int setget set_horizontal_resolution, get_horizontal_resolution
	var color_resolution: int setget set_color_resolution, get_color_resolution

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		var _signal: bool = set_lines_per_field(new_register, true)
		_signal = set_horizontal_resolution(new_register, true) or _signal
		_signal = set_color_resolution(new_register, true) or _signal
		if _signal:
			emit_signal('register_set', register)

	func get_lpf1() -> bool:
		return lpf1

	func set_lpf1(new_lpf1: bool, delay_signals: bool = false) -> bool:
		var old_lpf1 := lpf1
		lpf1 = new_lpf1
		_set_register_bit(new_lpf1, VideoResolution.LPF1)
		if old_lpf1 != new_lpf1:
			emit_signal('lines_per_field_1_toggled', new_lpf1)
			if not delay_signals:
				emit_signal('lines_per_field_set', self.lines_per_field)
				emit_signal('register_set', register)
			return true
		return false

	func set_lines_per_field_1(new_lines_per_field_1: bool) -> void:
		self.lpf1 = new_lines_per_field_1

	func get_lines_per_field_1() -> bool:
		return lpf1

	func get_lpf0() -> bool:
		return lpf0

	func set_lpf0(new_lpf0: bool, delay_signals: bool = false) -> bool:
		var old_lpf0 := lpf0
		lpf0 = new_lpf0
		_set_register_bit(new_lpf0, VideoResolution.LPF0)
		if old_lpf0 != new_lpf0:
			emit_signal('lines_per_field_0_toggled', new_lpf0)
			if not delay_signals:
				emit_signal('lines_per_field_set', self.lines_per_field)
				emit_signal('register_set', register)
			return true
		return false

	func set_lines_per_field_0(new_lines_per_field_0: bool) -> void:
		self.lpf0 = new_lines_per_field_0

	func get_lines_per_field_0() -> bool:
		return lpf0

	func set_lines_per_field(new_lines_per_field: int, delay_signals: bool = false) -> bool:
		register = (register & (255 - (VideoResolution.LPF0 | VideoResolution.LPF1))) \
			| (new_lines_per_field & (VideoResolution.LPF0 | VideoResolution.LPF1))
		var _signal := set_lpf0(new_lines_per_field & VideoResolution.LPF0, true)
		_signal = set_lpf1(new_lines_per_field & VideoResolution.LPF1, true) or _signal
		if _signal:
			emit_signal('lines_per_field_set', self.lines_per_field)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func get_lines_per_field() -> int:
		return register & (VideoResolution.LPF0 | VideoResolution.LPF1)

	func get_hres2() -> bool:
		return hres2

	func set_hres2(new_hres2: bool, delay_signals: bool = false) -> bool:
		var old_hres2 := hres2
		hres2 = new_hres2
		_set_register_bit(new_hres2, VideoResolution.HRES2)
		if old_hres2 != new_hres2:
			emit_signal('horizontal_resolution_2_toggled', new_hres2)
			if not delay_signals:
				emit_signal('horizontal_resolution_set', self.horizontal_resolution)
				emit_signal('register_set', register)
			return true
		return false

	func set_horizontal_resolution_2(new_horizontal_resolution_2: bool) -> void:
		self.hres2 = new_horizontal_resolution_2

	func get_horizontal_resolution_2() -> bool:
		return hres2

	func get_hres1() -> bool:
		return hres1

	func set_hres1(new_hres1: bool, delay_signals: bool = false) -> bool:
		var old_hres1 := hres1
		hres1 = new_hres1
		_set_register_bit(new_hres1, VideoResolution.HRES1)
		if old_hres1 != new_hres1:
			emit_signal('horizontal_resolution_1_toggled', new_hres1)
			if not delay_signals:
				emit_signal('horizontal_resolution_set', self.horizontal_resolution)
				emit_signal('register_set', register)
			return true
		return false

	func set_horizontal_resolution_1(new_horizontal_resolution_1: bool) -> void:
		self.hres1 = new_horizontal_resolution_1

	func get_horizontal_resolution_1() -> bool:
		return hres1

	func get_hres0() -> bool:
		return hres0

	func set_hres0(new_hres0: bool, delay_signals: bool = false) -> bool:
		var old_hres0 := hres0
		hres0 = new_hres0
		_set_register_bit(new_hres0, VideoResolution.HRES0)
		if old_hres0 != new_hres0:
			emit_signal('horizontal_resolution_0_toggled', new_hres0)
			if not delay_signals:
				emit_signal('horizontal_resolution_set', self.horizontal_resolution)
				emit_signal('register_set', register)
			return true
		return false

	func set_horizontal_resolution_0(new_horizontal_resolution_0: bool) -> void:
		self.hres0 = new_horizontal_resolution_0

	func get_horizontal_resolution_0() -> bool:
		return hres0

	func set_horizontal_resolution(new_horizontal_resolution: int, delay_signals: bool = false) -> bool:
		register = (register & (255 - (VideoResolution.HRES0 | VideoResolution.HRES1 | VideoResolution.HRES2))) \
			| (new_horizontal_resolution & (VideoResolution.HRES0 | VideoResolution.HRES1 | VideoResolution.HRES2))
		var _signal := set_hres0(new_horizontal_resolution & VideoResolution.HRES0, true)
		_signal = set_hres1(new_horizontal_resolution & VideoResolution.HRES1, true) or _signal
		_signal = set_hres2(new_horizontal_resolution & VideoResolution.HRES2, true) or _signal
		if _signal:
			emit_signal('horizontal_resolution_set', self.horizontal_resolution)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func get_horizontal_resolution() -> int:
		return register & (VideoResolution.HRES0 | VideoResolution.HRES1 | VideoResolution.HRES2)

	func get_cres1() -> bool:
		return cres1

	func set_cres1(new_cres1: bool, delay_signals: bool = false) -> bool:
		var old_cres1 := cres1
		cres1 = new_cres1
		_set_register_bit(new_cres1, VideoResolution.CRES1)
		if old_cres1 != new_cres1:
			emit_signal('color_resolution_1_toggled', new_cres1)
			if not delay_signals:
				emit_signal('color_resolution_set', self.color_resolution)
				emit_signal('register_set', register)
			return true
		return false

	func set_color_resolution_1(new_color_resolution_1: bool) -> void:
		self.cres1 = new_color_resolution_1

	func get_color_resolution_1() -> bool:
		return cres1

	func get_cres0() -> bool:
		return cres0

	func set_cres0(new_cres0: bool, delay_signals: bool = false) -> bool:
		var old_cres0 := cres0
		cres0 = new_cres0
		_set_register_bit(new_cres0, VideoResolution.CRES0)
		if old_cres0 != new_cres0:
			emit_signal('color_resolution_0_toggled', new_cres0)
			if not delay_signals:
				emit_signal('color_resolution_set', self.color_resolution)
				emit_signal('register_set', register)
			return true
		return false

	func set_color_resolution_0(new_color_resolution_0: bool) -> void:
		self.cres0 = new_color_resolution_0

	func get_color_resolution_0() -> bool:
		return cres0

	func set_color_resolution(new_color_resolution: int, delay_signals: bool = false) -> bool:
		register = (register & (255 - (VideoResolution.CRES0 | VideoResolution.CRES1))) \
			| (new_color_resolution & (VideoResolution.CRES0 | VideoResolution.CRES1))
		var _signal := set_cres0(new_color_resolution & VideoResolution.CRES0, true)
		_signal = set_cres1(new_color_resolution & VideoResolution.CRES1, true) or _signal
		if _signal:
			emit_signal('color_resolution_set', self.color_resolution)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func get_color_resolution() -> int:
		return register & (VideoResolution.CRES0 | VideoResolution.CRES1)

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var video_resolution_register: VideoResolutionRegister = VideoResolutionRegister.new()

# FF9A:       Border Register (All bits are 0 for CoCo 1 and CoCo 2 compatibility)
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5 = RED1        Most significant red bit
#        BIT 4 = GRN1        Most significant green bit
#        BIT 3 = BLU1        Most significant blue bit
#        BIT 2 = RED0        Least significant red bit
#        BIT 1 = GRN0        Least significant green bit
#        BIT 0 = BLU0        Least significant blue bit

enum Border {
	BLUE0 = 0x01,
	GREEN0 = 0x02,
	RED0 = 0x04,
	BLUE1 = 0x08,
	GREEN1 = 0x10,
	RED1 = 0x20
}

enum BorderBlue {
	BLUE0 = 0x00,
	BLUE1 = Border.BLUE0,
	BLUE2 = Border.BLUE1,
	BLUE3 = Border.BLUE0 | Border.BLUE1
}

enum BorderGreen {
	GREEN0 = 0x00,
	GREEN1 = Border.GREEN0,
	GREEN2 = Border.GREEN1,
	GREEN3 = Border.GREEN0 | Border.GREEN1
}

enum BorderRed {
	RED0 = 0x00,
	RED1 = Border.RED0,
	RED2 = Border.RED1,
	RED3 = Border.RED0 | Border.RED1
}

class BorderRegister:

	signal blue_0_toggled(current)
	signal blue_1_toggled(current)
	signal blue_set(current)

	signal green_0_toggled(current)
	signal green_1_toggled(current)
	signal green_set(current)

	signal red_0_toggled(current)
	signal red_1_toggled(current)
	signal red_set(current)

	signal register_set(current)

	var register: int = 0 setget set_register

	var red1: bool = false setget set_red1 # Most significant red bit
	var grn1: bool = false setget set_grn1 # Most significant green bit
	var blu1: bool = false setget set_blu1 # Most significant blue bit
	var red0: bool = false setget set_red0 # Least significant red bit
	var grn0: bool = false setget set_grn0 # Least significant green bit
	var blu0: bool = false setget set_blu0 # Least significant blue bit

	var red: int setget set_red, get_red
	var green: int setget set_green, get_green
	var blue: int setget set_blue, get_blue

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int = 0) -> void:
		var _signal := set_red(new_register, true)
		_signal = set_green(new_register, true) or _signal
		_signal = set_blue(new_register, true) or _signal
		if _signal:
			emit_signal('register_set', register)

	func get_red1() -> bool:
		return red1

	func set_red1(new_red1: bool, delay_signals: bool = false) -> bool:
		var old_red1 := red1
		red1 = new_red1
		_set_register_bit(new_red1, Border.RED1)
		if old_red1 != new_red1:
			emit_signal('red_1_toggled', new_red1)
			if not delay_signals:
				emit_signal('red_set', self.red)
				emit_signal('register_set', register)
			return true
		return false

	func set_red_1(new_red_1: bool) -> void:
		self.red1 = new_red_1

	func get_red_1() -> bool:
		return red1

	func get_red0() -> bool:
		return red0

	func set_red0(new_red0: bool, delay_signals: bool = false) -> bool:
		var old_red0 := red0
		red0 = new_red0
		_set_register_bit(new_red0, Border.RED0)
		if old_red0 != new_red0:
			emit_signal('red_0_toggled', new_red0)
			if not delay_signals:
				emit_signal('red_set', self.red)
				emit_signal('register_set', register)
			return true
		return false

	func set_red_0(new_red_0: bool) -> void:
		self.red0 = new_red_0

	func get_red_0() -> bool:
		return red0

	func set_red(new_red: int, delay_signals: bool = false) -> bool:
		register = (register & (255 - (Border.RED1 | Border.RED0))) \
			| (new_red & (Border.RED1 | Border.RED0))
		var _signal := set_red0(new_red & Border.RED0, true)
		_signal = set_red1(new_red & Border.RED1, true) or _signal
		if _signal:
			emit_signal('red_set', self.red)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func get_red() -> int:
		return register & (Border.RED1 | Border.RED0)

	func get_grn1() -> bool:
		return grn1

	func set_grn1(new_grn1: bool, delay_signals: bool = false) -> bool:
		var old_grn1 := grn1
		grn1 = new_grn1
		_set_register_bit(new_grn1, Border.GREEN1)
		if old_grn1 != new_grn1:
			emit_signal('green_1_toggled', new_grn1)
			if not delay_signals:
				emit_signal('green_set', self.green)
				emit_signal('register_set', register)
			return true
		return false

	func set_green_1(new_green_1: bool) -> void:
		self.grn1 = new_green_1

	func get_green_1() -> bool:
		return grn1

	func get_grn0() -> bool:
		return grn0

	func set_grn0(new_grn0: bool, delay_signals: bool = false) -> bool:
		var old_grn0 := grn0
		grn0 = new_grn0
		_set_register_bit(new_grn0, Border.GREEN0)
		if old_grn0 != new_grn0:
			emit_signal('green_0_toggled', new_grn0)
			if not delay_signals:
				emit_signal('green_set', self.green)
				emit_signal('register_set', register)
			return true
		return false

	func set_green_0(new_green_0: bool) -> void:
		self.grn0 = new_green_0

	func get_green_0() -> bool:
		return grn0

	func set_green(new_green: int, delay_signals: bool = false) -> bool:
		register = (register & (255 - (Border.GREEN1 | Border.GREEN0))) \
			| (new_green & (Border.GREEN1 | Border.GREEN0))
		var _signal := set_grn0(new_green & Border.GREEN0, true)
		_signal = set_grn1(new_green & Border.GREEN1, true) or _signal
		if _signal:
			emit_signal('green_set', self.green)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func get_green() -> int:
		return register & (Border.GREEN1 | Border.GREEN0)

	func get_blu1() -> bool:
		return blu1

	func set_blu1(new_blu1: bool, delay_signals: bool = false) -> bool:
		var old_blu1 := blu1
		blu1 = new_blu1
		_set_register_bit(new_blu1, Border.BLUE1)
		if old_blu1 != new_blu1:
			emit_signal('blue_1_toggled', new_blu1)
			if not delay_signals:
				emit_signal('blue_set', self.blue)
				emit_signal('register_set', register)
			return true
		return false

	func set_blue_1(new_blue_1: bool) -> void:
		self.blu1 = new_blue_1

	func get_blue_1() -> bool:
		return blu1

	func get_blu0() -> bool:
		return blu0

	func set_blu0(new_blu0: bool, delay_signals: bool = false) -> bool:
		var old_blu0 := blu0
		blu0 = new_blu0
		_set_register_bit(new_blu0, Border.BLUE0)
		if old_blu0 != new_blu0:
			emit_signal('blue_0_toggled', new_blu0)
			if not delay_signals:
				emit_signal('blue_set', self.blue)
				emit_signal('register_set', register)
			return true
		return false

	func set_blue_0(new_blue_0: bool) -> void:
		self.blu0 = new_blue_0

	func get_blue_0() -> bool:
		return blu0

	func set_blue(new_blue: int, delay_signals: bool = false) -> bool:
		register = (register & (255 - (Border.BLUE1 | Border.BLUE0))) \
			| (new_blue & (Border.BLUE1 | Border.BLUE0))
		var _signal := set_blu0(new_blue & Border.BLUE0, true)
		_signal = set_blu1(new_blue & Border.BLUE1, true) or _signal
		if _signal:
			emit_signal('blue_set', self.blue)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func get_blue() -> int:
		return register & (Border.BLUE1 | Border.BLUE0)

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var border_register: BorderRegister = BorderRegister.new()

# FF9C:       Vertical Scroll Register
#
#        BIT 7   -
#        BIT 6   -
#        BIT 5   -
#        BIT 4   -
#        BIT 3 = VSC3        (Vert. Scroll)
#        BIT 2 = VSC2
#        BIT 1 = VSC1
#        BIT 0 = VSC0
#
#        NOTE: In the CoCo mode, the VSC's must be initialized to 0F hex.

enum VerticalScroll {
	VSC0 = 0x01,
	VSC1 = 0x02,
	VSC2 = 0x04,
	VSC3 = 0x08
}

class VerticalScrollRegister:

	signal vertical_scroll_0_toggled(current)
	signal vertical_scroll_1_toggled(current)
	signal vertical_scroll_2_toggled(current)
	signal vertical_scroll_3_toggled(current)
	signal vertical_scroll_set(current)

	var register: int setget set_register

	var vsc3: bool = false setget set_vsc3 # Vertical Scroll
	var vsc2: bool = false setget set_vsc2 # Vertical Scroll
	var vsc1: bool = false setget set_vsc1 # Vertical Scroll
	var vsc0: bool = false setget set_vsc0 # Vertical Scroll
	
	var vertical_scroll: int setget set_vertical_scroll, get_vertical_scroll

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		self.vertical_scroll = new_register

	func get_vsc3() -> bool:
		return vsc3

	func set_vsc3(new_vsc3: bool, delay_signals: bool = false) -> bool:
		var old_vsc3 := vsc3
		vsc3 = new_vsc3
		_set_register_bit(new_vsc3, VerticalScroll.VSC3)
		if old_vsc3 != new_vsc3:
			emit_signal('vertical_scroll_3_toggled', new_vsc3)
			if not delay_signals:
				emit_signal('vertical_scroll_set', self.vertical_scroll)
			return true
		return false

	func set_vertical_scroll_3(new_vertical_scroll_3: bool) -> void:
		self.vsc3 = new_vertical_scroll_3

	func get_vertical_scroll_3() -> bool:
		return vsc3

	func get_vsc2() -> bool:
		return vsc2

	func set_vsc2(new_vsc2: bool, delay_signals: bool = false) -> bool:
		var old_vsc2 := vsc2
		vsc2 = new_vsc2
		_set_register_bit(new_vsc2, VerticalScroll.VSC2)
		if old_vsc2 != new_vsc2:
			emit_signal('vertical_scroll_2_toggled', new_vsc2)
			if not delay_signals:
				emit_signal('vertical_scroll_set', self.vertical_scroll)
			return true
		return false

	func set_vertical_scroll_2(new_vertical_scroll_2: bool) -> void:
		self.vsc2 = new_vertical_scroll_2

	func get_vertical_scroll_2() -> bool:
		return vsc2

	func get_vsc1() -> bool:
		return vsc1

	func set_vsc1(new_vsc1: bool, delay_signals: bool = false) -> bool:
		var old_vsc1 := vsc1
		vsc1 = new_vsc1
		_set_register_bit(new_vsc1, VerticalScroll.VSC1)
		if old_vsc1 != new_vsc1:
			emit_signal('vertical_scroll_1_toggled', new_vsc1)
			if not delay_signals:
				emit_signal('vertical_scroll_set', self.vertical_scroll)
			return true
		return false

	func set_vertical_scroll_1(new_vertical_scroll_1: bool) -> void:
		self.vsc1 = new_vertical_scroll_1

	func get_vertical_scroll_1() -> bool:
		return vsc1

	func get_vsc0() -> bool:
		return vsc0

	func set_vsc0(new_vsc0: bool, delay_signals: bool = false) -> bool:
		var old_vsc0 := vsc0
		vsc0 = new_vsc0
		_set_register_bit(new_vsc0, VerticalScroll.VSC0)
		if old_vsc0 != new_vsc0:
			emit_signal('vertical_scroll_0_toggled', new_vsc0)
			if not delay_signals:
				emit_signal('vertical_scroll_set', self.vertical_scroll)
			return true
		return false

	func set_vertical_scroll_0(new_vertical_scroll_0: bool) -> void:
		self.vsc0 = new_vertical_scroll_0

	func get_vertical_scroll_0() -> bool:
		return vsc0

	func set_vertical_scroll(new_vertical_scroll: int) -> void:
		register = (register & (255 - \
				(VerticalScroll.VSC0 | VerticalScroll.VSC1 | VerticalScroll.VSC2 | VerticalScroll.VSC3) \
			)) | (new_vertical_scroll & \
				(VerticalScroll.VSC0 | VerticalScroll.VSC1 | VerticalScroll.VSC2 | VerticalScroll.VSC3)
			)
		var _signal := set_vsc0(new_vertical_scroll & VerticalScroll.VSC0, true)
		_signal = set_vsc1(new_vertical_scroll & VerticalScroll.VSC1, true) or _signal
		_signal = set_vsc2(new_vertical_scroll & VerticalScroll.VSC2, true) or _signal
		_signal = set_vsc3(new_vertical_scroll & VerticalScroll.VSC3, true) or _signal
		if _signal:
			emit_signal('vertical_scroll_set', self.vertical_scroll)

	func get_vertical_scroll() -> int:
		return register & (VerticalScroll.VSC0 | VerticalScroll.VSC1 | VerticalScroll.VSC2 | VerticalScroll.VSC3)

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var vertical_scroll_register: VerticalScrollRegister = VerticalScrollRegister.new()

# FF9D:       Vertical Offset 1 Register
#
#        BIT 7 = Y18         (Vert. Offset)
#        BIT 6 = Y17
#        BIT 5 = Y16
#        BIT 4 = Y15
#        BIT 3 = Y14
#        BIT 2 = Y13
#        BIT 1 = Y12
#        BIT 0 = Y11

enum VerticalOffset1 {
	Y11 = 0x01,
	Y12 = 0x02,
	Y13 = 0x04,
	Y14 = 0x08,
	Y15 = 0x10,
	Y16 = 0x20,
	Y17 = 0x40,
	Y18 = 0x80
}

class VerticalOffsetRegister1:

	signal y11_toggled(current)
	signal y12_toggled(current)
	signal y13_toggled(current)
	signal y14_toggled(current)
	signal y15_toggled(current)
	signal y16_toggled(current)
	signal y17_toggled(current)
	signal y18_toggled(current)
	signal register_set(current)

	var register: int = 0 setget set_register

	var y18: bool = false setget set_y18
	var y17: bool = false setget set_y17
	var y16: bool = false setget set_y16
	var y15: bool = false setget set_y15
	var y14: bool = false setget set_y14
	var y13: bool = false setget set_y13
	var y12: bool = false setget set_y12
	var y11: bool = false setget set_y11

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		var _signal := set_y18(new_register & VerticalOffset1.Y18, true)
		_signal = set_y17(new_register & VerticalOffset1.Y17, true) or _signal
		_signal = set_y16(new_register & VerticalOffset1.Y16, true) or _signal
		_signal = set_y15(new_register & VerticalOffset1.Y15, true) or _signal
		_signal = set_y14(new_register & VerticalOffset1.Y14, true) or _signal
		_signal = set_y13(new_register & VerticalOffset1.Y13, true) or _signal
		_signal = set_y12(new_register & VerticalOffset1.Y12, true) or _signal
		_signal = set_y11(new_register & VerticalOffset1.Y11, true) or _signal
		if _signal:
			emit_signal('register_set', register)

	func set_y18(new_y18: bool, delay_signals: bool = false) -> bool:
		var old_y18 := y18
		y18 = new_y18
		_set_register_bit(new_y18, VerticalOffset1.Y18)
		if old_y18 != new_y18:
			emit_signal('y18_toggled', new_y18)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y17(new_y17: bool, delay_signals: bool = false) -> bool:
		var old_y17 := y17
		y17 = new_y17
		_set_register_bit(new_y17, VerticalOffset1.Y17)
		if old_y17 != new_y17:
			emit_signal('y17_toggled', new_y17)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y16(new_y16: bool, delay_signals: bool = false) -> bool:
		var old_y16 := y16
		y16 = new_y16
		_set_register_bit(new_y16, VerticalOffset1.Y16)
		if old_y16 != new_y16:
			emit_signal('y16_toggled', new_y16)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y15(new_y15: bool, delay_signals: bool = false) -> bool:
		var old_y15 := y15
		y15 = new_y15
		_set_register_bit(new_y15, VerticalOffset1.Y15)
		if old_y15 != new_y15:
			emit_signal('y15_toggled', new_y15)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y14(new_y14: bool, delay_signals: bool = false) -> bool:
		var old_y14 := y14
		y14 = new_y14
		_set_register_bit(new_y14, VerticalOffset1.Y14)
		if old_y14 != new_y14:
			emit_signal('y14_toggled', new_y14)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y13(new_y13: bool, delay_signals: bool = false) -> bool:
		var old_y13 := y13
		y13 = new_y13
		_set_register_bit(new_y13, VerticalOffset1.Y13)
		if old_y13 != new_y13:
			emit_signal('y13_toggled', new_y13)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y12(new_y12: bool, delay_signals: bool = false) -> bool:
		var old_y12 := y12
		y12 = new_y12
		_set_register_bit(new_y12, VerticalOffset1.Y12)
		if old_y12 != new_y12:
			emit_signal('y12_toggled', new_y12)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y11(new_y11: bool, delay_signals: bool = false) -> bool:
		var old_y11 := y11
		y11 = new_y11
		_set_register_bit(new_y11, VerticalOffset1.Y11)
		if old_y11 != new_y11:
			emit_signal('y11_toggled', new_y11)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var vertical_offset_1: VerticalOffsetRegister1 = VerticalOffsetRegister1.new()

# FF9E:       Vertical Offset 0 Register
#
#        BIT 7 = Y10         (Vert. Offset)
#        BIT 6 = Y9
#        BIT 5 = Y8
#        BIT 4 = Y7
#        BIT 3 = Y6
#        BIT 2 = Y5
#        BIT 1 = Y4
#        BIT 0 = Y3

enum VerticalOffset0 {
	Y3 = 0x01,
	Y4 = 0x02,
	Y5 = 0x04,
	Y6 = 0x08,
	Y7 = 0x10,
	Y8 = 0x20,
	Y9 = 0x40,
	Y10 = 0x80
}

class VerticalOffsetRegister0:

	signal y10_toggled(current)
	signal y9_toggled(current)
	signal y8_toggled(current)
	signal y7_toggled(current)
	signal y6_toggled(current)
	signal y5_toggled(current)
	signal y4_toggled(current)
	signal y3_toggled(current)
	signal register_set(current)

	var register: int = 0 setget set_register

	var y10: bool = false setget set_y10
	var y9: bool = false setget set_y9
	var y8: bool = false setget set_y8
	var y7: bool = false setget set_y7
	var y6: bool = false setget set_y6
	var y5: bool = false setget set_y5
	var y4: bool = false setget set_y4
	var y3: bool = false setget set_y3
	
	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		var _signal := set_y10(new_register & VerticalOffset0.Y10, true)
		_signal = set_y9(new_register & VerticalOffset0.Y9, true) or _signal
		_signal = set_y8(new_register & VerticalOffset0.Y8, true) or _signal
		_signal = set_y7(new_register & VerticalOffset0.Y7, true) or _signal
		_signal = set_y6(new_register & VerticalOffset0.Y6, true) or _signal
		_signal = set_y5(new_register & VerticalOffset0.Y5, true) or _signal
		_signal = set_y4(new_register & VerticalOffset0.Y4, true) or _signal
		_signal = set_y3(new_register & VerticalOffset0.Y3, true) or _signal
		if _signal:
			emit_signal('register_set', register)

	func set_y10(new_y10: bool, delay_signals: bool = false) -> bool:
		var old_y10 := y10
		y10 = new_y10
		_set_register_bit(new_y10, VerticalOffset0.Y10)
		if old_y10 != new_y10:
			emit_signal('y10_toggled', new_y10)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y9(new_y9: bool, delay_signals: bool = false) -> bool:
		var old_y9 := y9
		y9 = new_y9
		_set_register_bit(new_y9, VerticalOffset0.Y9)
		if old_y9 != new_y9:
			emit_signal('y9_toggled', new_y9)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y8(new_y8: bool, delay_signals: bool = false) -> bool:
		var old_y8 := y8
		y8 = new_y8
		_set_register_bit(new_y8, VerticalOffset0.Y8)
		if old_y8 != new_y8:
			emit_signal('y8_toggled', new_y8)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y7(new_y7: bool, delay_signals: bool = false) -> bool:
		var old_y7 := y7
		y7 = new_y7
		_set_register_bit(new_y7, VerticalOffset0.Y7)
		if old_y7 != new_y7:
			emit_signal('y7_toggled', new_y7)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y6(new_y6: bool, delay_signals: bool = false) -> bool:
		var old_y6 := y6
		y6 = new_y6
		_set_register_bit(new_y6, VerticalOffset0.Y6)
		if old_y6 != new_y6:
			emit_signal('y6_toggled', new_y6)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y5(new_y5: bool, delay_signals: bool = false) -> bool:
		var old_y5 := y5
		y5 = new_y5
		_set_register_bit(new_y5, VerticalOffset0.Y5)
		if old_y5 != new_y5:
			emit_signal('y5_toggled', new_y5)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y4(new_y4: bool, delay_signals: bool = false) -> bool:
		var old_y4 := y4
		y4 = new_y4
		_set_register_bit(new_y4, VerticalOffset0.Y4)
		if old_y4 != new_y4:
			emit_signal('y4_toggled', new_y4)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func set_y3(new_y3: bool, delay_signals: bool = false) -> bool:
		var old_y3 := y3
		y3 = new_y3
		_set_register_bit(new_y3, VerticalOffset0.Y3)
		if old_y3 != new_y3:
			emit_signal('y3_toggled', new_y3)
			if not delay_signals:
				emit_signal('register_set', register)
			return true
		return false

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var vertical_offset_0: VerticalOffsetRegister0 = VerticalOffsetRegister0.new()

#        NOTE: In CoCo mode, Y15 - Y9 are not effective, and are controlled by SAM bits F6 - F0.
#              Also in CoCo mode, Y18 - Y16 should be 1, all others 0.
#
# -------
# |
# | Vertical Offset Registers 0 & 1
# |
# |     The starting address of a buffer area is indicated to the ACVC via these registers. This is
# | done by writing the upper sixteen bits (Y18-Y3) of the starting physical address into these
# | registers. Y18-Y11 are written to vertical offset 1 and Y10-Y3 are written to vertical offset
# | 0. Thus, a buffer is limited to starting on an 8-bit boundary, or the starting address is
# | limited to the binary form: xxx xxxx xxxx xxxx x000
# |
# - From Assembly Language Programming For The COCO 3 by Laurence A. Tepolt

class VerticalOffset:

	var offset_1: VerticalOffsetRegister1
	var offset_0: VerticalOffsetRegister0

	var offset: int setget , get_offset

	# can't type other inner class?
	func _init(new_offset_1, new_offset_0):
		offset_1 = new_offset_1
		offset_0 = new_offset_0

	func get_offset() -> int:
		return (offset_1.register << 11) | (offset_0.register << 3)

var vertical_offset: VerticalOffset = VerticalOffset.new(vertical_offset_1, vertical_offset_0)

# FF9F:       Horizontal Offset 0 Register
#
#        BIT 7 = HVEN        Horizontal Virtual Enable
#        BIT 6 = X6          Horizontal Offset address
#        BIT 5 = X5          Horizontal Offset address
#        BIT 4 = X4          Horizontal Offset address
#        BIT 3 = X3          Horizontal Offset address
#        BIT 2 = X2          Horizontal Offset address
#        BIT 1 = X1          Horizontal Offset address
#        BIT 0 = X0          Horizontal Offset address
#
#        NOTE: HVEN enables a horizontal screen width of 128 bytes regardless of the HRES bits and
#              CRES bits selected. This will allow a "virtual" screen somewhat larger than the
#              displayed screen. The user can move the "window" (the displayed screen) by means of
#              the horizontal offset bits. In character mode, the screen width is 128 characters
#              regardless of attribute (or 64, if double-wide is selected).

enum HorizontalOffset {
	X0 = 0x01,
	X1 = 0x02,
	X2 = 0x04,
	X3 = 0x08,
	X4 = 0x10,
	X5 = 0x20,
	X6 = 0x40,
	HVEN = 0x80
}

class HorizontalOffsetRegister:

	signal hven_toggled(current)
	signal x6_toggled(current)
	signal x5_toggled(current)
	signal x4_toggled(current)
	signal x3_toggled(current)
	signal x2_toggled(current)
	signal x1_toggled(current)
	signal x0_toggled(current)
	signal horizontal_offset_address_set(current)

	var register: int = 0 setget set_register

	var hven: bool = false setget set_hven # Horizontal Virtual Enable
	var x6: bool = false setget set_x6     # Horizontal Offset address
	var x5: bool = false setget set_x5     # Horizontal Offset address
	var x4: bool = false setget set_x4     # Horizontal Offset address
	var x3: bool = false setget set_x3     # Horizontal Offset address
	var x2: bool = false setget set_x2     # Horizontal Offset address
	var x1: bool = false setget set_x1     # Horizontal Offset address
	var x0: bool = false setget set_x0     # Horizontal Offset address

	var horizontal_virtual_enable: bool setget set_hven, get_hven
	var horizontal_offset_address: int \
		setget set_horizontal_offset_address, get_horizontal_offset_address

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		register = new_register
		refresh_hven()
		self.horizontal_offset_address = register

	func get_hven() -> bool:
		return hven

	func refresh_hven() -> void:
		self.hven = register & HorizontalOffset.HVEN

	func set_hven(new_hven: bool) -> void:
		var old_hven := hven
		hven = new_hven
		_set_register_bit(new_hven, HorizontalOffset.HVEN)
		if old_hven != new_hven:
			emit_signal('hven_toggled', new_hven)

	func set_horizontal_virtual_enable(new_horizontal_virtual_enable: bool) -> void:
		self.hven = new_horizontal_virtual_enable

	func get_horizontal_virtual_enable() -> bool:
		return hven

	func set_x6(new_x6: bool, delay_signals: bool = false) -> bool:
		var old_x6 := x6
		x6 = new_x6
		_set_register_bit(new_x6, HorizontalOffset.X6)
		if old_x6 != new_x6:
			emit_signal('x6_toggled', new_x6)
			if not delay_signals:
				emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)
			return true
		return false

	func set_x5(new_x5: bool, delay_signals: bool = false) -> bool:
		var old_x5 := x5
		x5 = new_x5
		_set_register_bit(new_x5, HorizontalOffset.X5)
		if old_x5 != new_x5:
			emit_signal('x5_toggled', new_x5)
			if not delay_signals:
				emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)
			return true
		return false

	func set_x4(new_x4: bool, delay_signals: bool = false) -> bool:
		var old_x4 := x4
		x4 = new_x4
		_set_register_bit(new_x4, HorizontalOffset.X4)
		if old_x4 != new_x4:
			emit_signal('x4_toggled', new_x4)
			if not delay_signals:
				emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)
			return true
		return false

	func set_x3(new_x3: bool, delay_signals: bool = false) -> bool:
		var old_x3 := x3
		x3 = new_x3
		_set_register_bit(new_x3, HorizontalOffset.X3)
		if old_x3 != new_x3:
			emit_signal('x3_toggled', new_x3)
			if not delay_signals:
				emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)
			return true
		return false

	func set_x2(new_x2: bool, delay_signals: bool = false) -> bool:
		var old_x2 := x2
		x2 = new_x2
		_set_register_bit(new_x2, HorizontalOffset.X2)
		if old_x2 != new_x2:
			emit_signal('x2_toggled', new_x2)
			if not delay_signals:
				emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)
			return true
		return false

	func set_x1(new_x1: bool, delay_signals: bool = false) -> bool:
		var old_x1 := x1
		x1 = new_x1
		_set_register_bit(new_x1, HorizontalOffset.X1)
		if old_x1 != new_x1:
			emit_signal('x1_toggled', new_x1)
			if not delay_signals:
				emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)
			return true
		return false

	func set_x0(new_x0: bool, delay_signals: bool = false) -> bool:
		var old_x0 := x0
		x0 = new_x0
		_set_register_bit(new_x0, HorizontalOffset.X0)
		if old_x0 != new_x0:
			emit_signal('x0_toggled', new_x0)
			if not delay_signals:
				emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)
			return true
		return false

	func set_horizontal_offset_address(new_horizontal_offset_address: int) -> void:
		# no real need to introduce that many ORs
		register = (register & (255 - 0x7F)) | (new_horizontal_offset_address & 0x7F)
		var _signal := set_x6(new_horizontal_offset_address & HorizontalOffset.X6, true)
		_signal = set_x5(new_horizontal_offset_address & HorizontalOffset.X5, true) or _signal
		_signal = set_x4(new_horizontal_offset_address & HorizontalOffset.X4, true) or _signal
		_signal = set_x3(new_horizontal_offset_address & HorizontalOffset.X3, true) or _signal
		_signal = set_x2(new_horizontal_offset_address & HorizontalOffset.X2, true) or _signal
		_signal = set_x1(new_horizontal_offset_address & HorizontalOffset.X1, true) or _signal
		_signal = set_x0(new_horizontal_offset_address & HorizontalOffset.X0, true) or _signal
		if _signal:
			emit_signal('horizontal_offset_address_set', self.horizontal_offset_address)

	func get_horizontal_offset_address() -> int:
		return register & 0x7F

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)

var horizontal_offset: HorizontalOffsetRegister = HorizontalOffsetRegister.new()

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
#
# --- From "Assembly Language Programming for the CoCo3" by Laurence A. Tepolt
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

signal memory_accessed(real_address, pins)

class PageAddressRegisterSet:
	extends Reference

	var par: Array = [0, 0, 0, 0, 0, 0, 0, 0]

	func set_par(index: int, value: int) -> void:
		par[index] = value & 0x3F

	func get_address(address: int) -> int:
		var index := (address & 0xE0) >> 5
		return (par[index] << 13) & (address & 0x1F)

# ZERO = executive
var executive_set: PageAddressRegisterSet = PageAddressRegisterSet.new()
# ONE = task
var task_set: PageAddressRegisterSet = PageAddressRegisterSet.new()

# COLOR PALETTE
#
# FFB0 - FFBF: 16 addresses, 6 bits each
#
# For the RGB output, the bits are defined as follows:
#
# -------------------------------------
# | Data Bit      | D5 D4 D3 D2 D1 D0 |
# -------------------------------------
# | Corresponding |                   |
# |  RGB output   | R1 G1 B1 R0 G0 B0 |
# |               |                   |
# -------------------------------------
#
# For the Composite output, the bits are defined as follows, where I is intensity level and P is
# phase:
#
# -------------------------------------
# | Data Bit      | D5 D4 D3 D2 D1 D0 |
# -------------------------------------
# | Corresponding |                   |
# |   composite   | I1 I0 P3 P2 P1 P0 |
# |    output     |                   |
# -------------------------------------
#
# Some Color Examples:
#
# --------------------------------------------------
# |                |      RGB      |   Composite   |
# |                ---------------------------------
# | Color          | Binary | Hex  | Binary | Hex  |
# --------------------------------------------------
# | White          | 111111 | (3F) | 110000 | (30) |
# | Black          | 000000 | (00) | 000000 | (00) |
# | Bright Green   | 010010 | (12) | 100010 | (22) |
# | Medium Green   | 010000 | (10) | 010010 | (12) |
# | Dark Green     | 000010 | (02) | 000010 | (02) |
# | Medium Magenta | 101000 | (28) | 010101 | (15) |
# --------------------------------------------------
#
# For CoCo compatibility, the following values should be loaded upon initialization. (NOTE: These
# are the RGB values.)
#
# FFB0 - Green   (12)
# FFB1 - Yellow  (36)
# FFB2 - Blue    (09)
# FFB3 - Red     (24)
# FFB4 - Buff    (3F)
# FFB5 - Cyan    (10)
# FFB6 - Magenta (2D)
# FFB7 - Orange  (26)
# FFB8 - Black   (00)
# FFB9 - Green   (12)
# FFBA - Black   (00)
# FFBB - Buff    (3F)
# FFBC - Black   (00)
# FFBD - Green   (12)
# FFBE - Black   (00)
# FFBF - Orange  (26)
#
# NOTE: For the PAL version, ignore the table attributed to composite.

enum Palette {
	BLUE0 = 0x01,
	GREEN0 = 0x02,
	RED0 = 0x04,
	BLUE1 = 0x08,
	GREEN1 = 0x10,
	RED1 = 0x20
}

enum PaletteBlue {
	BLUE0 = 0x00,
	BLUE1 = Border.BLUE0,
	BLUE2 = Border.BLUE1,
	BLUE3 = Border.BLUE0 | Border.BLUE1
}

enum PaletteGreen {
	GREEN0 = 0x00,
	GREEN1 = Border.GREEN0,
	GREEN2 = Border.GREEN1,
	GREEN3 = Border.GREEN0 | Border.GREEN1
}

enum PaletteRed {
	RED0 = 0x00,
	RED1 = Border.RED0,
	RED2 = Border.RED1,
	RED3 = Border.RED0 | Border.RED1
}

class PaletteEntry:

	var register: int = 0 setget set_register

	var r1: bool = false setget set_r1
	var g1: bool = false setget set_g1
	var b1: bool = false setget set_b1
	var r0: bool = false setget set_r0
	var g0: bool = false setget set_g0
	var b0: bool = false setget set_b0

	var i1: bool setget set_r1, get_r1
	var i0: bool setget set_g1, get_g1
	var p3: bool setget set_b1, get_b1
	var p2: bool setget set_r0, get_r0
	var p1: bool setget set_g0, get_g0
	var p0: bool setget set_b0, get_b0

	var red: int setget set_red, get_red
	var green: int setget set_green, get_green
	var blue: int setget set_blue, get_blue

	var phase: int setget set_phase, get_phase
	var intensity: int setget set_intensity, get_intensity

	func _init(new_register: int = 0) -> void:
		self.register = new_register

	func set_register(new_register: int) -> void:
		self.red = new_register
		self.green = new_register
		self.blue = new_register

	func get_r1() -> bool:
		return r1

	func set_r1(new_r1: bool) -> void:
		r1 = new_r1
		_set_register_bit(new_r1, Palette.RED1)

	func get_red_1() -> bool:
		return r1

	func set_red_1(new_red_1: bool) -> void:
		self.r1 = new_red_1

	func get_r0() -> bool:
		return r0

	func set_r0(new_r0: bool) -> void:
		r0 = new_r0
		_set_register_bit(new_r0, Palette.RED0)

	func get_red_0() -> bool:
		return r0

	func set_red_0(new_red_0: bool) -> void:
		self.r0 = new_red_0

	func set_red(new_red: int):
		register = (register & (255 - (Palette.RED1 | Palette.RED0))) \
			| (new_red & (Palette.RED1 | Palette.RED0))
		r0 = register & Palette.RED0
		r1 = register & Palette.RED1

	func get_red() -> int:
		return register & (Palette.RED1 | Palette.RED0)

	func get_g1() -> bool:
		return g1

	func set_g1(new_g1: bool) -> void:
		g1 = new_g1
		_set_register_bit(new_g1, Palette.GREEN1)

	func get_green_1() -> bool:
		return g1

	func set_green_1(new_green_1: bool) -> void:
		self.g1 = new_green_1

	func get_g0() -> bool:
		return g0

	func set_g0(new_g0: bool) -> void:
		g0 = new_g0
		_set_register_bit(new_g0, Palette.GREEN0)

	func get_green_0() -> bool:
		return g0

	func set_green_0(new_green_0: bool) -> void:
		self.g0 = new_green_0

	func set_green(new_green: int):
		register = (register & (255 - (Palette.GREEN1 | Palette.GREEN0))) \
			| (new_green & (Palette.GREEN1 | Palette.GREEN0))
		g0 = register & Palette.GREEN0
		g1 = register & Palette.GREEN1

	func get_green() -> int:
		return register & (Palette.GREEN1 | Palette.GREEN0)

	func get_b1() -> bool:
		return b1

	func set_b1(new_b1: bool) -> void:
		b1 = new_b1
		_set_register_bit(new_b1, Palette.BLUE1)

	func get_blue_1() -> bool:
		return b1

	func set_blue_1(new_blue_1: bool) -> void:
		self.b1 = new_blue_1

	func get_b0() -> bool:
		return b0

	func set_b0(new_b0: bool) -> void:
		b0 = new_b0
		_set_register_bit(new_b0, Palette.BLUE0)

	func get_blue_0() -> bool:
		return b0

	func set_blue_0(new_blue_0: bool) -> void:
		self.b0 = new_blue_0

	func set_blue(new_blue: int):
		register = (register & (255 - (Palette.BLUE1 | Palette.BLUE0))) \
			| (new_blue & (Palette.BLUE1 | Palette.BLUE0))
		b0 = register & Palette.BLUE0
		b1 = register & Palette.BLUE1

	func get_blue() -> int:
		return register & (Palette.BLUE1 | Palette.BLUE0)

	func set_phase(new_phase: int) -> void:
		register = (register & (255 - 0x0F)) | (new_phase & 0x0F)
		b0 = register & Palette.BLUE0
		g0 = register & Palette.GREEN0
		r0 = register & Palette.RED0
		b1 = register & Palette.BLUE1

	func get_phase() -> int:
		return register & 0x0F

	func set_intensity(new_intensity: int) -> void:
		register = (register & (255 - 0x30)) | (new_intensity & 0x30)
		g1 = register & Palette.GREEN1
		r1 = register & Palette.RED1

	func get_intensity() -> int:
		return register & 0x30

	func _set_register_bit(value: bool, bit: int) -> void:
		if value:
			register |= bit
		else:
			register &= (255 - bit)


class ColorPalette:

	signal palette_entry_changed(index)

	var palette: Array

	func _init() -> void:
		palette = [
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new(),
			PaletteEntry.new()
		]

	func set_palette_entry(index: int, register: int) -> void:
		palette[index].register = register
		emit_signal('palette_entry_changed', index)

var color_palette: ColorPalette = ColorPalette.new()

# ALPHANUMERIC MODES
#
# Text screen memory:
#
#     Even Byte (Character byte)
#     --------------------------
#     BIT 7    -
#     BIT 6 = Character bit 6
#     BIT 5 = Character bit 5
#     BIT 4 = Character bit 4
#     BIT 3 = Character bit 3
#     BIT 2 = Character bit 2
#     BIT 1 = Character bit 1
#     BIT 0 = Character bit 0
#
#     Odd Byte (Attribute byte)
#     -------------------------
#     BIT 7 = BLINK       Characters blink at 1/2 sec. rate
#     BIT 6 = UNDLN       Characters are underline
#     BIT 5 = FGND2       Foreground color bit (palette addr.)
#     BIT 4 = FGND1       Foreground color bit (palette addr.)
#     BIT 3 = FGND0       Foreground color bit (palette addr.)
#     BIT 2 = BGND2       Background color bit (palette addr.)
#     BIT 1 = BGND1       Background color bit (palette addr.)
#     BIT 0 = BGND0       Background color bit (palette addr.)
#
# NOTE: Attributes are not available when CoCo = 1

enum Character {
	CHAR_BIT_0 = 0x01,
	CHAR_BIT_1 = 0x02,
	CHAR_BIT_2 = 0x04,
	CHAR_BIT_3 = 0x08,
	CHAR_BIT_4 = 0x10,
	CHAR_BIT_5 = 0x20,
	CHAR_BIT_6 = 0x40
}

class CharacterByte:

	var byte: int = 0 setget set_byte

	var char_bit_6: bool = false setget set_char_bit_6
	var char_bit_5: bool = false setget set_char_bit_5
	var char_bit_4: bool = false setget set_char_bit_4
	var char_bit_3: bool = false setget set_char_bit_3
	var char_bit_2: bool = false setget set_char_bit_2
	var char_bit_1: bool = false setget set_char_bit_1
	var char_bit_0: bool = false setget set_char_bit_0
	
	var char_bits: int setget set_char_bits, get_char_bits

	func _init(new_byte: int = 0) -> void:
		self.byte = new_byte

	func set_byte(new_byte: int) -> void:
		self.char_bits = new_byte

	func set_char_bit_6(new_char_bit_6: bool) -> void:
		char_bit_6 = new_char_bit_6
		_set_byte_bit(char_bit_6, Character.CHAR_BIT_6)

	func set_char_bit_5(new_char_bit_5: bool) -> void:
		char_bit_5 = new_char_bit_5
		_set_byte_bit(char_bit_5, Character.CHAR_BIT_5)

	func set_char_bit_4(new_char_bit_4: bool) -> void:
		char_bit_4 = new_char_bit_4
		_set_byte_bit(char_bit_4, Character.CHAR_BIT_4)

	func set_char_bit_3(new_char_bit_3: bool) -> void:
		char_bit_3 = new_char_bit_3
		_set_byte_bit(char_bit_3, Character.CHAR_BIT_3)

	func set_char_bit_2(new_char_bit_2: bool) -> void:
		char_bit_2 = new_char_bit_2
		_set_byte_bit(char_bit_2, Character.CHAR_BIT_2)

	func set_char_bit_1(new_char_bit_1: bool) -> void:
		char_bit_1 = new_char_bit_1
		_set_byte_bit(char_bit_1, Character.CHAR_BIT_1)

	func set_char_bit_0(new_char_bit_0: bool) -> void:
		char_bit_0 = new_char_bit_0
		_set_byte_bit(char_bit_0, Character.CHAR_BIT_0)

	func set_char_bits(new_char_bits: int) -> void:
		byte = (byte & (255 - 0x7F)) | (new_char_bits & 0x7F)
		char_bit_0 = byte & Character.CHAR_BIT_0
		char_bit_1 = byte & Character.CHAR_BIT_1
		char_bit_2 = byte & Character.CHAR_BIT_2
		char_bit_3 = byte & Character.CHAR_BIT_3
		char_bit_4 = byte & Character.CHAR_BIT_4
		char_bit_5 = byte & Character.CHAR_BIT_5
		char_bit_6 = byte & Character.CHAR_BIT_6

	func get_char_bits() -> int:
		return byte & 0x7F

	func _set_byte_bit(value: bool, bit: int) -> void:
		if value:
			byte |= bit
		else:
			byte &= (255 - bit)

enum Attribute {
	BGND0 = 0x01,
	BGND1 = 0x02,
	BGND2 = 0x04,
	FGND0 = 0x08,
	FGND1 = 0x10,
	FGND2 = 0x20,
	UNDERLINE = 0x40,
	BLINK = 0x80
}

class AttributeByte:

	var byte: int = 0 setget set_byte

	var blink: bool = false setget set_blink
	var underline: bool = false setget set_underline
	var foreground_2: bool = false setget set_foreground_2
	var foreground_1: bool = false setget set_foreground_1
	var foreground_0: bool = false setget set_foreground_0
	var background_2: bool = false setget set_background_2
	var background_1: bool = false setget set_background_1
	var background_0: bool = false setget set_background_0

	var foreground: int setget set_foreground, get_foreground
	var background: int setget set_background, get_background

	func _init(new_byte: int = 0) -> void:
		self.byte = new_byte

	func set_byte(new_byte: int) -> void:
		byte = new_byte
		refresh_blink()
		refresh_underline()
		self.foreground = byte
		self.background = byte

	func get_blink() -> bool:
		return blink

	func refresh_blink() -> void:
		blink = byte & Attribute.BLINK

	func set_blink(new_blink: bool) -> void:
		blink = new_blink
		_set_byte_bit(blink, Attribute.BLINK)

	func get_underline() -> bool:
		return underline

	func refresh_underline() -> void:
		underline = byte & Attribute.UNDERLINE

	func set_underline(new_underline: bool) -> void:
		underline = new_underline
		_set_byte_bit(underline, Attribute.UNDERLINE)

	func set_foreground_2(new_foreground_2: bool) -> void:
		foreground_2 = new_foreground_2
		_set_byte_bit(foreground_2, Attribute.FGND2)

	func set_foreground_1(new_foreground_1: bool) -> void:
		foreground_1 = new_foreground_1
		_set_byte_bit(foreground_1, Attribute.FGND1)

	func set_foreground_0(new_foreground_0: bool) -> void:
		foreground_0 = new_foreground_0
		_set_byte_bit(foreground_0, Attribute.FGND0)

	func set_background_2(new_background_2: bool) -> void:
		background_2 = new_background_2
		_set_byte_bit(background_2, Attribute.BGND2)

	func set_background_1(new_background_1: bool) -> void:
		background_1 = new_background_1
		_set_byte_bit(background_1, Attribute.BGND1)

	func set_background_0(new_background_0: bool) -> void:
		background_0 = new_background_0
		_set_byte_bit(background_0, Attribute.BGND0)

	func set_foreground(new_foreground: int) -> void:
		byte = (byte & (255 - (Attribute.FGND2 | Attribute.FGND1 | Attribute.FGND0))) \
			| (new_foreground & (Attribute.FGND2 | Attribute.FGND1 | Attribute.FGND0))
		foreground_2 = byte & Attribute.FGND2
		foreground_1 = byte & Attribute.FGND1
		foreground_0 = byte & Attribute.FGND0

	func get_foreground() -> int:
		return byte & (Attribute.FGND2 | Attribute.FGND1 | Attribute.FGND0)

	func set_background(new_background: int) -> void:
		byte = (byte & (255 - (Attribute.BGND2 | Attribute.BGND1 | Attribute.BGND0))) \
			| (new_background & (Attribute.BGND2 | Attribute.BGND1 | Attribute.BGND0))
		background_2 = byte & Attribute.BGND2
		background_1 = byte & Attribute.BGND1
		background_0 = byte & Attribute.BGND0

	func get_background() -> int:
		return byte & (Attribute.BGND2 | Attribute.BGND1 | Attribute.BGND0)

	func _set_byte_bit(value: bool, bit: int) -> void:
		if value:
			byte |= bit
		else:
			byte &= (255 - bit)

class Alphanumeric:

	# first byte
	var character_byte: CharacterByte
	# second byte
	var attribute_byte: AttributeByte

	# first byte = character
	# second byte = attribute
	func _init(new_bytes: int) -> void:
		character_byte.byte = (new_bytes >> 8) & 0xFF
		attribute_byte.byte = new_bytes & 0xFF

# GRAPHICS MODES
#
# 16 Color Modes: (CRES1 = 1, CRES0 = 0)
#     Byte from DRAM
#         Bit 7             PA3, First Pixel
#         Bit 6             PA2, First Pixel
#         Bit 5             PA1, First Pixel
#         Bit 4             PA0, First Pixel
#         Bit 3             PA3, Second Pixel
#         Bit 2             PA2, Second Pixel
#         Bit 1             PA1, Second Pixel
#         Bit 0             PA0, Second Pixel
#
# 4 Color Modes: (CRES1 = 0, CRES0 = 1)
#     Byte from DRAM
#         Bit 7             PA1, First Pixel
#         Bit 6             PA0, First Pixel
#         Bit 5             PA1, Second Pixel
#         Bit 4             PA0, Second Pixel
#         Bit 3             PA1, Third Pixel
#         Bit 2             PA0, Third Pixel
#         Bit 1             PA1, Fourth Pixel
#         Bit 0             PA0, Fourth Pixel
#
# 2 Color Modes: (CRES1 = 0, CRES0 = 0)
#     Byte from DRAM
#         Bit 7             PA0, First Pixel
#         Bit 6             PA0, Second Pixel
#         Bit 5             PA0, Third Pixel
#         Bit 4             PA0, Fourth Pixel
#         Bit 3             PA0, Fifth Pixel
#         Bit 2             PA0, Sixth Pixel
#         Bit 1             PA0, Seventh Pixel
#         Bit 0             PA0, Eighth Pixel
#
# Palette Addresses
#
# ---------------------------------------------------------
# | PA3 | PA2 | PA1 | PA0 | Address of Contents Displayed |
# ---------------------------------------------------------
# |  0  |  0  |  0  |  0  |             FFB0              |
# |  0  |  0  |  0  |  1  |             FFB1              |
# |  0  |  0  |  1  |  0  |             FFB2              |
# |  0  |  0  |  1  |  1  |             FFB3              |
# |  0  |  1  |  0  |  0  |             FFB4              |
# |  0  |  1  |  0  |  1  |             FFB5              |
# |  0  |  1  |  1  |  0  |             FFB6              |
# |  0  |  1  |  1  |  1  |             FFB7              |
# |  1  |  0  |  0  |  0  |             FFB8              |
# |  1  |  0  |  0  |  1  |             FFB9              |
# |  1  |  0  |  1  |  0  |             FFBA              |
# |  1  |  0  |  1  |  1  |             FFBB              |
# |  1  |  1  |  0  |  0  |             FFBC              |
# |  1  |  1  |  0  |  1  |             FFBD              |
# |  1  |  1  |  1  |  0  |             FFBE              |
# |  1  |  1  |  1  |  1  |             FFBF              |
# ---------------------------------------------------------

enum SixteenColors {
	PA0_2ND_PIXEL = 0x01,
	PA1_2ND_PIXEL = 0x02,
	PA2_2ND_PIXEL = 0x04,
	PA3_2ND_PIXEL = 0x08,
	PA0_1ST_PIXEL = 0x10,
	PA1_1ST_PIXEL = 0x20,
	PA2_1ST_PIXEL = 0x40,
	PA3_1ST_PIXEL = 0x80
}

class SixteenColorByte:

	var byte: int = 0 setget set_byte

	var pa3_1st_pixel: bool = false setget set_pa3_1st_pixel
	var pa2_1st_pixel: bool = false setget set_pa2_1st_pixel
	var pa1_1st_pixel: bool = false setget set_pa1_1st_pixel
	var pa0_1st_pixel: bool = false setget set_pa0_1st_pixel

	var pa3_2nd_pixel: bool = false setget set_pa3_2nd_pixel
	var pa2_2nd_pixel: bool = false setget set_pa2_2nd_pixel
	var pa1_2nd_pixel: bool = false setget set_pa1_2nd_pixel
	var pa0_2nd_pixel: bool = false setget set_pa0_2nd_pixel

	var pa_1st_pixel: int setget set_pa_1st_pixel, get_pa_1st_pixel # bits shifted
	var pa_2nd_pixel: int setget set_pa_2nd_pixel, get_pa_2nd_pixel

	func _init(new_byte: int = 0) -> void:
		self.byte = new_byte

	func set_byte(new_byte: int) -> void:
		self.pa_1st_pixel = new_byte >> 4
		self.pa_2nd_pixel = new_byte

	func set_pa3_1st_pixel(new_pa3_1st_pixel: bool) -> void:
		pa3_1st_pixel = new_pa3_1st_pixel
		_set_byte_bit(new_pa3_1st_pixel, SixteenColors.PA3_1ST_PIXEL)

	func set_pa2_1st_pixel(new_pa2_1st_pixel: bool) -> void:
		pa2_1st_pixel = new_pa2_1st_pixel
		_set_byte_bit(new_pa2_1st_pixel, SixteenColors.PA2_1ST_PIXEL)

	func set_pa1_1st_pixel(new_pa1_1st_pixel: bool) -> void:
		pa1_1st_pixel = new_pa1_1st_pixel
		_set_byte_bit(new_pa1_1st_pixel, SixteenColors.PA1_1ST_PIXEL)

	func set_pa0_1st_pixel(new_pa0_1st_pixel: bool) -> void:
		pa0_1st_pixel = new_pa0_1st_pixel
		_set_byte_bit(new_pa0_1st_pixel, SixteenColors.PA0_1ST_PIXEL)

	# bits shifted
	func set_pa_1st_pixel(new_1st_pixel: int) -> void:
		byte = (byte & (255 - 0xF0)) | ((new_1st_pixel << 4) & 0xF0)
		pa3_1st_pixel = byte & SixteenColors.PA3_1ST_PIXEL
		pa2_1st_pixel = byte & SixteenColors.PA2_1ST_PIXEL
		pa1_1st_pixel = byte & SixteenColors.PA1_1ST_PIXEL
		pa0_1st_pixel = byte & SixteenColors.PA0_1ST_PIXEL

	# bits shifted
	func get_pa_1st_pixel() -> int:
		return (byte >> 4) & 0x0F

	func set_pa3_2nd_pixel(new_pa3_2nd_pixel: bool) -> void:
		pa3_2nd_pixel = new_pa3_2nd_pixel
		_set_byte_bit(new_pa3_2nd_pixel, SixteenColors.PA3_2ND_PIXEL)

	func set_pa2_2nd_pixel(new_pa2_2nd_pixel: bool) -> void:
		pa2_2nd_pixel = new_pa2_2nd_pixel
		_set_byte_bit(new_pa2_2nd_pixel, SixteenColors.PA2_2ND_PIXEL)

	func set_pa1_2nd_pixel(new_pa1_2nd_pixel: bool) -> void:
		pa1_2nd_pixel = new_pa1_2nd_pixel
		_set_byte_bit(new_pa1_2nd_pixel, SixteenColors.PA1_2ND_PIXEL)

	func set_pa0_2nd_pixel(new_pa0_2nd_pixel: bool) -> void:
		pa0_2nd_pixel = new_pa0_2nd_pixel
		_set_byte_bit(new_pa0_2nd_pixel, SixteenColors.PA0_2ND_PIXEL)

	func set_pa_2nd_pixel(new_2nd_pixel: int) -> void:
		byte = (byte & (255 - 0x0F)) | (new_2nd_pixel & 0x0F)
		pa3_2nd_pixel = byte & SixteenColors.PA3_2ND_PIXEL
		pa2_2nd_pixel = byte & SixteenColors.PA2_2ND_PIXEL
		pa1_2nd_pixel = byte & SixteenColors.PA1_2ND_PIXEL
		pa0_2nd_pixel = byte & SixteenColors.PA0_2ND_PIXEL

	func get_pa_2nd_pixel() -> int:
		return byte & 0x0F

	func _set_byte_bit(value: bool, bit: int) -> void:
		if value:
			byte |= bit
		else:
			byte &= (255 - bit)

enum FourColors {
	PA0_4TH_PIXEL = 0x01,
	PA1_4TH_PIXEL = 0x02,
	PA0_3RD_PIXEL = 0x04,
	PA1_3RD_PIXEL = 0x08,
	PA0_2ND_PIXEL = 0x10,
	PA1_2ND_PIXEL = 0x20,
	PA0_1ST_PIXEL = 0x40,
	PA1_1ST_PIXEL = 0x80
}

class FourColorByte:

	var byte: int = 0 setget set_byte

	var pa1_1st_pixel: bool = false setget set_pa1_1st_pixel
	var pa0_1st_pixel: bool = false setget set_pa0_1st_pixel
	
	var pa1_2nd_pixel: bool = false setget set_pa1_2nd_pixel
	var pa0_2nd_pixel: bool = false setget set_pa0_2nd_pixel
	
	var pa1_3rd_pixel: bool = false setget set_pa1_3rd_pixel
	var pa0_3rd_pixel: bool = false setget set_pa0_3rd_pixel
	
	var pa1_4th_pixel: bool = false setget set_pa1_4th_pixel
	var pa0_4th_pixel: bool = false setget set_pa0_4th_pixel
	
	var pa_1st_pixel: int setget set_pa_1st_pixel, get_pa_1st_pixel # bits shifted
	var pa_2nd_pixel: int setget set_pa_2nd_pixel, get_pa_2nd_pixel # bits shifted
	var pa_3rd_pixel: int setget set_pa_3rd_pixel, get_pa_3rd_pixel # bits shifted
	var pa_4th_pixel: int setget set_pa_4th_pixel, get_pa_4th_pixel

	func _init(new_byte: int = 0) -> void:
		self.byte = new_byte

	func set_byte(new_byte: int) -> void:
		self.pa_1st_pixel = new_byte >> 6
		self.pa_2nd_pixel = new_byte >> 4
		self.pa_3rd_pixel = new_byte >> 2
		self.pa_4th_pixel = new_byte

	func set_pa1_1st_pixel(new_pa1_1st_pixel: bool) -> void:
		pa1_1st_pixel = new_pa1_1st_pixel
		_set_byte_bit(new_pa1_1st_pixel, FourColors.PA1_1ST_PIXEL)

	func set_pa0_1st_pixel(new_pa0_1st_pixel: bool) -> void:
		pa0_1st_pixel = new_pa0_1st_pixel
		_set_byte_bit(new_pa0_1st_pixel, FourColors.PA0_1ST_PIXEL)

	# bits shifted
	func set_pa_1st_pixel(new_pa_1st_pixel: int) -> void:
		byte = (byte & (255 - (FourColors.PA0_1ST_PIXEL | FourColors.PA1_1ST_PIXEL))) \
			| ((new_pa_1st_pixel << 6) & (FourColors.PA0_1ST_PIXEL | FourColors.PA1_1ST_PIXEL))
		pa1_1st_pixel = byte & FourColors.PA1_1ST_PIXEL
		pa0_1st_pixel = byte & FourColors.PA0_1ST_PIXEL

	# bits shifted
	func get_pa_1st_pixel() -> int:
		return (byte >> 6) & 0x03

	func set_pa1_2nd_pixel(new_pa1_2nd_pixel: bool) -> void:
		pa1_2nd_pixel = new_pa1_2nd_pixel
		_set_byte_bit(new_pa1_2nd_pixel, FourColors.PA1_2ND_PIXEL)

	func set_pa0_2nd_pixel(new_pa0_2nd_pixel: bool) -> void:
		pa0_2nd_pixel = new_pa0_2nd_pixel
		_set_byte_bit(new_pa0_2nd_pixel, FourColors.PA0_2ND_PIXEL)

	# bits shifted
	func set_pa_2nd_pixel(new_pa_2nd_pixel: int) -> void:
		byte = (byte & (255 - (FourColors.PA0_2ND_PIXEL | FourColors.PA1_2ND_PIXEL))) \
			| ((new_pa_2nd_pixel << 4) & (FourColors.PA0_2ND_PIXEL | FourColors.PA1_2ND_PIXEL))
		pa1_2nd_pixel = byte & FourColors.PA1_2ND_PIXEL
		pa0_2nd_pixel = byte & FourColors.PA0_2ND_PIXEL

	# bits shifted
	func get_pa_2nd_pixel() -> int:
		return (byte >> 4) & 0x03

	func set_pa1_3rd_pixel(new_pa1_3rd_pixel: bool) -> void:
		pa1_3rd_pixel = new_pa1_3rd_pixel
		_set_byte_bit(new_pa1_3rd_pixel, FourColors.PA1_3RD_PIXEL)

	func set_pa0_3rd_pixel(new_pa0_3rd_pixel: bool) -> void:
		pa0_3rd_pixel = new_pa0_3rd_pixel
		_set_byte_bit(new_pa0_3rd_pixel, FourColors.PA0_3RD_PIXEL)

	# bits shifted
	func set_pa_3rd_pixel(new_pa_3rd_pixel: int) -> void:
		byte = (byte & (255 - (FourColors.PA0_3RD_PIXEL | FourColors.PA1_3RD_PIXEL))) \
			| ((new_pa_3rd_pixel << 2) & (FourColors.PA0_3RD_PIXEL | FourColors.PA1_3RD_PIXEL))
		pa1_3rd_pixel = byte & FourColors.PA1_3RD_PIXEL
		pa0_3rd_pixel = byte & FourColors.PA0_3RD_PIXEL

	# bits shifted
	func get_pa_3rd_pixel() -> int:
		return (byte >> 2) & 0x03

	func set_pa1_4th_pixel(new_pa1_4th_pixel: bool) -> void:
		pa1_4th_pixel = new_pa1_4th_pixel
		_set_byte_bit(new_pa1_4th_pixel, FourColors.PA1_4TH_PIXEL)

	func set_pa0_4th_pixel(new_pa0_4th_pixel: bool) -> void:
		pa0_4th_pixel = new_pa0_4th_pixel
		_set_byte_bit(new_pa0_4th_pixel, FourColors.PA0_4TH_PIXEL)

	func set_pa_4th_pixel(new_pa_4th_pixel: int) -> void:
		byte = (byte & (255 - (FourColors.PA0_4TH_PIXEL | FourColors.PA1_4TH_PIXEL))) \
			| (new_pa_4th_pixel & (FourColors.PA0_4TH_PIXEL | FourColors.PA1_4TH_PIXEL))
		pa1_4th_pixel = byte & FourColors.PA1_4TH_PIXEL
		pa0_4th_pixel = byte & FourColors.PA0_4TH_PIXEL

	func get_pa_4th_pixel() -> int:
		return byte & 0x03

	func _set_byte_bit(value: bool, bit: int) -> void:
		if value:
			byte |= bit
		else:
			byte &= (255 - bit)

enum TwoColors {
	PA0_8TH_PIXEL = 0x01,
	PA0_7TH_PIXEL = 0x02,
	PA0_6TH_PIXEL = 0x04,
	PA0_5TH_PIXEL = 0x08,
	PA0_4TH_PIXEL = 0x10,
	PA0_3RD_PIXEL = 0x20,
	PA0_2ND_PIXEL = 0x40,
	PA0_1ST_PIXEL = 0x80
}

class TwoColorByte:

	var byte: int = 0 setget set_byte

	var pa0_1st_pixel: bool = false setget set_pa0_1st_pixel
	var pa0_2nd_pixel: bool = false setget set_pa0_2nd_pixel
	var pa0_3rd_pixel: bool = false setget set_pa0_3rd_pixel
	var pa0_4th_pixel: bool = false setget set_pa0_4th_pixel
	var pa0_5th_pixel: bool = false setget set_pa0_5th_pixel
	var pa0_6th_pixel: bool = false setget set_pa0_6th_pixel
	var pa0_7th_pixel: bool = false setget set_pa0_7th_pixel
	var pa0_8th_pixel: bool = false setget set_pa0_8th_pixel

	func _init(new_byte: int = 0) -> void:
		self.byte = new_byte

	func set_byte(new_byte: int) -> void:
		byte = new_byte
		refresh_pa0_1st_pixel()
		refresh_pa0_2nd_pixel()
		refresh_pa0_3rd_pixel()
		refresh_pa0_4th_pixel()
		refresh_pa0_5th_pixel()
		refresh_pa0_6th_pixel()
		refresh_pa0_7th_pixel()
		refresh_pa0_8th_pixel()
		
	func get_pa0_1st_pixel() -> bool:
		return pa0_1st_pixel

	func refresh_pa0_1st_pixel() -> void:
		pa0_1st_pixel = byte & TwoColors.PA0_1ST_PIXEL

	func set_pa0_1st_pixel(new_pa0_1st_pixel: bool) -> void:
		pa0_1st_pixel = new_pa0_1st_pixel
		_set_byte_bit(new_pa0_1st_pixel, TwoColors.PA0_1ST_PIXEL)

	func get_pa0_2nd_pixel() -> bool:
		return pa0_2nd_pixel

	func refresh_pa0_2nd_pixel() -> void:
		pa0_2nd_pixel = byte & TwoColors.PA0_2ND_PIXEL

	func set_pa0_2nd_pixel(new_pa0_2nd_pixel: bool) -> void:
		pa0_2nd_pixel = new_pa0_2nd_pixel
		_set_byte_bit(new_pa0_2nd_pixel, TwoColors.PA0_2ND_PIXEL)

	func get_pa0_3rd_pixel() -> bool:
		return pa0_3rd_pixel

	func refresh_pa0_3rd_pixel() -> void:
		pa0_3rd_pixel = byte & TwoColors.PA0_3RD_PIXEL

	func set_pa0_3rd_pixel(new_pa0_3rd_pixel: bool) -> void:
		pa0_3rd_pixel = new_pa0_3rd_pixel
		_set_byte_bit(new_pa0_3rd_pixel, TwoColors.PA0_3RD_PIXEL)

	func get_pa0_4th_pixel() -> bool:
		return pa0_4th_pixel

	func refresh_pa0_4th_pixel() -> void:
		pa0_4th_pixel = byte & TwoColors.PA0_4TH_PIXEL

	func set_pa0_4th_pixel(new_pa0_4th_pixel: bool) -> void:
		pa0_4th_pixel = new_pa0_4th_pixel
		_set_byte_bit(new_pa0_4th_pixel, TwoColors.PA0_4TH_PIXEL)

	func get_pa0_5th_pixel() -> bool:
		return pa0_5th_pixel

	func refresh_pa0_5th_pixel() -> void:
		pa0_5th_pixel = byte & TwoColors.PA0_5TH_PIXEL

	func set_pa0_5th_pixel(new_pa0_5th_pixel: bool) -> void:
		pa0_5th_pixel = new_pa0_5th_pixel
		_set_byte_bit(new_pa0_5th_pixel, TwoColors.PA0_5TH_PIXEL)

	func get_pa0_6th_pixel() -> bool:
		return pa0_6th_pixel

	func refresh_pa0_6th_pixel() -> void:
		pa0_6th_pixel = byte & TwoColors.PA0_6TH_PIXEL

	func set_pa0_6th_pixel(new_pa0_6th_pixel: bool) -> void:
		pa0_6th_pixel = new_pa0_6th_pixel
		_set_byte_bit(new_pa0_6th_pixel, TwoColors.PA0_6TH_PIXEL)

	func get_pa0_7th_pixel() -> bool:
		return pa0_7th_pixel

	func refresh_pa0_7th_pixel() -> void:
		pa0_7th_pixel = byte & TwoColors.PA0_7TH_PIXEL

	func set_pa0_7th_pixel(new_pa0_7th_pixel: bool) -> void:
		pa0_7th_pixel = new_pa0_7th_pixel
		_set_byte_bit(new_pa0_7th_pixel, TwoColors.PA0_7TH_PIXEL)

	func get_pa0_8th_pixel() -> bool:
		return pa0_8th_pixel

	func refresh_pa0_8th_pixel() -> void:
		pa0_8th_pixel = byte & TwoColors.PA0_8TH_PIXEL

	func set_pa0_8th_pixel(new_pa0_8th_pixel: bool) -> void:
		pa0_8th_pixel = new_pa0_8th_pixel
		_set_byte_bit(new_pa0_8th_pixel, TwoColors.PA0_8TH_PIXEL)

	func _set_byte_bit(value: bool, bit: int) -> void:
		if value:
			byte |= bit
		else:
			byte &= (255 - bit)

# SAM CONTROL REGISTERS:    (FFC0 - FFDF)
#
# Clear    Set
# FFC0  -  FFC1   V0   CoCo graphics mode select
# FFC2  -  FFC3   V1   CoCo graphics mode select
# FFC4  -  FFC5   V2   CoCo graphics mode select
# FFC6  -  FFC7   F0   CoCo Vertical offset
# FFC8  -  FFC9   F1   CoCo Vertical offset
# FFCA  -  FFCB   F2   CoCo Vertical offset
# FFCC  -  FFCD   F3   CoCo Vertical offset
# FFCE  -  FFCF   F4   CoCo Vertical offset
# FFD0  -  FFD1   F5   CoCo Vertical offset
# FFD2  -  FFD3   F6   CoCo Vertical offset
# FFD8  -  FFD9   R1   MPU Speed
# FFDE  -  FFDF   TY   ROM disable
#
# NOTE: These bits work like the ones in the Motorola SAM chip (MC6883/SN74LS785) in that by
#       writing to the upper address of each two-address group (data is don't care), the bit is
#       set; by writing to the lower address, the bit is cleared. The graphics modes and vertical
#       offset bits are valid only in the CoCo mode, but the other two bits are valid anytime. Note
#       the only semigraphics mode supported is Semi Four
#
# ----------------------------
# | FFDF |  S  |      | MAP  |
# --------------  TY  | TYPE |
# | FFDE |  C  |      |      |
# ---------------------------------------------------
# | FFD9 |  S  |      | CPU  |          |     |     |
# --------------  R1  | Rate |          |  1  |  0  |
# | FFD8 |  C  |      |      |          |     |     |
# ---------------------------------------------------
# | FFD3 |  S  |      |          |\        |     |
# --------------  F6  |          |  \      |     0.89 MHz
# | FFD2 |  C  |      |          |  |      |
# ---------------------          |  |      1.78 MHz
# | FFD1 |  S  |      |          |  |
# --------------  F5  |          |  |
# | FFD0 |  C  |      |          |  |
# ---------------------          |  |
# | FFCF |  S  |      |          |  |
# --------------  F4  | DISPLAY  |  |- Address of Upper-Left-Most
# | FFCE |  C  |      | OFFSET   |  |  Display Element = 0000 + (1/2K Offset)
# ---------------------          |  |
# | FFCD |  S  |      |          |  |     N.U.
# --------------  F3  |          |  |        |     RG6, CG6
# | FFCC |  C  |      |          |  |        |     |
# --------------------- (BINARY) |  |        |     |     RG3
# | FFCB |  S  |      |          |  |        |     |     |
# --------------  F2  |          |  |        |     |     |     CG3
# | FFCA |  C  |      |          |  /        |     |     |     |
# ---------------------          |/          |     |     |     |     RG2
# | FFC9 |  S  |      |          |           |     |     |     |     |
# --------------  F1  |          |           |     |     |     |     |     CG2
# | FFC8 |  C  |      |          |           |     |     |     |     |     |
# ---------------------          |           |     |     |     |     |     |     CG1, RG1
# | FFC7 |  S  |      |          |           |     |     |     |     |     |     |
# --------------  F0  |          |           |     |     |     |     |     |     |     AI, AE, S4
# | FFC6 |  C  |      |          |           |     |     |     |     |     |     |     |
# -----------------------------------------------------------------------------------------
# | FFC5 |  S  |      |          |        |     |     |     |     |     |     |     |     |
# --------------  V2  | DISPLAY  |        |  1  |  1  |  1  |  1  |  0  |  0  |  0  |  0  |
# | FFC4 |  C  |      |  MODE    |        |     |     |     |     |     |     |     |     |
# --------------------- CONTROL  ----------------------------------------------------------
# | FFC3 |  S  |      |          |        |     |     |     |     |     |     |     |     |
# --------------  V1  |          |        |  1  |  1  |  0  |  0  |  1  |  1  |  0  |  0  |
# | FFC2 |  C  |      |  (SAM)   |        |     |     |     |     |     |     |     |     |
# ---------------------          ----------------------------------------------------------
# | FFC1 |  S  |      |          |        |     |     |     |     |     |     |     |     |
# --------------  V0  |          |        |  1  |  0  |  1  |  0  |  1  |  0  |  1  |  0  |
# | FFC0 |  C  |      |          |        |     |     |     |     |     |     |     |     |
# -----------------------------------------------------------------------------------------
#
# (S = Set Bit, C = Clear Bit, all Bits are cleared when SAM is reset)
#
# Figure 1-3. Memory Map for SAM Control Register

enum DisplayOffset {
	F0 = 0x01,
	F1 = 0x02,
	F2 = 0x04,
	F3 = 0x08,
	F4 = 0x10,
	F5 = 0x20,
	F6 = 0x40
}

enum DisplayModeControl {
	V0 = 0x01,
	V1 = 0x02,
	V2 = 0x04
}

class SamControlRegisters:

	signal map_type_toggled(current)
	signal cpu_rate_toggled(current)

	signal f6_toggled(current)
	signal f5_toggled(current)
	signal f4_toggled(current)
	signal f3_toggled(current)
	signal f2_toggled(current)
	signal f1_toggled(current)
	signal f0_toggled(current)
	signal display_offset_set(current)

	signal v2_toggled(current)
	signal v1_toggled(current)
	signal v0_toggled(current)
	signal display_mode_control_set(current)

	var ty: bool = false setget set_ty
	var map_type: bool setget set_map_type, get_map_type

	var r1: bool = false setget set_r1
	var cpu_rate: bool setget set_cpu_rate, get_cpu_rate

	var display_offset: int = 0 setget set_display_offset
	var f6: bool = false setget set_f6
	var f5: bool = false setget set_f5
	var f4: bool = false setget set_f4
	var f3: bool = false setget set_f3
	var f2: bool = false setget set_f2
	var f1: bool = false setget set_f1
	var f0: bool = false setget set_f0

	var display_mode_control: int = 0 setget set_display_mode_control
	var v2: bool = false setget set_v2
	var v1: bool = false setget set_v1
	var v0: bool = false setget set_v0

	func set_ty(new_ty: bool) -> void:
		var old_ty := ty
		ty = new_ty
		if (old_ty != new_ty):
			emit_signal('map_type_toggled', ty)

	func set_map_type(new_map_type: bool) -> void:
		self.ty = new_map_type

	func get_map_type() -> bool:
		return ty

	func set_r1(new_r1: bool) -> void:
		var old_r1 := r1
		r1 = new_r1
		if (old_r1 != new_r1):
			emit_signal('cpu_rate_toggled', ty)

	func set_cpu_rate(new_cpu_rate: bool) -> void:
		r1 = new_cpu_rate

	func get_cpu_rate() -> bool:
		return r1

	func set_display_offset(new_display_offset: int) -> void:
		display_offset = new_display_offset & 0x7F
		var _signal := set_f6(new_display_offset & DisplayOffset.F6, true)
		_signal = set_f5(new_display_offset & DisplayOffset.F5, true) or _signal
		_signal = set_f4(new_display_offset & DisplayOffset.F4, true) or _signal
		_signal = set_f3(new_display_offset & DisplayOffset.F3, true) or _signal
		_signal = set_f2(new_display_offset & DisplayOffset.F2, true) or _signal
		_signal = set_f1(new_display_offset & DisplayOffset.F1, true) or _signal
		_signal = set_f0(new_display_offset & DisplayOffset.F0, true) or _signal
		if _signal:
			emit_signal('display_offset_set', display_offset)

	func set_f6(new_f6: bool, delay_signals: bool = false) -> bool:
		var old_f6 := f6
		f6 = new_f6
		_set_display_offset_bit(new_f6, DisplayOffset.F6)
		if old_f6 != new_f6:
			emit_signal('f6_toggled', new_f6)
			if not delay_signals:
				emit_signal('display_offset_set', display_offset)
			return true
		return false

	func set_f5(new_f5: bool, delay_signals: bool = false) -> bool:
		var old_f5 := f5
		f5 = new_f5
		_set_display_offset_bit(new_f5, DisplayOffset.F5)
		if old_f5 != new_f5:
			emit_signal('f5_toggled', new_f5)
			if not delay_signals:
				emit_signal('display_offset_set', display_offset)
			return true
		return false

	func set_f4(new_f4: bool, delay_signals: bool = false) -> bool:
		var old_f4 := f4
		f4 = new_f4
		_set_display_offset_bit(f4, DisplayOffset.F4)
		if old_f4 != new_f4:
			emit_signal('f4_toggled', new_f4)
			if not delay_signals:
				emit_signal('display_offset_set', display_offset)
			return true
		return false

	func set_f3(new_f3: bool, delay_signals: bool = false) -> bool:
		var old_f3 := f3
		f3 = new_f3
		_set_display_offset_bit(f3, DisplayOffset.F3)
		if old_f3 != new_f3:
			emit_signal('f3_toggled', new_f3)
			if not delay_signals:
				emit_signal('display_offset_set', display_offset)
			return true
		return false

	func set_f2(new_f2: bool, delay_signals: bool = false) -> bool:
		var old_f2 := f2
		f2 = new_f2
		_set_display_offset_bit(f2, DisplayOffset.F2)
		if old_f2 != new_f2:
			emit_signal('f2_toggled', new_f2)
			if not delay_signals:
				emit_signal('display_offset_set', display_offset)
			return true
		return false

	func set_f1(new_f1: bool, delay_signals: bool = false) -> bool:
		var old_f1 := f1
		f1 = new_f1
		_set_display_offset_bit(f1, DisplayOffset.F1)
		if old_f1 != new_f1:
			emit_signal('f1_toggled', new_f1)
			if not delay_signals:
				emit_signal('display_offset_set', display_offset)
			return true
		return false

	func set_f0(new_f0: bool, delay_signals: bool = false) -> bool:
		var old_f0 := f0
		f0 = new_f0
		_set_display_offset_bit(f0, DisplayOffset.F0)
		if old_f0 != new_f0:
			emit_signal('f0_toggled', new_f0)
			if not delay_signals:
				emit_signal('display_offset_set', display_offset)
			return true
		return false

	func _set_display_offset_bit(value: bool, bit: int) -> void:
		if value:
			display_offset |= bit
		else:
			display_offset &= (255 - bit)

	func set_display_mode_control(new_display_mode_control: int) -> void:
		display_mode_control = new_display_mode_control & 0x07
		var _signal := set_v2(new_display_mode_control & DisplayModeControl.V2, true)
		_signal = set_v1(new_display_mode_control & DisplayModeControl.V1, true) or _signal
		_signal = set_v0(new_display_mode_control & DisplayModeControl.V0, true) or _signal
		if _signal:
			emit_signal('display_mode_control_set', display_mode_control)

	func set_v2(new_v2: bool, delay_signals: bool = false) -> bool:
		var old_v2 := v2
		v2 = new_v2
		_set_display_mode_control_bit(new_v2, DisplayModeControl.V2)
		if old_v2 != v2:
			emit_signal('v2_toggled', v2)
			if not delay_signals:
				emit_signal('display_mode_control_set', display_mode_control)
			return true
		return false

	func set_v1(new_v1: bool, delay_signals: bool = false) -> bool:
		var old_v1 := v1
		v1 = new_v1
		_set_display_mode_control_bit(new_v1, DisplayModeControl.V1)
		if old_v1 != v1:
			emit_signal('v1_toggled', v1)
			if not delay_signals:
				emit_signal('display_mode_control_set', display_mode_control)
			return true
		return false

	func set_v0(new_v0: bool, delay_signals: bool = false) -> bool:
		var old_v0 := v0
		v0 = new_v0
		_set_display_mode_control_bit(new_v0, DisplayModeControl.V0)
		if old_v0 != v0:
			emit_signal('v0_toggled', v0)
			if not delay_signals:
				emit_signal('display_mode_control_set', display_mode_control)
			return true
		return false

	func _set_display_mode_control_bit(value: bool, bit: int) -> void:
		if value:
			display_mode_control |= bit
		else:
			display_mode_control &= (255 - bit)

var sam_control_register: SamControlRegisters = SamControlRegisters.new()

# 1.6 68B09E Vector Registers
#
# ---------------------------
# | FFE0 - FFFF | CPU | IC1 |
# ---------------------------
#
#     FFFF: Reset vector LS
#     FFFE: Reset vector MS
#     FFFD: NMI vector LS
#     FFFC: NMI vector MS
#     FFFB: SWI1 vector LS
#     FFFA: SWI1 vector MS
#     FFF9: IRQ vector LS
#     FFF8: IRQ vector MS
#     FFF7: FIRQ vector LS
#     FFF6: FIRQ vector MS
#     FFF5: SWI2 vecor LS
#     FFF4: SWI2 vector MS
#     FFF3: SWI3 vector LS
#     FFF2: SWI3 vector MS
#     FFF1: Reserved
#     FFF0: Reserved
#     FFEF - FFE0: Not used
#
#     LS: Least significant address byte
#     MS: Most significant address byte

enum ControlChipRegisters {
	INITIALIZATION_0 = 0x90,
	INITIALIZERION_1,
	INTERRUPT_REQUEST_ENABLE,
	FAST_INTERRUPT_REQUEST_ENABLE,
	TIMER_MOST_SIGNIFICANT_NIBBLE,
	TIMER_LEAST_SIGNIFICANT_BYTE,
	VIDEO_MODE = 0x98,
	VIDEO_RESOLUTION,
	BORDER,
	VERTICAL_SCROLL = 0x9C,
	VERTICAL_OFFSET_1,
	VERTICAL_OFFSET_0,
	HORIZONTAL_OFFSET_0,
	MMU_LOCATION_0 = 0xA0,
	MMU_LOCATION_1,
	MMU_LOCATION_2,
	MMU_LOCAITON_3,
	MMU_LOCATION_4,
	MMU_LOCATION_5,
	MMU_LOCATION_6,
	MMU_LOCATION_7,
	MMU_LOCAITON_8,
	MMU_LOCATION_9,
	MMU_LOCATION_10,
	MMU_LOCATION_11,
	MMU_LOCATION_12,
	MMU_LOCATION_13,
	MMU_LOCATION_14,
	MMU_LOCATION_15,
	PALETTE_0 = 0xB0,
	PALETTE_1
	PALETTE_2
	PALETTE_3
	PALETTE_4
	PALETTE_5
	PALETTE_6
	PALETTE_7
	PALETTE_8
	PALETTE_9
	PALETTE_10
	PALETTE_11
	PALETTE_12
	PALETTE_13
	PALETTE_14
	PALETTE_15
	SAM_COCO_GRAPHICS_MODE_SELECT_V0_SET = 0xC0,
	SAM_COCO_GRAPHICS_MODE_SELECT_V0_CLEAR,
	SAM_COCO_GRAPHICS_MODE_SELECT_V1_SET,
	SAM_COCO_GRAPHICS_MODE_SELECT_V1_CLEAR,
	SAM_COCO_GRAPHICS_MODE_SELECT_V2_SET,
	SAM_COCO_GRAPHICS_MODE_SELECT_V2_CLEAR,
	SAM_COCO_VERTICAL_OFFSET_F0_SET,
	SAM_COCO_VERTICAL_OFFSET_F0_CLEAR,
	SAM_COCO_VERTICAL_OFFSET_F1_SET,
	SAM_COCO_VERTICAL_OFFSET_F1_CLEAR,
	SAM_COCO_VERTICAL_OFFSET_F2_SET,
	SAM_COCO_VERTICAL_OFFSET_F2_CLEAR,
	SAM_COCO_VERTICAL_OFFSET_F3_SET,
	SAM_COCO_VERTICAL_OFFSET_F3_CLEAR,
	SAM_COCO_VERTICAL_OFFSET_F4_SET,
	SAM_COCO_VERTICAL_OFFSET_F4_CLEAR,
	SAM_COCO_VERTICAL_OFFSET_F5_SET,
	SAM_COCO_VERTICAL_OFFSET_F5_CLEAR,
	SAM_COCO_VERTICAL_OFFSET_F6_SET,
	SAM_COCO_VERTICAL_OFFSET_F6_CLEAR,
	SAM_MPU_SPEED_SET,
	SAM_MPU_SPEED_CLEAR,
	SAM_ROM_DISABLE_SET,
	SAM_ROM_DISABLE_CLEAR
}

class ControlRegisters:

	var register_space: Array
	var tcc1014

	func _init(new_tcc1014) -> void:
		register_space.resize(256)
		tcc1014 = new_tcc1014

	func read(address) -> int:
		address &= 0xFF

		match address:
			ControlChipRegisters.INITIALIZATION_0:
				return tcc1014.init0.register

			ControlChipRegisters.INITIALIZATION_1:
				return tcc1014.init1.register

			ControlChipRegisters.INTERRUPT_REQUEST_ENABLE:
				var register: int = tcc1014.irqenr.register
				tcc1014.irqenr.register = 0
				return register

			ControlChipRegisters.FAST_INTERRUPT_REQUEST_ENABLE:
				var register: int = tcc1014.firqenr.register
				tcc1014.firqenr.register = 0
				return register

			ControlChipRegisters.TIMER_MOST_SIGNIFICANT_NIBBLE:
				return tcc1014.timer.most_significant_nibble

			ControlChipRegisters.TIMER_LEAST_SIGNIFICANT_BYTE:
				return tcc1014.timer.least_significant_byte

			ControlChipRegisters.VIDEO_MODE:
				return tcc1014.video_mode_register.register

			ControlChipRegisters.VIDEO_RESOLUTION:
				return tcc1014.video_resolution_register.register

			ControlChipRegisters.BORDER:
				return tcc1014.border_register.register

			ControlChipRegisters.VERTICAL_SCROLL:
				return tcc1014.vertical_scroll_register.register

			ControlChipRegisters.VERTICAL_OFFSET_1:
				return tcc1014.vertical_offset_1.register

			ControlChipRegisters.VERTICAL_OFFSET_0:
				return tcc1014.vertical_offset_0.register

			ControlChipRegisters.HORIZONTAL_OFFSET_0:
				return tcc1014.horizontal_offset.register

			ControlChipRegisters.MMU_LOCATION_0:
				return tcc1014.executive_set.par[0]

			ControlChipRegisters.MMU_LOCATION_1:
				return tcc1014.executive_set.par[1]

			ControlChipRegisters.MMU_LOCATION_2:
				return tcc1014.executive_set.par[2]

			ControlChipRegisters.MMU_LOCATION_3:
				return tcc1014.executive_set.par[3]

			ControlChipRegisters.MMU_LOCATION_4:
				return tcc1014.executive_set.par[4]

			ControlChipRegisters.MMU_LOCATION_5:
				return tcc1014.executive_set.par[5]

			ControlChipRegisters.MMU_LOCATION_6:
				return tcc1014.executive_set.par[6]

			ControlChipRegisters.MMU_LOCATION_7:
				return tcc1014.executive_set.par[7]

			ControlChipRegisters.MMU_LOCATION_8:
				return tcc1014.task_set.par[0]

			ControlChipRegisters.MMU_LOCATION_9:
				return tcc1014.task_set.par[1]

			ControlChipRegisters.MMU_LOCATION_10:
				return tcc1014.task_set.par[2]

			ControlChipRegisters.MMU_LOCATION_11:
				return tcc1014.task_set.par[3]

			ControlChipRegisters.MMU_LOCATION_12:
				return tcc1014.task_set.par[4]

			ControlChipRegisters.MMU_LOCATION_13:
				return tcc1014.task_set.par[5]

			ControlChipRegisters.MMU_LOCATION_14:
				return tcc1014.task_set.par[6]

			ControlChipRegisters.MMU_LOCATION_15:
				return tcc1014.task_set.par[7]

			ControlChipRegisters.PALETTE_0:
				return tcc1014.color_palette.palette[0].register

			ControlChipRegisters.PALETTE_1:
				return tcc1014.color_palette.palette[1].register

			ControlChipRegisters.PALETTE_2:
				return tcc1014.color_palette.palette[2].register

			ControlChipRegisters.PALETTE_3:
				return tcc1014.color_palette.palette[3].register

			ControlChipRegisters.PALETTE_4:
				return tcc1014.color_palette.palette[4].register

			ControlChipRegisters.PALETTE_5:
				return tcc1014.color_palette.palette[5].register

			ControlChipRegisters.PALETTE_6:
				return tcc1014.color_palette.palette[6].register

			ControlChipRegisters.PALETTE_7:
				return tcc1014.color_palette.palette[7].register

			ControlChipRegisters.PALETTE_8:
				return tcc1014.color_palette.palette[8].register

			ControlChipRegisters.PALETTE_9:
				return tcc1014.color_palette.palette[9].register

			ControlChipRegisters.PALETTE_10:
				return tcc1014.color_palette.palette[10].register

			ControlChipRegisters.PALETTE_11:
				return tcc1014.color_palette.palette[11].register

			ControlChipRegisters.PALETTE_12:
				return tcc1014.color_palette.palette[12].register

			ControlChipRegisters.PALETTE_13:
				return tcc1014.color_palette.palette[13].register

			ControlChipRegisters.PALETTE_14:
				return tcc1014.color_palette.palette[14].register

			ControlChipRegisters.PALETTE_15:
				return tcc1014.color_palette.palette[15].register

			_:
				return register_space[address]

	func write(address, data) -> void:
		address &= 0xFF

		match address:
			ControlChipRegisters.INITIALIZATION_0:
				tcc1014.init0.register = data

			ControlChipRegisters.INITIALIZATION_1:
				tcc1014.init1.register = data

			ControlChipRegisters.INTERRUPT_REQUEST_ENABLE:
				tcc1014.irqenr.register = data

			ControlChipRegisters.FAST_INTERRUPT_REQUEST_ENABLE:
				tcc1014.firqenr.register = data

			ControlChipRegisters.TIMER_MOST_SIGNIFICANT_NIBBLE:
				tcc1014.timer.most_significant_nibble = data

			ControlChipRegisters.TIMER_LEAST_SIGNIFICANT_BYTE:
				tcc1014.timer.least_significant_byte = data

			ControlChipRegisters.VIDEO_MODE:
				tcc1014.video_mode_register.register = data

			ControlChipRegisters.VIDEO_RESOLUTION:
				tcc1014.video_resolution_register.register = data

			ControlChipRegisters.BORDER:
				tcc1014.border_register.register = data

			ControlChipRegisters.VERTICAL_SCROLL:
				tcc1014.vertical_scroll_register.register = data

			ControlChipRegisters.VERTICAL_OFFSET_1:
				tcc1014.vertical_offset_1.register = data

			ControlChipRegisters.VERTICAL_OFFSET_0:
				tcc1014.vertical_offset_0.register = data

			ControlChipRegisters.HORIZONTAL_OFFSET_0:
				tcc1014.horizontal_offset.register = data

			ControlChipRegisters.MMU_LOCATION_0:
				tcc1014.executive_set.set_par(0, data)

			ControlChipRegisters.MMU_LOCATION_1:
				tcc1014.executive_set.set_par(1, data)

			ControlChipRegisters.MMU_LOCATION_2:
				tcc1014.executive_set.set_par(2, data)

			ControlChipRegisters.MMU_LOCATION_3:
				tcc1014.executive_set.set_par(3, data)

			ControlChipRegisters.MMU_LOCATION_4:
				tcc1014.executive_set.set_par(4, data)

			ControlChipRegisters.MMU_LOCATION_5:
				tcc1014.executive_set.set_par(5, data)

			ControlChipRegisters.MMU_LOCATION_6:
				tcc1014.executive_set.set_par(6, data)

			ControlChipRegisters.MMU_LOCATION_7:
				tcc1014.executive_set.set_par(7, data)

			ControlChipRegisters.MMU_LOCATION_8:
				tcc1014.task_set.set_par(0, data)

			ControlChipRegisters.MMU_LOCATION_9:
				tcc1014.task_set.set_par(1, data)

			ControlChipRegisters.MMU_LOCATION_10:
				tcc1014.task_set.set_par(2, data)

			ControlChipRegisters.MMU_LOCATION_11:
				tcc1014.task_set.set_par(3, data)

			ControlChipRegisters.MMU_LOCATION_12:
				tcc1014.task_set.set_par(4, data)

			ControlChipRegisters.MMU_LOCATION_13:
				tcc1014.task_set.set_par(5, data)

			ControlChipRegisters.MMU_LOCATION_14:
				tcc1014.task_set.set_par(6, data)

			ControlChipRegisters.MMU_LOCATION_15:
				tcc1014.task_set.set_par(7, data)

			ControlChipRegisters.PALETTE_0:
				tcc1014.color_palette.set_palette_entry(0, data)

			ControlChipRegisters.PALETTE_1:
				tcc1014.color_palette.set_palette_entry(1, data)

			ControlChipRegisters.PALETTE_2:
				tcc1014.color_palette.set_palette_entry(2, data)

			ControlChipRegisters.PALETTE_3:
				tcc1014.color_palette.set_palette_entry(3, data)

			ControlChipRegisters.PALETTE_4:
				tcc1014.color_palette.set_palette_entry(4, data)

			ControlChipRegisters.PALETTE_5:
				tcc1014.color_palette.set_palette_entry(5, data)

			ControlChipRegisters.PALETTE_6:
				tcc1014.color_palette.set_palette_entry(6, data)

			ControlChipRegisters.PALETTE_7:
				tcc1014.color_palette.set_palette_entry(7, data)

			ControlChipRegisters.PALETTE_8:
				tcc1014.color_palette.set_palette_entry(8, data)

			ControlChipRegisters.PALETTE_9:
				tcc1014.color_palette.set_palette_entry(9, data)

			ControlChipRegisters.PALETTE_10:
				tcc1014.color_palette.set_palette_entry(10, data)

			ControlChipRegisters.PALETTE_11:
				tcc1014.color_palette.set_palette_entry(11, data)

			ControlChipRegisters.PALETTE_12:
				tcc1014.color_palette.set_palette_entry(12, data)

			ControlChipRegisters.PALETTE_13:
				tcc1014.color_palette.set_palette_entry(13, data)

			ControlChipRegisters.PALETTE_14:
				tcc1014.color_palette.set_palette_entry(14, data)

			ControlChipRegisters.PALETTE_15:
				tcc1014.color_palette.set_palette_entry(15, data)
	
			ControlChipRegisters.SAM_COCO_GRAPHICS_MODE_SELECT_V0_SET:
				tcc1014.sam_control_register.v0 = true

			ControlChipRegisters.SAM_COCO_GRAPHICS_MODE_SELECT_V0_CLEAR:
				tcc1014.sam_control_register.v0 = false

			ControlChipRegisters.SAM_COCO_GRAPHICS_MODE_SELECT_V1_SET:
				tcc1014.sam_control_register.v1 = true

			ControlChipRegisters.SAM_COCO_GRAPHICS_MODE_SELECT_V1_CLEAR:
				tcc1014.sam_control_register.v1 = false

			ControlChipRegisters.SAM_COCO_GRAPHICS_MODE_SELECT_V2_SET:
				tcc1014.sam_control_register.v2 = true

			ControlChipRegisters.SAM_COCO_GRAPHICS_MODE_SELECT_V2_CLEAR:
				tcc1014.sam_control_register.v2 = false

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F0_SET:
				tcc1014.sam_control_register.f0 = true

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F0_CLEAR:
				tcc1014.sam_control_register.f0 = false

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F1_SET:
				tcc1014.sam_control_register.f1 = true

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F1_CLEAR:
				tcc1014.sam_control_register.f1 = false

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F2_SET:
				tcc1014.sam_control_register.f2 = true

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F2_CLEAR:
				tcc1014.sam_control_register.f2 = false

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F3_SET:
				tcc1014.sam_control_register.f3 = true

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F3_CLEAR:
				tcc1014.sam_control_register.f3 = false

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F4_SET:
				tcc1014.sam_control_register.f4 = true

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F4_CLEAR:
				tcc1014.sam_control_register.f4 = false

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F5_SET:
				tcc1014.sam_control_register.f5 = true

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F5_CLEAR:
				tcc1014.sam_control_register.f5 = false

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F6_SET:
				tcc1014.sam_control_register.f6 = true

			ControlChipRegisters.SAM_COCO_VERTICAL_OFFSET_F6_CLEAR:
				tcc1014.sam_control_register.f6 = false

			ControlChipRegisters.SAM_MPU_SPEED_SET:
				tcc1014.sam_control_register.cpu_rate = true

			ControlChipRegisters.SAM_MPU_SPEED_CLEAR:
				tcc1014.sam_control_register.cpu_rate = false

			ControlChipRegisters.SAM_ROM_DISABLE_SET:
				tcc1014.sam_control_register.map_type = true

			ControlChipRegisters.SAM_ROM_DISABLE_CLEAR:
				tcc1014.sam_control_register.map_type = false

			_:
				register_space[address] = data

var control_registers: ControlRegisters = ControlRegisters.new(self)

## This is where the bus connects the processor and the ACVC
func _on_Processor_bus_accessed(pins) -> void:
	# locally cache
	var address: int = pins.address
	var data: int = pins.data

	if (address & 0xFF00) != 0xFF00:
		# We're accessing memory normally

		if init0.mmu_enabled:
			# Memory Management Unit enabled
			if init1.task_register_select:
				address = task_set.get_address(address)
			else:
				address = executive_set.get_address(address)

			emit_signal('memory_accessed', address, pins)
		else:
			# Normal memory
			emit_signal('memory_accessed', address, pins)
	else:
		# We're accessing reserved memory

		if pins.rw:
			# read
			pins.data = control_registers.read(address)
		else:
			control_registers.write(address, data)

# ACVC Video Control

# set up Godot target render surface

signal timer_irq
signal timer_firq

const TARGET_BYTE_PER_PIXEL: int = 4

var target_screen_buffer: StreamPeerBuffer = StreamPeerBuffer.new()
var target_screen_image: Image = Image.new()


## Initialize the screen graphics (video component)
func _init() -> void:
	target_screen_image.create(0, 0, false, Image.FORMAT_RGBA8)
	# initialize texture to black
	texture = ImageTexture.new()
	texture.create_from_image(target_screen_image, 0) # must be called at least once before set_data

	# connect our timer
	timer.connect('hit_zero', self, '_on_Timer_hit_zero')
	graphics_mode.connect('graphics_mode_changed', self, 'update_graphics_mode')

	##### TESTING CODE #####
	color_palette.set_palette_entry(0, 0x00)
	color_palette.set_palette_entry(1, PaletteRed.RED3)
	color_palette.set_palette_entry(2, PaletteBlue.BLUE3)
	color_palette.set_palette_entry(3, PaletteGreen.GREEN3)
	color_palette.set_palette_entry(4, PaletteRed.RED1)
	color_palette.set_palette_entry(5, PaletteBlue.BLUE1)
	color_palette.set_palette_entry(6, PaletteGreen.GREEN1)
	color_palette.set_palette_entry(7, PaletteRed.RED2)
	color_palette.set_palette_entry(8, PaletteBlue.BLUE2)
	color_palette.set_palette_entry(9, PaletteGreen.GREEN2)
	color_palette.set_palette_entry(10, PaletteRed.RED3)
	color_palette.set_palette_entry(11, PaletteBlue.BLUE3)
	color_palette.set_palette_entry(12, PaletteGreen.GREEN3)
	color_palette.set_palette_entry(13, PaletteRed.RED3)
	color_palette.set_palette_entry(14, PaletteBlue.BLUE2)
	color_palette.set_palette_entry(15, PaletteGreen.GREEN1)

	video_mode_register.graphics_plane = true
	video_resolution_register.register = GraphicsResolution.FIVE_TWELVE_4 | LinesPerField.TWO_TWENTY_FIVE
	vertical_offset_0.register = 0x01


func _ready() -> void:
	var processor = find_node('Processor')
	
	var time = OS.get_ticks_usec()
	
	processor.execute(CYCLES_PER_SECOND_089)
	
	time = OS.get_ticks_usec() - time
	
	print(time)


func update_graphics_mode():
	if graphics_mode.lines_per_field and graphics_mode.horizontal_resolution:
		target_screen_buffer.resize(
			graphics_mode.lines_per_field
			* graphics_mode.horizontal_resolution
			* TARGET_BYTE_PER_PIXEL
		)

		target_screen_buffer.seek(0)
		for _i in range(target_screen_buffer.get_size()):
			target_screen_buffer.put_u8(0)

		target_screen_image.create_from_data(
			graphics_mode.horizontal_resolution,
			graphics_mode.lines_per_field,
			false,
			Image.FORMAT_RGBA8,
			target_screen_buffer.data_array
		)

		texture.create_from_image(target_screen_image, 0)

		expand = true
		set_stretch_mode(TextureRect.STRETCH_SCALE)

		rect_size.x = graphics_mode.horizontal_resolution
		rect_size.y = graphics_mode.lines_per_field

		match graphics_mode.horizontal_resolution:
			320:
				continue
			256:
				rect_min_size.x = graphics_mode.horizontal_resolution * 2

			160:
				rect_min_size.x = graphics_mode.horizontal_resolution * 4

			_:
				rect_min_size.x = graphics_mode.horizontal_resolution

		rect_min_size.y = graphics_mode.lines_per_field * 2





	# expand = true
	# set_stretch_mode(5)

	#rect_size.x = graphics_mode.horizontal_resolution
	#rect_size.y = graphics_mode.lines_per_field

#	rect_min_size.y = rect_size.y * 2

#	target_screen_buffer.resize(
#		graphics_mode.lines_per_field
#		* graphics_mode.horizontal_resolution
#		* TARGET_BYTE_PER_PIXEL
#	)

#	target_screen_buffer.seek(0)
#	for _i in range(target_screen_buffer.get_size()):
#		target_screen_buffer.put_u8(0)


func _on_Timer_hit_zero() -> void:
	_signal_timer()


func _signal_timer():
	if firqenr.timer and init0.firq_output_enabled:
		_signal_horizontal_firq()
	elif irqenr.timer and init0.irq_output_enabled:
		_signal_horizontal_irq()


func _signal_timer_firq():
	firqenr.horizontal_border = true
	emit_signal('timer_firq')


func _signal_timer_irq():
	irqenr.horizontal_border = true
	emit_signal('timer_irq')


## Render the Image data to the screen
func _draw() -> void:
	texture.set_data(target_screen_image)

# set up internal color palettes

class RGBSourceColorPalette:

	const INTENSITY_LEVEL: int = 256 / 3
	const COLOR_INTENSITIES: Array = [0, INTENSITY_LEVEL, INTENSITY_LEVEL * 2, INTENSITY_LEVEL * 3]

	var colors: Array

	func _init() -> void:
		colors.resize(64)

		var red: int = 0
		var green: int = 0
		var blue: int = 0

		for i in range(64):
			red = COLOR_INTENSITIES[((i & Palette.RED1) >> 4) | ((i & Palette.RED0) >> 2)]
			green = COLOR_INTENSITIES[((i & Palette.GREEN1) >> 3) | ((i & Palette.GREEN0) >> 1)]
			blue = COLOR_INTENSITIES[((i & Palette.BLUE1) >> 2) | (i & Palette.BLUE0)]
			colors[i] = Color8(red, green, blue)

var rgb_source_color_palette: RGBSourceColorPalette = RGBSourceColorPalette.new()

# From Assembly Language Programming for the CoCo 3 by Laurency A. Tepolt
#
# Describing Colors
#
#     The basic attributes of color are its hue, saturation, and brightness. Of course there are
# many others such as texture, glare, and glitter, but the three basic attributes serve well when
# describing the colors generated by the CoCo 3.
#
# * Hue - This is a classification of the color. The hues include all the rainbow colors and those
#       between adjacent rainbow colors such as greenish yellow.
#
# * Saturation - This is a measure of the vividness or amount of color in the sample. For example,
#       medium blue is more saturated than pale blue.
#
# * Brithness - A measure of how light or dark the sample color is. It is easiest to imagine the
#       color sample has a background that may vary from black, through the grays, to white. A
#       bright color has a white background and a dark color has a black background.
#
# ...
#
# Composite Color Set
#
#     The composite color set is the set of colors generated on a composite monitor (or TV) by the
# 64 color codes. When using a composite monitor the bits of the palette registers are interpreted
# as shown in Fig. 2-3. The six bits (5-0) generate a color by specifying its hue, saturation, and
# brightness.
#
#            -------------------------------
# Bit number | 5  | 4  | 3  | 2  | 1  | 0  |
#            -------------------------------
# Label      | S1 | S0 | A3 | A2 | A1 | A0 |
#            -------------------------------
#            \________/\___________________/
#                 |              |
# Bright/Saturation              |
#                                |
#                        Hue Angle
#
# Fig. 2-3 Composite Palette Register
#
#     Bits 3-0 select a hue from a hue wheel by specifying an angle. The angles are number 0-15 and
# select a hue as shown in Fig. 2-4. The primary colors are underlined and all the others are the
# illusory colors. Each illusory color, except gray, is a combination of the two primary colors it
# is between. Gray is a combination of all three primary colors. For example, indigo is mostly blue
# and some red.
#
# 0  - Gray
# 1  - _Green_
# 2  - Greenish Yellow
# 3  - Yellow
# 4  - Yellowish Orange
# 5  - Orange
# 6  - Reddish Orange
# 7  - _Red_
# 8  - Reddish Magenta
# 9  - Magenta
# 10 - Indigo
# 11 - _Blue_
# 12 - Bluish Cyan
# 13 - Cyan
# 14 - Greenish Cyan
# 15 - Blueish Green
#
# Fig. 2-4 Hue Wheel (ED: Unraveled for ASCII)
#
#     Bits 4 and 5 select both the brightness and saturation. They can't be selected independently.
# Table 2-2 shows the four bit combinations and the corresponding brightness and saturation.
#
# -------------------------------------
# | S1 | S0 | Brightness | Saturation |
# -------------------------------------
# | 0  | 0  |    low     |    high    |
# | 0  | 1  |   medium   |   medium   |
# | 1  | 0  |    high    |    low     |
# | 1  | 1  | very high  |  very low  |
# -------------------------------------
#
# Table 2-2. Brightness and Saturation
#
#     The exception to this scheme is the color generated by color code 63. It is not a bluish
# green of a very high brightness and very low saturation. It is white. Some example of colors and
# their codes follow:
#
#     Binary Code     Color
#
#        000000       Black
#        000111       Dark Red
#        011011       Medium Blue
#
class CompositeSourceColorPalette:

	const DEGREES_PER_ANGLE: float = 360.0 / 15

	var colors: Array

	func _init() -> void:
		colors.resize(64)

		var counter: int = 0

		colors[counter] = Color8(0, 0, 0)
		counter += 1

		var angle: float = 120.0
		for _i in range(15):
			colors[counter] = _hsb_to_rgb(angle, 100.0, 55.0)
			counter += 1
			angle -= DEGREES_PER_ANGLE
			if angle < 0:
				angle += 360

		colors[counter] = Color8(85, 85, 85)
		counter += 1

		angle = 120.0
		for _i in range(15):
			colors[counter] = _hsb_to_rgb(angle, 80.8, 81.6)
			counter += 1
			angle -= DEGREES_PER_ANGLE
			if angle < 0:
				angle += 360

		colors[counter] = Color8(170, 170, 170)
		counter += 1

		for _i in range(15):
			colors[counter] = _hsb_to_rgb(angle, 68.2, 100.0)
			counter += 1
			angle -= DEGREES_PER_ANGLE
			if angle < 0:
				angle += 360

		colors[counter] = Color8(255, 255, 255)
		counter += 1

		for _i in range(14):
			colors[counter] = _hsb_to_rgb(angle, 54.9, 99.2)
			counter += 1
			angle -= DEGREES_PER_ANGLE
			if angle < 0:
				angle += 360

		colors[counter] = Color8(255, 255, 255)

	func _hsb_to_rgb(hue: float, saturation: float, brightness: float) -> Color:
		hue = clamp(hue, 0, 360)
		saturation = clamp(saturation, 0, 100)
		brightness = clamp(brightness, 0, 100)

		saturation /= 100
		brightness /= 100
		
		var c := saturation * brightness
		var x := c * (1 - abs(fmod((hue / 60), 2) - 1))
		var m := brightness - c

		var r: float = 0
		var g: float = 0
		var b: float = 0

		if hue >= 0 and hue < 60:
			r = c
			g = x
		elif hue >= 60 and hue < 120:
			r = x
			g = c
		elif hue >= 120 and hue < 180:
			g = c
			b = x
		elif hue >= 180 and hue < 240:
			g = x
			b = c
		elif hue >= 240 and hue < 300:
			r = x
			b = c
		elif hue >= 300 and hue <= 360:
			r = c
			b = x

		return Color8(int((r + m) * 255), int((g + m) * 255), int((b + m) * 255))

var composite_source_color_palette: CompositeSourceColorPalette = CompositeSourceColorPalette.new()

enum MonitorTypes {
	RGB,
	COMPOSITE
}

# Monitors
#
#     The standard (NTSC) Color Computer 3 can interface with RGB and Composite signals. The color
# output signals (mappable to a 64 value 6 bit space) have different interpretations depending on
# whether it's an RGB monitor, or a standard Composite monitor. This object keeps track of which
# monitor is being used, and returns the appropriate color through its interface.
class Monitor:

	var type: int

	var rgb_palette: RGBSourceColorPalette
	var composite_palette: CompositeSourceColorPalette

	func _init(new_rgb_palette, new_composite_palette):
		rgb_palette = new_rgb_palette
		composite_palette = new_composite_palette

	func get_source_palette_color(index: int) -> Color:
		if type == MonitorTypes.RGB:
			return rgb_palette.colors[index]
		else:
			return composite_palette.colors[index]

var monitor: Monitor = Monitor.new(rgb_source_color_palette, composite_source_color_palette)

# Graphics Modes
#
class GraphicsMode:

	signal graphics_mode_changed

	var coco_mode: bool = false setget set_coco_mode

	# COCO 3
	var graphics: bool = false
	var character_columns: int = 0
	var color_resolution: int = 0
	var horizontal_resolution: int = 0
	var horizontal_border: int = 0
	var horizontal_extension: bool = false
	# in bytes
	var buffer_width: int = 0
	# input LPR bits, get number back
	var lines_per_character_row: int = 0 setget set_lines_per_character_row
	# input LPF bits, get number back
	var lines_per_field: int = 0 setget set_lines_per_field
	var vertical_border: int = 0
	
	func _init(tcc1014) -> void:
		# string up connections
		tcc1014.init0.connect('coco_toggled', self, 'set_coco_mode')
		tcc1014.video_mode_register.connect('plane_toggled', self, 'set_graphics')
		tcc1014.video_mode_register.connect('lines_per_row_set', self, 'set_lines_per_character_row')
		tcc1014.video_resolution_register.connect('register_set', self, 'update_resolution')
		tcc1014.horizontal_offset.connect('hven_toggled', self, 'set_horizontal_extension')

	func set_coco_mode(new_coco_mode: bool) -> void:
		var old_coco_mode := coco_mode
		coco_mode = new_coco_mode
		if old_coco_mode != new_coco_mode:
			emit_signal('graphics_mode_changed')

	func set_graphics(new_graphics: bool) -> void:
		var old_graphics := new_graphics
		graphics = new_graphics
		if old_graphics != new_graphics:
			emit_signal('graphics_mode_changed')

	func set_lines_per_character_row(new_lines_per_character: int) -> void:
		var old_lines_per_character_row := lines_per_character_row

		match new_lines_per_character:
			LinesPerRow.ONE:
				lines_per_character_row = 1

			LinesPerRow.TWO:
				lines_per_character_row = 2

			LinesPerRow.THREE:
				lines_per_character_row = 3

			LinesPerRow.EIGHT:
				lines_per_character_row = 8

			LinesPerRow.NINE:
				lines_per_character_row = 9

			LinesPerRow.TWELVE:
				lines_per_character_row = 12

			_:
				pass

		if old_lines_per_character_row != lines_per_character_row:
			emit_signal('graphics_mode_changed')

	func update_resolution(new_register: int) -> void:
		var new_lines_per_field: int = new_register & (VideoResolution.LPF0 | VideoResolution.LPF1)
		var new_horizontal_resolution: int = new_register & (VideoResolution.HRES0 | VideoResolution.HRES1 | VideoResolution.HRES2)
		var new_color_resolution: int = new_register & (VideoResolution.CRES0 | VideoResolution.CRES1)
		var new_resolution: int = new_horizontal_resolution | new_color_resolution

		set_lines_per_field(new_lines_per_field, true)

		match new_resolution:
			AlphanumericsWidth.THIRTY_TWO_CHARACTER:
				character_columns = 32
				continue

			AlphanumericsWidth.FORTY_CHARACTER:
				character_columns = 40
				continue

			AlphanumericsWidth.EIGHTY_CHARACTER:
				character_columns = 80
				continue

			GraphicsResolution.TWO_FIFTY_SIX_2:
				horizontal_resolution = 256
				color_resolution = 2
				horizontal_border = 192

			GraphicsResolution.FIVE_TWELVE_2:
				horizontal_resolution = 512
				color_resolution = 2
				horizontal_border = 64

			GraphicsResolution.TWO_FIFTY_SIX_4:
				horizontal_resolution = 256
				color_resolution = 4
				horizontal_border = 192

			GraphicsResolution.SIX_FORTY_2:
				horizontal_resolution = 640
				color_resolution = 2
				horizontal_border = 0

			GraphicsResolution.THREE_TWENTY_4:
				horizontal_resolution = 320
				color_resolution = 4
				horizontal_border = 160

			GraphicsResolution.ONE_SIXTY_16:
				horizontal_resolution = 160
				color_resolution = 16
				horizontal_border = 240

			GraphicsResolution.FIVE_TWELVE_4:
				horizontal_resolution = 512
				color_resolution = 4
				horizontal_border = 64

			GraphicsResolution.TWO_FIFTY_SIX_16:
				horizontal_resolution = 256
				color_resolution = 16
				horizontal_border = 192

			GraphicsResolution.SIX_FORTY_4:
				horizontal_resolution = 640
				color_resolution = 4
				horizontal_border = 0

			GraphicsResolution.THREE_TWENTY_16:
				horizontal_resolution = 320
				color_resolution = 16
#				horizontal_border = 160
				horizontal_border = 0 # stretched

			_:
				pass

		if graphics:
			match color_resolution:
				2:
					buffer_width = horizontal_resolution / 8

				4:
					buffer_width = horizontal_resolution / 4

				16:
					buffer_width = horizontal_resolution / 2

				_:
					pass
		else:
			if horizontal_extension:
				buffer_width = 256
			else:
				if new_resolution & AlphanumericsWidth.THIRTY_TWO_CHARACTER:
					buffer_width = 64
				elif new_resolution & AlphanumericsWidth.FORTY_CHARACTER:
					buffer_width = 80
				elif new_resolution & AlphanumericsWidth.EIGHTY_CHARACTER:
					buffer_width = 160

		emit_signal('graphics_mode_changed')


	func set_lines_per_field(new_lines_per_field: int, delay_signals: bool = false) -> void:
		var old_lines_per_field := lines_per_field

		match new_lines_per_field:
			LinesPerField.ONE_NINETY_TWO:
				lines_per_field = 192
				vertical_border = 23

			LinesPerField.TWO_HUNDRED:
				lines_per_field = 200
				vertical_border = 19

			LinesPerField.TWO_TWENTY_FIVE:
				lines_per_field = 225
				vertical_border = 7

			_:
				pass

		if old_lines_per_field != lines_per_field:
			if not delay_signals:
				emit_signal('graphics_mode_changed')

	func set_horizontal_extension(new_horizontal_extension: bool) -> void:
		horizontal_extension = new_horizontal_extension

var graphics_mode: GraphicsMode = GraphicsMode.new(self)

signal memory_accessed_by_vdg(address, bytes, buffer)

# We're going to pretend we have optimal conditions and run at 60 fps, even if CoCo3 didn't run
# at exactly 60 fps.
const FRAMERATE = 60
# NTSC Color Burst in Hertz
const COLOR_BURST: float = (315.0 / 88.0)
# material suggests 0.89 MHz, but a more accurate reprsentation comes from the technical specs
const CYCLES_PER_SECOND_089: float = (COLOR_BURST / 4) * 1000000
const CYCLES_PER_SECOND_178: float = CYCLES_PER_SECOND_089 * 2
const CYCLES_PER_FRAME_089: float = CYCLES_PER_SECOND_089 / FRAMERATE
const CYCLES_PER_FRAME_178: float = CYCLES_PER_SECOND_178 / FRAMERATE
# NTSC ideal lines per screen
const LINES_PER_SCREEN: float = 262.0
const CYCLES_PER_LINE_089: float = CYCLES_PER_FRAME_089 / LINES_PER_SCREEN
const CYCLES_PER_LINE_178: float = CYCLES_PER_FRAME_178 / LINES_PER_SCREEN

class ColorPaletteData:

	var colors: Array

	var tcc1014

	func _init(new_tcc1014) -> void:
		tcc1014 = new_tcc1014
		colors.resize(16)
		for i in range(16):
			colors[i] = tcc1014.monitor.get_source_palette_color(
				tcc1014.color_palette.palette[i].register
			).to_abgr32()
		tcc1014.color_palette.connect(
			'palette_entry_changed',
			self,
			'_on_ColorPalette_palette_entry_changed'
		)

	func _on_ColorPalette_palette_entry_changed(index: int) -> void:
		colors[index] = tcc1014.monitor.get_source_palette_color(
			tcc1014.color_palette.palette[index].register
		).to_abgr32()

var color_palette_data: ColorPaletteData = ColorPaletteData.new(self)

var vram_buffer: Dictionary = {
	'data': []
}

# render video ram onto screen
#
# NOTE border should already be rendered
func render_frame():
	# set blink ?
	# assert vertical sync (6821)

	# vertical blanking for 13 lines
	# 4 unrendered top border lines
	for _i in range(17): # vertical blanking for 13 lines + 4 unrendered top border lines
		scanline_time()

	# border should already be rendered
	for _i in range(graphics_mode.vertical_border):
		scanline_time()

	# we're now in the active display area
#	target_screen_buffer.seek(
#		((TARGET_SCREEN_WIDTH * graphics_mode.vertical_border * 2) \
#		+ graphics_mode.horizontal_border) * TARGET_BYTE_PER_PIXEL
#	)
	target_screen_buffer.seek(0)

	var vram_start_address = vertical_offset.offset

	if init0.coco:
		# compatibility mode enabled
		pass
	else:
		if video_mode_register.graphics_plane:
			var color_resolution := video_resolution_register.color_resolution

			match color_resolution:
				ColorResolution.TWO:
					var blit_function: FuncRef

					match graphics_mode.horizontal_resolution:
						640:
							blit_function = funcref(self, '_blit_80_2')
						512:
							blit_function = funcref(self, '_blit_64_2')
						256:
							blit_function = funcref(self, '_blit_32_2')

					for _y in range(graphics_mode.lines_per_field):
						emit_signal(
							'memory_accessed_by_vdg',
							vram_start_address,
							graphics_mode.buffer_width,
							vram_buffer
						)

						blit_function.call_func(vram_buffer['data'])
						vram_start_address += graphics_mode.buffer_width
						scanline_time()

				ColorResolution.FOUR:
					var blit_function: FuncRef

					match graphics_mode.horizontal_resolution:
						640:
							blit_function = funcref(self, '_blit_160_4')
						512:
							blit_function = funcref(self, '_blit_128_4')
						320:
							blit_function = funcref(self, '_blit_80_4')
						256:
							blit_function = funcref(self, '_blit_64_4')

					for _y in range(graphics_mode.lines_per_field):
						emit_signal(
							'memory_accessed_by_vdg',
							vram_start_address,
							graphics_mode.buffer_width,
							vram_buffer
						)

						blit_function.call_func(vram_buffer['data'])
						vram_start_address += graphics_mode.buffer_width
						scanline_time()

				ColorResolution.SIXTEEN:
					var blit_function: FuncRef

					match graphics_mode.horizontal_resolution:
						320:
							blit_function = funcref(self, '_blit_160_16')
						256:
							blit_function = funcref(self, '_blit_128_16')
						160:
							blit_function = funcref(self, '_blit_80_16')

					for _y in range(graphics_mode.lines_per_field):
						emit_signal(
							'memory_accessed_by_vdg',
							vram_start_address,
							graphics_mode.buffer_width,
							vram_buffer
						)

						blit_function.call_func(vram_buffer['data'])
						vram_start_address += graphics_mode.buffer_width
						scanline_time()

		else:
			# alphanumerics mode
			pass

	# assert vertical sync switch

	# bottom border - should already be rendered
	for _i in range(graphics_mode.vertical_border):
		scanline_time()

	# vertical retrace for 6 lines
	for _i in range(6):
		scanline_time()


var cpu_state: Dictionary = {
	'drift': 0.0
}

signal cpu_cycles_requested(num_of_cycles, acvc)
signal horizontal_irq
signal horizontal_firq


# called every scanline
func scanline_time():
	# signal horizontal interrupt from the ACVC
	_signal_horizontal()
	# assert horizontal (6821)

	if not init1.tins: # 0 = 63 µsec
		timer.decrement_timer()

	emit_signal(
		'cpu_cycles_requested',
		cpu_state['drift'] + \
			(CYCLES_PER_LINE_178 if sam_control_register.cpu_rate else CYCLES_PER_LINE_089),
		cpu_state
	)


func _signal_horizontal():
	if firqenr.horizontal_border and init0.firq_output_enabled:
		_signal_horizontal_firq()
	elif irqenr.horizontal_border and init0.irq_output_enabled:
		_signal_horizontal_irq()


func _signal_horizontal_firq():
	firqenr.horizontal_border = true
	emit_signal('horizontal_firq')


func _signal_horizontal_irq():
	irqenr.horizontal_border = true
	emit_signal('horizontal_irq')


const SINGLE_FRAME_TIME: float = 1.0 / 60.0


func _process(delta: float) -> void:
	while delta > SINGLE_FRAME_TIME * 2:

		#if vertical_offset_0.register > 4:
		#	vertical_offset_0.register = 1

		emit_signal(
			'cpu_cycles_requested',
			cpu_state['drift'] + \
				(CYCLES_PER_FRAME_178 if sam_control_register.cpu_rate else CYCLES_PER_FRAME_089),
			cpu_state
		)

		delta -= SINGLE_FRAME_TIME

	vertical_offset_0.register += 1
	if vertical_offset_0.register > 8:
		vertical_offset_0.register = 1

	render_frame()

	# generate the image data
	target_screen_image.create_from_data(
		graphics_mode.horizontal_resolution,
		graphics_mode.lines_per_field,
		false,
		Image.FORMAT_RGBA8,
		target_screen_buffer.data_array
	)

	update()

func _blit_160_4(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	# 4 pixels, 2 at a time
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[64] & 0x03] << 32) | (_color_palette_data[(buffer_data[64] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[64] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[64] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[65] & 0x03] << 32) | (_color_palette_data[(buffer_data[65] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[65] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[65] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[66] & 0x03] << 32) | (_color_palette_data[(buffer_data[66] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[66] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[66] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[67] & 0x03] << 32) | (_color_palette_data[(buffer_data[67] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[67] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[67] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[68] & 0x03] << 32) | (_color_palette_data[(buffer_data[68] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[68] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[68] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[69] & 0x03] << 32) | (_color_palette_data[(buffer_data[69] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[69] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[69] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[70] & 0x03] << 32) | (_color_palette_data[(buffer_data[70] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[70] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[70] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[71] & 0x03] << 32) | (_color_palette_data[(buffer_data[71] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[71] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[71] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[72] & 0x03] << 32) | (_color_palette_data[(buffer_data[72] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[72] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[72] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[73] & 0x03] << 32) | (_color_palette_data[(buffer_data[73] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[73] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[73] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[74] & 0x03] << 32) | (_color_palette_data[(buffer_data[74] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[74] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[74] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[75] & 0x03] << 32) | (_color_palette_data[(buffer_data[75] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[75] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[75] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[76] & 0x03] << 32) | (_color_palette_data[(buffer_data[76] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[76] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[76] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[77] & 0x03] << 32) | (_color_palette_data[(buffer_data[77] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[77] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[77] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[78] & 0x03] << 32) | (_color_palette_data[(buffer_data[78] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[78] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[78] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[79] & 0x03] << 32) | (_color_palette_data[(buffer_data[79] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[79] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[79] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[80] & 0x03] << 32) | (_color_palette_data[(buffer_data[80] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[80] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[80] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[81] & 0x03] << 32) | (_color_palette_data[(buffer_data[81] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[81] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[81] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[82] & 0x03] << 32) | (_color_palette_data[(buffer_data[82] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[82] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[82] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[83] & 0x03] << 32) | (_color_palette_data[(buffer_data[83] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[83] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[83] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[84] & 0x03] << 32) | (_color_palette_data[(buffer_data[84] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[84] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[84] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[85] & 0x03] << 32) | (_color_palette_data[(buffer_data[85] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[85] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[85] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[86] & 0x03] << 32) | (_color_palette_data[(buffer_data[86] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[86] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[86] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[87] & 0x03] << 32) | (_color_palette_data[(buffer_data[87] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[87] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[87] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[88] & 0x03] << 32) | (_color_palette_data[(buffer_data[88] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[88] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[88] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[89] & 0x03] << 32) | (_color_palette_data[(buffer_data[89] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[89] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[89] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[90] & 0x03] << 32) | (_color_palette_data[(buffer_data[90] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[90] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[91] & 0x03] << 32) | (_color_palette_data[(buffer_data[91] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[91] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[91] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[92] & 0x03] << 32) | (_color_palette_data[(buffer_data[92] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[92] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[92] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[93] & 0x03] << 32) | (_color_palette_data[(buffer_data[93] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[93] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[93] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[94] & 0x03] << 32) | (_color_palette_data[(buffer_data[94] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[94] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[94] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[95] & 0x03] << 32) | (_color_palette_data[(buffer_data[95] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[95] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[95] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[96] & 0x03] << 32) | (_color_palette_data[(buffer_data[96] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[96] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[96] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[97] & 0x03] << 32) | (_color_palette_data[(buffer_data[97] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[97] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[97] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[98] & 0x03] << 32) | (_color_palette_data[(buffer_data[98] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[98] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[98] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[99] & 0x03] << 32) | (_color_palette_data[(buffer_data[99] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[99] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[99] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[100] & 0x03] << 32) | (_color_palette_data[(buffer_data[100] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[100] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[100] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[101] & 0x03] << 32) | (_color_palette_data[(buffer_data[101] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[101] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[101] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[102] & 0x03] << 32) | (_color_palette_data[(buffer_data[102] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[102] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[102] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[103] & 0x03] << 32) | (_color_palette_data[(buffer_data[103] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[103] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[103] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[104] & 0x03] << 32) | (_color_palette_data[(buffer_data[104] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[104] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[104] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[105] & 0x03] << 32) | (_color_palette_data[(buffer_data[105] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[105] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[105] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[106] & 0x03] << 32) | (_color_palette_data[(buffer_data[106] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[106] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[106] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[107] & 0x03] << 32) | (_color_palette_data[(buffer_data[107] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[107] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[107] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[108] & 0x03] << 32) | (_color_palette_data[(buffer_data[108] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[108] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[108] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[109] & 0x03] << 32) | (_color_palette_data[(buffer_data[109] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[109] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[109] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[110] & 0x03] << 32) | (_color_palette_data[(buffer_data[110] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[110] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[110] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[111] & 0x03] << 32) | (_color_palette_data[(buffer_data[111] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[111] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[111] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[112] & 0x03] << 32) | (_color_palette_data[(buffer_data[112] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[112] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[112] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[113] & 0x03] << 32) | (_color_palette_data[(buffer_data[113] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[113] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[113] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[114] & 0x03] << 32) | (_color_palette_data[(buffer_data[114] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[114] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[114] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[115] & 0x03] << 32) | (_color_palette_data[(buffer_data[115] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[115] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[115] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[116] & 0x03] << 32) | (_color_palette_data[(buffer_data[116] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[116] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[116] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[117] & 0x03] << 32) | (_color_palette_data[(buffer_data[117] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[117] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[117] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[118] & 0x03] << 32) | (_color_palette_data[(buffer_data[118] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[118] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[118] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[119] & 0x03] << 32) | (_color_palette_data[(buffer_data[119] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[119] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[119] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[120] & 0x03] << 32) | (_color_palette_data[(buffer_data[120] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[120] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[120] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[121] & 0x03] << 32) | (_color_palette_data[(buffer_data[121] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[121] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[121] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[122] & 0x03] << 32) | (_color_palette_data[(buffer_data[122] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[122] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[122] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[123] & 0x03] << 32) | (_color_palette_data[(buffer_data[123] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[123] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[123] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[124] & 0x03] << 32) | (_color_palette_data[(buffer_data[124] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[124] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[124] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[125] & 0x03] << 32) | (_color_palette_data[(buffer_data[125] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[125] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[125] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[126] & 0x03] << 32) | (_color_palette_data[(buffer_data[126] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[126] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[126] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[127] & 0x03] << 32) | (_color_palette_data[(buffer_data[127] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[127] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[127] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[128] & 0x03] << 32) | (_color_palette_data[(buffer_data[128] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[128] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[128] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[129] & 0x03] << 32) | (_color_palette_data[(buffer_data[129] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[129] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[129] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[130] & 0x03] << 32) | (_color_palette_data[(buffer_data[130] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[130] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[130] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[131] & 0x03] << 32) | (_color_palette_data[(buffer_data[131] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[131] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[131] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[132] & 0x03] << 32) | (_color_palette_data[(buffer_data[132] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[132] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[132] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[133] & 0x03] << 32) | (_color_palette_data[(buffer_data[133] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[133] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[133] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[134] & 0x03] << 32) | (_color_palette_data[(buffer_data[134] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[134] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[134] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[135] & 0x03] << 32) | (_color_palette_data[(buffer_data[135] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[135] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[135] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[136] & 0x03] << 32) | (_color_palette_data[(buffer_data[136] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[136] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[136] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[137] & 0x03] << 32) | (_color_palette_data[(buffer_data[137] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[137] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[137] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[138] & 0x03] << 32) | (_color_palette_data[(buffer_data[138] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[138] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[138] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[139] & 0x03] << 32) | (_color_palette_data[(buffer_data[139] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[139] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[139] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[140] & 0x03] << 32) | (_color_palette_data[(buffer_data[140] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[140] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[140] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[141] & 0x03] << 32) | (_color_palette_data[(buffer_data[141] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[141] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[141] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[142] & 0x03] << 32) | (_color_palette_data[(buffer_data[142] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[142] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[142] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[143] & 0x03] << 32) | (_color_palette_data[(buffer_data[143] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[143] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[143] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[144] & 0x03] << 32) | (_color_palette_data[(buffer_data[144] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[144] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[144] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[145] & 0x03] << 32) | (_color_palette_data[(buffer_data[145] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[145] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[145] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[146] & 0x03] << 32) | (_color_palette_data[(buffer_data[146] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[146] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[146] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[147] & 0x03] << 32) | (_color_palette_data[(buffer_data[147] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[147] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[147] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[148] & 0x03] << 32) | (_color_palette_data[(buffer_data[148] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[148] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[148] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[149] & 0x03] << 32) | (_color_palette_data[(buffer_data[149] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[149] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[149] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[150] & 0x03] << 32) | (_color_palette_data[(buffer_data[150] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[150] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[110] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[151] & 0x03] << 32) | (_color_palette_data[(buffer_data[151] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[151] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[111] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[152] & 0x03] << 32) | (_color_palette_data[(buffer_data[152] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[152] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[112] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[153] & 0x03] << 32) | (_color_palette_data[(buffer_data[153] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[153] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[113] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[154] & 0x03] << 32) | (_color_palette_data[(buffer_data[154] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[154] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[114] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[155] & 0x03] << 32) | (_color_palette_data[(buffer_data[155] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[155] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[115] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[156] & 0x03] << 32) | (_color_palette_data[(buffer_data[156] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[156] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[116] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[157] & 0x03] << 32) | (_color_palette_data[(buffer_data[157] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[157] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[117] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[158] & 0x03] << 32) | (_color_palette_data[(buffer_data[158] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[158] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[118] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[159] & 0x03] << 32) | (_color_palette_data[(buffer_data[159] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[159] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[119] >> 6) & 0x03]))


func _blit_160_16(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x0F] << 32) | _color_palette_data[buffer_data[0] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x0F] << 32) | _color_palette_data[buffer_data[1] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x0F] << 32) | _color_palette_data[buffer_data[2] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x0F] << 32) | _color_palette_data[buffer_data[3] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x0F] << 32) | _color_palette_data[buffer_data[4] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x0F] << 32) | _color_palette_data[buffer_data[5] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x0F] << 32) | _color_palette_data[buffer_data[6] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x0F] << 32) | _color_palette_data[buffer_data[7] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x0F] << 32) | _color_palette_data[buffer_data[8] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x0F] << 32) | _color_palette_data[buffer_data[9] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x0F] << 32) | _color_palette_data[buffer_data[10] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x0F] << 32) | _color_palette_data[buffer_data[11] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x0F] << 32) | _color_palette_data[buffer_data[12] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x0F] << 32) | _color_palette_data[buffer_data[13] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x0F] << 32) | _color_palette_data[buffer_data[14] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x0F] << 32) | _color_palette_data[buffer_data[15] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x0F] << 32) | _color_palette_data[buffer_data[16] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x0F] << 32) | _color_palette_data[buffer_data[17] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x0F] << 32) | _color_palette_data[buffer_data[18] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x0F] << 32) | _color_palette_data[buffer_data[19] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x0F] << 32) | _color_palette_data[buffer_data[20] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x0F] << 32) | _color_palette_data[buffer_data[21] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x0F] << 32) | _color_palette_data[buffer_data[22] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x0F] << 32) | _color_palette_data[buffer_data[23] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x0F] << 32) | _color_palette_data[buffer_data[24] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x0F] << 32) | _color_palette_data[buffer_data[25] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x0F] << 32) | _color_palette_data[buffer_data[26] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x0F] << 32) | _color_palette_data[buffer_data[27] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x0F] << 32) | _color_palette_data[buffer_data[28] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x0F] << 32) | _color_palette_data[buffer_data[29] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x0F] << 32) | _color_palette_data[buffer_data[30] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x0F] << 32) | _color_palette_data[buffer_data[31] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x0F] << 32) | _color_palette_data[buffer_data[32] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x0F] << 32) | _color_palette_data[buffer_data[33] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x0F] << 32) | _color_palette_data[buffer_data[34] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x0F] << 32) | _color_palette_data[buffer_data[35] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x0F] << 32) | _color_palette_data[buffer_data[36] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x0F] << 32) | _color_palette_data[buffer_data[37] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x0F] << 32) | _color_palette_data[buffer_data[38] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x0F] << 32) | _color_palette_data[buffer_data[39] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x0F] << 32) | _color_palette_data[buffer_data[40] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x0F] << 32) | _color_palette_data[buffer_data[41] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x0F] << 32) | _color_palette_data[buffer_data[42] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x0F] << 32) | _color_palette_data[buffer_data[43] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x0F] << 32) | _color_palette_data[buffer_data[44] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x0F] << 32) | _color_palette_data[buffer_data[45] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x0F] << 32) | _color_palette_data[buffer_data[46] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x0F] << 32) | _color_palette_data[buffer_data[47] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x0F] << 32) | _color_palette_data[buffer_data[48] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x0F] << 32) | _color_palette_data[buffer_data[49] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x0F] << 32) | _color_palette_data[buffer_data[50] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x0F] << 32) | _color_palette_data[buffer_data[51] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x0F] << 32) | _color_palette_data[buffer_data[52] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x0F] << 32) | _color_palette_data[buffer_data[53] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x0F] << 32) | _color_palette_data[buffer_data[54] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x0F] << 32) | _color_palette_data[buffer_data[55] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x0F] << 32) | _color_palette_data[buffer_data[56] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x0F] << 32) | _color_palette_data[buffer_data[57] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x0F] << 32) | _color_palette_data[buffer_data[58] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x0F] << 32) | _color_palette_data[buffer_data[59] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x0F] << 32) | _color_palette_data[buffer_data[60] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x0F] << 32) | _color_palette_data[buffer_data[61] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x0F] << 32) | _color_palette_data[buffer_data[62] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x0F] << 32) | _color_palette_data[buffer_data[63] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[64] & 0x0F] << 32) | _color_palette_data[buffer_data[64] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[65] & 0x0F] << 32) | _color_palette_data[buffer_data[65] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[66] & 0x0F] << 32) | _color_palette_data[buffer_data[66] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[67] & 0x0F] << 32) | _color_palette_data[buffer_data[67] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[68] & 0x0F] << 32) | _color_palette_data[buffer_data[68] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[69] & 0x0F] << 32) | _color_palette_data[buffer_data[69] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[70] & 0x0F] << 32) | _color_palette_data[buffer_data[70] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[71] & 0x0F] << 32) | _color_palette_data[buffer_data[71] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[72] & 0x0F] << 32) | _color_palette_data[buffer_data[72] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[73] & 0x0F] << 32) | _color_palette_data[buffer_data[73] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[74] & 0x0F] << 32) | _color_palette_data[buffer_data[74] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[75] & 0x0F] << 32) | _color_palette_data[buffer_data[75] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[76] & 0x0F] << 32) | _color_palette_data[buffer_data[76] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[77] & 0x0F] << 32) | _color_palette_data[buffer_data[77] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[78] & 0x0F] << 32) | _color_palette_data[buffer_data[78] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[79] & 0x0F] << 32) | _color_palette_data[buffer_data[79] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[80] & 0x0F] << 32) | _color_palette_data[buffer_data[80] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[81] & 0x0F] << 32) | _color_palette_data[buffer_data[81] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[82] & 0x0F] << 32) | _color_palette_data[buffer_data[82] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[83] & 0x0F] << 32) | _color_palette_data[buffer_data[83] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[84] & 0x0F] << 32) | _color_palette_data[buffer_data[84] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[85] & 0x0F] << 32) | _color_palette_data[buffer_data[85] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[86] & 0x0F] << 32) | _color_palette_data[buffer_data[86] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[87] & 0x0F] << 32) | _color_palette_data[buffer_data[87] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[88] & 0x0F] << 32) | _color_palette_data[buffer_data[88] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[89] & 0x0F] << 32) | _color_palette_data[buffer_data[89] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[90] & 0x0F] << 32) | _color_palette_data[buffer_data[90] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[91] & 0x0F] << 32) | _color_palette_data[buffer_data[91] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[92] & 0x0F] << 32) | _color_palette_data[buffer_data[92] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[93] & 0x0F] << 32) | _color_palette_data[buffer_data[93] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[94] & 0x0F] << 32) | _color_palette_data[buffer_data[94] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[95] & 0x0F] << 32) | _color_palette_data[buffer_data[95] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[96] & 0x0F] << 32) | _color_palette_data[buffer_data[96] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[97] & 0x0F] << 32) | _color_palette_data[buffer_data[97] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[98] & 0x0F] << 32) | _color_palette_data[buffer_data[98] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[99] & 0x0F] << 32) | _color_palette_data[buffer_data[99] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[100] & 0x0F] << 32) | _color_palette_data[buffer_data[100] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[101] & 0x0F] << 32) | _color_palette_data[buffer_data[101] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[102] & 0x0F] << 32) | _color_palette_data[buffer_data[102] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[103] & 0x0F] << 32) | _color_palette_data[buffer_data[103] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[104] & 0x0F] << 32) | _color_palette_data[buffer_data[104] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[105] & 0x0F] << 32) | _color_palette_data[buffer_data[105] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[106] & 0x0F] << 32) | _color_palette_data[buffer_data[106] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[107] & 0x0F] << 32) | _color_palette_data[buffer_data[107] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[108] & 0x0F] << 32) | _color_palette_data[buffer_data[108] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[109] & 0x0F] << 32) | _color_palette_data[buffer_data[109] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[110] & 0x0F] << 32) | _color_palette_data[buffer_data[110] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[111] & 0x0F] << 32) | _color_palette_data[buffer_data[111] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[112] & 0x0F] << 32) | _color_palette_data[buffer_data[112] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[113] & 0x0F] << 32) | _color_palette_data[buffer_data[113] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[114] & 0x0F] << 32) | _color_palette_data[buffer_data[114] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[115] & 0x0F] << 32) | _color_palette_data[buffer_data[115] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[116] & 0x0F] << 32) | _color_palette_data[buffer_data[116] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[117] & 0x0F] << 32) | _color_palette_data[buffer_data[117] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[118] & 0x0F] << 32) | _color_palette_data[buffer_data[118] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[119] & 0x0F] << 32) | _color_palette_data[buffer_data[119] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[120] & 0x0F] << 32) | _color_palette_data[buffer_data[120] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[121] & 0x0F] << 32) | _color_palette_data[buffer_data[121] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[122] & 0x0F] << 32) | _color_palette_data[buffer_data[122] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[123] & 0x0F] << 32) | _color_palette_data[buffer_data[123] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[124] & 0x0F] << 32) | _color_palette_data[buffer_data[124] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[125] & 0x0F] << 32) | _color_palette_data[buffer_data[125] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[126] & 0x0F] << 32) | _color_palette_data[buffer_data[126] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[127] & 0x0F] << 32) | _color_palette_data[buffer_data[127] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[128] & 0x0F] << 32) | _color_palette_data[buffer_data[128] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[129] & 0x0F] << 32) | _color_palette_data[buffer_data[129] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[130] & 0x0F] << 32) | _color_palette_data[buffer_data[130] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[131] & 0x0F] << 32) | _color_palette_data[buffer_data[131] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[132] & 0x0F] << 32) | _color_palette_data[buffer_data[132] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[133] & 0x0F] << 32) | _color_palette_data[buffer_data[133] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[134] & 0x0F] << 32) | _color_palette_data[buffer_data[134] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[135] & 0x0F] << 32) | _color_palette_data[buffer_data[135] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[136] & 0x0F] << 32) | _color_palette_data[buffer_data[136] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[137] & 0x0F] << 32) | _color_palette_data[buffer_data[137] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[138] & 0x0F] << 32) | _color_palette_data[buffer_data[138] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[139] & 0x0F] << 32) | _color_palette_data[buffer_data[139] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[140] & 0x0F] << 32) | _color_palette_data[buffer_data[140] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[141] & 0x0F] << 32) | _color_palette_data[buffer_data[141] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[142] & 0x0F] << 32) | _color_palette_data[buffer_data[142] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[143] & 0x0F] << 32) | _color_palette_data[buffer_data[143] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[144] & 0x0F] << 32) | _color_palette_data[buffer_data[144] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[145] & 0x0F] << 32) | _color_palette_data[buffer_data[145] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[146] & 0x0F] << 32) | _color_palette_data[buffer_data[146] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[147] & 0x0F] << 32) | _color_palette_data[buffer_data[147] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[148] & 0x0F] << 32) | _color_palette_data[buffer_data[148] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[149] & 0x0F] << 32) | _color_palette_data[buffer_data[149] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[150] & 0x0F] << 32) | _color_palette_data[buffer_data[150] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[151] & 0x0F] << 32) | _color_palette_data[buffer_data[151] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[152] & 0x0F] << 32) | _color_palette_data[buffer_data[152] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[153] & 0x0F] << 32) | _color_palette_data[buffer_data[153] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[154] & 0x0F] << 32) | _color_palette_data[buffer_data[154] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[155] & 0x0F] << 32) | _color_palette_data[buffer_data[155] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[156] & 0x0F] << 32) | _color_palette_data[buffer_data[156] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[157] & 0x0F] << 32) | _color_palette_data[buffer_data[157] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[158] & 0x0F] << 32) | _color_palette_data[buffer_data[158] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[159] & 0x0F] << 32) | _color_palette_data[buffer_data[159] >> 4])


func _blit_128_4(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	# 4 pixels, 2 at a time
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[64] & 0x03] << 32) | (_color_palette_data[(buffer_data[64] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[64] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[64] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[65] & 0x03] << 32) | (_color_palette_data[(buffer_data[65] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[65] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[65] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[66] & 0x03] << 32) | (_color_palette_data[(buffer_data[66] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[66] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[66] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[67] & 0x03] << 32) | (_color_palette_data[(buffer_data[67] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[67] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[67] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[68] & 0x03] << 32) | (_color_palette_data[(buffer_data[68] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[68] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[68] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[69] & 0x03] << 32) | (_color_palette_data[(buffer_data[69] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[69] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[69] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[70] & 0x03] << 32) | (_color_palette_data[(buffer_data[70] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[70] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[70] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[71] & 0x03] << 32) | (_color_palette_data[(buffer_data[71] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[71] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[71] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[72] & 0x03] << 32) | (_color_palette_data[(buffer_data[72] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[72] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[72] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[73] & 0x03] << 32) | (_color_palette_data[(buffer_data[73] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[73] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[73] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[74] & 0x03] << 32) | (_color_palette_data[(buffer_data[74] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[74] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[74] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[75] & 0x03] << 32) | (_color_palette_data[(buffer_data[75] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[75] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[75] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[76] & 0x03] << 32) | (_color_palette_data[(buffer_data[76] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[76] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[76] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[77] & 0x03] << 32) | (_color_palette_data[(buffer_data[77] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[77] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[77] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[78] & 0x03] << 32) | (_color_palette_data[(buffer_data[78] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[78] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[78] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[79] & 0x03] << 32) | (_color_palette_data[(buffer_data[79] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[79] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[79] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[80] & 0x03] << 32) | (_color_palette_data[(buffer_data[80] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[80] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[80] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[81] & 0x03] << 32) | (_color_palette_data[(buffer_data[81] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[81] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[81] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[82] & 0x03] << 32) | (_color_palette_data[(buffer_data[82] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[82] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[82] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[83] & 0x03] << 32) | (_color_palette_data[(buffer_data[83] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[83] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[83] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[84] & 0x03] << 32) | (_color_palette_data[(buffer_data[84] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[84] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[84] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[85] & 0x03] << 32) | (_color_palette_data[(buffer_data[85] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[85] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[85] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[86] & 0x03] << 32) | (_color_palette_data[(buffer_data[86] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[86] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[86] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[87] & 0x03] << 32) | (_color_palette_data[(buffer_data[87] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[87] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[87] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[88] & 0x03] << 32) | (_color_palette_data[(buffer_data[88] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[88] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[88] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[89] & 0x03] << 32) | (_color_palette_data[(buffer_data[89] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[89] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[89] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[90] & 0x03] << 32) | (_color_palette_data[(buffer_data[90] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[90] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[91] & 0x03] << 32) | (_color_palette_data[(buffer_data[91] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[91] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[91] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[92] & 0x03] << 32) | (_color_palette_data[(buffer_data[92] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[92] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[92] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[93] & 0x03] << 32) | (_color_palette_data[(buffer_data[93] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[93] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[93] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[94] & 0x03] << 32) | (_color_palette_data[(buffer_data[94] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[94] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[94] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[95] & 0x03] << 32) | (_color_palette_data[(buffer_data[95] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[95] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[95] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[96] & 0x03] << 32) | (_color_palette_data[(buffer_data[96] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[96] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[96] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[97] & 0x03] << 32) | (_color_palette_data[(buffer_data[97] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[97] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[97] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[98] & 0x03] << 32) | (_color_palette_data[(buffer_data[98] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[98] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[98] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[99] & 0x03] << 32) | (_color_palette_data[(buffer_data[99] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[99] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[99] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[100] & 0x03] << 32) | (_color_palette_data[(buffer_data[100] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[100] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[100] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[101] & 0x03] << 32) | (_color_palette_data[(buffer_data[101] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[101] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[101] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[102] & 0x03] << 32) | (_color_palette_data[(buffer_data[102] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[102] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[102] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[103] & 0x03] << 32) | (_color_palette_data[(buffer_data[103] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[103] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[103] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[104] & 0x03] << 32) | (_color_palette_data[(buffer_data[104] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[104] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[104] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[105] & 0x03] << 32) | (_color_palette_data[(buffer_data[105] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[105] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[105] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[106] & 0x03] << 32) | (_color_palette_data[(buffer_data[106] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[106] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[106] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[107] & 0x03] << 32) | (_color_palette_data[(buffer_data[107] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[107] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[107] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[108] & 0x03] << 32) | (_color_palette_data[(buffer_data[108] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[108] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[108] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[109] & 0x03] << 32) | (_color_palette_data[(buffer_data[109] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[109] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[109] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[110] & 0x03] << 32) | (_color_palette_data[(buffer_data[110] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[110] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[110] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[111] & 0x03] << 32) | (_color_palette_data[(buffer_data[111] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[111] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[111] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[112] & 0x03] << 32) | (_color_palette_data[(buffer_data[112] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[112] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[112] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[113] & 0x03] << 32) | (_color_palette_data[(buffer_data[113] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[113] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[113] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[114] & 0x03] << 32) | (_color_palette_data[(buffer_data[114] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[114] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[114] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[115] & 0x03] << 32) | (_color_palette_data[(buffer_data[115] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[115] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[115] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[116] & 0x03] << 32) | (_color_palette_data[(buffer_data[116] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[116] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[116] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[117] & 0x03] << 32) | (_color_palette_data[(buffer_data[117] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[117] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[117] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[118] & 0x03] << 32) | (_color_palette_data[(buffer_data[118] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[118] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[118] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[119] & 0x03] << 32) | (_color_palette_data[(buffer_data[119] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[119] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[119] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[120] & 0x03] << 32) | (_color_palette_data[(buffer_data[120] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[120] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[120] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[121] & 0x03] << 32) | (_color_palette_data[(buffer_data[121] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[121] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[121] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[122] & 0x03] << 32) | (_color_palette_data[(buffer_data[122] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[122] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[122] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[123] & 0x03] << 32) | (_color_palette_data[(buffer_data[123] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[123] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[123] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[124] & 0x03] << 32) | (_color_palette_data[(buffer_data[124] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[124] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[124] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[125] & 0x03] << 32) | (_color_palette_data[(buffer_data[125] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[125] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[125] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[126] & 0x03] << 32) | (_color_palette_data[(buffer_data[126] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[126] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[126] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[127] & 0x03] << 32) | (_color_palette_data[(buffer_data[127] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[127] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[127] >> 6) & 0x03]))


func _blit_128_16(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x0F] << 32) | _color_palette_data[buffer_data[0] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x0F] << 32) | _color_palette_data[buffer_data[1] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x0F] << 32) | _color_palette_data[buffer_data[2] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x0F] << 32) | _color_palette_data[buffer_data[3] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x0F] << 32) | _color_palette_data[buffer_data[4] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x0F] << 32) | _color_palette_data[buffer_data[5] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x0F] << 32) | _color_palette_data[buffer_data[6] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x0F] << 32) | _color_palette_data[buffer_data[7] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x0F] << 32) | _color_palette_data[buffer_data[8] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x0F] << 32) | _color_palette_data[buffer_data[9] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x0F] << 32) | _color_palette_data[buffer_data[10] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x0F] << 32) | _color_palette_data[buffer_data[11] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x0F] << 32) | _color_palette_data[buffer_data[12] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x0F] << 32) | _color_palette_data[buffer_data[13] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x0F] << 32) | _color_palette_data[buffer_data[14] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x0F] << 32) | _color_palette_data[buffer_data[15] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x0F] << 32) | _color_palette_data[buffer_data[16] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x0F] << 32) | _color_palette_data[buffer_data[17] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x0F] << 32) | _color_palette_data[buffer_data[18] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x0F] << 32) | _color_palette_data[buffer_data[19] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x0F] << 32) | _color_palette_data[buffer_data[20] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x0F] << 32) | _color_palette_data[buffer_data[21] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x0F] << 32) | _color_palette_data[buffer_data[22] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x0F] << 32) | _color_palette_data[buffer_data[23] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x0F] << 32) | _color_palette_data[buffer_data[24] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x0F] << 32) | _color_palette_data[buffer_data[25] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x0F] << 32) | _color_palette_data[buffer_data[26] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x0F] << 32) | _color_palette_data[buffer_data[27] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x0F] << 32) | _color_palette_data[buffer_data[28] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x0F] << 32) | _color_palette_data[buffer_data[29] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x0F] << 32) | _color_palette_data[buffer_data[30] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x0F] << 32) | _color_palette_data[buffer_data[31] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x0F] << 32) | _color_palette_data[buffer_data[32] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x0F] << 32) | _color_palette_data[buffer_data[33] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x0F] << 32) | _color_palette_data[buffer_data[34] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x0F] << 32) | _color_palette_data[buffer_data[35] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x0F] << 32) | _color_palette_data[buffer_data[36] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x0F] << 32) | _color_palette_data[buffer_data[37] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x0F] << 32) | _color_palette_data[buffer_data[38] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x0F] << 32) | _color_palette_data[buffer_data[39] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x0F] << 32) | _color_palette_data[buffer_data[40] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x0F] << 32) | _color_palette_data[buffer_data[41] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x0F] << 32) | _color_palette_data[buffer_data[42] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x0F] << 32) | _color_palette_data[buffer_data[43] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x0F] << 32) | _color_palette_data[buffer_data[44] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x0F] << 32) | _color_palette_data[buffer_data[45] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x0F] << 32) | _color_palette_data[buffer_data[46] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x0F] << 32) | _color_palette_data[buffer_data[47] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x0F] << 32) | _color_palette_data[buffer_data[48] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x0F] << 32) | _color_palette_data[buffer_data[49] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x0F] << 32) | _color_palette_data[buffer_data[50] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x0F] << 32) | _color_palette_data[buffer_data[51] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x0F] << 32) | _color_palette_data[buffer_data[52] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x0F] << 32) | _color_palette_data[buffer_data[53] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x0F] << 32) | _color_palette_data[buffer_data[54] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x0F] << 32) | _color_palette_data[buffer_data[55] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x0F] << 32) | _color_palette_data[buffer_data[56] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x0F] << 32) | _color_palette_data[buffer_data[57] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x0F] << 32) | _color_palette_data[buffer_data[58] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x0F] << 32) | _color_palette_data[buffer_data[59] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x0F] << 32) | _color_palette_data[buffer_data[60] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x0F] << 32) | _color_palette_data[buffer_data[61] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x0F] << 32) | _color_palette_data[buffer_data[62] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x0F] << 32) | _color_palette_data[buffer_data[63] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[64] & 0x0F] << 32) | _color_palette_data[buffer_data[64] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[65] & 0x0F] << 32) | _color_palette_data[buffer_data[65] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[66] & 0x0F] << 32) | _color_palette_data[buffer_data[66] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[67] & 0x0F] << 32) | _color_palette_data[buffer_data[67] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[68] & 0x0F] << 32) | _color_palette_data[buffer_data[68] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[69] & 0x0F] << 32) | _color_palette_data[buffer_data[69] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[70] & 0x0F] << 32) | _color_palette_data[buffer_data[70] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[71] & 0x0F] << 32) | _color_palette_data[buffer_data[71] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[72] & 0x0F] << 32) | _color_palette_data[buffer_data[72] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[73] & 0x0F] << 32) | _color_palette_data[buffer_data[73] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[74] & 0x0F] << 32) | _color_palette_data[buffer_data[74] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[75] & 0x0F] << 32) | _color_palette_data[buffer_data[75] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[76] & 0x0F] << 32) | _color_palette_data[buffer_data[76] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[77] & 0x0F] << 32) | _color_palette_data[buffer_data[77] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[78] & 0x0F] << 32) | _color_palette_data[buffer_data[78] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[79] & 0x0F] << 32) | _color_palette_data[buffer_data[79] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[80] & 0x0F] << 32) | _color_palette_data[buffer_data[80] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[81] & 0x0F] << 32) | _color_palette_data[buffer_data[81] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[82] & 0x0F] << 32) | _color_palette_data[buffer_data[82] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[83] & 0x0F] << 32) | _color_palette_data[buffer_data[83] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[84] & 0x0F] << 32) | _color_palette_data[buffer_data[84] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[85] & 0x0F] << 32) | _color_palette_data[buffer_data[85] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[86] & 0x0F] << 32) | _color_palette_data[buffer_data[86] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[87] & 0x0F] << 32) | _color_palette_data[buffer_data[87] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[88] & 0x0F] << 32) | _color_palette_data[buffer_data[88] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[89] & 0x0F] << 32) | _color_palette_data[buffer_data[89] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[90] & 0x0F] << 32) | _color_palette_data[buffer_data[90] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[91] & 0x0F] << 32) | _color_palette_data[buffer_data[91] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[92] & 0x0F] << 32) | _color_palette_data[buffer_data[92] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[93] & 0x0F] << 32) | _color_palette_data[buffer_data[93] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[94] & 0x0F] << 32) | _color_palette_data[buffer_data[94] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[95] & 0x0F] << 32) | _color_palette_data[buffer_data[95] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[96] & 0x0F] << 32) | _color_palette_data[buffer_data[96] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[97] & 0x0F] << 32) | _color_palette_data[buffer_data[97] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[98] & 0x0F] << 32) | _color_palette_data[buffer_data[98] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[99] & 0x0F] << 32) | _color_palette_data[buffer_data[99] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[100] & 0x0F] << 32) | _color_palette_data[buffer_data[100] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[101] & 0x0F] << 32) | _color_palette_data[buffer_data[101] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[102] & 0x0F] << 32) | _color_palette_data[buffer_data[102] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[103] & 0x0F] << 32) | _color_palette_data[buffer_data[103] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[104] & 0x0F] << 32) | _color_palette_data[buffer_data[104] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[105] & 0x0F] << 32) | _color_palette_data[buffer_data[105] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[106] & 0x0F] << 32) | _color_palette_data[buffer_data[106] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[107] & 0x0F] << 32) | _color_palette_data[buffer_data[107] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[108] & 0x0F] << 32) | _color_palette_data[buffer_data[108] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[109] & 0x0F] << 32) | _color_palette_data[buffer_data[109] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[110] & 0x0F] << 32) | _color_palette_data[buffer_data[110] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[111] & 0x0F] << 32) | _color_palette_data[buffer_data[111] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[112] & 0x0F] << 32) | _color_palette_data[buffer_data[112] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[113] & 0x0F] << 32) | _color_palette_data[buffer_data[113] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[114] & 0x0F] << 32) | _color_palette_data[buffer_data[114] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[115] & 0x0F] << 32) | _color_palette_data[buffer_data[115] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[116] & 0x0F] << 32) | _color_palette_data[buffer_data[116] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[117] & 0x0F] << 32) | _color_palette_data[buffer_data[117] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[118] & 0x0F] << 32) | _color_palette_data[buffer_data[118] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[119] & 0x0F] << 32) | _color_palette_data[buffer_data[119] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[120] & 0x0F] << 32) | _color_palette_data[buffer_data[120] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[121] & 0x0F] << 32) | _color_palette_data[buffer_data[121] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[122] & 0x0F] << 32) | _color_palette_data[buffer_data[122] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[123] & 0x0F] << 32) | _color_palette_data[buffer_data[123] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[124] & 0x0F] << 32) | _color_palette_data[buffer_data[124] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[125] & 0x0F] << 32) | _color_palette_data[buffer_data[125] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[126] & 0x0F] << 32) | _color_palette_data[buffer_data[126] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[127] & 0x0F] << 32) | _color_palette_data[buffer_data[127] >> 4])


func _blit_80_2(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	# 8 pixels, 2 at a time
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[64] & 0x01] << 32) | (_color_palette_data[(buffer_data[64] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[64] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[64] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[64] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[64] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[64] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[64] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[65] & 0x01] << 32) | (_color_palette_data[(buffer_data[65] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[65] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[65] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[65] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[65] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[65] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[65] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[66] & 0x01] << 32) | (_color_palette_data[(buffer_data[66] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[66] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[66] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[66] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[66] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[66] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[66] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[67] & 0x01] << 32) | (_color_palette_data[(buffer_data[67] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[67] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[67] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[67] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[67] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[67] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[67] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[68] & 0x01] << 32) | (_color_palette_data[(buffer_data[68] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[68] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[68] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[68] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[68] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[68] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[68] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[69] & 0x01] << 32) | (_color_palette_data[(buffer_data[69] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[69] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[69] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[69] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[69] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[69] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[69] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[70] & 0x01] << 32) | (_color_palette_data[(buffer_data[70] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[70] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[70] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[70] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[70] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[70] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[70] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[71] & 0x01] << 32) | (_color_palette_data[(buffer_data[71] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[71] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[71] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[71] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[71] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[71] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[71] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[72] & 0x01] << 32) | (_color_palette_data[(buffer_data[72] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[72] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[72] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[72] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[72] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[72] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[72] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[73] & 0x01] << 32) | (_color_palette_data[(buffer_data[73] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[73] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[73] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[73] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[73] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[73] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[73] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[74] & 0x01] << 32) | (_color_palette_data[(buffer_data[74] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[74] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[74] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[74] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[74] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[74] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[74] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[75] & 0x01] << 32) | (_color_palette_data[(buffer_data[75] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[75] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[75] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[75] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[75] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[75] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[75] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[76] & 0x01] << 32) | (_color_palette_data[(buffer_data[76] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[76] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[76] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[76] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[76] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[76] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[76] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[77] & 0x01] << 32) | (_color_palette_data[(buffer_data[77] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[77] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[77] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[77] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[77] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[77] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[77] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[78] & 0x01] << 32) | (_color_palette_data[(buffer_data[78] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[78] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[78] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[78] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[78] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[78] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[78] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[79] & 0x01] << 32) | (_color_palette_data[(buffer_data[79] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[79] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[79] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[79] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[79] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[79] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[79] >> 7) & 0x01]))


func _blit_80_4(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	# 4 pixels, 2 at a time
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[64] & 0x03] << 32) | (_color_palette_data[(buffer_data[64] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[64] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[64] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[65] & 0x03] << 32) | (_color_palette_data[(buffer_data[65] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[65] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[65] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[66] & 0x03] << 32) | (_color_palette_data[(buffer_data[66] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[66] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[66] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[67] & 0x03] << 32) | (_color_palette_data[(buffer_data[67] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[67] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[67] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[68] & 0x03] << 32) | (_color_palette_data[(buffer_data[68] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[68] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[68] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[69] & 0x03] << 32) | (_color_palette_data[(buffer_data[69] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[69] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[69] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[70] & 0x03] << 32) | (_color_palette_data[(buffer_data[70] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[70] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[70] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[71] & 0x03] << 32) | (_color_palette_data[(buffer_data[71] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[71] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[71] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[72] & 0x03] << 32) | (_color_palette_data[(buffer_data[72] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[72] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[72] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[73] & 0x03] << 32) | (_color_palette_data[(buffer_data[73] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[73] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[73] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[74] & 0x03] << 32) | (_color_palette_data[(buffer_data[74] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[74] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[74] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[75] & 0x03] << 32) | (_color_palette_data[(buffer_data[75] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[75] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[75] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[76] & 0x03] << 32) | (_color_palette_data[(buffer_data[76] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[76] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[76] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[77] & 0x03] << 32) | (_color_palette_data[(buffer_data[77] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[77] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[77] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[78] & 0x03] << 32) | (_color_palette_data[(buffer_data[78] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[78] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[78] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[79] & 0x03] << 32) | (_color_palette_data[(buffer_data[79] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[79] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[79] >> 6) & 0x03]))


func _blit_80_16(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x0F] << 32) | _color_palette_data[buffer_data[0] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x0F] << 32) | _color_palette_data[buffer_data[1] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x0F] << 32) | _color_palette_data[buffer_data[2] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x0F] << 32) | _color_palette_data[buffer_data[3] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x0F] << 32) | _color_palette_data[buffer_data[4] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x0F] << 32) | _color_palette_data[buffer_data[5] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x0F] << 32) | _color_palette_data[buffer_data[6] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x0F] << 32) | _color_palette_data[buffer_data[7] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x0F] << 32) | _color_palette_data[buffer_data[8] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x0F] << 32) | _color_palette_data[buffer_data[9] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x0F] << 32) | _color_palette_data[buffer_data[10] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x0F] << 32) | _color_palette_data[buffer_data[11] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x0F] << 32) | _color_palette_data[buffer_data[12] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x0F] << 32) | _color_palette_data[buffer_data[13] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x0F] << 32) | _color_palette_data[buffer_data[14] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x0F] << 32) | _color_palette_data[buffer_data[15] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x0F] << 32) | _color_palette_data[buffer_data[16] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x0F] << 32) | _color_palette_data[buffer_data[17] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x0F] << 32) | _color_palette_data[buffer_data[18] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x0F] << 32) | _color_palette_data[buffer_data[19] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x0F] << 32) | _color_palette_data[buffer_data[20] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x0F] << 32) | _color_palette_data[buffer_data[21] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x0F] << 32) | _color_palette_data[buffer_data[22] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x0F] << 32) | _color_palette_data[buffer_data[23] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x0F] << 32) | _color_palette_data[buffer_data[24] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x0F] << 32) | _color_palette_data[buffer_data[25] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x0F] << 32) | _color_palette_data[buffer_data[26] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x0F] << 32) | _color_palette_data[buffer_data[27] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x0F] << 32) | _color_palette_data[buffer_data[28] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x0F] << 32) | _color_palette_data[buffer_data[29] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x0F] << 32) | _color_palette_data[buffer_data[30] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x0F] << 32) | _color_palette_data[buffer_data[31] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x0F] << 32) | _color_palette_data[buffer_data[32] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x0F] << 32) | _color_palette_data[buffer_data[33] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x0F] << 32) | _color_palette_data[buffer_data[34] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x0F] << 32) | _color_palette_data[buffer_data[35] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x0F] << 32) | _color_palette_data[buffer_data[36] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x0F] << 32) | _color_palette_data[buffer_data[37] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x0F] << 32) | _color_palette_data[buffer_data[38] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x0F] << 32) | _color_palette_data[buffer_data[39] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x0F] << 32) | _color_palette_data[buffer_data[40] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x0F] << 32) | _color_palette_data[buffer_data[41] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x0F] << 32) | _color_palette_data[buffer_data[42] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x0F] << 32) | _color_palette_data[buffer_data[43] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x0F] << 32) | _color_palette_data[buffer_data[44] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x0F] << 32) | _color_palette_data[buffer_data[45] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x0F] << 32) | _color_palette_data[buffer_data[46] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x0F] << 32) | _color_palette_data[buffer_data[47] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x0F] << 32) | _color_palette_data[buffer_data[48] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x0F] << 32) | _color_palette_data[buffer_data[49] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x0F] << 32) | _color_palette_data[buffer_data[50] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x0F] << 32) | _color_palette_data[buffer_data[51] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x0F] << 32) | _color_palette_data[buffer_data[52] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x0F] << 32) | _color_palette_data[buffer_data[53] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x0F] << 32) | _color_palette_data[buffer_data[54] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x0F] << 32) | _color_palette_data[buffer_data[55] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x0F] << 32) | _color_palette_data[buffer_data[56] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x0F] << 32) | _color_palette_data[buffer_data[57] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x0F] << 32) | _color_palette_data[buffer_data[58] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x0F] << 32) | _color_palette_data[buffer_data[59] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x0F] << 32) | _color_palette_data[buffer_data[60] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x0F] << 32) | _color_palette_data[buffer_data[61] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x0F] << 32) | _color_palette_data[buffer_data[62] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x0F] << 32) | _color_palette_data[buffer_data[63] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[64] & 0x0F] << 32) | _color_palette_data[buffer_data[64] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[65] & 0x0F] << 32) | _color_palette_data[buffer_data[65] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[66] & 0x0F] << 32) | _color_palette_data[buffer_data[66] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[67] & 0x0F] << 32) | _color_palette_data[buffer_data[67] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[68] & 0x0F] << 32) | _color_palette_data[buffer_data[68] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[69] & 0x0F] << 32) | _color_palette_data[buffer_data[69] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[70] & 0x0F] << 32) | _color_palette_data[buffer_data[70] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[71] & 0x0F] << 32) | _color_palette_data[buffer_data[71] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[72] & 0x0F] << 32) | _color_palette_data[buffer_data[72] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[73] & 0x0F] << 32) | _color_palette_data[buffer_data[73] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[74] & 0x0F] << 32) | _color_palette_data[buffer_data[74] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[75] & 0x0F] << 32) | _color_palette_data[buffer_data[75] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[76] & 0x0F] << 32) | _color_palette_data[buffer_data[76] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[77] & 0x0F] << 32) | _color_palette_data[buffer_data[77] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[78] & 0x0F] << 32) | _color_palette_data[buffer_data[78] >> 4])
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[79] & 0x0F] << 32) | _color_palette_data[buffer_data[79] >> 4])


func _blit_64_4(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	# 4 pixels, 2 at a time
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[0] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[1] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[2] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[3] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[4] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[5] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[6] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[7] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[8] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[9] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[10] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[11] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[12] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[13] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[14] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[15] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[16] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[17] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[18] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[19] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[20] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[21] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[22] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[23] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[24] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[25] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[26] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[27] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[28] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[29] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[30] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[31] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[32] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[33] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[34] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[35] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[36] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[37] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[38] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[39] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[40] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[41] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[42] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[43] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[44] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[45] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[46] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[47] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[48] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[49] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[50] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[51] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[52] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[53] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[54] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[55] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[56] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[57] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[58] >> 6) & 0x03]))
	
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[59] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[60] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[61] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[62] >> 6) & 0x03]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 2) & 0x03]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 4) & 0x03] << 32) | (_color_palette_data[(buffer_data[63] >> 6) & 0x03]))


func _blit_64_2(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	# 8 pixels, 2 at a time
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[32] & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[32] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[32] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[33] & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[33] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[33] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[34] & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[34] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[34] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[35] & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[35] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[35] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[36] & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[36] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[36] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[37] & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[37] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[37] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[38] & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[38] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[38] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[39] & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[39] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[39] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[40] & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[40] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[40] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[41] & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[41] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[41] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[42] & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[42] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[42] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[43] & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[43] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[43] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[44] & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[44] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[44] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[45] & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[45] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[45] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[46] & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[46] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[46] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[47] & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[47] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[47] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[48] & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[48] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[48] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[49] & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[49] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[49] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[50] & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[50] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[50] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[51] & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[51] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[51] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[52] & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[52] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[52] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[53] & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[53] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[53] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[54] & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[54] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[54] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[55] & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[55] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[55] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[56] & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[56] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[56] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[57] & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[57] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[57] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[58] & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[58] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[58] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[59] & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[59] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[59] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[60] & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[60] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[60] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[61] & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[61] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[61] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[62] & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[62] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[62] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[63] & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[63] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[63] >> 7) & 0x01]))


func _blit_32_2(buffer_data: Array) -> void:
	var _color_palette_data := color_palette_data.colors
	# 8 pixels, 2 at a time
	target_screen_buffer.put_u64((_color_palette_data[buffer_data[0] & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[0] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[0] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[1] & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[1] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[1] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[2] & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[2] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[2] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[3] & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[3] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[3] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[4] & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[4] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[4] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[5] & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[5] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[5] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[6] & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[6] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[6] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[7] & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[7] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[7] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[8] & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[8] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[8] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[9] & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[9] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[9] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[10] & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[10] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[10] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[11] & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[11] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[11] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[12] & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[12] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[12] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[13] & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[13] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[13] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[14] & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[14] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[14] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[15] & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[15] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[15] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[16] & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[16] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[16] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[17] & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[17] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[17] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[18] & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[18] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[18] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[19] & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[19] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[19] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[20] & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[20] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[20] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[21] & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[21] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[21] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[22] & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[22] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[22] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[23] & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[23] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[23] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[24] & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[24] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[24] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[25] & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[25] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[25] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[26] & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[26] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[26] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[27] & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[27] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[27] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[28] & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[28] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[28] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[29] & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[29] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[29] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[30] & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[30] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[30] >> 7) & 0x01]))

	target_screen_buffer.put_u64((_color_palette_data[buffer_data[31] & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 1) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 2) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 3) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 4) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 5) & 0x01]))
	target_screen_buffer.put_u64((_color_palette_data[(buffer_data[31] >> 6) & 0x01] << 32) | (_color_palette_data[(buffer_data[31] >> 7) & 0x01]))

