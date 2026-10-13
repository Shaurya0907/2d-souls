extends CharacterBody2D

@onready var timer: Timer = $Timer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var walking: AnimatedSprite2D = $walking
var isjump = false

const SPEED = 1

func _physics_process(delta: float) -> void:
	

		
	
	if Input.is_action_pressed("move_forward"):
		position.x += SPEED 
		anim_player.play("walking")
	elif Input.is_action_pressed("move_backward"):
		position.x -= SPEED
		anim_player.play("walking")
	elif Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward") or isjump:
		anim_player.play("idle")
	
	if not is_on_floor():
		#anim_player.play("jumping_inplace")
		pass
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		walking.hide()
		anim_player.play("jumping_inplace")
		timer.start()
	
	
	#Gravity here
	velocity.y += 20
	move_and_slide()
		


func _on_timer_timeout() -> void:
	velocity.y = -360
	walking.show()
