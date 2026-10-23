extends CharacterBody2D

@onready var jumptimer: Timer = $jump
@onready var anim_player: AnimationPlayer = $player_animated/AnimationPlayer
@onready var player: AnimatedSprite2D = $player_animated
@onready var timer: Timer = $Timer
@onready var boss: CharacterBody2D = $"../boss1"
@onready var attack_area: Area2D = $player_animated/Area2D
@onready var attack_start: Timer = $attack_start
@onready var attack_collision: CollisionShape2D = $player_animated/Area2D/CollisionShape2D
@onready var boss_health: RichTextLabel = $"../boss_health_value"
@onready var disable_attacking_area: Timer = $disable_attacking_area
@onready var player_health_value: RichTextLabel = $"../player_health_value"


var queue_freed = false
var player_health = 100
var isjump = false
var isattacking = false
var isdashing = false
var isparry = false
var has_dashed = false
const SPEED = 70

func _ready():
	attack_area.monitoring = false

func _physics_process(_delta: float) -> void:
		
	# This is my movement code
		
	var direction = Input.get_axis("move_backward", "move_forward")
	if not isdashing:	
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
		velocity.y += 20  #gravity during normal scenario
	
	else:
		velocity.y = 0  #gravity during dashing
	#Flips the player
	if velocity.x > 0:
		player.flip_h = false
		attack_collision.position.x = 15.25
		
	if velocity.x < 0:
		player.flip_h = true
		attack_collision.position.x = -15.25
	
	if not is_on_floor():
		isjump = true
	else:
		isjump = false
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anim_player.play("jumping")
		jumptimer.start()

#HEALTH
	if player_health < 0:
		player_health = 0
	if player_health == 0:
		queue_free()
		queue_freed = true

#ATTACK
	if Input.is_action_just_pressed("attack") and not isattacking:
		isattacking = true
		anim_player.play("attacking")
		attack_start.start()
		await anim_player.animation_finished
		isattacking = false
		
		if not Input.is_action_pressed("move_forward") or not Input.is_action_pressed("move_backward"):
			anim_player.play("idle")
	
	if Input.is_action_just_pressed("dash") and not isdashing and isjump and not has_dashed:
		dash()
	
	if Input.is_action_just_pressed("parry"):
		parry()
		
	if is_on_floor():	
		has_dashed = false
	
	
	move_and_slide()
	

func damage(damage_value):
	player_health -= damage_value
	player_health_value.text = str(player_health)

func dash():
	has_dashed = true
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


func _on_timer_timeout() -> void:
	velocity.x = 0
	isdashing = false


func _on_attack_start_timeout() -> void:
		attack_area.monitoring = true
		disable_attacking_area.start()
			

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "boss1":
		boss.boss_health -= 10
		disable_attacking_area.start()
		boss_health.text = str(boss.boss_health)


func _on_disable_attacking_area_timeout() -> void:
	attack_area.monitoring = false
