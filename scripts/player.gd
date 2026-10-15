extends CharacterBody2D

@onready var jumptimer: Timer = $jump
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var dashtimer: Timer = $dash
@onready var dash_end: Timer = $dashEnd

var isjump = false
var isattacking = false
var isdashing = false
const SPEED = 1

func _physics_process(_delta: float) -> void:
	
	# This is my movement code
	if Input.is_action_pressed("move_forward"):
		position.x += SPEED 
		if anim_player.current_animation != "attacking" and anim_player.current_animation != "jumping" and anim_player.current_animation != "dash":
			anim_player.play("walking")
	elif Input.is_action_pressed("move_backward"):
		position.x -= SPEED
		if anim_player.current_animation != "attacking" and anim_player.current_animation != "jumping" and anim_player.current_animation != "dash":
			anim_player.play("walking")
	elif Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward") and not isjump:
		if not isattacking and not isdashing:
			anim_player.play("idle")

	if not is_on_floor():
		isjump = true
	else:
		isjump = false
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anim_player.play("jumping")
		jumptimer.start()

	if Input.is_action_just_pressed("attack") and not isattacking:
		isattacking = true
		anim_player.play("attacking")
		await anim_player.animation_finished
		isattacking = false
		
		if not Input.is_action_pressed("move_forward") or not Input.is_action_pressed("move_backward"):
			anim_player.play("idle")
	
	if Input.is_action_just_pressed("dash") and not isdashing and isjump:
		dash()
	
	if not isdashing:
		velocity.y += 20  #gravity during normal scenario
	else:
		velocity.y = 0  #gravity during dashing
	move_and_slide()
		
func dash():
	isdashing = true
	anim_player.play("dash")
	velocity.x = 240
	await anim_player.animation_finished
	velocity.x = 0
	isdashing = false
func _on_jump_timeout() -> void:
	velocity.y = -360
	if Input.is_action_just_pressed("dash") and not isattacking:
		dash()
