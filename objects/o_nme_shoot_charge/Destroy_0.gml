/// @description

// Inherit the parent event
event_inherited();

if is_hitboxGroup(group) {
	list_delete_safe(group.hitboxes);
}

if audio_is_playing(charge_sound) {
	audio_stop_sound(charge_sound);
}
