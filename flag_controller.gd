extends Area2D
var tile_size = 64
var flag_picked_up = false

export var team = "blue"


# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func action_sort(x, y):
	return actions[x] > actions[y]

func _process(delta):
	try_move()
	if not tween.is_active():
		$AnimatedSprite.set_frame(0)	
		$AnimatedSprite.stop()

func try_move():
	# Currently moving
	if tween.is_active():
		return
	
	# Get input direction
	var dir = get_new_direction()
	if dir == null:
		return
	
	# Check if new position has a wall
	if rays[dir].is_colliding():
		return
	
	# Start move to new tile
	var new_pos = directions[dir] * tile_size + position
	tween.interpolate_property(self, "position", position, new_pos, 1.0/speed, Tween.TRANS_LINEAR, 0)
	tween.start()
	
	# Set new facing direction
	facing = dir
	$AnimatedSprite.play(facing)

func get_new_direction(): 
	var inputs = actions.keys()
	inputs.sort_custom(self, "action_sort")
	
	for input in inputs:
		if Input.is_action_pressed(input):
			return input
	return null

func _unhandled_input(event):
	for dir in actions.keys():
		if event.is_action_pressed(dir):
			actions[dir] = OS.get_ticks_msec()

	
