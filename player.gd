extends Area2D
var tile_size = 64

export var speed = 5
onready var tween = $Tween

var direction = Vector2.ZERO

var actions = {
	"move_left": 0,
	"move_right": 0,
	"move_up": 0,
	"move_down": 0,
}

var directions = {
	"move_left": Vector2.LEFT,
	"move_right":  Vector2.RIGHT,
	"move_up":  Vector2.UP,
	"move_down":  Vector2.DOWN,
}

onready var rays = {
	"move_left": $ray_move_left,
	"move_right":  $ray_move_right,
	"move_up":  $ray_move_up,
	"move_down":  $ray_move_down,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * tile_size)

func action_sort(x, y):
	return actions[x] > actions[y]

func _process(delta):
	try_move()

	$AnimatedSprite.play()

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
	
	# Move to new tile
	var new_pos = directions[dir] * tile_size + position
	tween.interpolate_property(self, "position", position, new_pos, 1.0/speed, Tween.TRANS_LINEAR, 0)
	tween.start()

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

	
