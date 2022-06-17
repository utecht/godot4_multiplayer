extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animator = $"atomic-robot/AnimationPlayer"
enum States { IDLE, RUN, AIR }
var _state : int = States.IDLE

func is_local_authority():
	return $Networking/MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func _ready():
	$Networking/MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	$Camera3D.current = is_local_authority()

func _physics_process(delta):
	if !is_local_authority():
		if not $Networking.processed_position:
			position = $Networking.sync_position
			$Networking.processed_position = true
		velocity = $Networking.sync_velocity
		move_and_slide()
		match $Networking.sync_state:
			States.RUN:
				animator.play("Walking")
			States.AIR:
				if velocity.y > 0:
					animator.play("Jump")
				else:
					animator.play("Fall")
			States.IDLE:
				animator.play("Idle")
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		_state = States.RUN
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		_state = States.IDLE
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if not is_on_floor():
		_state = States.AIR
	
	match _state:
		States.RUN:
			animator.play("Walking")
		States.AIR:
			if velocity.y > 0:
				animator.play("Jump")
			else:
				animator.play("Fall")
		States.IDLE:
			animator.play("Idle")

	move_and_slide()
	
	$Networking.sync_position = position
	$Networking.sync_velocity = velocity
	$Networking.sync_state = _state
