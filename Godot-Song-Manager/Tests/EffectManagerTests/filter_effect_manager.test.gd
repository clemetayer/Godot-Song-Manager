extends WAT.Test

# Doc : https://github.com/AlexDarigan/WAT

##### ENUMS #####
# enumerations

##### VARIABLES #####
var filter_effect_manager: FilterEffectManager


##### PROCESSING #####
func pre():
	filter_effect_manager = FilterEffectManager.new()


func post():
	filter_effect_manager.queue_free()


func title() -> String:
	return "Test of the filter effect manager"


##### UTILS #####
# Usefull general functions for the test


##### TEST FUNCTIONS #####
# tests the start effect method
func test_start_effect() -> void:
	filter_effect_manager.TIME = 0.25
	var filter = AudioEffectFilter.new()
	filter.cutoff_hz = 0.0
	add_child(filter_effect_manager)
	filter_effect_manager.init_updating_properties(
		[
			{
				"object": filter,
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			}
		]
	)
	filter_effect_manager.start_effect(
		[
			{
				"object": filter,
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			}
		]
	)
	watch(filter_effect_manager._tween, "tween_step")
	watch(filter_effect_manager._tween, "tween_all_completed")
	asserts.is_true(
		is_instance_valid(filter_effect_manager._tween), "tween in effect manager is created"
	)
	yield(until_signal(filter_effect_manager._tween, "tween_step", 0.1), YIELD)
	asserts.is_less_than(filter.cutoff_hz, 20000, "filter starts at less than 20 kHz")
	yield(until_signal(filter_effect_manager._tween, "tween_all_completed", 0.5), YIELD)
	asserts.is_equal(filter.cutoff_hz, 20000, "filter ends at 20 kHz")
	describe("Test of the start effect")


# test of the init_updating_properties method
func test_init_updating_properties() -> void:
	filter_effect_manager.init_updating_properties(
		[
			{
				"object": self,
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			},
			{
				"object": null,
				"interpolate_value": "unused",
				"interpolate_type": "property",
				"type": "none",
				"fade_in": true
			}
		]
	)
	asserts.is_equal(1, filter_effect_manager.updating_properties.size(), "1 effect in updating properties array")
	asserts.is_equal({
		"object": self,
		"interpolate_value": "cutoff_hz",
		"interpolate_type": "property",
		"type": "filter",
		"fade_in": true
	}.hash(), filter_effect_manager.updating_properties[0].hash(), "effect set correctly in updating_properties")
	describe("Test of the init updating properties method")


# test of the cancel same effects method
func test_cancel_same_effects() -> void:
	filter_effect_manager.TIME = 0.5
	var filter = AudioEffectFilter.new()
	filter.cutoff_hz = 0.0
	add_child(filter_effect_manager)
	filter_effect_manager.init_updating_properties(
		[
			{
				"object": filter,
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			}
		]
	)
	filter_effect_manager.start_effect(
		[
			{
				"object": filter,
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			}
		]
	)
	watch(filter_effect_manager._tween, "tween_all_completed")
	asserts.is_less_than(filter.cutoff_hz, 20000, "filter starts at below 20 kHz")
	var new_filter_effect_manager = FilterEffectManager.new()
	new_filter_effect_manager.TIME = 0.25
	new_filter_effect_manager.init_updating_properties(
		[
			{
				"object": filter,
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			}
		]
	)
	new_filter_effect_manager.start_effect(
		[
			{
				"object": filter,
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": false
			}
		]
	)
	filter_effect_manager.cancel_same_effects(new_filter_effect_manager)
	yield(until_signal(new_filter_effect_manager._tween, "tween_all_completed", 0.5), YIELD)
	asserts.is_less_than(
		filter.cutoff_hz, 20000, "filter ends at less than 20 kHz (because it was cancelled)"
	)
	describe("Test of the cancel_same_effects method")
