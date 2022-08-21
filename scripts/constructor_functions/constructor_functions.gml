// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

// Constructors
function Vector2_Parent(_x, _y) constructor {
	x = _x;
	y = _y;
	
	// alter this vector
	static update = function(_x, _y) {
		x = _x;
		y = _y;
	}
	static update_from_vector = function(vector) {
		update(vector.x, vector.y);
	}
	
	// returns a new vector
	//static add = function(vector) {
	//	return (new Vector2_Parent(x + vector.x, y + vector.y));
	//}
	//static multiply = function(c) {
	//	return (new Vector2_Parent(x*c, y*c));
	//}
		
	// returns a new vector
	//static lerp_2D = function (vector, amount) {
		
	//}
	
	
	#region check_for_movements @deprecated - debug only
	/*
	static check_for_movements = function () {
		
		if !global.debug return;
		
		if !held {
			if mouse_x <= x + radius and mouse_x >= x - radius and mouse_y <= y + radius and mouse_y >= y - radius {
				if mouse_check_button_pressed(mb_left) {
					held = true;
					global.holding = true;
				}
			}
		} else {
			x = clamp(mouse_x, 0, room_width);
			y = clamp(mouse_y, 0, room_height);;
			
			if !mouse_check_button(mb_left) {
				held = false;
				global.holding = false;
			}
		}
	}
	*/
	#endregion
}

function Vector2(_mag, _dir) : Vector2_Parent(_mag, _dir) constructor {
	mag = _mag;
	dir = _dir;
	x = lengthdir_x(mag, dir);
	y = lengthdir_y(mag, dir);
	
	// updates the components based on an update to the magnitude/direction
	static update_components = function() {
		x = lengthdir_x(mag, dir);
		y = lengthdir_y(mag, dir);
	}
	static update_mag = function(_mag) {
		mag = _mag;
		update_components();
	}
	static update_dir = function(_dir) {
		dir = _dir;
		update_components();
	}
	static limit = function(_mag) {
		update_mag(min(mag, _mag));
	}
	
	// updates magnitude and direction based on an update to the x/y components
	static update_from_components = function() {
		mag = point_distance(0, 0, x, y);
		dir = point_direction(0, 0, x, y);
	}
	
	// returns a copy of this vector
	static copy = function() {
		var v = new Vector2(mag, dir);

		var arr = variable_struct_get_names(self);
		var vars = array_length(arr);
		
		// copy each variable
		for (var a = 0; a < vars; a++) {
			variable_struct_set(v, arr[a], variable_struct_get(self, arr[a]));
		}
		return (v);
	}
}
function Vector2_xy(_x, _y) : Vector2(0, 0) constructor {
	x = _x;
	y = _y;
	update_from_components();
}
function Vector2_fromTo(x1, y1, x2, y2) : Vector2_xy(x2 - x1, y2 - y1) constructor {
	
}

function Point(_x, _y) : Vector2_Parent(_x, _y) constructor {
	x = _x;
	y = _y;
	
	color = c_white;
	
	static xy = function(_x, _y) {
		x = _x;
		y = _y;
	}
	// draws this point
	static draw = function (rel_x, rel_y, rad) {
		draw_set_color(color);
		draw_circle(x + rel_x, y + rel_y, rad, false);
		//draw_set_color(c_white);
		//draw_circle(x + relative_x, y + relative_y, radius, true);
	}
	// draws a line from this point to another
	static draw_line_to = function (rel_x, rel_y, point) {
		draw_line_width(x + rel_x, y + rel_y, 
					point.x + rel_x, point.y + rel_y, global.line_width);
	}
		
	// gets distance from another point
	static distance_to = function (point) {
		return (point_distance(x, y, point.x, point.y));
	}
	
	static distance_to_xy = function(_x, _y) {
		return (point_distance(x, y, _x, _y));
	}
		
	static lerp_point = function(point, amount) {
		return(new Point(lerp(x, point.x, amount), lerp(y, point.y, amount)));
	}
	static lerp_xy = function(_x, _y, amount) {
		return(new Point(lerp(x, _x, amount), lerp(y, _y, amount)));
	}
		
	// returns a copy of this point
	static copy = function() {
		var p = new Point(x, y);

		var arr = variable_struct_get_names(self);
		var vars = array_length(arr);
		
		// copy each variable
		for (var a = 0; a < vars; a++) {
			variable_struct_set(p, arr[a], variable_struct_get(self, arr[a]));
		}
		return (p);
	}
	
	// returns a new Point
	static add = function(point) {
		return (new Point(x + point.x, y + point.y));
	}
	static add_xy = function(_x, _y){
		return (new Point(x + _x, y + _y));
	}
	static multiply = function(c) {
		return (new Point(x*c, y*c));
	}
		
	static clamp_to_rectangle = function(left, top, right, bottom) {
		x = clamp(x, left, right);
		y = clamp(y, top, bottom);
	}
}

