extends Area2D

################
# Bullet script

###############
# Exported vars

# Bullet speed
export (int) var speed = 1200

##############
# Private vars

# Bullet velocity
var velocity = Vector2(0, 0)

################
# Public methods

func start(pos, rot):
    """
    Start bullet.
    
    :param pos: Bullet position
    :param rot: Bullet rotation
    """
    position = pos
    rotation = rot
    velocity = Vector2(speed, 0).rotated(rot)

#################
# Private methods

func _connect_signals():
    connect("body_entered", self, "_on_body_entered")
    $VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

###################
# Lifecycle methods

func _ready():
    _connect_signals()

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
