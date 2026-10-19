extends CharacterBody2D

@onready var jumptimer: Timer = $jump
@onready var anim_player: AnimationPlayer = $player_animated/AnimationPlayer
@onready var player: AnimatedSprite2D = $player_animated
@onready var timer: Timer = $Timer
@onready var boss: CharacterBody2D = $"../boss1"
@onready var attack_area: Area2D = $Area2D
@onready var attack_start: Timer = $attack_start

var player_health = 100
var isjump = false
var isattacking = false
var isdashing = false
var isparry = false
const SPEED = 70

func _ready():
	attack_area.monitoring = false

func _physics_process(_delta: float) -> void:
		
	# This is my movement code

	var direction = Input.get_axis("move_backward", "move_forward")

	if Input.is_action_pressed("move_forward") and not isdashing:
		velocity.x = direction * SPEED 
		if anim_player.current_animation not in ["attacking", "jumping", "dash", "parry", "down_parry"]:
			anim_player.play("walking")
	elif Input.is_action_pressed("move_backward") and not isdashing:
		velocity.x = direction * SPEED 
		if anim_player.current_animation not in ["attacking", "jumping", "dash", "parry", "down_parry"]:
			anim_player.play("walking")
	elif Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_backward"):
		velocity.x = 0
		if not isattacking and not isdashing and not isparry:
			anim_player.play("idle")

	#Flips the player
	if velocity.x > 0:
		player.flip_h = false
	if velocity.x < 0:
		player.flip_h = true

	if not is_on_floor():
		isjump = true
	else:
		isjump = false
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anim_player.play("jumping")
		jumptimer.start()

#ATTACK
	if Input.is_action_just_pressed("attack") and not isattacking:
		isattacking = true
		anim_player.play("attacking")
		attack_start.start()
		await anim_player.animation_finished
		isattacking = false
		
		if not Input.is_action_pressed("move_forward") or not Input.is_action_pressed("move_backward"):
			anim_player.play("idle")
	
	if Input.is_action_just_pressed("dash") and not isdashing and isjump:
		dash()
	
	if Input.is_action_just_pressed("parry"):
		parry()
		
	
	
	if not isdashing:
		velocity.y += 20  #gravity during normal scenario
	else:
		velocity.y = 0  #gravity during dashing
	
	move_and_slide()
	
	print(boss.boss_health)

func health():
	pass

func dash():
	isdashing = true
	anim_player.play("dash")
	if player.flip_h:
		velocity.x = -240
	else:
		velocity.x = 240
	timer.start()

func parry():
	isparry = true
	if not isjump:
		anim_player.play("parry")
	else:
		anim_player.play("down_parry")
	await anim_player.animation_finished
	isparry = false
	
	if not Input.is_action_pressed("move_forward") or not Input.is_action_pressed("move_backward"):
			anim_player.play("idle")
func _on_jump_timeout() -> void:
	velocity.y = -480
	if Input.is_action_just_pressed("dash") and not isattacking:
		dash()


func _on_timer_timeout() -> void:
	velocity.x = 0
	isdashing = false


func _on_attack_start_timeout() -> void:
		attack_area.monitoring = true
			

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "boss1":
		boss.boss_health -= 10
	if anim_player.current_animation == "attacking":
		await anim_player.animation_finished
		attack_area.monitoring = false


func _on_area_2d_body_exited(body: Node2D) -> void:
	attack_area.monitoring = false
