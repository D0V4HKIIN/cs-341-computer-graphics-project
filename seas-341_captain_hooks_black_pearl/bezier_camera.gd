extends Camera3D

@onready var target = $"../Boat"

var p0 = Vector3(10, 10, 10);
var p1 = Vector3(20, -10, -10);
var p2 = Vector3(-10, 20, 20);
var p3 = Vector3(20, -10, 15);
var t = 0
var speed = 0.1 

# Called when the node enters the scene tree for the first time.
func _ready():
 pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
 look_at(target.position)
 if t < 1:
  t += speed * delta
  position = cubic_bezier(p0, p1, p2, p3, t)
  
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
