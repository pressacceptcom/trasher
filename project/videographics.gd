class_name VideoGraphics
extends TextureRect

signal horizontal_sync()
signal memory_accessed(address, vdg)

const SCREEN_WIDTH: int = 640
const SCREEN_HEIGHT: int = 480
const BYTE_PER_PIXEL: int = 3

var screen: Image
var screen_buffer: PoolByteArray

var byte_from_memory

func _init() -> void:
	screen_buffer.resize(SCREEN_WIDTH * SCREEN_HEIGHT * BYTE_PER_PIXEL)
	var address: int = 0
	for y in range(SCREEN_HEIGHT):
		for x in range(SCREEN_WIDTH):
			address = ((y * x) + x * 3)
			screen_buffer[address] = 0
			screen_buffer[address + 1] = 0
			screen_buffer[address + 2] = 0

	screen = Image.new()
	screen.create_from_data(
		SCREEN_WIDTH,
		SCREEN_HEIGHT,
		false,
		Image.FORMAT_RGB8,
		screen_buffer
	)

	texture = ImageTexture.new()
	texture.create_from_image(screen, 0)


func _draw() -> void:
	# render a frame
	pass


func _horizontal_sync() -> void:
	# a line has been rendered we now assert horizontal sync and advance the processor
	pass

