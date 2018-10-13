tool
extends Area2D

enum Rotation {
    E = 0,
    SE = 45,
    S = 90,
    SW = 135,
    W = 180,
    NW = 225,
    N = 270,
    NE = 315
}

export (Rotation) var rotation_value = Rotation.E

var orbit_velocity = 0.5
var angular_velocity = 50

func _set_label():
    var ch
    match rotation_value:
        E:
            ch = "s"
        SE:
            ch = "t"
        S:
            ch = "u"
        SW:
            ch = "v"
        W:
            ch = "w"
        NW:
            ch = "x"
        N:
            ch = "y"
        NE:
            ch = "z"

    $Label.text = ch

func _ready():
    $Particles2D.process_material.orbit_velocity = orbit_velocity
    $Particles2D.process_material.angular_velocity = angular_velocity

    _set_label()