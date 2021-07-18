extends WAT.Test
class_name TransitionUTest

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var transition : Transition

##### PROCESSING #####
func pre():
	transition = Transition.new()
	transition.TIME_TYPE = transition.time_type.time
	transition.FADE_IN_TIME = 2
	transition.FADE_OUT_TIME = 2

func title() -> String:
	return "Test of the default transition"

##### TEST FUNCTIONS #####
# Test of the computeTransitionTime function
func test_computeTransitionTime() -> void:
	var res = transition.computeTransitionTime(120,4)
	asserts.is_equal(res[0],2,"Transition in time set at 2 seconds")
	asserts.is_equal(res[1],2,"Transition out time set at 2 seconds")
	describe("Test of the computeTransitionTime function")
