extends RigidBody2D

onready var Game = get_node("/root/Game")
onready var Camera = get_node("/root/Game/Camera")
onready var Starting = get_node("/root/Game/Starting")
onready var Comet = get_node("/root/Game/Comet")

#sounds
onready var Blip = get_node("/root/Game/Blip")
onready var Applause = get_node("/root/Game/Applause")
onready var Boing = get_node("/root/Game/Boing")

var _decay_rate = 0.0
var _max_offset = 4
var _trama_color = Color(1,1,1,1)

var _start_size
var _start_position
var _trama = 0.0
var _rotation = 0
var _rotation_speed = .05
var _color = 0.0
var _color_decay = 1
var _normal_color
var _size_decay = 0.02
var _alpha_decay = 0.3

var _count = 0

func _ready():
	contact_monitor = true
	set_max_contacts_reported(4)
	_start_position = $ColorRect.rect_position
	_normal_color = $ColorRect.color
	
func _process(delta):
	if _trama > 0:
		_decay_trama(delta)
		_apply_shake()
	if _trama > 0:
		_decay_trama(delta)
		_apply_color(1)
	if _color == 0 and $ColorRect.color != _normal_color:
		$ColorRect.color = _normal_color
	
	#create comet trail
	var temp = $ColorRect.duplicate()
	temp.rect_position = Vector2(position.x + $ColorRect.rect_position.x, position.y + $ColorRect.rect_position.y)
	temp.name = "Trail" + str(_count)
	_count += 1
	temp.color = temp.color.linear_interpolate(Color(0,0,0,1), 0.5)
	Comet.add_child(temp)
	var trail = Comet.get_children()
	for t in trail:
		t.rect_size = Vector2(t.rect_size.x - _size_decay, t.rect_size.y - _size_decay)
		t.color.a -= _alpha_decay
		if t.color.a <= 0:
			t.color.a = 0
		if t.rect_size.x <= 0.5 or t.color.a <= 0:
			t.queue_free()
	
	

func _physics_process(delta):
	# Check for collisions
	var bodies = get_colliding_bodies()
	for body in bodies:
		Camera.add_trama(0.2)
		add_trama(2.0)
		if body.is_in_group("Tiles"):
			Game.change_score(body.points)
			Camera.add_trama(0.25)
			add_color(1.0)
			body.find_node("Smoke").emitting = true
			Blip.playing = true
			body.kill()
		if body.name == "Paddle":
			Applause.playing = true
			var tile_rows = get_tree().get_nodes_in_group("Tile Row")
			for tile in tile_rows:
				tile.add_trama(0.5)
		if body.name == "Wall":
			Boing.playing = true
			Camera.add_trama(0.3)
		
	
		
	
	if position.y > get_viewport().size.y:
		Game.change_lives(-1)
		Starting.startCountdown(3)
		queue_free()
		
		
		
func add_color(amount):
	_color += amount
	
func _apply_color(delta):
	var a = min(1, _color)
	$ColorRect.color = _normal_color.linear_interpolate(_trama_color, a)

func _decay_color(delta):
	var change = _color_decay * delta
	_color = max(_color - change, 0)

func add_trama(amount):
	_trama = min(_trama + amount, 1)
	
func _decay_trama(delta):
	var change = _decay_rate * delta
	_trama = max(_trama - change, 0)
	
func _apply_shake():
	var shake = _trama * _trama
	var o_x = _max_offset * shake * _get_neg_or_pos_scalar()
	var o_y = _max_offset * shake * _get_neg_or_pos_scalar()
	$ColorRect.rect_position = _start_position + Vector2(o_x, o_y)
	
func _get_neg_or_pos_scalar():
	return rand_range(-1.0, 1.0) 
	