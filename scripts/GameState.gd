extends Node

#####################
# GameState singleton

# Screens enumeration
enum Screens {
    TITLE,               # Title screen
    INTRO,               # Introduction screen
    INSTRUCTIONS,        # Instructions screen
    GAME_OVER,           # Game over screen
    END_GAME,            # End game screen
    END_GAME_SUCCESS     # End game success screen
}

##############
# Private vars

# Current score
var score = 0
# High score
var high_score = 0
# Current lives
var lives = 5
# Current level ID
var current_level = 0
# Current treasures
var treasures = []
# Game already finished
var game_already_finished = false

# Current game save
var current_game_save = null

# Screen map
var screen_map = {
    Screens.TITLE: "res://screens/title_screen/TitleScreen.tscn",
    Screens.INTRO: "res://screens/intro_screen/IntroScreen.tscn",
    Screens.INSTRUCTIONS: "res://screens/instructions_screen/InstructionsScreen.tscn",
    Screens.GAME_OVER: "res://screens/game_over_screen/GameOverScreen.tscn",
    Screens.END_GAME: "res://screens/end_game_screen/EndGameScreen.tscn",
    Screens.END_GAME_SUCCESS: "res://screens/end_game_success_screen/EndGameSuccessScreen.tscn"
}

################
# Public methods

# Screen loading methods

func load_screen(screen):
    """
    Load screen.

    :param screen:  Screen enum value
    """
    if screen == Screens.TITLE:
        reset_state_values()

    _change_scene(screen_map[screen])

func load_level(level_id, transition_speed=1):
    """
    Load level.

    :param level_id:            Level ID
    :param transition_speed:    Transition speed
    """
    current_level = level_id
    _change_scene("res://levels/Level" + str(level_id) + ".tscn", transition_speed)

func load_next_level():
    """Load next level."""
    if current_level == 4:
        # End game !
        load_screen(Screens.END_GAME)
    else:
        load_level(current_level + 1)

func reload_current_level():
    """Reload current level."""
    load_level(current_level, 2)

# State update methods

func reset_state_values():
    """Reset state values."""
    score = 0
    lives = 5
    current_level = 0
    treasures = []

func add_score(value):
    """
    Add value to score.

    :param value:   Score to add
    """
    score += value

func remove_life():
    """Remove a life."""
    lives = max(lives - 1, 0)

func unlock_treasure(name):
    """
    Unlock treasure.

    :param name:    Name
    """
    treasures.push_back(name)

func all_treasures_unlocked():
    """Check if all treasures are unlocked."""
    return treasures == ["Triangle", "Quad", "Hex"]

func update_hud(hud):
    """
    Update HUD.

    :param hud: HUD node
    """
    hud.update_score(score)
    hud.update_lives(lives)
    hud.show_treasures(treasures)

############################
# User data handling methods

func load_empty_game_save():
    """Load default game save."""
    return {
        "high_score": 0,
        "game_already_finished": false
    }

func load_game_save():
    """Load game save."""
    var file_path = File.new()
    if not file_path.file_exists("user://save.dat"):
        return load_empty_game_save()

    var game_save = null
    file_path.open("user://save.dat", File.READ)
    while not file_path.eof_reached():
        game_save = parse_json(file_path.get_line())
        break
    file_path.close()

    if not game_save:
        game_save = load_empty_game_save()

    return game_save

func save_game_save(game_save):
    """
    Save game save.

    :param game_save:    Game save
    """
    var file_path = File.new()
    file_path.open("user://save.dat", File.WRITE)
    file_path.store_line(to_json(game_save))
    file_path.close()

func apply_game_save(game_save):
    """
    Apply game save to current state.

    :param game_save:    Game save
    """
    high_score = game_save["high_score"]
    game_already_finished = game_save["game_already_finished"]
    current_game_save = game_save

func save_game_over():
    """Save after game over."""
    if score > high_score:
        high_score = score
        current_game_save["high_score"] = high_score
        save_game_save(current_game_save)

func save_game_success():
    """Save after game success."""
    game_already_finished = true
    if score > high_score:
        high_score = score
        current_game_save["high_score"] = high_score
    current_game_save["game_already_finished"] = true
    save_game_save(current_game_save)

#################
# Private methods

func _change_scene(path, transition_speed=1):
    Transition.fade_to_scene(path, transition_speed)

###################
# Lifecycle methods

func _ready():
    var game_save = load_game_save()
    apply_game_save(game_save)