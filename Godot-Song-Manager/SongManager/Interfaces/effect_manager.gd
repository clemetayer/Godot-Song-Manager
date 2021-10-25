extends Node
class_name EffectManager
# Interface to manage the effects that should be applied to the song, every method here can (and should) be overrided 

#---- EXPORTS -----
export (String) var WAIT_SIGNAL = null  # if it should wait for a particular signal emitted by a song (verification if it exists should be done by song's manager)
export (float) var TIME = 0.0  # transition time

#---- STANDARD -----
#==== PUBLIC ====
var updating_properties := []  # array of the properties that the transition will actually update (to cancel some if necessary)
var tween: Tween


##### PUBLIC METHODS #####
# initializes a tween for the transition, according to an array of parameters specified by the song
# Note : does not start it, just initializes it.
func init_tween(_params: Array) -> void:
	tween = Tween.new()


# cancels the effects that are the same as the one specified in parameters
func cancel_same_effects(_effect: EffectManager):
	pass
