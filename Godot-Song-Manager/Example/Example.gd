extends Node2D

##### EXPORTS #####
# songs
export(String, FILE) var SONG_1_PATH = "res://Example/Songs/Scenes/Song1/Song1.tscn"
export(String, FILE) var SONG_2_PATH = "res://Example/Songs/Scenes/Song2/Song2.tscn"
# transitions
export(String, FILE) var FILTER_TRANSITION = "res://Example/Transitions/FilterTransition/FilterTransition.tscn"
export(String, FILE) var INSTANT_TRANSITION = "res://Example/Transitions/InstantTransition/InstantTransition.tscn"
export(String, FILE) var VOLUME_TRANSITION = "res://Example/Transitions/VolumeTransition/VolumeTransition.tscn"

##### SCRIPT VARIABLES #####
var check_lock = false # to avoid triggering the "checked"

##### BUTTONS SIGNALS #####
func _on_Song1Button_pressed():
	var song : Song = load(SONG_1_PATH).instance()
	var tracks = song.getTrackList()
	for child in $Menu/Center/VSplit/Songs/Song2/Checks.get_children(): # unchecks everything in other song
		check_lock = true
		child.pressed = false
	var uncheck_all = true # if everything is already checked, should uncheck all
	for check in $Menu/Center/VSplit/Songs/Song1/Checks.get_children():
		if(not check.pressed):
			check_lock = true
			check.pressed = true
			uncheck_all = false
	if(uncheck_all):
		for check in $Menu/Center/VSplit/Songs/Song1/Checks.get_children():
			check_lock = true
			check.pressed = false
	for track in tracks:
		song.setPlay(track.name, not uncheck_all)
	var transition = getTransition()
	$SongManager.addSongToQueue(song, transition)

func _on_Song2Button_pressed():
	var song : Song = load(SONG_2_PATH).instance()
	var tracks = song.getTrackList()
	for child in $Menu/Center/VSplit/Songs/Song1/Checks.get_children():
		check_lock = true
		child.pressed = false
	var uncheck_all = true # if everything is already checked, should uncheck all
	for check in $Menu/Center/VSplit/Songs/Song2/Checks.get_children():
		if(not check.pressed):
			check_lock = true
			check.pressed = true
			uncheck_all = false
	if(uncheck_all):
		for check in $Menu/Center/VSplit/Songs/Song2/Checks.get_children():
			check_lock = true
			check.pressed = false
	for track in tracks:
		song.setPlay(track.name, not uncheck_all)
	var transition = getTransition()
	$SongManager.addSongToQueue(song, transition)

func _on_Song1Chords_toggled(button_pressed):
	if(not check_lock):
		for child in $Menu/Center/VSplit/Songs/Song2/Checks.get_children(): # unchecks everything in other song
			check_lock = true
			child.pressed = false
		var song : Song = load(SONG_1_PATH).instance()
		check_lock = false
		song.setPlay("Chords",button_pressed)
		song.setPlay("Bass",$Menu/Center/VSplit/Songs/Song1/Checks/Song1Bass.pressed)
		song.setPlay("Arpeggio",$Menu/Center/VSplit/Songs/Song1/Checks/Song1Arpeggio.pressed)
		var transition = getTransition()
		$SongManager.addSongToQueue(song, transition)
	else: 
		check_lock = false

func _on_Song1Bass_toggled(button_pressed):
	if(not check_lock):
		for child in $Menu/Center/VSplit/Songs/Song2/Checks.get_children(): # unchecks everything in other song
			check_lock = true
			child.pressed = false
		var song : Song = load(SONG_1_PATH).instance()
		check_lock = false
		song.setPlay("Chords",$Menu/Center/VSplit/Songs/Song1/Checks/Song1Chords.pressed)
		song.setPlay("Bass",button_pressed)
		song.setPlay("Arpeggio",$Menu/Center/VSplit/Songs/Song1/Checks/Song1Arpeggio.pressed)
		var transition = getTransition()
		$SongManager.addSongToQueue(song, transition)
	else: 
		check_lock = false

