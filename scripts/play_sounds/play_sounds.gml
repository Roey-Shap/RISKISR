// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function play_sound_random(sound_array){
	var snd = play_sound_random_master(sound_array, 4);
	audio_sound_gain(snd, global.SFX_volume, 0);
	return snd;
}
function play_sound_random_priority(sound_array, priority){
	var snd = play_sound_random_master(sound_array, priority);
	audio_sound_gain(snd, global.SFX_volume, 0);
	return snd;
}


function play_sound_random_master(sound_array, priority) {
	var len = array_length(sound_array);
	var snd = audio_play_sound(sound_array[irandom(len-1)], priority, false);
	return snd;
}


function play_sound_random_pitch(sound_array){
	var snd = play_sound_random(sound_array);
	audio_sound_pitch(snd, random_range(0.9, 1.1));
	return snd;
}

function play_sound_random_pitch_priority(sound_array, priority){
	var snd = play_sound_random_priority(sound_array, priority);
	audio_sound_pitch(snd, random_range(0.9, 1.1));
	return snd;
}





function set_SFX_sound_gain(snd) {
	audio_sound_gain(snd, global.SFX_volume, 0);
}

