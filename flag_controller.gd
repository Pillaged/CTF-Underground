extends StaticBody2D
export var team = "blue"

var tile_size = 64
var flag_picked_up = false
var score = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	position = (position - Vector2.ONE * tile_size/2).snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	$AnimatedSprite.play(team)

func _process(delta):
	pass

func interact(player):
	if not flag_picked_up and player.team != team and player.can_pickup_flag():
		flag_picked_up = true
		player.set_held_flag(team, self)
		$AnimatedSprite.play("empty")
		return
		
	if flag_picked_up and player.held_flag == team:
		return_flag()
		player.set_held_flag("", null)
		
	if player.team == team and player.held_flag != "" and player.held_flag != team :
		player.held_flag_controller.return_flag()
		player.set_held_flag("", null)
		
func return_flag():
	flag_picked_up = false
	$AnimatedSprite.play(team)

func score():
	score += 1
