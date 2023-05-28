extends Camera3D

@onready var target = $"./movingTarget"

var p0 = Vector3(55, 25, 42);
var p1 = Vector3(20, 15, 30);
var p2 = Vector3(-30, 37, -20);
var p3 = Vector3(10, 2, -10);
var t1 = 0
var speed1 = 0.07

var p4 = Vector3(20, 20, -20);
var p5 = Vector3(30, 35, 0);
var t2 = 0;
var speed2 = 0.09;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(target.position)
	if t1 < 1:
		t1 += speed1 * delta
		position = cubic_bezier(p0, p1, p2, p3, t1)
	else:
		if t2 < 1:
			t2 += speed2 * delta
			position = cubic_bezier(p3, p5, p4, p0, t2)
		else:
			t1 = 0;
			t2 = 0;
	

func cubic_bezier(p0, p1, p2, p3, t):
	var q0 = interpolate(p0, p1, t)
	var q1 = interpolate(p1, p2, t)
	var q2 = interpolate(p2, p3, t)
	var r0 = interpolate(q0, q1, t)
	var r1 = interpolate(q1, q2, t)
	var s = interpolate(r0, r1, t)
	return s

func interpolate(a, b, t):
	return (1-t) * a + t * b;
	
func restart():
	t1 = 0;
	t2 = 0;
