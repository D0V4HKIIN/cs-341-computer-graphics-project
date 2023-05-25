extends Camera3D

@onready var target = $"../Boat"

#var speedTowards : float = 2;
var speedCircular = 0.5;

var theta = 0;
var dtheta = 2 * PI / 600;
var r = 10;

# Called when the node enters the scene tree for the first time.
func _ready():
 pass;
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
 #var target_dir = (target.position - self.position).normalized()
 rotateAround(target, self)
 look_at(target.position)

func rotateAround(center, curr):
 theta += dtheta;
 if curr.position.distance_to(center.position) > 2. and curr.position.distance_to(center.position) < 12.:
  r -= 0.05;
 curr.position.x = center.position.x + r * cos(theta) * speedCircular;
 curr.position.y = 8 + center.position.y;
 curr.position.z = center.position.z + r * sin(theta) * speedCircular;
