extends Node
## Reveals an area in the fog of war
##
## Add this node to your nodes that needs to reveal an area in the fog of war.
##
class_name RevealerBehavior

@onready var parent: Node2D = get_parent()

static var circle : Image
static func _loadCircle(format:Image.Format) -> Image:
	if !circle:
		circle = Image.new()
		circle.copy_from(preload("res://white_circle_64x64.png").get_image())
		circle.resize(32,32) # To match the collider size
		circle.convert(format)
	return circle

var _mgr:RevealerManager = RevealerManager.Instance()

func _exit_tree() -> void:
	_mgr.unregister(self)

func _ready() -> void:
	_mgr.register_for_reveal(self)
	
func reveal(img:Image) -> void:
	var c := RevealerBehavior._loadCircle(img.get_format())
	# Target destinations specify the center of the shapes, *not* the upper left corner.
	img.blit_rect_mask(c, c, Rect2i(Vector2i(), c.get_size()), Vector2i(parent.position) - c.get_size() / 2)
	# For a rect, we the traget rect specify the upper left corner
	#img.fill_rect(Rect2i(Vector2i(parent.position) - Vector2i(30, 30) / 2, Vector2i(30, 30)), Color.TRANSPARENT)