func _on_Song1Arpeggio_toggled(button_pressed):
	if(not check_lock):
		for child in $Menu/Center/VSplit/Songs/Song2/Checks.get_children(): # unchecks everything in other song
			check_lock = true
			child.pressed = false
		var song : Song = load(SONG_1_PATH).instance()
		check_lock = false
		song.setPlay("Chords",$Menu/Center/VSplit/Songs/Song1/Checks/Song1Chords.pressed)
		song.setPlay("Bass",$Menu/Center/VSplit/Songs/Song1/Checks/Song1Bass.pressed)
		song.setPlay("Arpeggio",button_pressed)
		var transition = getTransition()
		$SongManager.addSongToQueue(song, transition)
	else: 
		check_lock = false

func _on_Song2Chords_toggled(button_pressed):
	if(not check_lock):
		for child in $Menu/Center/VSplit/Songs/Song1/Checks.get_children(): # unchecks everything in other song
			check_lock = true
			child.pressed = false
		var song : Song = load(SONG_2_PATH).instance()
		check_lock = false
		song.setPlay("Chords",button_pressed)
		song.setPlay("Bass",$Menu/Center/VSplit/Songs/Song2/Checks/Song2Bass.pressed)
		song.setPlay("Drums",$Menu/Center/VSplit/Songs/Song2/Checks/Song2Drums.pressed)
		var transition = getTransition()
		$SongManager.addSongToQueue(song, transition)
	else: 
		check_lock = false

func _on_Song2Bass_toggled(button_pressed):
	if(not check_lock):
		for child in $Menu/Center/VSplit/Songs/Song1/Checks.get_children(): # unchecks everything in other song
			check_lock = true
			child.pressed = false
		var song : Song = load(SONG_2_PATH).instance()
		check_lock = false
		song.setPlay("Chords",$Menu/Center/VSplit/Songs/Song2/Checks/Song2Chords.pressed)
		song.setPlay("Bass",button_pressed)
		song.setPlay("Drums",$Menu/Center/VSplit/Songs/Song2/Checks/Song2Drums.pressed)
		var transition = getTransition()
		$SongManager.addSongToQueue(song, transition)
	else: 
		check_lock = false

func _on_Song2Drums_toggled(button_pressed):
	if(not check_lock):
		for child in $Menu/Center/VSplit/Songs/Song1/Checks.get_children(): # unchecks everything in other song
			check_lock = true
			child.pressed = false
		var song : Song = load(SONG_2_PATH).instance()
		check_lock = false
		song.setPlay("Chords",$Menu/Center/VSplit/Songs/Song2/Checks/Song2Chords.pressed)
		song.setPlay("Bass",$Menu/Center/VSplit/Songs/Song2/Checks/Song2Bass.pressed)
		song.setPlay("Drums",button_pressed)
		var transition = getTransition()
		$SongManager.addSongToQueue(song, transition)
	else: 
		check_lock = false

##### FUNCTIONS #####

# returns the appropriate transition
func getTransition() -> Transition:
	var transition : Transition
	match($Menu/Center/VSplit/Transitions/TransitionType.selected):
		0: # filter
			transition = load(FILTER_TRANSITION).instance()
		1: # volume
			transition = load(VOLUME_TRANSITION).instance()
		2: # instant
			transition = load(INSTANT_TRANSITION).instance()
	setTransitionTimeUnit(transition)
	setTransitionWait(transition)
	setTransitionTimes(transition)
	return transition

# sets the time unit in the transition
func setTransitionTimeUnit(transition : Transition):
	match($Menu/Center/VSplit/Transitions/TransitionTimeType.selected):
		0: # seconds
			transition.TIME_TYPE = transition.time_type.time
		1: # beats
			transition.TIME_TYPE = transition.time_type.beat
		2: # bars
			transition.TIME_TYPE = transition.time_type.bar

# sets a wait for next beat/bar if needed
func setTransitionWait(transition : Transition):
	match($Menu/Center/VSplit/Transitions/TransitionWait.selected):
		0: # no wait
			pass
		1: # next beat
			transition.WAIT_NEXT_BEAT = true
		2: # next bar
			transition.WAIT_NEXT_BAR = true

# sets the fade in/out of transition
func setTransitionTimes(transition : Transition):
	transition.FADE_IN_TIME = $Menu/Center/VSplit/Transitions/CenterTimes/Times/StartTime.value
	transition.FADE_OUT_TIME = $Menu/Center/VSplit/Transitions/CenterTimes/Times/EndTime.value
