extends Resource

@export var spawnPoints : Array[Vector2] = [
	Vector2(0,0),
	Vector2(-1,-1),
	Vector2(-1,0),
	Vector2(-1,1),
	Vector2(0,1),
	Vector2(1,1),
	Vector2(1,0),
	Vector2(1,-1),
	Vector2(0,-1),
	Vector2(-3,-3),
	Vector2(-3,0),
	Vector2(-3,3),
	Vector2(0,3),
	Vector2(3,3),
	Vector2(3,0),
	Vector2(3,-3),
	Vector2(0,-3),
];

@export var subdivision : Array[int] = [
	199,
	0,
	99,
	99,
	99,
	99,
	99,
	99,
	99,
	49,
	49,
	49,
	49,
	49,
	49,
	49,
	49,
];

@export var scale : Array[int] = [
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	3,
	3,
	3,
	3,
	3,
	3,
	3,
	3,
];
