extends EffectManager
class_name VolumeEffectManager

##### VARIABLES #####
#---- STANDARD -----
var _tween: Tween

##### PUBLIC METHODS #####
"""
starts an effect, emits "effect_done" when done
compatible param :
{
	"object":Object,
	"interpolate_value":"<volume_param>",
	"interpolate_type":"property/method",
	"type":"volume",
	"fade_in":bool
}
"""


func start_effect(params: Array) -> void:
	_init_tween(params)
	add_child(_tween)
	var _err = _tween.start()
	yield(_tween, "tween_all_completed")
	emit_signal("effect_done")


# inits the updating properties array (to cancel the same effects if necessary)
func init_updating_properties(params: Array) -> void:
	for param in params:
		if param.has("type") and param.type == "volume":
			updating_properties.append(param)


# cancels the effects that are the same as the one specified in parameters
func cancel_same_effects(effect):
	for new_effect in effect.updating_properties:
		var remove_effect := []
		for cur_effect in updating_properties:
			if (
				cur_effect.object == new_effect.object
				and cur_effect.interpolate_value == new_effect.interpolate_value
				and cur_effect.type == new_effect.type
			):
				var _err = _tween.stop(cur_effect.object, cur_effect.interpolate_value)
				remove_effect.append(cur_effect)
		for effect in remove_effect:  # remove the effects that has been cancelled
			updating_properties.erase(effect)


##### PROTECTED METHODS #####
func _init_tween(params: Array) -> void:
	_tween = Tween.new()
#	var _err = _tween.connect("tween_step", self, "_print_tween_step")
	for param in params:
		if param.has("type") and param.type == "volume":
			_add_effect_to_tween(param)


# adds an effect to the tween with the parameter specified
func _add_effect_to_tween(param: Dictionary):
	match param.interpolate_type:
		"property":
			if param.fade_in:
				var _err = _tween.interpolate_property(
					param.object,
					param.interpolate_value,
					-80.0,
					0.0,
					TIME,
					Tween.TRANS_QUART,
					Tween.EASE_OUT
				)  # looks weird, but it is better this way
			else:
				var _err = _tween.interpolate_property(
					param.object,
					param.interpolate_value,
					param.object.get(param.interpolate_value),
					-80.0,
					TIME,
					Tween.TRANS_QUART,
					Tween.EASE_IN
				)  # looks weird, but it is better this way
		"method":
			var _err = _tween.interpolate_method(
				param.object, param.interpolate_value, 0.0, 1.0, TIME
			)


##### DEBUG #####
func _print_updating_properties():
	print("Updating properties = %s" % updating_properties)


func _print_tween_step(object: Object, key: NodePath, elapsed: float, value: Object):
	print("tween step : object %s, key %s, elapsed %f, value %s" % [object, key, elapsed, value])
