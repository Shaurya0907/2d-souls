extends CharacterBody2D
@onready var anim_player: AnimationPlayer = $boss_animated/AnimationPlayer
@onready var heavyintro: Timer = $heavyintro
@onready var heavymid: Timer = $heavymid
@onready var boss: AnimatedSprite2D = $boss_animated
@onready var left_detection: Area2D = $left_detection
@onready var right_detection: Area2D = $right_detection
@onready var player: CharacterBody2D = $"../player"

var isattacking = false

var SPEED = 5

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attackboss"):
		isattacking = true
		anim_player.play("heavy_attack")
		print(anim_player.current_animation)
		heavyintro.start()
	
	if player.global_position.x > boss.global_position.x:
		if not boss.flip_h and not isattacking:
			boss.flip_h = true
	elif player.global_position.x < boss.global_position.x:
		if not isattacking:
			boss.flip_h = false
	
	print(player.global_position.x,"   ",boss.global_position.x)
	move_and_slide()

func _on_heavyintro_timeout() -> void:
	if not boss.flip_h:
		velocity.x = -240
	else:
		velocity.x = 240
	heavymid.start()


func _on_heavymid_timeout() -> void:
	velocity.x = 0
	isattacking = false
	anim_player.play("idle")	
	print(anim_player.current_animation)
