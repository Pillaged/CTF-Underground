extends Area2D
var tile_size = 64

export var speed = 5
export var flag_rotation_speed = PI
export var has_team_flag = "blue"

onready var tween = $Tween
onready var animatedSprite = $AnimatedSprite

var direction = Vector2.ZERO

var facing = "move_down"

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
	position += Vector2.ONE * tile_size/2
	set_flag_visible(has_team_flag != "")

func action_sort(x, y):
	return actions[x] > actions[y]

func _process(delta):
	# Currently moving
	if not tween.is_active():
		try_move()
			
	rotate_flag(delta)

# Tries to start a move in the direction the player is facing. Changes the 
# direction of the player.
# Returns true is the player if the player is moving, false otherwise. If the 
# only change is in direction, then returns false.
func try_move():
	# Get input direction
	var dir = get_new_direction()
	if dir == null:
		return false
	
	# Set new facing direction
	facing = dir
	
	# Check if new position has a wall
	if rays[dir].is_colliding():
		return false
	
	# Start move to new tile
	var new_pos = directions[dir] * tile_size + position
	tween.interpolate_callback(self, 1.0/speed, "move_callback")
	tween.interpolate_property(self, "position", position, new_pos, 1.0/speed, Tween.TRANS_LINEAR, 0)
	tween.start()
	
	$AnimatedSprite.play(facing)
	return true
	
	
func move_callback():
	if not try_move():
		$AnimatedSprite.stop()

	
func rotate_flag(delta):
	$Pivot.rotation += flag_rotation_speed * delta


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

func set_flag_visible(val):
	$Pivot/Flag.visible = val
	
