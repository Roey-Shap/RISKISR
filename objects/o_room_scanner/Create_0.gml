/// @description


show_debug_message("Room Scanner Created");

rooms_to_scan = ds_list_create();
ds_list_add(rooms_to_scan,
	rm_floor_start,
	rm_dungeon_1,
	rm_dungeon_2,
	rm_dungeon_3,
	rm_dungeon_4,
	rm_dungeon_5,
	rm_dungeon_6,
	rm_dungeon_7,
	rm_dungeon_8,
	rm_dungeon_9,
	rm_dungeon_10,
	rm_dungeon_11,
)

number_of_rooms = ds_list_size(rooms_to_scan);
rooms_remaining = number_of_rooms;

checking_room = true;

function room_scan_start_frame() {
	if rooms_remaining > 0 {
		var cur_room = rooms_to_scan[| number_of_rooms - rooms_remaining];
	
		room_goto(cur_room);
		checking_room = true;
		
		rooms_remaining -= 1;


	}
}

room_scan_start_frame();

