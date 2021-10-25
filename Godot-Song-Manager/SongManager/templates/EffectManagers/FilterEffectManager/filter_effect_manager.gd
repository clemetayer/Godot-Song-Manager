extends EffectManager
class_name FilterEffectManager

##### PUBLIC METHODS #####
"""
initializes a tween for the transition, according to an array of parameters specified by the song
Note : does not start it, just initializes it.
compatible param :
{
	"object":Object,
	"interpolate_value":"cutoff_hz",
	"interpolate_type":"property",
	"type":"filter",
	"fade_in":bool
}
"""


func init_tween(params: Array) -> void:
	tween = Tween.new()
	for param in params:
		if param.has("type") and param.type == "filter":
			_add_effect_to_tween(param)
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
				var _err = tween.stop(cur_effect.object, cur_effect.interpolate_value)
				remove_effect.append(cur_effect)
		for effect in remove_effect:  # remove the effects that has been cancelled
			updating_properties.erase(effect)


##### PROTECTED METHODS #####
# adds an effect to the tween with the parameter specified
func _add_effect_to_tween(param: Dictionary):
	if param.fade_in:
		var _err = tween.interpolate_property(
			param.object,
			param.interpolate_value,
			0.0,
			20000.0,
			TIME,
			Tween.TRANS_QUAD,
			Tween.EASE_IN
		)
	else:
		var _err = tween.interpolate_property(
			param.object,
			param.interpolate_value,
			param.object[param.interpolate_value],
			0.0,
			TIME,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)


##### DEBUG #####
func _print_updating_properties():
	print("Updating properties = %s" % updating_properties)


func _print_tween_step(object: Object, key: NodePath, elapsed: float, value: Object):
	print("tween step : object %s, key %s, elapsed %f, value %s" % [object, key, elapsed, value])
