extends Node

const FLOAT_EPSILON = 0.0001

static func float_eq(a, b):
    return abs(a - b) <= FLOAT_EPSILON