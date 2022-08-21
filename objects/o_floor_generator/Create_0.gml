/// @description 

// Upon creation (at the beginning of a given floor), generate a room layout
// Populate that layout, risizing the room to allow for tile placement as necessary
global.room_generated = false;
// the floor's dimensions, in units of 1 room-size
room_grid_w = 8;
room_grid_h = 8;

num_rooms = 3 + ceil(global.difficulty * 0.75);
var rooms_to_place = num_rooms;

// a grid representing each room-unit cell of the floor
// we use a buffer of 2 for edge-cases later on
buffer = 2;
global.total_floor_w = room_grid_w + buffer;
global.total_floor_h = room_grid_h + buffer;

if ds_exists(global.floor_grid, ds_type_grid) {
	ds_grid_destroy(global.floor_grid);
}
floor_grid = ds_grid_create(room_grid_w + buffer, room_grid_h + buffer);
global.floor_grid = floor_grid;
root_cells = ds_list_create();
available_cells = ds_list_create();

var grid_bound_left = buffer/2, grid_bound_top = buffer/2, grid_bound_right = room_grid_w-1 + (buffer/2), grid_bound_bottom = room_grid_h-1 + (buffer/2);
#macro GRID_BOUNDS grid_bound_left, grid_bound_top, grid_bound_right, grid_bound_bottom

