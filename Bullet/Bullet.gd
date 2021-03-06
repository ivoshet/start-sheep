#Bullet
extends Area2D

export (int) var speed
var velocity = Vector2()
var layers
var size

func start(pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed, 0).rotated(dir)

func _process(delta):
	position += velocity * delta

# 	метод уведомляет о видимости объекта
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

#	уведомление о попадании
func _on_Bullet_body_entered(body):
	if body.is_in_group('rocks'):
#		print('Bullet._on_Bullet_body_entered')
		body.explode()
		queue_free()

# поражение врага
func _on_Bullet_area_entered(area):
	if area.is_in_group('enemies'):
		area.take_damage(1)
	queue_free()
