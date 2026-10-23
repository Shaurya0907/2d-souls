extends CharacterBody2D
@onready var anim_player: AnimationPlayer = $boss_animated/AnimationPlayer
@onready var heavyintro: Timer = $heavy_attack/heavyintro
@onready var heavymid: Timer = $heavy_attack/heavymid
@onready var boss: AnimatedSprite2D = $boss_animated
@onready var player: CharacterBody2D = $"../player"
@onready var knockback: Timer = $knockback
@onready var before_ascent: Timer = $"coolest_attack/before ascent"
@onready var attack_delay: Timer = $attack_delay
@onready var attack_area: Area2D = $boss_animated/Area2D
@onready var attack_collision: CollisionShape2D = $boss_animated/Area2D/CollisionShape2D
@onready var attack_start: Timer = $attack_start
@onready var disable_attack_area: Timer = $disable_attack_area
@onready var player_char: CharacterBody2D = $"../player"
@onready var jump_attack_detection: Area2D = $jump_attack_detection
@onready var jump_attack_start: Timer = $jump_attack_start



var attacks_list = ["coolest_attack"]
var queue_freed = false
var isattacking = false
var boss_health = 100
var counter:= 0.0
var SPEED = 5
var isjumping = false


func _ready():
	#for disabling attack damage when not attacking
	attack_area.monitoring = false
	jump_attack_detection.monitoring = false

func _physics_process(delta: float) -> void:
		
	# I forgot about the gravity for boss XDD
	if boss.flip_h:
		attack_collision.position.x = 23.0
	else:
		attack_collision.position.x = -23.0
	
	velocity.y += 20
	move_and_slide()
	if is_on_floor() and not isattacking:
		velocity.x = 0
		

	
	#HEALTH
	if boss_health < 0:
		boss_health = 0
	
	if boss_health == 0:
		queue_free()
		queue_freed = true
	if not queue_freed and is_instance_valid(player) and not player.queue_freed:
		if player.global_position.x > boss.global_position.x:
			if not boss.flip_h and not isattacking:
				boss.flip_h = true
		elif player.global_position.x < boss.global_position.x:
			if not isattacking:
				boss.flip_h = false	
				
	if isattacking:		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.name == "player":
				#if collider.velocity.x < velocity.x:
					if isattacking:
						if not boss.flip_h:
							velocity.x = -240
						else:
							velocity.x = 240
						collider.velocity.x = velocity.x + 20
						knockback.start()
func heavy_attack():
	isattacking = true
	anim_player.play("heavy_attack")
	heavyintro.start()
	attack_start.start()
					
func coolest_attack():	
	jump_attack_start.stop()
	disable_attack_area.stop()
	
	isjumping = true
	anim_player.play("coolest_attack")
	jump_attack_start.start()
	before_ascent.start()
	await anim_player.animation_finished
	isjumping = false
	
	

func _on_heavyintro_timeout() -> void:
	if not boss.flip_h:
		velocity.x = -240
	else:
		velocity.x = 240
	heavymid.start()

func attacks(attack_name):
	if attack_name == "coolest_attack":
		coolest_attack()
	elif attack_name == "heavy_attack":
		heavy_attack()


func _on_heavymid_timeout() -> void:
	velocity.x = 0
	isattacking = false
	anim_player.play("idle")	
	attack_delay.start()


func _on_knockback_timeout() -> void:
	if is_instance_valid(player):
		player.velocity.x = 0


func _on_before_ascent_timeout() -> void:
	if isjumping and anim_player.current_animation == "coolest_attack":
		velocity.y = -480
		if boss.flip_h:
			velocity.x += 100
		else:
			velocity.x -= 100
		attack_delay.start()


func _on_attack_delay_timeout() -> void:
	attacks(attacks_list.pick_random())

func _on_attack_start_timeout() -> void:
	attack_area.monitoring = true
	disable_attack_area.start()
	

func _on_disable_attack_area_timeout() -> void:
	attack_area.monitoring = false
	jump_attack_detection.monitoring = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if isattacking and is_instance_valid(player):
			player_char.damage(5)
			disable_attack_area.start()
			


func _on_jump_attack_detection_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("HELLOOO")
		if isjumping and is_instance_valid(player):
			if player_char.is_on_floor():
				player_char.damage(20)
				disable_attack_area.start()
			else:
				player_char.damage(10)
				disable_attack_area.start()
	


func _on_jump_attack_start_timeout() -> void:
	if isjumping:
		jump_attack_detection.monitoring = true
		disable_attack_area.start()
	
