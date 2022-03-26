extends Node2D

var pos = Vector2(20,20)
var lastPos = null
var drawActive = false

func _draw():
	if !drawActive || pos == lastPos:
		return
	# interpolate when distance between last element
	# and this element is too big
	if lastPos != null:
		var distSqr = lastPos.distance_squared_to(pos)
		if distanceTooBig(distSqr):
			putBrushDot(pos)
			draw_interpolated(distSqr)
		else:
			putBrushDot(pos)
		lastPos = pos
	else:
		lastPos = pos
		putBrushDot(pos)
	
func distanceTooBig(dist2):
	return dist2 > max_dist_btwn_dots() * max_dist_btwn_dots()

func draw_interpolated(distSqr):
	var dirVector : Vector2 = lastPos.direction_to(pos)
	dirVector = dirVector * max_dist_btwn_dots()
	var interpVector = Vector2(dirVector)
	while interpVector.length_squared() < distSqr:
		putBrushDot(lastPos + interpVector)
		interpVector += dirVector
		
func getSize():
	return Global.brushSize
	
func max_dist_btwn_dots():
	return Global.brushSize / 2.0

func putBrushDot(pos):
	draw_circle(pos, getSize(), Color.black)
	var transp = Color.black
	transp.a = 0.05
	draw_circle(pos, getSize() + getSize() * 0.25, transp)
	draw_circle(pos, getSize() + getSize() * 0.5, transp)
	draw_circle(pos, getSize() + getSize() * 0.75, transp)
