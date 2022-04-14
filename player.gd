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

# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * tile_size)

func action_sort(x, y):
	return actions[x] > actions[y]

func _process(delta):
	if not tween.is_active():
		var dir = get_new_direction()
		if dir.length() > 0 :
			var new_pos = dir * tile_size + position
			tween.interpolate_property(self, "position", position, position + dir * tile_size, 1.0/speed, Tween.TRANS_LINEAR, 0)
			tween.start()
	
	$AnimatedSprite.play()

func get_new_direction(): 
	var inputs = actions.keys()
	inputs.sort_custom(self, "action_sort")
	
	var new_direction = Vector2.ZERO
	for input in inputs:
		if Input.is_action_pressed(input):
			new_direction = directions[input]
			break
	return new_direction

func _unhandled_input(event):
	for dir in actions.keys():
		if event.is_action_pressed(dir):
			actions[dir] = OS.get_ticks_msec()

	