function Bezier(_points) constructor {
	// quadratic (3 control points) or cubic (4 control points)
	points = _points;
	num_points = array_length(_points);
	
	// tracks the last updated coordinates along the curve for less demanding draw calls
	segment_points = [];
	// number of segments
	segments = 0;
	
	color_start = points[0].color;
	color_end = points[num_points-1].color;

	line_width = 1;
	
	// updates interpolated points and then caches for next curve draw
	static update_segment_points = function(_segments) {
		segments = max(1, _segments) + 1;
		segment_points = array_create(segments + 1);		//+1 for starting point
		var p1 = points[0], p2 = points[1], p3 = points[2];
		
		// run through and perform interpolations, caching the in-between points
		// in segment_points for later use
		var prev_point = p1;
		
		for (var i = 0; i <= segments; i++) {
			var t = i/segments;
			
			// insert this point into the array
			segment_points[i] = prev_point;
			
			switch (num_points) {
				case 3:
					var A = p1.lerp_2D(p2, t);
					var B = p2.lerp_2D(p3, t);
		
					var AB = A.lerp_2D(B, t);
					
					prev_point = AB;
				break;
			
				case 4:
					var p4 = points[3];			// in this case we need a fourth point
					var A = p1.lerp_2D(p2, t);
					var B = p2.lerp_2D(p3, t);
					var C = p3.lerp_2D(p4, t);
		
					var AB = A.lerp_2D(B, t);
					var BC = B.lerp_2D(C, t);
		
					var ABC = AB.lerp_2D(BC, t);
			
					prev_point = ABC;
				break; 
			}
		}
	}

	// drawing functions
	static draw_curve = function (rel_x, rel_y) {	
		global.line_width = line_width;
		
		for (var i = 0; i < segments; i++) {
			var t = i/segments;
			draw_set_color(merge_color(color_start, color_end, t));
			// segment_points includes the first point, giving us the +1 we need to not go OOB
			segment_points[i].draw_line_to(rel_x, rel_y, segment_points[i+1]);
		}
		
		global.line_width = 1;
	}
	static draw_points = function (rel_x, rel_y) {
		for (var i = 0; i < num_points; i++) {
			points[i].draw(rel_x, rel_y, 10);
		}
	}
	
	// bounding box / debug information
	static get_bounding_box_coords = function() {
		var left = infinity;
		var top = infinity;
		var right = 0;
		var bottom = 0;
		for (var i = 0; i < num_points; i++) {
			if (points[i].x < left) left = points[i].x;
			if (points[i].y < top) top = points[i].y;
			if (points[i].x > right) right = points[i].x;
			if (points[i].y > bottom) bottom = points[i].y;
		}
		return ([left, top, right, bottom]);
	}
	static draw_bounding_box = function() {
		var bounds = get_bounding_box_coords();
		draw_set_color(c_lime);
		draw_rectangle(bounds[0], bounds[1], bounds[2], bounds[3], true);
		draw_set_color(c_white);
	}
	
	// collision
	static bezier_in_rectangle = function (x1, y1, x2, y2) {
		var bounds = get_bounding_box_coords();
		return (rectangle_in_rectangle(x1, y1, x2, y2, bounds[0], bounds[1], bounds[2], bounds[3]));
	}
}

