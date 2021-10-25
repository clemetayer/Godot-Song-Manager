extends Node
class_name Song
# Interface for the songs

##### PUBLIC METHODS #####
# plays the song, returns an array to give to the EffectManager as a parameter
func play() -> Array:
	return []


# stops the song, returns an array to give to  the EffectManager as a parameter
func stop() -> Array:
	return []


# updates the song to match the one specified in parameters, returns an array to give to  the EffectManager as a parameter
func update(_song: Song) -> Array:
	return []


# links to the effects that can be triggered in "neutral" position (for example, same song, but lower the volume slowly on pause), depending on whatever is specified in parameters, returns an array to give to the EffectManager as a parameter
func get_neutral_effect_data(_param) -> Array:
	return []
