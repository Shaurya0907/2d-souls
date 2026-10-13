extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var isjump = false

const SPEED = 1

func _physics_process(_delta: float) -> void:
	
	# This is my movement code
	if Input.is_action_pressed("move_forward"):
		position.x += SPEED 
		anim_player.play("walking")
	elif Input.is_action_pressed("move_backward"):
		position.x -= SPEED
		anim_player.play("walking")
	elif Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward") and isjump:
		anim_player.play("idle")
		pass
	
	if not is_on_floor():
		isjump = true
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anim_player.play("jumping")
		timer.start()
	if Input.is_action_just_pressed("attack"):
		anim_player.play("attacking")
	
	
	#Gravity here
	velocity.y += 20
	move_and_slide()
		


func _on_timer_timeout() -> void:
	velocity.y = -360
