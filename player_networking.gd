extends Node


var sync_position: Vector3:
	set(value):
		sync_position = value
		processed_position = false

var sync_velocity: Vector3
var sync_state: int

var processed_position: bool
