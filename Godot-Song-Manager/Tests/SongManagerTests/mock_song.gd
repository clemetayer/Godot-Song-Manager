extends Song
class_name MockSong
# Mock for the standard song manager, to write tests more easily

##### SIGNALS #####
# Node signals

##### ENUMS #####
# enumerations

##### VARIABLES #####
#---- CONSTANTS -----
# const constant := 10 # Optionnal comment

#---- EXPORTS -----
# export(int) var EXPORT_NAME # Optionnal comment

#---- STANDARD -----
#==== PUBLIC ====
var playing := false
var updated := false
var neutral_effect_done := false

#==== PRIVATE ====
# var _private_var # Optionnal comment

#==== ONREADY ====
# onready var onready_var # Optionnal comment


##### PUBLIC METHODS #####
# plays the song, returns an array to give to the EffectManager as a parameter
func play() -> Array:
	playing = true
	return []


# stops the song, returns an array to give to  the EffectManager as a parameter
func stop() -> Array:
	playing = false
	return []


# updates the song to match the one specified in parameters, returns an array to give to  the EffectManager as a parameter
func update(_song: Song) -> Array:
	playing = true
	updated = true
	return []


# links to the effects that can be triggered in "neutral" position (for example, same song, but lower the volume slowly on pause), depending on whatever is specified in parameters, returns an array to give to the EffectManager as a parameter
func get_neutral_effect_data(_param) -> Array:
	neutral_effect_done = true
	return []
