extends Node

##############
# Level script

###############
# Exported vars

# Level ID
export (int) var level_id = 0
# Level title
export (String) var level_title = ""
# Time left
export (int) var base_time_left = 60

##############
# Private vars

var Rock = preload("res://elements/rock/Rock.tscn")

onready var HUD = $CanvasLayer/HUD
onready var Player = $Objects/Spaceship

# Time left for the level
var time_left = base_time_left

#################
# Private methods

func _connect_signals():
    Player.connect("shoot", self, "_on_Spaceship_shoot")
    Player.connect("dead", self, "_on_Spaceship_dead")
    Player.connect("exploded", self, "_on_Spaceship_exploded")
    Player.connect("win", self, "_on_Spaceship_win")
    Player.connect("shrunk", self, "_on_Spaceship_shrunk")
    Player.connect("treasure_unlocked", self, "_on_Spaceship_treasure_unlocked")
    $TimeLeftTimer.connect("timeout", self, "_on_TimeLeftTimer_timeout")

    for barrier in $Barriers.get_children():
        barrier.connect("exploded", self, "_on_Barrier_exploded")

func _remove_life():
    GameState.remove_life()
    if GameState.lives > 0:
        GameState.reload_current_level()
    else:
        GameState.load_screen(GameState.Screens.GAME_OVER)

func _spawn_rock(size, pos, vel):
    if !vel:
        vel = Vector2(1, 0).rotated(rand_range(0, 2 * PI)) * rand_range(100, 150)

    var r = Rock.instance()
    r.is_sub_rock = true
    r.connect('exploded', self, '_on_Rock_exploded')
    r.start(pos, vel, size)

    $Rocks.add_child(r)

func _set_pyramid_autopilot():
    var pyramid_position = $Objects/Pyramid.global_position
    $Objects/Spaceship.set_autopilot(pyramid_position)
    $TimeLeftTimer.stop()

###################
# Lifecycle methods

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

    # Set current level
    GameState.current_level = level_id

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
        GameState.load_screen(GameState.Screens.GAME_OVER)

func _on_Spaceship_win():
    GameState.add_score(time_left * 100)
    GameState.load_next_level()

func _on_Spaceship_exploded():
    $TimeLeftTimer.stop()

func _on_Spaceship_shrunk():
    _set_pyramid_autopilot()

func _on_Spaceship_treasure_unlocked(treasure_name):
    GameState.add_score(500)
    GameState.unlock_treasure(treasure_name)
    GameState.update_hud(HUD)

func _on_Barrier_exploded():
    GameState.add_score(100)
    GameState.update_hud(HUD)

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

    if time_left == 0:
        Player.kill()
