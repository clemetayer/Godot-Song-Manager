extends Node
class_name Transition

# should take care of transition tween creation and 

enum time_type {time,beat,bar}
export(time_type) var TIME_TYPE = time_type.time

export(bool) var WAIT_NEXT_BEAT = false
export(bool) var WAIT_NEXT_BAR = false

export(float) var FADE_IN_TIME = 0 # how much time new song should take to fade in
export(float) var FADE_OUT_TIME = 0 # how much time old song should take to fade in

# computes the transition in/out times [transition_in,transition_out] in seconds
# default function, can be overrided (by re-defining it in children classes)
# by default, just takes the time in fade in/out
func computeTransitionTime(_tempo : int, _beats_per_bar : int) -> Array:
	return [FADE_IN_TIME,FADE_OUT_TIME]

# initializes the tween for the transition (does not start it)
# default function, can be overrided (by re-defining it in children classes)
# by default, either returns an empty tween, or the custom tween
func initTransitionTween(_fade_in : bool, _bus_name : String, _transition_time : Array,  _effects : Dictionary, custom_tween : Tween = null) -> Tween:
	if(custom_tween == null):
		return Tween.new()
	else:
		return custom_tween
