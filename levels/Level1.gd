extends Node

# Level 1

func _connect_signals():
    $Spaceship.connect("shoot", self, "_on_Spaceship_shoot")
    $Spaceship.connect("dead", self, "_on_Spaceship_dead")
    $Spaceship.connect("win", self, "_on_Spaceship_win")

func _ready():
    VisualServer.set_default_clear_color(Color.black)
    _connect_signals()

##################
# Event callbacks

func _on_Spaceship_shoot(bullet, pos, dir):
    var bullet_inst = bullet.instance()
    bullet_inst.start(pos, dir)
    add_child(bullet_inst)

func _on_Spaceship_dead():
    get_tree().reload_current_scene()

func _on_Spaceship_win():
    get_tree().reload_current_scene()
