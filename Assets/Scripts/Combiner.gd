extends Viewport

onready var sprite = $Sprite

func _ready():
	sprite.flip_v = true

func _process(delta):
	if get_child_count() > 4:
		# combine all images to one
		var image = get_texture().get_data()
		var tex = ImageTexture.new()
		tex.create_from_image(image)
		sprite.texture = tex
		freeOldestHistoryStates()

func freeOldestHistoryStates():
	remove_child(sprite)
	var newest = get_child(get_child_count() - 1)
	newest.remove_and_skip()
	for child in get_children():
		child.queue_free()
	add_child(sprite)
	add_child(newest)
