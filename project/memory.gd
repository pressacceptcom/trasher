class_name Memory
extends Node

var memory_space: Array


func _init() -> void:
	memory_space.resize(131072)

	for i in range(131072):
		memory_space[i] = 0
	
	memory_space[0] = Mc68b09e.Opcodes.ADDA_IMMEDIATE
	memory_space[1] = 1
	memory_space[2] = Mc68b09e.Opcodes.JMP_EXTENDED
	memory_space[3] = 0
	memory_space[4] = 0

	for i in range(8, 72008):
		memory_space[i] = i % 255



func _on_ACVC_memory_accessed(real_address: int, pins) -> void:
	if pins.rw:
		# read operation
		pins.data = memory_space[real_address]
	else:
		#write opertion
		memory_space[real_address] = pins.data


func _on_ACVC_memory_accessed_by_vdg(address: int, num_bytes: int, buffer: Dictionary) -> void:
	# read only
	buffer.data = memory_space.slice(address, address + num_bytes - 1)
