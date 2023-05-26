@tool
extends MeshInstance3D

@onready var st = SurfaceTool.new()

@export var size = 20
@export var density = 3
@export var dist_between_circles = 2 * PI / density

func vertex(x, y):
	st.set_normal(Vector3(0, 1, 0))
	st.add_vertex(Vector3(x, 0, y))

func triangle(x, y, index):
	var angle = 2 * PI * y / density
	vertex(dist_between_circles * x * x * sin(angle), dist_between_circles * x * x * cos(angle))
	# 2 vertices are already created for the triangle
	st.add_index(index)
	st.add_index(index - density)
	st.add_index(index + 1)
	
	st.add_index(index + 1)
	st.add_index(index - density)
	st.add_index(index - density + 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# first circle is bit different
	vertex(0,0)
	vertex(0, dist_between_circles)
	for x1 in range(density - 1):
		var x = x1 + 1
		var angle = (2 * PI * x + (x % 2)) / density
		vertex(dist_between_circles * sin(angle), dist_between_circles * cos(angle))
		var index = x
		st.add_index(index + 1)
		st.add_index(index)
		st.add_index(0)
	# close first circle
	st.add_index(0)
	st.add_index(1)
	st.add_index(density)

	for x1 in range(size):
		var x = x1 + 2
		print(x)
		vertex(0, dist_between_circles * x * x)
		for y1 in range(density - 1):
			var y = y1 + 1
			triangle(x, y, (x - 1) * density + y)
	
		st.add_index(x * density)
		st.add_index(x * density - density)
		st.add_index(x * density - 2 * density + 1)
		
		st.add_index(x * density)
		st.add_index(x * density - 2 * density + 1)
		st.add_index(x * density - density + 1)
	
	# Commit to a mesh.
	var mesh = st.commit()
	set_mesh(mesh)
