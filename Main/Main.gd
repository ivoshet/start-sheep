#	Main
extends Node

export (PackedScene) var Rock
export (PackedScene) var Enemy

var screensize

# для счета
var level : int = 0
var score : int = 0
var playing : bool = false

func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
#	get_tree().paused = true
#	появляются 3 метеорита
	for i in range(3):
		spawn_rock(3)

#	появляются метеориты	
func spawn_rock(size, pos=null, vel=null):
	if !pos:
		$RockPath/RockSpawn.set_offset(randi())
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1, 0).rotated(rand_range(0, 2*PI))*rand_range(100, 150)
	var r = Rock.instance()
	r.screensize = screensize
	r.start(pos, vel, size)
	$Rocks.add_child(r)
#	подключаем сигнал от метеорита через код
	r.connect('exploded', self, '_on_Rock_exploded')
		
#	появляются выстрелы
func _on_Player_shoot(bullet, pos, dir):
	var b = bullet.instance()
	b.start(pos, dir)
	add_child(b)

#	разбиваем метеорит на 2
func _on_Rock_exploded(size, radius, pos, vel):
	score += 1
	$HUD.update_score(score)
	if size <= 1:
		return
	for offset in [-1, 1]:
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)
		
func new_game():
#	get_tree().paused = false
	for rock in $Rocks.get_children():
		rock.queue_free()
	level = 0
	score = 0
	$HUD.update_score(score)
	$Player.start()
	$HUD.show_message("Get Ready!")
	yield($HUD/MessageTimer, 'timeout')
	playing = true
	new_level()
	
func new_level():
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in range(level):
		spawn_rock(3)
#	появление врагов вначале уровня
	$EnemyTimer.wait_time = rand_range(5, 10)
	$EnemyTimer.start()

func _process(delta):
	if playing and $Rocks.get_child_count() == 0:
		new_level()
		
#	доступ к концу игры
func game_over():
	playing = false
	$HUD.game_over()
	
#	постановка игры на паузу
func _input(event):
	if event.is_action_pressed('pause'):
		if get_tree().paused:
			get_tree().paused = false
			$HUD/MessageLabel.text = ""
			$HUD/MessageLabel.hide()			
		else:
			get_tree().paused = true
			$HUD/MessageLabel.text = "Paused"
			$HUD/MessageLabel.show()

#	инициализация врагов
#	5, 10 - интервал появления врагов
func _on_EnemyTimer_timeout():
#	print('Main 97')
	var e = Enemy.instance()
	add_child(e)
	e.target = $Player
	e.connect('shoot', self, '_on_Player_shoot')
	$EnemyTimer.wait_time = rand_range(5, 10)
	$EnemyTimer.start()






















