#Player
extends RigidBody2D

signal shoot
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
		ALIVE:
			$CollisionShape2D.disabled = false
		INVULNERABLE:
			$CollisionShape2D.disabled = true
		DEAD:
			$CollisionShape2D.disabled = true
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
