extends Area2D

##################
# Text zone script

###############
# Exported vars

# Standard text
export (String, MULTILINE) var text = ""
# Mobile text
export (String, MULTILINE) var mobile_text = ""
# Text speed
export (float) var text_speed = 0.025
# Zone shape scale
export (float) var shape_scale = 1

################
# Public methods

func get_text():
    """Get text."""
    if _is_mobile() and mobile_text != "":
        return mobile_text
    else:
        return text

func get_text_speed():
    """Get text speed."""
    return text_speed

#################
# Private methods

func _is_mobile():
    var os_name = OS.get_name()
    return os_name == "Android" or os_name == "iOS"

###################
# Lifecycle methods

func _ready():
    $CollisionShape2D.shape.extents *= Vector2(shape_scale, shape_scale)
