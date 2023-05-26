extends Camera3D

@onready var target = $"../Boat"

var p0 = Vector3(10, 10, 10);
var p1 = Vector3(20, 0, -10);
var p2 = Vector3(-10, 20, 20);
var p3 = Vector3(-50, 20, 10);
var t = 0
var speed = 0.09

var theta = 0;
var dtheta = 2 * PI / 200;
var r;

# Called when the node enters the scene tree for the first time.
func _ready():
	r = p3.distance_to(target.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(target.position);
	if t < 1:
		t += speed * delta
		position = cubic_bezier(p0, p1, p2, p3, t)
	else:
		print(position, "position")
		
			# add some rotation
		rotateAround_bezier(target, self, r)


  
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


func rotateAround_bezier(center, curr, dist):
	
	theta += dtheta;

	curr.position.x = center.position.x + dist * cos(theta);
	curr.position.z = center.position.z + dist * sin(theta);
	print(dist)
