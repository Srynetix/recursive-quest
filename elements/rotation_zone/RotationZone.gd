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

    if $Label.text != ch:
        $Label.text = ch

func _ready():
    _set_label()

func _process(delta):
    _set_label()