function sprite_FX(_x, _y, _sprite_index, over_or_under) constructor {
	list = global.sprite_FX_list_over;
	switch(over_or_under) {
		case -1:
			list = global.sprite_FX_list_under;
			break;
		case 1:
			list = global.sprite_FX_list_over;
			break;
		case 10:
			list = global.sprite_FX_list_GUI_over;
			break;
	}
	
	ds_list_add(list, self);
	ds_list_add(global.sprite_FX_list, self);
	
	x = _x;
	y = _y;
	
	sprite_index = _sprite_index;
	image_index = 0;
	max_index = sprite_get_number(sprite_index) - 1;
	image_speed = 1;
	width = 1;		// get actual width and height below in switch statement !!!!!
	height = 1;		// for actual dimensions multiply by x/yscale
	
	// I like using frames per second in the sprite editor, so sprite_spd is in FPS
	sprite_spd = sprite_get_speed(sprite_index);
	
	image_xscale = 1;
	image_yscale = 1;
	image_angle = 0;
	image_blend = c_white;
	image_alpha = 1;
	
	
	hspd = 0;
	vspd = 0;
	
	fric = 1;
	grav = 0;
	
	hspd_targ = 0;
	vspd_targ = 0;
	fog_col = -1;
	
	loop = false;
	end_of_loop = false;
	hold_sprite_time = 0;
	
	draw_func = -1;
	switch (sprite_index) {
		case effects.circle:
			draw_func = function() {
				draw_set_alpha(image_alpha);
				draw_set_color(image_blend);
				draw_circle(round(x), round(y), width, false);
			}
		break;
		
		default:
			width = sprite_get_width(sprite_index);
			height = sprite_get_height(sprite_index);		// for actual dimensions multiply by x/yscale
			
			draw_func = function() {
				if fog_col != -1 {
					gpu_set_fog(true, fog_col, -1, 1);
					draw_set_alpha(image_alpha);
				}
				draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale,
								image_angle, image_blend, image_alpha);
				if fog_col != -1 {
					draw_set_alpha(1);
					gpu_set_fog(false, c_white, -1, 1);
				}
			}			
		break;
	}
	
	static step = function() {
		if (end_of_loop) {
			if (hold_sprite_time <= 0) {
				// remove this from the global list of effects structs
				ds_list_delete(list, ds_list_find_index(list, self));
				ds_list_delete(global.sprite_FX_list, ds_list_find_index(global.sprite_FX_list, self));
				
				// return that this just died, don't go through the rest of the image_index calcuations
				return 1;
			}
		}
		
		
		// move image_index forward
		image_index += (image_speed * sprite_spd * global.timeDelta) / game_get_speed(gamespeed_fps);
		
		// check for reaching the end of an animation cycle
		if (image_index >= max_index) {
			if (loop) {
				image_index = 0;
			} else {
				image_speed = 0;
				end_of_loop = true;
				hold_sprite_time -= global.timeDelta;
			}
		} else {
			if (image_index < 0) {
				if (loop) {
					image_index = max_index-1;
				} else {
					image_speed = 0;
					end_of_loop = true;
					hold_sprite_time -= global.timeDelta;
				}
			}
		}
		
		hspd *= fric;
		vspd += grav;
		
		x += hspd;
		y += vspd;
		
		// it's still alive and going - no death
		return 0;
	}
	static draw = function() {
		if draw_func != -1 draw_func();
	}
}
function fade_FX(_x, _y, _sprite_index, _over_or_under, _image_index, _time) : sprite_FX(_x, _y, _sprite_index, _over_or_under) constructor {
	hold_sprite_time = _time;
	totalTime = max(1, _time);
	alpha_factor = 1;
	image_index = _image_index;
	max_index = _image_index;
	
	static update_alpha = function() {
		image_alpha = clamp(alpha_factor * (hold_sprite_time / totalTime), 0, 1);
	}
}


function ButtonGUI(_x, _y, _function, _text = "Default!", _width = 300, _height = 80) constructor {
	x = _x;
	y = _y;
	width = _width;
	height = _height;
	corner1 = new Point(x - width/2, y - height/2);
	corner2 = new Point(x + width/2, y + height/2);
	
	border = 3;
	
	state = button_gui.unselected;
	text = _text;
	
	clicked_function = _function;
	
	hover = false;
	
	static updateCoords = function(_x, _y) {
		x = _x;
		y = _y;
		corner1 = new Point(x - width/2, y - height/2);
		corner2 = new Point(x + width/2, y + height/2);
	}
	static step = function() {
		// check if the mouse is in this button
		var mouse = get_mouse_pos();
		var prev_hover = hover;
		hover = in_rectangle(mouse.x, mouse.y, corner1.x, corner1.y, corner2.x, corner2.y);
		if hover and !prev_hover {
			var snd = play_sound_random(global.click_sounds);
			var gain = audio_sound_get_gain(snd);
			audio_sound_gain(snd, gain * 0.1, 0);
		}
		
		if hover and mouse_check_button_pressed(mb_left) {
			play_sound_random(global.click_sounds);
			clicked_function();
		}
	}
	static draw = function() {
	
		var col = hover? c_white : c_player_blue;
		draw_set_color(col);
		draw_roundrect(corner1.x, corner1.y, corner2.x, corner2.y, false);
		draw_set_color(c_black);
		draw_roundrect(corner1.x + border, corner1.y + border, corner2.x - border, corner2.y - border, false);
		
		draw_set_color(col);
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_set_font(fnt_GUI);
		
		draw_text(x, y, text);
		
		draw_set_color(c_white);
	}
}


