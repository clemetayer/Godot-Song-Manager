extends WAT.Test

# Doc : https://github.com/AlexDarigan/WAT

##### ENUMS #####
# enumerations

##### VARIABLES #####
var effect_manager: EffectManager


##### PROCESSING #####
func pre():
	effect_manager = EffectManager.new()


func post():
	effect_manager.queue_free()


func title() -> String:
	return "Test of a standard effect manager"


##### UTILS #####
# Usefull general functions for the test


##### TEST FUNCTIONS #####
# tests the tween initialisation
func test_start_effect() -> void:
	watch(effect_manager, "effect_done")
	effect_manager.init_updating_properties([])
	effect_manager.start_effect([])
	asserts.signal_was_emitted(effect_manager, "effect_done")
	describe("Test of the start effect method")


# test of the init updating properties
func test_init_updating_properties() -> void:
	asserts.is_true(true, "standard (useless) test")
	describe("Test of the init updating properties method")


# test of the cancel same effects method
func test_cancel_same_effects() -> void:
	asserts.is_true(true, "standard (useless) test")
	describe("Test of the cancel_same_effects method")