// instantiate the grid with empty room cell objects
for (var w = 0; w < room_grid_w + buffer; w++) {
	for (var h = 0; h < room_grid_h + buffer; h++) {
		floor_grid[# w, h] = new RoomCell(new Point(w, h), room_cell.empty);
	}
}

var neighbor_offsets = [
	[0, -1],
	[1, 0],
	[0, 1],
	[-1, 0],
]
//yay 3AM no angle specificities now
//top case, right case, bottom case, left case
var wall_w = ceil((ROOM_W/3) / TILE_W);
var wall_h = ceil((ROOM_H/3) / TILE_H);

//top case: wall1 coords, wall1 length, wall2 coords, wall2 length
//right case: wall1 coords... etc.
var neighbor_wall_offsets = [
	[[-ROOM_W/2, -ROOM_H/2, wall_w, 1],				[(ROOM_W/2) - (wall_w * TILE_W), -ROOM_H/2, wall_w, 1]],
	[[(ROOM_W/2) - TILE_W, -ROOM_H/2, 1, wall_h],	[(ROOM_W/2) - TILE_W, (ROOM_H/2) - (wall_h * TILE_H), 1, wall_h]],
	[[-ROOM_W/2, (ROOM_H/2) - TILE_H, wall_w, 1],	[(ROOM_W/2) - (wall_w * TILE_W), (ROOM_H/2) - TILE_H, wall_w, 1]],
	[[(-ROOM_W/2), (-ROOM_H/2), 1, wall_h],			[(-ROOM_W/2), (ROOM_H/2) - (wall_h * TILE_H), 1, wall_h]]
]
// prepare bounds for later
left = room_grid_w;
top = room_grid_h;
right = 0;
bottom = 0;



#region First room 
// choose a random room as the starting point
var cur_room_point = new Point(irandom_range(grid_bound_left, grid_bound_right), irandom_range(grid_bound_top, grid_bound_bottom));
first_room_point = new Point(cur_room_point.x, cur_room_point.y);

var cur_room = floor_grid[# cur_room_point.x, cur_room_point.y];
with(cur_room){
	state = room_cell.root;
	// assign this first room 'rm_floor_start', the first room to be scanned and placed in the 'scanned_rooms' list
	abstract_room = global.scanned_rooms[| 0];
}
left = min(left, cur_room_point.x);
top = min(top, cur_room_point.y);
right = max(right, cur_room_point.x);
bottom = max(bottom, cur_room_point.y);

// update neighbors
for (var i = 0; i < 4; i++) {
	var offset = neighbor_offsets[i];
	var cx = cur_room_point.x + offset[0];
	var cy = cur_room_point.y + offset[1];
	
	
	// add neighbors
	// ensure that the tile being checked is within the bounds
	if in_rectangle(cx, cy, GRID_BOUNDS) {
		ds_list_add(available_cells, new Point(cx, cy));
		floor_grid[# cx, cy].state = room_cell.potential;
	}
}
rooms_to_place--;
#endregion


#region Rest of rooms
// repeat the process num_rooms times
while (rooms_to_place > 0) {
	
	// pick a random point from the available_cells list
	var choices = ds_list_size(available_cells);
	var ran_index = irandom_range(0, choices-1);

	// get the chosen coordinates and remove them from the list of choices
	cur_room_point = available_cells[| ran_index];
	ds_list_delete(available_cells, ran_index);
	
	// access the room cell and assign it a random room
	cur_room = floor_grid[# cur_room_point.x, cur_room_point.y];
	with(cur_room){
		state = room_cell.root;
		abstract_room = get_random_scanned_abs_room();
	}
	left = min(left, cur_room_point.x);
	top = min(top, cur_room_point.y);
	right = max(right, cur_room_point.x);
	bottom = max(bottom, cur_room_point.y);

	// update neighbors
	for (var i = 0; i < 4; i++) {
		var offset = neighbor_offsets[i];
		var cx = cur_room_point.x + offset[0];
		var cy = cur_room_point.y + offset[1];
	
		// add neighbors
		// ensure that the tile being checked is within the bounds
		if in_rectangle(cx, cy, GRID_BOUNDS) {
			var check = floor_grid[# cx, cy];
			if check.state == room_cell.empty {
				ds_list_add(available_cells, new Point(cx, cy));
				check.state = room_cell.potential;
			}
		}
	}
	
	rooms_to_place--;	
}
#endregion

last_room_point = new Point(cur_room_point.x, cur_room_point.y);


ds_list_destroy(available_cells);

var debug_message = show_debug_message_floor();
//clipboard_set_text(debug_message);




// Begin preparing room and placing instances

// get room bounds
var spawned_room_width = right - left + 1;
var spawned_room_height = bottom - top + 1;
global.spawned_room_width = spawned_room_width;
global.spawned_room_height = spawned_room_height;
global.floor_top_corner = new Point(left, top);

show_debug_message("Final room dimensions: " + string(spawned_room_width) + " x " + string(spawned_room_height));

room_width = spawned_room_width * ROOM_W;
room_height = spawned_room_height * ROOM_H;


// go through the entire floor and have each existent room build itself
for (var w = 0; w < room_grid_w + buffer; w++) {
	for (var h = 0; h < room_grid_h + buffer; h++) {
		var c_cell = floor_grid[# w, h];
		var raw_center_x = ((w * ROOM_W) + ROOM_W/2) + (-left * ROOM_W);
		var raw_center_y = ((h * ROOM_H) + ROOM_H/2) + (-top * ROOM_H);
			
		if c_cell.state == room_cell.root {
			
			ds_list_add(root_cells, new Point(w, h));
			
			// spawn instances
			c_cell.build_room(-left * ROOM_W, -top * ROOM_H); 
			
			
			// build walls
			for (var i = 0; i < 4; i++) {
				var arr = [c_white, c_ltgray, c_dkgray, c_black];
				var col = c_white; //arr[i];
				var offset = neighbor_offsets[i];
				var cx = w + offset[0];
				var cy = h + offset[1];
				
				var data = neighbor_wall_offsets[i];
				var wall1_data = data[0];
				var wall2_data = data[1];
				
				var neighbor = floor_grid[# cx, cy];
				
				// if this neighbor is occupied by a room (for now just root room, whatever)
				// build walls between them and this room
								
				if neighbor.state == room_cell.root {
				
					var wall1 = instance_create_layer(raw_center_x + wall1_data[0], raw_center_y + wall1_data[1], LAYER_COLLISION, o_collision_basic);
					wall1.image_xscale = wall1_data[2];
					wall1.image_yscale = wall1_data[3];
					wall1.image_blend = col;
					
					var wall2 = instance_create_layer(raw_center_x + wall2_data[0], raw_center_y + wall2_data[1], LAYER_COLLISION, o_collision_basic);
					wall2.image_xscale = wall2_data[2];
					wall2.image_yscale = wall2_data[3];
					wall2.image_blend = col;
					
				} else {
					//solid walls
					show_debug_message("Edge wall on edge: " + string(i) + " of room " + string([w, h]));
					var wall1 = instance_create_layer(raw_center_x + wall1_data[0], raw_center_y + wall1_data[1], LAYER_COLLISION, o_collision_basic);
					var top_bottom = (i % 2 == 0);
					// if on the top or bottom iteration, use wide but short wall
					wall1.image_xscale = top_bottom? (ROOM_W div TILE_W) : 1;
					wall1.image_yscale = top_bottom? 1 : (ROOM_H div TILE_H);
					wall1.image_blend = col;
				}
			}
		} else { // for now, if it isn't a root room then it's empty
			// fill this room in with a big ol' collision
			var wall = instance_create_layer(raw_center_x - ROOM_W/2, raw_center_y - ROOM_H/2, LAYER_COLLISION, o_collision_basic);
			wall.image_xscale = ROOM_W div TILE_W;
			wall.image_yscale = ROOM_H div TILE_H;
		}
	}
}



var col = o_collision_basic;

// Placing extra objects around the floor

mask_index = spr_room_generate_nemy_collision_mask;
// Placing enemies and props
for (var w = 0; w < room_grid_w + buffer; w++) {
	for (var h = 0; h < room_grid_h + buffer; h++) {
		var c_cell = floor_grid[# w, h];
		if c_cell.state == room_cell.root {
			
			var raw_center_x = ((w * ROOM_W) + ROOM_W/2) + (-left * ROOM_W);
			var raw_center_y = ((h * ROOM_H) + ROOM_H/2) + (-top * ROOM_H);
			
			
			var spots = get_empty_spots_in_room(new Point(w, h), 0, 3);
			var props = irandom_range(5, 20);
			var prop_sprites = [spr_ground_texture_1, spr_ground_texture_2, spr_ground_texture_3, spr_ground_texture_4, spr_ground_texture_5];
			var prop_sprites_num = array_length(prop_sprites);
			repeat(props) {
				var num_spots = ds_list_size(spots);
				var ind = irandom(num_spots-1);
				var chosen = spots[| ind];
				
				// this little bit is so that the tutorial sprite isn't overlapping anything (don't want to deal with layers right now)
				var doNotContinue = false;
				if w == first_room_point.x and h == first_room_point.y {
					var rad = 400 / 2;
					if in_rectangle(chosen.x, chosen.y, raw_center_x - rad, raw_center_y - rad, raw_center_x + rad, raw_center_y + rad) {
						doNotContinue = true;
					}
				}
				
				if !doNotContinue {
					var flip = choose(-1, 1);
					var spr = layer_sprite_create(LAYER_ASSET, chosen.x + (flip < 0? 32 : 0), chosen.y, prop_sprites[irandom(prop_sprites_num-1)]);
					layer_sprite_xscale(spr, flip);
					layer_sprite_alpha(spr, random_range(0.5, 1));
					ds_list_delete(spots, ind);
				}
			}
			ds_list_destroy(spots);
			
			// *note that the floor_start room has a num_enemies_to_spawn_base of 0; therefore we don't need to do any extra checks here for efficiency:
			var difficulty_factor = random_range(0.6, 1) * map(global.difficulty_min, global.difficulty_max, global.difficulty, 0.8, 1.5);
			var enemies = ceil(c_cell.abstract_room.num_enemies_to_spawn_base * difficulty_factor);
			if enemies > 0 {
				show_debug_message("Enemies: " + string(enemies));
			
				// get the empty spots of that room for pack placements
				var spots = get_empty_spots_in_room(new Point(w, h), 0, 0);
				show_debug_message(num_spots);
			
				while (enemies > 0 and num_spots > 0) {
					// begin a new pack
					var num_spots = ds_list_size(spots);
					var ind = irandom(num_spots-1);
					var pack_origin = spots[| ind];
					pack_origin = pack_origin.add(new Point(TILE_W/2, TILE_H/2));	// make pack origin at origin of chosen tile
				
					// remove as an option
					ds_list_delete(spots, ind);
				
					var pack_size = min(irandom_range(1, 3), enemies);
					while (pack_size > 0) {
						var killed_enemies = 0;
						var ran_rad = 64 * random_range(0.8, 1.2);
						var nme_origin = pick_point_on_circle(pack_origin.x, pack_origin.y, ran_rad);
						var ran_nme = global.available_enemies[| irandom(ds_list_size(global.available_enemies)-1)];
						var nme = instance_create_layer(nme_origin.x, nme_origin.y, LAYER_ENEMY, ran_nme);
						with(nme) {
							// point back towards pack center and get out of any walls by being nudged towards it
							var origin_dir = point_direction(x, y, pack_origin.x, pack_origin.y);
							var nudge_x = lengthdir_x(4, origin_dir);
							var nudge_y = lengthdir_y(4, origin_dir);
							var tries = 30;
							while (tries > 0 and place_meeting(x, y, o_collision_basic)) {
								// and !rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, raw_center_x - ROOM_W/2, raw_center_y - ROOM_H/2, raw_center_x + ROOM_W/2, raw_center_y + ROOM_H/2))
								x += nudge_x;
								y += nudge_y;
								tries--;
							}
							if tries <= 0 {
								killed_enemies++;
								instance_destroy(id);
							} else {
								if place_meeting(x, y, o_collision_basic) show_debug_message("Enemy in wall!");
								// successfully placed!
								enemies--;
								pack_size--;
							}
						}
						show_debug_message("Killed enemies: " + string(killed_enemies));
					}
					num_spots = ds_list_size(spots);
				}
				show_debug_message("Enemy spots: " + string(num_spots) + ", had " + string(enemies) + " enemies left");
			
				ds_list_destroy(spots);
			}
		}	
	}
}

// Placing charm pickups somewhere on the map
var num_charms = irandom_range(1, ceil(num_rooms/3));
var available_root_cells_for_charms = ds_list_create();
ds_list_copy(available_root_cells_for_charms, root_cells);
repeat (num_charms) {	
	// pick a random room
	var ran_index = irandom(ds_list_size(available_root_cells_for_charms )-1);
	var ran_room_coords = available_root_cells_for_charms [| ran_index];
	
	// remove this is an option as a room to have a charm
	ds_list_delete(available_root_cells_for_charms , ran_index);
	
	// get the empty spots of that room and place a chest in a random one of them
	var spots = get_empty_spots_in_room(ran_room_coords, 1, 3, false);
	var num_spots = ds_list_size(spots);
	var ran_spot = spots[| irandom(num_spots-1)];	
	var chest = instance_create_layer(ran_spot.x, ran_spot.y, LAYER_BULLET, o_chest);
	chest.charm_type = irandom_range(1, charms.LAST-1);
	if irandom(global.chest_has_linker_chance - 1) == 0 chest.charm_type = charms.linker;
	
	ds_list_destroy(spots);
}


// Placing a key somewhere in the last room
var spots = get_empty_spots_in_room(last_room_point, 0, 0);
var num_spots = ds_list_size(spots);
var ran_spot = spots[| irandom(num_spots-1)];	
var key = instance_create_layer(ran_spot.x, ran_spot.y, LAYER_BULLET, o_activation_module);
with (key) {
	var out_of_wall_spot = get_out_of_wall_ext(new Point(x, y), 16, o_collision_basic, 300, 300);
	x = out_of_wall_spot.x;
	y = out_of_wall_spot.y;
}

ds_list_destroy(spots);



// Placing tiles
show_debug_message("placing tiles...");

// kill the visibility of the collision layer
layer_set_visible(LAYER_COLLISION, false);

// add the player's tutorial asset on top
var spr = layer_sprite_create(LAYER_ASSET, o_player.x + 20, o_player.y, spr_starting_tutorial_ground);
layer_sprite_alpha(spr, 0.75);
//layer_sprite_xscale(spr, 0.75);
//layer_sprite_yscale(spr, 0.75);


mask_index = spr_collision_check_mask;

var tilemap_id = layer_tilemap_get_id(LAYER_TILES_COLLISION);

var me = id;
with (col) {
	for (var w = 0; w < image_xscale; w++) {
		for (var h = 0; h < image_yscale; h++) {
			var xx = x + (TILE_W*w);// + (-left * ROOM_W);
			var yy = y + (TILE_H*h);// + (-top * ROOM_H);
			
			with (me) {
				var tile_coords = new Point(floor(xx / TILE_W), floor(yy / TILE_H));
				var north	= place_meeting(xx, yy - TILE_H, col);
				var west	= place_meeting(xx + TILE_W, yy, col);
				var south	= place_meeting(xx, yy + TILE_H, col);
				var east	= place_meeting(xx - TILE_W, yy, col);
				var index = 1 + (NORTH * north) + (WEST * west) + (SOUTH * south) + (EAST * east);
				tilemap_set(tilemap_id, index, tile_coords.x, tile_coords.y);
			}
		}
	}
}

global.room_generated = true;
show_debug_message("Done generating room!");


ds_list_destroy(root_cells);
//ds_grid_destroy(floor_grid);

//for (var w = 0; w < room_width_in_cells; w++) {
//	for (var h = 0; h < room_height_in_cells; h++) {
//		if instance_position(x, y, o_collision_basic) {
//		var top_n = place_meeting
//	}
//}


