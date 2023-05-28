extends Camera3D

@onready var target = $"../Boat"

#var speedTowards : float = 2;
var speedCircular = 0.5;

var theta = 0.1;
var dtheta = 2 * PI / 600;
var r = 50;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#var target_dir = (target.position - self.position).normalized()
	rotateAround(target, self)
	look_at(target.position)

func rotateAround(center, curr):
	theta += dtheta;
	curr.position.x = center.position.x + r * cos(theta) * speedCircular;
	curr.position.y = 35 + center.position.y;
	curr.position.z = center.position.z + r * sin(theta) * speedCircular;
