#Player
extends RigidBody2D

signal shoot
signal dead
# для подсчета результатов
signal lives_changed
#	вызов сеттера каждый раз при изменении значения переменной
var lives = 0 setget set_lives

export (PackedScene) var Bullet
export (float) var fire_rate
var can_shoot = true

# to create a finite state machine
enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = null

export (int) var engine_power
export (int) var spin_power

# to need find what is linear dumb and angular dump, to need some experiments
var thrust = Vector2()
var rotation_dir = 0

# screen size
var screensize = Vector2()


func _ready():
#	initial state - ALIVE
#	print(typeof(state))
	change_state(ALIVE)
#	получаем размер видимого экрана
	screensize = get_viewport().get_visible_rect().size
	$GunTimer.wait_time = fire_rate	

func _process(delta):
	get_input()

#	получаем вектор направления
func get_input():
	thrust = Vector2()
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power, 0)
	rotation_dir = 0
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed('rotate_left'):
		rotation_dir -= 1
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
func shoot():
	if state == INVULNERABLE:
		return
	emit_signal('shoot', Bullet, $Muzzle.global_position, rotation)
	can_shoot = false
	$GunTimer.start()
		
# автомат конечных состояний
func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.1
		ALIVE:
			$CollisionShape2D.disabled = false
			$Sprite.modulate.a = 1
		INVULNERABLE:
			$CollisionShape2D.disabled = true
			$Sprite.modulate.a = 0.5
			$InvulnerabilityTimer.start()
		DEAD:
			$CollisionShape2D.disabled = true
			$Sprite.hide()
			linear_velocity = Vector2()
			emit_signal("dead")
	state = new_state

#	метод прямого доступа к свойствам RigidBody
#	применяется для получения положения объекта, 
#	
func _integrate_forces(physics_state):
#	задаем физические силы действующие на объект
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
#	получаем текущее положение
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screensize.x
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
#	задаем новое положение
	physics_state.set_transform(xform)

func _on_GunTimer_timeout():
	can_shoot = true

#	вызов функции при каждом изменении значения переменной
func set_lives(value):
	lives = value
	emit_signal("lives_changed", lives)

func start():
	$Sprite.show()
	self.lives = 3
	change_state(ALIVE)

func _on_InvulnerabilityTimer_timeout():
	change_state(ALIVE)

func _on_AnimationPlayer_animation_finished(anim_name):
#	pass # Replace with function body.
	$Explosion.hide()

#	контакт с другим RigidBody2D - предварительно включить Contact Monitor и
#	задать значение 1 в Contact Report
func _on_Player_body_entered(body):
#	pass # Replace with function body.
#	print("Player._on_Player_body_entered")
	if body.is_in_group('rocks'):
		body.explode()
		$Explosion.show()
		$Explosion/AnimationPlayer.play("explosion")
		self.lives -= 1
		if lives <= 0:
			change_state(DEAD)
		else:
			change_state(INVULNERABLE) 
	
	
	
	
	
	
	
	
	
	
	
	
	
