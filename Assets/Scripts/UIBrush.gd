extends Panel

signal brushSizeChanged

onready var nameLabel = $Name
onready var sizeLabel = $Size
onready var slider = $Slider

# Called when the node enters the scene tree for the first time.
func _ready():
	onBrushUpdated()
	slider.connect("value_changed", self, "onSliderChanged")
	
func onSliderChanged(val):
	emit_signal("brushSizeChanged", val)

func onBrushUpdated():
	slider.value = Global.brushSize
	sizeLabel.text = str(Global.brushSize)