#region // Struct validation functions
function is_vector2(struct) {
	return (instanceof(struct) == "Vector2");
}

function is_point(struct) {
	return (instanceof(struct) == "Point");
}

function is_bezier(struct) {
	return (instanceof(struct) == "Bezier");
}
	
function is_sprite_FX(struct) {
	return (instanceof(struct) == "sprite_FX"); 
}

function is_fade_FX(struct) {
	return (instanceof(struct) == "fade_FX");
} 
#endregion


// Functions that might use these

function make_sprite_FX_master(_x, _y, _sprites, over_or_under, num, min_corner, max_corner, hspd_range, vspd_range, spritespd_range, colors, fric, grav) {
	repeat(num) {
		var ran_sprite = _sprites[irandom(array_length(_sprites)-1)];
		var ran_col = colors[irandom(array_length(colors)-1)];
		var ran_x = 0;
		var ran_y = 0;
		if is_point(min_corner) {
			ran_x = irandom_range(min_corner.x, max_corner.x);
		}
		if is_point(max_corner) {
			ran_y = irandom_range(min_corner.y, max_corner.y);
		}
		var ran_hspd = random_range(hspd_range[0], hspd_range[1]);
		var ran_vspd = random_range(vspd_range[0], vspd_range[1]);
		var ran_speed = random_range(spritespd_range[0],spritespd_range[1]);
		var ran_fric = fric;
		var ran_grav = random_range(0.9, 1.1) * grav;
		if over_or_under == 0 over_or_under = choose(-1, 1);
		
		var FX = new sprite_FX(_x + ran_x, _y + ran_y, ran_sprite, over_or_under);
		FX.image_speed = ran_speed;
		FX.image_blend = ran_col;
		FX.hspd = ran_hspd;
		FX.vspd = ran_vspd;
		FX.fric = ran_fric;
		FX.grav = ran_grav;
	}
}


function make_sprite_FX_ext(_x, _y, _sprites, over_or_under, num, min_corner, max_corner, hspd_range, vspd_range, spritespd_range, colors) {
	make_sprite_FX_master(_x, _y, _sprites, over_or_under, num, min_corner, max_corner, hspd_range, vspd_range, spritespd_range, colors, 1, 0);
}

function make_sprite_FX(_x, _y, _sprites, over_or_under, num, hspd_range, vspd_range, colors) {
	make_sprite_FX_master(_x, _y, _sprites, over_or_under, num, -1, -1, hspd_range, vspd_range, [1, 1], colors, 1, 0);
}




// run upon exiting rooms or making transitions, etc.
function reset_FX_lists() {
	var len = array_length(global.FX_lists);
	for (var i = 0; i < len; i++) {
		var glob = variable_global_get(global.FX_lists[i]);
		if ds_exists(glob, ds_type_list) {
			ds_list_destroy(glob);
		}
		variable_global_set(global.FX_lists[i], ds_list_create());
	}
}

function reset_GUI_FX_lists() {
	if ds_exists(global.sprite_FX_list_GUI_over, ds_type_list) {
		ds_list_destroy(global.sprite_FX_list_GUI_over);
	}
	variable_global_set(global.sprite_FX_list_GUI_over, ds_list_create());
}

function reset_hitbox_list() {
	if ds_exists(global.hitboxes, ds_type_list) {
		ds_list_destroy(global.hitboxes);
	}
	global.hitboxes = ds_list_create();
}


// run upon initialization to properly set up constructor-based functions
function init_constructors(){
	enum effects {
		circle,
		LAST
	}
	
	global.FX_lists = [
		"sprite_FX_list_over", 
		"sprite_FX_list_under", 
		"sprite_FX_list", 
		"sprite_FX_list_GUI_over"
	];
	var len = array_length(global.FX_lists);
	for (var i = 0; i < len; i++) {
		if !variable_global_exists(global.FX_lists[i]) {
			variable_global_set(global.FX_lists[i], ds_list_create());
		}
	}
}
