#	Rock
extends RigidBody2D

var screensize : Vector2 = Vector2()
var size : int
var radius : int
var scale_factor : float = 0.2
signal exploded

func start(pos, vel, _size):
#	встроенный параметр объекта
	position = pos
	size = _size
	mass = 1.5 * size
#	ставим размер спрайта 
	$Sprite.scale = Vector2(1,1) * scale_factor * size
#	получаем размер спрайта
	radius = int($Sprite.texture.get_size().x/2 * scale_factor * size)
#	выбираем тип шейпа
	var shape = CircleShape2D.new()
#	задаем радиус шейпа
#	print("Rock.start()")
	shape.radius =radius
#	установливаем CollisionShape тип шейпа
	$CollisionShape2D.shape = shape
#	присваеваем значения встроенным параметрам линейного движения и угла 
	linear_velocity = vel
	angular_velocity = rand_range(-1.5, 1.5)
#	добавляем взрыв
	$Explosion.scale = Vector2(0.75, 0.75) * size
	
#	
#	задаем способность появляться с другой стороны экрана	
func _integrate_forces(physics_state):
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x + radius:
		xform.origin.x = 0 - radius
	if xform.origin.x < 0 - radius:
		xform.origin.x = screensize.x + radius
	if xform.origin.y > screensize.y + radius:
		xform.origin.y = 0 - radius
	if xform.origin.y < 0 - radius:
		xform.origin.y = screensize.y + radius
	physics_state.set_transform(xform)
	
func explode():
	layers = 0
	$Sprite.hide()
	$Explosion/AnimationPlayer.play("explosion")
	emit_signal("exploded", size, radius, position, linear_velocity)
	linear_velocity = Vector2()
	angular_velocity = 0

#	убираем анимацию после завершения
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
