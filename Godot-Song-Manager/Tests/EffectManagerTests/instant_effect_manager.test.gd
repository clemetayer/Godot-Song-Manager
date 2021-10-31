extends WAT.Test

# Doc : https://github.com/AlexDarigan/WAT

##### ENUMS #####
# enumerations

##### VARIABLES #####
var instant_effect_manager: InstantEffectManager


##### PROCESSING #####
func pre():
	instant_effect_manager = InstantEffectManager.new()


func post():
	instant_effect_manager.queue_free()


func title() -> String:
	return "Test of an instant effect manager"


##### UTILS #####
# Usefull general functions for the test


##### TEST FUNCTIONS #####
# tests the tween initialisation
func test_start_effect() -> void:
	watch(instant_effect_manager, "effect_done")
	instant_effect_manager.init_updating_properties([])
	instant_effect_manager.start_effect([])
	asserts.signal_was_emitted(instant_effect_manager, "effect_done")
	describe("Test of the start effect method")


# test of the init updating properties
func test_init_updating_properties() -> void:
	asserts.is_true(true, "standard (useless) test")
	describe("Test of the init updating properties method")


# test of the cancel same effects method
func test_cancel_same_effects() -> void:
	asserts.is_true(true, "standard (useless) test")
	describe("Test of the cancel_same_effects method")
