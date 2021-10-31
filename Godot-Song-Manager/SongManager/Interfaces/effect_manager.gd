extends Node
class_name EffectManager
# Interface to manage the effects that should be applied to the song, every method here can (and should) be overrided 

##### VARIABLES #####
#---- SIGNALS -----
signal effect_done

#---- EXPORTS -----
export (String) var WAIT_SIGNAL = null  # if it should wait for a particular signal emitted by a song (verification if it exists should be done by song's manager)
export (float) var TIME = 0.0  # transition time

#---- STANDARD -----
#==== PUBLIC ====
var updating_properties := []  # array of the properties that the transition will actually update (to cancel some if necessary)


##### PUBLIC METHODS #####
# starts the effect, emits "effect_done" signal when it is over
func start_effect(_params:Array) -> void:
	emit_signal("effect_done")

# inits the updating properties array (to cancel the same effects if necessary)
func init_updating_properties(_params:Array) -> void:
	pass

# cancels the effects that are the same as the one specified in parameters
func cancel_same_effects(_effect: EffectManager):
	pass
