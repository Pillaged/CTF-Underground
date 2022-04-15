extends Area2D
var tile_size = 64

export var speed = 5
export var flag_rotation_speed = PI
export var held_flag = ""

onready var tween = $Tween
onready var animatedSprite = $AnimatedSprite

var held_flag_controller = null
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
	position = (position - Vector2.ONE * tile_size/2).snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	set_held_flag(held_flag, null)

func action_sort(x, y):
	return actions[x] > actions[y]

func _process(delta):
	# Currently moving
	if not tween.is_active():
		$AnimatedSprite.stop()
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
	$AnimatedSprite.play(facing)
	
	# Check if new position has a wall
	if rays[dir].is_colliding():
		return false
	
	# Start move to new tile
	var new_pos = directions[dir] * tile_size + position
	tween.interpolate_callback(self, 1.0/speed, "move_callback")
	tween.interpolate_property(self, "position", position, new_pos, 1.0/speed, Tween.TRANS_LINEAR, 0)
	tween.start()
	
	
	return true
	
func move_callback():
	var pos = position - Vector2.ONE * tile_size/2
	position = pos.snapped(Vector2.ONE * tile_size) + Vector2.ONE * tile_size/2
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
			
	handle_interact(event)

func handle_interact(event):
	if not event.is_action_pressed("interact"):
		return
		
	var body = rays[facing].get_collider()
	if body == null or not body.has_method("interact"):
		return
		
	body.interact(self)
	
func set_held_flag(team, controller):
	held_flag = team
	held_flag_controller = controller
	$Pivot/Flag.visible = held_flag != ""
	$Pivot/Flag.play(held_flag)

func can_pickup_flag():
	# TODO implement
	return true
