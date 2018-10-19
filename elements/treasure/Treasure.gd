extends Node2D

#################
# Treasure script

##############
# Exposed vars

export (String) var treasure_name

##############
# Private vars

var textures = {
    'Triangle': 'res://assets/images/triangle.png',
    'Quad': 'res://assets/images/quad.png',
    'Hex': 'res://assets/images/hex.png'
}

################
# Public methods

func shrink():
    """Shrink treasure."""
    $AnimationPlayer.play("shrink")
    yield($AnimationPlayer, "animation_finished")
    queue_free()

###################
# Lifecycle methods

func _ready():
    if treasure_name in textures:
        $Sprite.texture = load(textures[treasure_name])