extends RigidBody2D

#############
# Rock script

# Exploded signal
#   - size: Rock size
#   - radius: Rock radius
#   - pos: Rock position
#   - vel: Rock velocity
signal exploded(size, radius, pos, vel)

###############
# Exported vars

# Base linear velocity
export (Vector2) var base_linear_velocity = Vector2(-150, -150)

##############
# Private vars

var size
var radius
var scale_factor = 0.5
var is_sub_rock = false

################
# Public methods

func start(pos, vel, start_size):
    """
    Start rock.

    :param pos: Rock position
    :param vel: Rock velocity
    :param start_size: Starting size
    """
    position = pos
    size = start_size
    mass = 1.5 * size

    $Sprite.scale = $Sprite.scale * start_size * scale_factor
    $Light2D.texture_scale = $Light2D.texture_scale * start_size * scale_factor * 1.25
    radius = int($Sprite.texture.get_size().x / 2 * scale_factor * start_size * 0.5)

    var shape = CircleShape2D.new()
    shape.radius = radius
    $CollisionShape2D.shape = shape

    linear_velocity = vel
    angular_velocity = rand_range(-1.5, 1.5)

func explode():
    """Explode rock."""
    $ExplodeSound.play()

    layers = 0
    $Sprite.hide()
    emit_signal("exploded", size, radius, position, linear_velocity)

    linear_velocity = Vector2()
    angular_velocity = 0

    $AnimationPlayer.play("explode")
    yield($AnimationPlayer, "animation_finished")
    queue_free()

###################
# Lifecycle methods

func _ready():
    if !is_sub_rock:
        start(position, base_linear_velocity, 2)
