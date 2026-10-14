extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var isjump = false
var isattacking = false

const SPEED = 1

func _physics_process(_delta: float) -> void:
	
	# This is my movement code
	if Input.is_action_pressed("move_forward"):
		position.x += SPEED 
		if anim_player.current_animation != "attacking" and anim_player.current_animation != "jumping":
			anim_player.play("walking")
	elif Input.is_action_pressed("move_backward"):
		position.x -= SPEED
		if anim_player.current_animation != "attacking" and anim_player.current_animation != "jumping":
			anim_player.play("walking")
	elif Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward") and not isjump:
		if not isattacking:
			anim_player.play("idle")

	if not is_on_floor():
		isjump = true
	else:
		isjump = false
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anim_player.play("jumping")
		timer.start()
	if Input.is_action_just_pressed("attack") and not isattacking:
		isattacking = true
		anim_player.play("attacking")
		await anim_player.animation_finished
		isattacking = false
		
		if not Input.is_action_pressed("move_forward") or not Input.is_action_pressed("move_backward"):
			anim_player.play("idle")

	#Gravity here
	velocity.y += 20
	move_and_slide()
		


func _on_timer_timeout() -> void:
	velocity.y = -360
	anim_player.play("idle")
