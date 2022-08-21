// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

// Making certain built-in functions more convenient

function object_is_ancestor_self(child, parent) {
	return (object_is_ancestor(child, parent) or child == parent);
}

function draw_line_ext(x1, y1, x2, y2, start_alpha, end_alpha, alpha_precision){

	var dir =  point_direction(x1, y1, x2, y2);
	
	for(var i = 1; i <= alpha_precision; i++) {
		var chunk_dis = point_distance(x1, y1, x2, y2) / (alpha_precision - i);
		var mid_x2 = x1 + lengthdir_x(chunk_dis, dir);
		var mid_y2 = y1 + lengthdir_y(chunk_dis, dir);
		
		var cur_alpha = end_alpha + (start_alpha / i);
		clamp(cur_alpha, 0, 1);
		draw_set_alpha(cur_alpha);
		draw_line(x1, y1, mid_x2, mid_y2);
	}
	
	draw_set_alpha(1);
}

function draw_set(font, halign, valign, color) {
	draw_set_font(font);
	draw_set_halign(halign);
	draw_set_valign(valign);
	if (!is_undefined(color)) draw_set_color(color);
}
	
function array_find(arr, item) {
	var len = array_length(arr);
	for (var i = 0; i < len; i++) {
		if arr[i] == item return i;
	}
	return -1;
}
	
function bbox_get_width(sprite) {
	return (sprite_get_bbox_right(sprite) - sprite_get_bbox_left(sprite));
}
function bbox_get_height(sprite) {
	return (sprite_get_bbox_bottom(sprite) - sprite_get_bbox_top(sprite));
}



// if deleted a list, will return 1
// otherwise, returns 0
function list_delete_safe(variable) {
	if !ds_exists(variable, ds_type_list) return 0;
	ds_list_destroy(variable);
}

function delete_ds_general(variable, type) {
	if !ds_exists(variable, type) return 0;
	var func = -1;
	switch (type) {
		case ds_type_list: 
			func = ds_list_destroy;
			break;
		case ds_type_grid: 
			func = ds_grid_destroy;
			break;
		case ds_type_map: 
			func = ds_map_destroy;
			break;
		case ds_type_stack: 
			func = ds_stack_destroy;
			break;
		case ds_type_queue: 
			func = ds_queue_destroy;
			break;
		case ds_type_priority: 
			func = ds_priority_destroy;
			break;		
	}
	func(variable);
	
	return 1;
}