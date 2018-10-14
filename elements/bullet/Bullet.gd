extends Area2D

# Bullet script

export (int) var speed = 1200

var velocity = Vector2(0, 0)

func _connect_signals():
    connect("body_entered", self, "_on_body_entered")
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

func _on_body_entered(body):
    if body.is_in_group("walls"):
        queue_free()
    elif body.is_in_group("rocks"):
        body.explode()
        queue_free()
    elif body.is_in_group("barriers"):
        queue_free()