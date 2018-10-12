extends Node

# Test level

func _connect_signals():
    $Spaceship.connect("shoot", self, "_on_Spaceship_shoot")

func _ready():
    _connect_signals()

##################
# Event callbacks

func _on_Spaceship_shoot(bullet, pos, dir):
    var bullet_inst = bullet.instance()
    bullet_inst.start(pos, dir)
    add_child(bullet_inst)