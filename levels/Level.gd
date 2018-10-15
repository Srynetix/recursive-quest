extends Node

# Level script

export (String) var level_title = ""

var Rock = preload("res://elements/rock/Rock.tscn")

onready var HUD = $CanvasLayer/HUD
onready var Player = $Spaceship

var base_time_left = 60
var time_left = base_time_left

func _connect_signals():
    Player.connect("shoot", self, "_on_Spaceship_shoot")
    Player.connect("dead", self, "_on_Spaceship_dead")
    Player.connect("exploded", self, "_on_Spaceship_exploded")
    Player.connect("win", self, "_on_Spaceship_win")
    $TimeLeftTimer.connect("timeout", self, "_on_TimeLeftTimer_timeout")

func _ready():
    VisualServer.set_default_clear_color(Color.black)
    $CanvasModulate.visible = true
    _connect_signals()

    # Update HUD
    GameState.update_hud(HUD)
    HUD.update_time_left(time_left)
    HUD.show_main_message(level_title)

    # Start timer
    $TimeLeftTimer.start()

    # Connect rocks
    for rock in $Rocks.get_children():
        rock.connect('exploded', self, '_on_Rock_exploded')

func _remove_life():
    GameState.remove_life()
    if GameState.lives > 0:
        GameState.reload_current_level()
    else:
        GameState.load_game_over_screen()

func _spawn_rock(size, pos, vel):
    if !vel:
        vel = Vector2(1, 0).rotated(rand_range(0, 2 * PI)) * rand_range(100, 150)

    var r = Rock.instance()
    r.is_sub_rock = true
    r.connect('exploded', self, '_on_Rock_exploded')
    r.start(pos, vel, size)

    $Rocks.add_child(r)

##################
# Event callbacks

func _on_Spaceship_shoot(bullet, pos, dir):
    var bullet_inst = bullet.instance()
    bullet_inst.start(pos, dir)
    add_child(bullet_inst)

func _on_Spaceship_dead():
    GameState.remove_life()
    if GameState.lives > 0:
        GameState.reload_current_level()
    else:
        GameState.load_game_over_screen()

func _on_Spaceship_win():
    GameState.load_next_level()

func _on_Spaceship_exploded():
    $TimeLeftTimer.stop()

func _on_Rock_exploded(size, radius, pos, vel):
    GameState.add_score(100)
    GameState.update_hud(HUD)

    if size <= 1:
        return

    for offset in [-1, 1]:
        var dir = (pos - Player.position).normalized().tangent() * offset
        var newpos = pos + dir * radius
        var newvel = dir * vel.length() * 1.1
        _spawn_rock(size - 1, newpos, newvel)

func _on_TimeLeftTimer_timeout():
    time_left -= 1
    HUD.update_time_left(time_left)

    if time_left == base_time_left / 2:
        Player.message_system.show_message("Hurry up!")

    if time_left == 0:
        Player.kill()