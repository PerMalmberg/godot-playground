class_name FogOfWar
extends Node2D

var img: Image = null
var dirty := true

func _process(_delta: float) -> void:
	if !dirty:
		dirty = true
		return

	if !img:
		img = create_image()

	_update_image()

func _update_image() -> void:
	_fill_with_fog()

	var items := RevealerManager.Instance().get_revealers()
	for r in items:
		r.reveal(img)

	%fogSprite.texture = ImageTexture.create_from_image(img)
	#dirty = false

func _fill_with_fog() -> void:
	img.fill(Color.BLACK)

func create_image() -> Image:
	# Create an image the size of the viewport
	var size := get_viewport_rect().size
	var image := Image.create(int(size.x), int(size.y), false, Image.FORMAT_LA8)

	# Position is calculated from center of image, so offset it by half size
	%fogSprite.position = Vector2(size.x, size.y) / 2

	return image
