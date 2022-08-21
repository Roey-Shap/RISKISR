// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


// holds the data for an object in an abstract sense for later use
function AbstractObject(_x, _y, _layer_name, _obj_ind, _xscale, _yscale, _sprite_index, _image_blend, _image_angle) constructor {
	x = _x;
	y = _y;
	layer_name = _layer_name;
	object_index = _obj_ind;
	image_xscale = _xscale;
	image_yscale = _yscale;
	sprite_index = _sprite_index;
	image_blend = _image_blend;
	image_angle = _image_angle;
	
	static manifest = function(rel_x, rel_y) {
		var fin_x = rel_x + x;
		var fin_y = rel_y + y;
		if object_index == o_collision_basic {
			fin_x = round_to_unit(fin_x, TILE_W);
			fin_y = round_to_unit(fin_y, TILE_H);
		}
		var inst = instance_create_layer(fin_x, fin_y, layer_name, object_index);
		inst.image_xscale = image_xscale;
		inst.image_yscale = image_yscale;
		inst.sprite_index = sprite_index;
		inst.image_blend = image_blend;
		inst.image_angle = image_angle;
		
		return (inst);
	}
}

// represents a room in simplified form - a linked list of abstracted objects
function AbstractRoom(_objects_list, _room_id) constructor {
	instances = _objects_list;
	room_id = _room_id;
	num_enemies_to_spawn_base = global.cur_room_extra_enemy_count;
	
	static add_instance = function(abstract_object) {
		ds_list_add(instances, abstract_object);
	}
}
	

// takes up a spot in the room_generator's floorplan grid
function RoomCell(_grid_pos, _state, _width = 1, _height = 1) constructor {
	grid_pos = _grid_pos;
	state = _state;
	
	discovered = false;
	
	width = _width;
	height = _height;
	
	abstract_room = -1;
	
	// given that it has a stored abstract_room, builds a scanned room at its position on the floorplan grid
	static build_room = function(rel_x, rel_y) {
		rel_x += grid_pos.x * ROOM_W;
		rel_y += grid_pos.y * ROOM_H;
		
		var list = abstract_room.instances;
		var instances = ds_list_size(list);
		for (var i = 0; i < instances; i++) {
			list[| i].manifest(rel_x, rel_y);
		}
	}
}


function get_random_scanned_abs_room() {
	// the range is from 1 to the end because we don't want to pick the initial 'rm_floor_start'
	var index = irandom_range(1, ds_list_size(global.scanned_rooms)-1);
	return (global.scanned_rooms[| index]);
}
	


function show_debug_message_floor() {
	var text = "\n ---- ";
	text += "\n|";
	for (var w = 0; w < room_grid_w + buffer; w++) {
		text += " - " + string(w);
	}
	text += " |";
	for (var h = 0; h < room_grid_h + buffer; h++) {
		text += "\n| ";
		for (var w = 0; w < room_grid_w + buffer; w++) {
			text += "-"
			switch (floor_grid[# w, h].state) {
				case room_cell.empty:
					text += "_";
				break;
				
				case room_cell.root:
					text += "r";
				break;
				
				case room_cell.taken:
					text += "o";
				break;
				
				case room_cell.potential:
					text += "x";
				break;
			}
			text += "- "
		}
		text += "|";
	}
	
	text += "\n ----\n";
	
	show_debug_message(text);
	return(text);
	//clipboard_set_text(text);
}
	
	
// to be used after initial objects have been placed
function get_empty_spots_in_room(room_coords, min_neighbors, max_neighbors, consider_hallways_as_neighbors) {
	if is_undefined(consider_hallways_as_neighbors) consider_hallways_as_neighbors = true;
	
	var prev_mask = mask_index;
	mask_index = spr_collision_check_mask;
	var col = o_collision_basic;

	// segment the last room into sections and find all available tiles that are next to walls
	// add them to a list and randomly select from that
	var raw_x = (room_coords.x * ROOM_W) + (-left * ROOM_W);
	var raw_y = (room_coords.y * ROOM_H) + (-top * ROOM_H);

	var origin = new Point(raw_x, raw_y);
	var tiles_w = ROOM_W div TILE_W;
	var tiles_h = ROOM_H div TILE_H;

	var spots = ds_list_create();
	var num_spots = 0;

	// looping through room's tiles
	// we know that the edges will be occupied by walls, so we only give the option to look over the center tiles
	// hence the w/h = 1, w/h < tiles_w/h - 1
	for (var w = 1; w < tiles_w-1; w++) {
		for (var h = 1; h < tiles_h-1; h++) {
			var cx = origin.x + (TILE_W*w);
			var cy = origin.y + (TILE_H*h);
		
			if !place_meeting(cx, cy, col) {
				var neighbors = 0;
				if min_neighbors > 0 {
					neighbors += place_meeting(cx, cy - TILE_H, col) or (h == 1 and consider_hallways_as_neighbors);	//top
					neighbors += place_meeting(cx + TILE_W, cy, col) or (w == tiles_w-1 - 1 and consider_hallways_as_neighbors);	//right
					neighbors += place_meeting(cx, cy + TILE_H, col) or (h == tiles_h-1 - 1 and consider_hallways_as_neighbors);	//bottom
					neighbors += place_meeting(cx - TILE_W, cy, col) or (w == 1 and consider_hallways_as_neighbors);	//left
				}
				if neighbors >= min_neighbors and neighbors <= max_neighbors {
					ds_list_add(spots, new Point(cx, cy));
					num_spots++;
				}
			}
		}
	}
	if num_spots == 0 show_message("NO PLACABLE SPOTS!");
	
	mask_index = prev_mask;
	return (spots);
	
}

