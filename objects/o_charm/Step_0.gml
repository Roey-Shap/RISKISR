/// @description


if charm_type == charms.none {
	instance_destroy(id);
}


// Inherit the parent event
event_inherited();

sprite_index = global.charm_info[charm_type][0];
if charm_type == charms.heart_of_gold {
	image_index = 3 - uses;
}


