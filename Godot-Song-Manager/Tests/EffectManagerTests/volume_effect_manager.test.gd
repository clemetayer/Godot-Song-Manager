extends WAT.Test

# Doc : https://github.com/AlexDarigan/WAT

##### ENUMS #####
# enumerations

##### VARIABLES #####
var volume_effect_manager: VolumeEffectManager
var volume: float


##### PROCESSING #####
func pre():
	volume_effect_manager = VolumeEffectManager.new()
	add_child(volume_effect_manager)
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, "test_bus")
	volume = 0.0


func post():
	volume_effect_manager.queue_free()
	AudioServer.remove_bus(AudioServer.get_bus_index("test_bus"))


func title() -> String:
	return "Test of the volume effect manager"


##### UTILS #####
# method to set the volume to the test bus
func set_volume_to_bus(_value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("test_bus"), volume)


##### TEST FUNCTIONS #####
# tests the start effect method
func test_start_effect() -> void:
	volume_effect_manager.TIME = 0.25
	volume_effect_manager.init_updating_properties(
		[
			{
				"object": self,
				"interpolate_value": "volume",
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": self,
				"interpolate_value": "set_volume_to_bus",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": true
			}
		]
	)
	volume_effect_manager.start_effect(
		[
			{
				"object": self,
				"interpolate_value": "volume",
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": self,
				"interpolate_value": "set_volume_to_bus",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": true
			}
		]
	)
	asserts.is_true(
		is_instance_valid(volume_effect_manager._tween), "tween in effect manager is created"
	)
	watch(volume_effect_manager, "effect_done")
	watch(volume_effect_manager._tween,"tween_step")
	yield(until_signal(volume_effect_manager._tween, "tween_step", 0.1), YIELD)
	asserts.is_less_than(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("test_bus")),
		0.0,
		"volume starts at less than 0.0 db"
	)
	yield(until_signal(volume_effect_manager, "effect_done", 2.0), YIELD)
	yield(until_timeout(1.0), YIELD) # for some reason, an additionnal wait time is required
	asserts.is_equal(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("test_bus")), 0.0, "volume ends at 0.0 db"
	)
	describe("Test of the start effect")


# test of the init_updating_properties method
func test_init_updating_properties() -> void:
	volume_effect_manager.init_updating_properties(
		[
			{
				"object": self,
				"interpolate_value": "volume",
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": self,
				"interpolate_value": "set_volume_to_bus",
				"interpolate_type": "method",
				"type": "volume",
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
	asserts.is_equal(2, volume_effect_manager.updating_properties.size(), "2 effects in updating properties array")
	if volume_effect_manager.updating_properties.size() == 2:
		asserts.is_equal({
					"object": self,
					"interpolate_value": "volume",
					"interpolate_type": "property",
					"type": "volume",
					"fade_in": true
				}.hash(), volume_effect_manager.updating_properties[0].hash(), "effect 0 set correctly in updating_properties")
		asserts.is_equal({
					"object": self,
					"interpolate_value": "set_volume_to_bus",
					"interpolate_type": "method",
					"type": "volume",
					"fade_in": true
				}.hash(), volume_effect_manager.updating_properties[1].hash(), "effect 1 set correctly in updating_properties")
	describe("Test of the init updating properties method")


# test of the cancel same effects method
func test_cancel_same_effects() -> void:
	volume_effect_manager.TIME = 0.25
	volume_effect_manager.init_updating_properties(
		[
			{
				"object": self,
				"interpolate_value": "volume",
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": self,
				"interpolate_value": "set_volume_to_bus",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": true
			}
		]
	)
	volume_effect_manager.start_effect(
		[
			{
				"object": self,
				"interpolate_value": "volume",
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": self,
				"interpolate_value": "set_volume_to_bus",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": true
			}
		]
	)
	watch(volume_effect_manager._tween, "tween_step")
	watch(volume_effect_manager._tween, "tween_all_completed")
	var new_volume_effect_manager = VolumeEffectManager.new()
	add_child(new_volume_effect_manager)
	new_volume_effect_manager.TIME = 0.25
	new_volume_effect_manager.init_updating_properties(
		[
			{
				"object": self,
				"interpolate_value": "volume",
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": self,
				"interpolate_value": "set_volume_to_bus",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": true
			}
		]
	)
	new_volume_effect_manager.start_effect(
		[
			{
				"object": self,
				"interpolate_value": "volume",
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": false
			},
			{
				"object": self,
				"interpolate_value": "set_volume_to_bus",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": false
			}
		]
	)
	volume_effect_manager.cancel_same_effects(new_volume_effect_manager)
	yield(until_signal(new_volume_effect_manager._tween, "tween_all_completed", 0.5), YIELD)
	asserts.is_less_than(
		volume, 0.0, "volume ends at less than 0.0 db (because it was cancelled)"
	)
	new_volume_effect_manager.queue_free()
	describe("Test of the cancel_same_effects method")
