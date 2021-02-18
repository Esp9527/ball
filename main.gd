extends Node2D
 
var balls = []

var ball_class = preload("res://ball.tscn")

var num = 0
var _next = 0
var _score = 0

func _ready():
	var r = fit_rect()
	$color.margin_left = r.position[0]
	$color.margin_top = r.position[1]
	$color.margin_right = r.position[0] + r.size[0]
	$color.margin_bottom = r.position[1] + r.size[1]
	
	create_wall(r, Vector2(100,100))
	random_next()
	pass 

func fit_rect():
	var v : Rect2  =  get_viewport_rect()
	var c = v.position + v.size / 2
	var s = v.size
	if s[0]*2 < s[1]:
		s = Vector2(s[0], s[0]*2)
	elif s[1] < s[0] * 1.5:
		s = Vector2(s[1]/1.5, s[1])
	return Rect2(c - s/2, s)
	

func create_wall(r:Rect2, border:Vector2):
	var p = PoolVector2Array()
	p.append(r.position)
	p.append(r.position + Vector2(0, r.size[1]))
	p.append(r.position + Vector2(r.size[0], r.size[1]))
	p.append(r.position + Vector2(r.size[0], 0))
	
	p.append(r.position + Vector2(r.size[0] + border[0], - border[1]))
	p.append(r.position + Vector2(r.size[0] + border[0], r.size[1] + border[1]))
	p.append(r.position + Vector2(- border[1], r.size[1] + border[1]))
	p.append(r.position + Vector2(- border[1], - border[1]))
	$static/wall.polygon = p
	pass

	
	
func _input(event):
	if event is InputEventMouseButton \
			and event.pressed \
			and (event.button_index & BUTTON_LEFT) \
			and _next != 0:
		var be = event as InputEventMouseButton
		var ball = ball_class.instance()
		ball.num = gen_num()
		ball.position = Vector2(be.position[0], 0)
		ball.connect("body_entered", self, "on_ball_entered", [ball])
		ball.connect("body_exited", self, "on_ball_remove", [ball])
		add_child(ball)
		ball.set_level(_next)
		_next = 0
		$pre_ball.visible = false
		yield(get_tree().create_timer(1.0), "timeout")
		random_next()

func random_next():
	_next = randi() % 4 + 1
	$pre_ball.set_level(_next)
	var r = fit_rect()
	$pre_ball.position = Vector2(r.position[0] + r.size[0]/2, 0)
	$pre_ball.visible = true
	

func on_ball_entered(body, source):
	if not body is CBall:
		return
		
	var ball = body as CBall
	ball.add(source)
	source.add(ball)
	if source.num < ball.num:
		check_ball(ball)
	else:
		check_ball(source)
	pass

func on_ball_remove(body, source):
	if not body is CBall:
		return
	body.remove(source)
	source.remove(body)
	
func free_ball(ball : CBall):
	print("free", ball)
	for c in ball.collisions():
		c.remove(ball)
	ball.queue_free()
	pass
	
class MyCustomSorter:
	static func sort_ascending(a, b):
		if a.num < b.num:
			return true
		return false
	
	
func check_ball(ball:CBall):
	var cs = []
	for c in ball.collisions():
		if c.level() == ball.level() && c.level() < 8:
			cs.append(c)
	
	cs.sort_custom(MyCustomSorter, "sort_ascending")
	
	if cs.empty():
		return
		
	if cs.size() >=2 && ball.level() + 1 < 8:
		free_ball(ball)
		free_ball(cs[1])
		cs[0].set_level(ball.level() + 2)
		gain_score(cs[0].level())
		check_ball(cs[0])
		return
		
	if cs.size() >= 1 && ball.level() < 8:
		free_ball(ball)
		cs[0].set_level(cs[0].level() + 1)
		gain_score(cs[0].level())
		check_ball(cs[0])
		return
	pass
	
func gain_score(level):
	_score += level * level 
	$score.text = str(_score)
	pass

func gen_num():
	num += 1
	return num
