extends Node3D

var mouseDelta: Vector2
var mousePressed: bool = false
@export var lookSensitivity: float = 1

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
	if event is InputEventMouseButton:
		mousePressed = event.pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mousePressed:
		var rot = Vector3(mouseDelta.y, mouseDelta.x, 0) * lookSensitivity * delta
		rotation.x -= rot.x
		rotation.y -= rot.y
	else:
		rotation.x -= (lerp(rotation.x, 0, 0.1) * delta)
		rotation.y -= (lerp(rotation.y, 0, 0.1) * delta)
		
