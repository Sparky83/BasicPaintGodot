extends Node2D

const HISTORY_SIZE = 16

signal updateBrush

onready var UI = $UI
onready var uiBrush = $UI/UIBrush

onready var viewport = $Viewport
onready var canvas = $Viewport/Canvas
onready var display = $Display
onready var history = $History
onready var combiner = $Combiner
onready var combinerView = $CombinerView

var undoneElems = []

func _ready():
	display.flip_v = true
	display.texture = viewport.get_texture()
	combinerView.flip_v = true
	combinerView.texture = combiner.get_texture()
	uiBrush.connect("brushSizeChanged", self, "onBrushSizeChange")
	connect("updateBrush", uiBrush, "onBrushUpdated")

func _input(event):
	if isCursorInUI():
		return
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			if !undoneElems.empty():
				clearUndoneElements()
			canvas.drawActive = true
		if !event.pressed && event.button_index == BUTTON_LEFT:
			canvas.drawActive = false
			drawing_halted()

func _process(delta):
	canvas.pos = get_viewport().get_mouse_position()
	if canvas.drawActive:
		canvas.update()
	# keyboard inputs #############################################
	if Input.is_action_just_pressed("short_undo"):
		if history.get_child_count() != 0:
			var mostRecent : Node = history.get_children().back()
			mostRecent.remove_and_skip()
			undoneElems.append(mostRecent)
		else:
			print("Nothing to undo!")
	if Input.is_action_just_pressed("short_redo"):
		if !undoneElems.empty():
			var redoElem = undoneElems.pop_back()
			history.add_child(redoElem)
		else:
			print("Redo is empty!")
	if Input.is_action_just_pressed("short_showui"):
		UI.visible = !UI.visible

func drawing_halted():
	canvas.lastPos = null
	var newCanvas = canvas.duplicate(4)
	var oldCanvas = canvas
	viewport.add_child(newCanvas)
	canvas = newCanvas
	makeNewSpriteFromCanvas()
	oldCanvas.free()
	tidyUpHistory()
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	
func makeNewSpriteFromCanvas():
	var img : Image = viewport.get_texture().get_data()
	var imgTex = ImageTexture.new()
	imgTex.create_from_image(img)
	var spr = Sprite.new()
	history.add_child(spr)
	spr.flip_v = true
	spr.texture = imgTex
	spr.centered = false
	spr.name = "TEST"

func tidyUpHistory():
	if history.get_child_count() > HISTORY_SIZE:
		var child = history.get_child(0)
		child.remove_and_skip()
		combiner.add_child(child)
		
func clearUndoneElements():
	for elem in undoneElems:
		elem.queue_free()
	undoneElems.clear()
	
func onBrushSizeChange(size):
	Global.brushSize = size
	emit_signal("updateBrush")
	
func isCursorInUI():
	var cursorPos = get_viewport().get_mouse_position()
	var aabbs = getUiAABBs()
	return isPointInBoxes(cursorPos, aabbs)
	
func getUiAABBs():
	var boxes = []
	if UI.visible:
		for elem in UI.get_children():
			if !elem.visible:
				continue
			var uiElem : Control = elem
			var aabb = Rect2(uiElem.rect_position, uiElem.rect_size * uiElem.rect_scale.x)
			boxes.append(aabb)
	return boxes
	
func isPointInBoxes(point : Vector2, boxes : Array):
	for box in boxes:
		if box.has_point(point):
			return true
	return false
