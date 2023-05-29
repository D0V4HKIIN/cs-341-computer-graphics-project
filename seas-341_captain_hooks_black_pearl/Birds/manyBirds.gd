@tool
extends MultiMeshInstance3D

@onready var box = $"../birds/Box"

var boxVerification: Vector3

@export var boidCount = 10
@export var boidSpeedMin= 3.0
@export var boidSpeedMax = 10.0
@export var neighbourDistance = 3.0
@export var avoidanceDistance = 2.0
@export var alignmentWeight = 0.6
@export var coheshionWeight = 0.01
@export var separationWeight = 0.7
@export var boundaryDistance = 7.0
@export var boundaryForceWeight = 0.3
@export var attactionWeight = 0.1

var attractorPositions: PackedVector3Array
@export var attractorCount = 100

var boidPositions: PackedVector3Array
var boidVelocities: PackedVector3Array
var minVertex = Vector3(INF, INF, INF)
var maxVertex = Vector3(-INF, -INF, -INF)

func setup():
	boidCount = multimesh.instance_count
	boidPositions.resize(boidCount)
	boidVelocities.resize(boidCount)
	attractorPositions.resize(attractorCount)
	
	# Get the aabb of the bounding box and set the min and max coordinates birds can go
	var box_aabb = box.get_aabb()
	
	for i in range(8):
		var curr = box_aabb.get_endpoint(i)
		if minVertex > curr:
			minVertex = curr
		
		if maxVertex < curr:
			maxVertex = curr
			
	for i in range(attractorCount):
		attractorPositions[i] = Vector3(randf_range(minVertex.x, maxVertex.x), randf_range(minVertex.y, maxVertex.y), randf_range(minVertex.z, maxVertex.z))
	
	for i in range(boidCount):
		boidPositions[i] = Vector3(randf_range(minVertex.x, maxVertex.x), randf_range(minVertex.y, maxVertex.y), randf_range(minVertex.z, maxVertex.z))
		boidVelocities[i] = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(boidSpeedMin, boidSpeedMax)
		multimesh.set_instance_transform(i, Transform3D(Basis(), boidPositions[i]))
		multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))


# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(multimesh.instance_count):
		var position = boidPositions[i]
		var velocity = boidVelocities[i]

		# Get the average velocity and position of neighboring boids
		var averageVelocity = Vector3()
		var averagePosition = Vector3()
		
		var separation = Vector3()
		var neighborCount = 0

		for j in range(multimesh.instance_count):
			if i != j:
				var neighborPosition = boidPositions[j]

				# Calculate distance to neighbor
				var distance = position.distance_to(neighborPosition)

				# Check if the birds is within the acceptable neighbour distance
				if distance < neighbourDistance:
					averageVelocity += boidVelocities[j]
					averagePosition += neighborPosition

				# Separate birds that are too close to its neighbours
				if distance < avoidanceDistance:
					separation += (neighborPosition - position).normalized() / distance

				neighborCount += 1

		if neighborCount > 0:
			averageVelocity /= neighborCount
			averagePosition /= neighborCount
			separation /= neighborCount

			var alignment = averageVelocity.normalized()
			var cohesion = (averagePosition - position).normalized()

			var steer = alignment * alignmentWeight + cohesion * coheshionWeight - separation * separationWeight
			
			# Birds should smoothly turn away from the boundary of the bounding mesh
			var boundaryForce = calculate_boundary_force(position)
			steer += boundaryForce * boundaryForceWeight
			
			# Added attraction force to attracting points so that boids can be separated by these points
			var attractorForce = calculate_attractor_force(position)
			steer += attractorForce * attactionWeight
			
			# Generate new speed in a range so velocit isn't always the same.
			velocity = (velocity + steer).normalized() * randf_range(boidSpeedMin, boidSpeedMax)

			# Apply steering force to boid
			position += velocity * delta

			boidPositions[i] = position
			boidVelocities[i] = velocity
			var rotation = Transform3D().looking_at(-velocity, Vector3.UP)
			
			multimesh.set_instance_transform(i, Transform3D(rotation.basis, position))

func calculate_boundary_force(position):
	var boundaryForce = Vector3.ZERO

	if position.x < minVertex.x + boundaryDistance:
		boundaryForce.x = 1.0 - (position.x - minVertex.x) / boundaryDistance
	elif position.x > maxVertex.x - boundaryDistance:
		boundaryForce.x = -1.0 + (position.x - maxVertex.x) / boundaryDistance

	if position.y < minVertex.y + boundaryDistance:
		boundaryForce.y = 1.0 - (position.y - minVertex.y) / boundaryDistance
	elif position.y > maxVertex.y - boundaryDistance:
		boundaryForce.y = -1.0 + (position.y - maxVertex.y) / boundaryDistance

	if position.z < minVertex.z + boundaryDistance:
		boundaryForce.z = 1.0 - (position.z - minVertex.z) / boundaryDistance
	elif position.z > maxVertex.z - boundaryDistance:
		boundaryForce.z = -1.0 + (position.z - maxVertex.z) / boundaryDistance

	return boundaryForce

func calculate_attractor_force(position):
	var attractorForce = Vector3.ZERO

	for attractorPos in attractorPositions:
		attractorForce += (attractorPos - position).normalized()

	if attractorPositions.size() > 0:
		attractorForce /= attractorPositions.size()

	return attractorForce
