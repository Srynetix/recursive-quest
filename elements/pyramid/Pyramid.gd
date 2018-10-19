extends Area2D

################
# Pyramid script

###############
# Exported vars

# Is the pyramid shrunk?
export (bool) var shrunk = false
# Is the pyramid hidden?
export (bool) var hidden = false
# Is the pyramid disabled?
export (bool) var disabled = false

#################
# Private methods

func _shrink():
    scale = Vector2(0.1, 0.1)
    $Particles2D.process_material.scale = 0.1

func _hide():
    $Sprite.visible = false
    $Light2D.visible = false
    $Particles2D.visible = false

###################
# Lifecycle methods

func _ready():
    if shrunk:
        _shrink()
    if hidden:
        _hide()
