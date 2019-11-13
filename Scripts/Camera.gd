extends Camera2D

var _decay_rate =  0.4
var _max_offset = 10

var _start_position
var _trama

func _ready():
	_start_position = position
	_trama = 0.0

func _process(delta):
	if _trama > 0:
		_decay_trama(delta)
		_apply_shake()

func add_trama(amount):
	_trama = min(_trama + amount, 1)
	
func _decay_trama(delta):
	var change = _decay_rate * delta
	_trama = max(_trama - change, 0)
	
func _apply_shake():
	var shake = _trama * _trama
	var o_x = _max_offset * shake * _get_neg_or_pos_scalar()
	var o_y = _max_offset * shake * _get_neg_or_pos_scalar()
	position = _start_position + Vector2(o_x, o_y)
	
func _get_neg_or_pos_scalar():
	return rand_range(-1.0, 1.0) 