extends Node

###########
# Utilities

##############
# Private vars

# Epsilon values, used for float comparisons
const FLOAT_EPSILON = 0.0001

################
# Public methods

static func float_eq(a, b):
    """Check if two floats are equal."""
    return abs(a - b) <= FLOAT_EPSILON
