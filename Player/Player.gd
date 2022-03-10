#Player
extends RigidBody2D

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
		





		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
