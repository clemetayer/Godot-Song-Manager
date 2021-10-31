extends EffectManager
class_name MockEffectManager
# A mock effect manager to make tests on the song manager easier

##### VARIABLES #####
#---- STANDARD -----
#==== PUBLIC ====
var effect_started := false
var properties_initiated := false
var effects_canceled := false


##### PUBLIC METHODS #####
# starts the effect, emits "effect_done" signal when it is over
func start_effect(_params: Array) -> void:
	effect_started = true
	emit_signal("effect_done")


# inits the updating properties array (to cancel the same effects if necessary)
func init_updating_properties(_params: Array) -> void:
	properties_initiated = true


# cancels the effects that are the same as the one specified in parameters
func cancel_same_effects(_effect: EffectManager):
	effects_canceled = true
