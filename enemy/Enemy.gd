#	Enemy
extends Area2D

signal shoot

export (PackedScene) var Bullet
export (int) var speed = 300
export (int) var health = 3

var follow
var target = null

func _ready():
#	$Sprite.frame = 0
	var path = $EnemyPath.get_children()[randi() % $EnemyPath.get_child_count()]
	print(path)
	follow = PathFollow2D.new()
	path.add_child(follow)
	follow.loop = false

func _process(delta):
	follow.offset += speed * delta
	position = follow.global_position
	if follow.unit_offset > 1:
		queue_free()
	
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()

func _on_GunTimer_timeout():
	pass # Replace with function body.
	
	
	
