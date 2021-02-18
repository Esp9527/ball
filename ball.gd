tool
extends RigidBody2D
class_name CBall

var _level = 0
var _radius = 30
var _color : Color
var _collisions = []
var _dynamic_font : DynamicFont
var num : int = 0

func _ready():
	_dynamic_font = DynamicFont.new()
	_dynamic_font.font_data = load("res://font/angsa.ttf")
	_dynamic_font.size = 64
	friction = 1
	bounce = 0.15
	yield(get_tree().create_timer(1.0), "timeout")
	bounce = 0
#	physics_material_override.bounce = 0
	pass

func set_level(lev):
	match lev:
		1:
			_color = Color.yellow
		2: 
			_color = Color.aliceblue
		3:
			_color = Color.antiquewhite
		4: 
			_color = Color.bisque
		5:
			_color = Color.pink
		6:
			_color = Color.gray
		7:
			_color = Color.green
		8:
			_color = Color.black
		
	_radius = lev * 12 + 15
	$shape.shape = CircleShape2D.new()
	$shape.shape.radius = _radius
	$shape.disabled = true
	$shape.disabled = false
	_level = lev
	mass = lev * 0.1 + 1
	
	update()
#	yield(get_tree().create_timer(1.0), "timeout")
#	add_torque(2)
	if angular_velocity != 0:
		angular_velocity = 0.1
	update()
	
	pass
	
func level():
	return _level
	
	
func _draw():
	draw_circle(Vector2.ZERO, _radius, _color)	
	draw_char(_dynamic_font, Vector2.ZERO, str(_level), "", Color.black)
	
func add(c:CBall):
	print(self, "add", c)
	if not _collisions.has(c):
		_collisions.append(c)

func remove(c:CBall):
	print(self, "remove", c)
	if _collisions.has(c):
		_collisions.erase(c)


func collisions():
	return _collisions
