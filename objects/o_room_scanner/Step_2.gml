

if checking_room {
	// instantiate a simplified representation of this room
	var abstract_room = new AbstractRoom(ds_list_create(), room);
	// go through each object in this room and store a simplified version of it in a list
	
	with(all) {
		if object_index != o_room_scanner {
			var abstracted = new AbstractObject(x, y, 
												layer_get_name(layer),
												object_index,
												image_xscale,
												image_yscale,
												sprite_index,
												image_blend,
												image_angle);
			
			abstract_room.add_instance(abstracted);
		}
	}

	// store this room in the global list of scanned rooms
	ds_list_add(global.scanned_rooms, abstract_room);
}


checking_room = false;

if rooms_remaining == 0 {
	room_goto(rm_main_menu);
	
	//don't set it off again
	rooms_remaining = -1;
} else if rooms_remaining != -1 {
	room_scan_start_frame();
}

	