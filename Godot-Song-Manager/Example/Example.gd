extends Node2D

##### EXPORTS #####
# songs
export(String, FILE) var SONG_1_PATH = "res://Example/Songs/Scenes/Song1/Song1.tscn"
export(String, FILE) var SONG_2_PATH = "res://Example/Songs/Scenes/Song2/Song2.tscn"
# transitions
export(String, FILE) var FILTER_EFFECT = "res://SongManager/templates/EffectManagers/FilterEffectManager/filter_effect_manager.gd"
export(String, FILE) var INSTANT_TRANSITION = "res://SongManager/templates/EffectManagers/InstantEffectManager/instant_effect_manager.gd"
export(String, FILE) var VOLUME_TRANSITION = "res://SongManager/templates/EffectManagers/VolumeEffectManager/volume_effect_manager.gd"

##### SCRIPT VARIABLES #####
var check_lock = false # to avoid triggering the "checked"
var song1_playing = false
var song2_playing = false

##### BUTTONS SIGNALS #####
func _on_Song1Button_pressed():
	check_lock = true
	for child in $Menu/Center/VSplit/Songs/Song2/Checks.get_children(): # unchecks everything in other song
		child.pressed = false
	check_lock = false
	check_lock = true
	for check in $Menu/Center/VSplit/Songs/Song1/Checks.get_children():
		if(check.pressed):
			check.pressed = false
	check_lock = false
	var song : Song = load(SONG_1_PATH).instance()
	song.ANIMATION = "All"
	var transition = getTransition()
	if not song1_playing:
		$StandardSongManager.add_to_queue(song, transition)
		song1_playing = true
	else:
		$StandardSongManager.stop_current(transition)
		song1_playing = false
		

func _on_Song2Button_pressed():
	check_lock = true
	for child in $Menu/Center/VSplit/Songs/Song1/Checks.get_children(): # unchecks everything in other song
		child.pressed = false
	check_lock = false
	var uncheck_all = true # if everything is already checked, should uncheck all (i.e stop the song)
	check_lock = true
	for check in $Menu/Center/VSplit/Songs/Song2/Checks.get_children():
		if(not check.pressed):
			check.pressed = true
			uncheck_all = false
	check_lock = false
	if uncheck_all:
		check_lock = true
		for check in $Menu/Center/VSplit/Songs/Song2/Checks.get_children():
			check.pressed = false
		check_lock = false
	var song : Song = load(SONG_2_PATH).instance()
	song.init() # using _ready does not work because it did not entered the tree yet
	for check in $Menu/Center/VSplit/Songs/Song2/Checks.get_children():
		song._tracks[check.text].play = not uncheck_all
	var transition = getTransition()
	if not uncheck_all:
		$StandardSongManager.add_to_queue(song, transition)
		song2_playing = true
	else:
		$StandardSongManager.stop_current(transition)
		song2_playing = false

func _on_Song1AB_toggled(button_pressed):
	if button_pressed:
		for check in $Menu/Center/VSplit/Songs/Song1/Checks.get_children():
			if check.pressed and not check.name == "Song1AB":
				check_lock = true
				check.pressed = false
				check_lock = false
		Song1Check("ArpeggioBass")
		song1_playing = true
	else:
		if not check_lock:
			$StandardSongManager.stop_current(getTransition())
			song1_playing = false


func _on_Song1AC_toggled(button_pressed):
	if button_pressed:
		check_lock = true
		for check in $Menu/Center/VSplit/Songs/Song1/Checks.get_children():
			if check.pressed and not check.name == "Song1AC":
				check.pressed = false
		check_lock = false
		Song1Check("ArpeggioChords")
		song1_playing = true
	else:
		if not check_lock:
			$StandardSongManager.stop_current(getTransition())
			song1_playing = false


func _on_Song1CB_toggled(button_pressed):
	if button_pressed:
		check_lock = true
		for check in $Menu/Center/VSplit/Songs/Song1/Checks.get_children():
			if check.pressed and not check.name == "Song1CB":
				check.pressed = false
		check_lock = false
		Song1Check("ChordsBass")
		song1_playing = true
	else:
		if not check_lock:
			$StandardSongManager.stop_current(getTransition())
			song1_playing = false

func Song1Check(name):
	if(not check_lock):
		check_lock = true
		for child in $Menu/Center/VSplit/Songs/Song2/Checks.get_children(): # unchecks everything in other song
			child.pressed = false
		check_lock = false
		var song : Song = load(SONG_1_PATH).instance()
		song.ANIMATION = name
		var transition = getTransition()
		$StandardSongManager.add_to_queue(song, transition)
	else: 
		check_lock = false

func Song2Check(_button_pressed):
	if(not check_lock):
		check_lock = true
		for child in $Menu/Center/VSplit/Songs/Song1/Checks.get_children(): # unchecks everything in other song
			child.pressed = false
		check_lock = false
		var song : Song = load(SONG_2_PATH).instance()
		song.init() # using _ready does not work because it did not entered the tree yet
		var stop_song := true # if every checkbox is unchecked, then stop the song
		for check in $Menu/Center/VSplit/Songs/Song2/Checks.get_children():
			if check.pressed: # should not stop song
				stop_song = false
			song._tracks[check.text].play = check.pressed
		var transition = getTransition()
		if not stop_song:
			$StandardSongManager.add_to_queue(song, transition)
			song2_playing = true
		else:
			$StandardSongManager.stop_current(transition)
			song2_playing = false

##### FUNCTIONS #####

# returns the appropriate transition
func getTransition() -> EffectManager:
	var transition : EffectManager
	match($Menu/Center/VSplit/Transitions/Transition/Elements/TransitionType.selected):
		0: # filter
			transition = load(FILTER_EFFECT).new()
		1: # volume
			transition = load(VOLUME_TRANSITION).new()
		2: # instant
			transition = load(INSTANT_TRANSITION).new()
	setTransitionTimes(transition)
	return transition

# sets a wait for next beat/bar if needed
func setTransitionWait(_effect : EffectManager):
	pass

# sets the fade in/out of transition
func setTransitionTimes(effect : EffectManager):
	effect.TIME = $Menu/Center/VSplit/Transitions/Transition/Elements/Time/Time.value
