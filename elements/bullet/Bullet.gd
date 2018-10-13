extends Node2D

# Bullet script

export (int) var speed = 1200

var velocity = Vector2(0, 0)

func _connect_signals():
    $VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func _ready():
    _connect_signals()

func start(pos, rot):
    position = pos
    rotation = rot
    velocity = Vector2(speed, 0).rotated(rot)

func _process(delta):
    position += velocity * delta

##################
# Event callbacks

func _on_screen_exited():
    queue_free()