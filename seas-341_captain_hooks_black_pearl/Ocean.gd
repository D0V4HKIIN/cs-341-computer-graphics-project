# makes the script run in the editor
@tool

extends Node3D

# Get waterplane and preset grid spawn info
var waterTile = preload("res://Water.tscn"); 
var spawnPoint = preload("res://OceanGridSpawnInfo.tres");

# creates a bunch of water tiles and sets the position, subdivision and scale
func createOcean():
	for i in spawnPoint.spawnPoints.size():
		# Get location, subdivision, and scale of each tile
		var spawnLocation = spawnPoint.spawnPoints[i];
		var tileSubdivision = spawnPoint.subdivision[i];
		var tileScale = spawnPoint.scale[i];
		
		# Instanciate tile
		var waterInstance = waterTile.instantiate();
		
		# Add to the scene
		add_child(waterInstance);
		
		# set position, subdivision and scale
		waterInstance.position = Vector3(spawnLocation.x, 0, spawnLocation.y) * waterInstance.mesh.size.x
		waterInstance.mesh.set_subdivide_width(tileSubdivision);
		waterInstance.mesh.set_subdivide_depth(tileSubdivision);
		waterInstance.set_scale(Vector3(tileScale, 1.0, tileScale)); # Ignore Y value because planes are 2d
		
		waterInstance.add_to_group("Water"); # to get the water meshes in the ui
# called when scene is instanciated
func _ready():
	createOcean();
