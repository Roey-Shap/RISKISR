// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function get_out_of_wall(accuracy){
	return(is_point(get_out_of_wall_ext(new Point(x, y), accuracy, o_collision_basic, sprite_get_width(mask_index), sprite_get_height(mask_index)))); 
}

function get_out_of_wall_ext(origin, accuracy, collision_object, probe_width, probe_height){
	origin = origin.copy();
	var wall = collision_object;
	var result_spot = -1;
	
	if !place_meeting(origin.x, origin.y, wall) {
		return origin;
	}
	

	var angle_each_iteration = 360 / accuracy;
	
	var spots_grid = ds_grid_create(3, 0);
	for (var i = 0; i < 360; i += angle_each_iteration ) {
			
		var test_x = origin.x + lengthdir_x(probe_width, i);
		var test_y = origin.y + lengthdir_y(probe_height, i);
			
		// see if the test point seems to get you out of the problem
		if !place_meeting(test_x, test_y, wall) {
				
			// get single-unit nudge angle information
			var dir_to_problem_point = point_direction(test_x, test_y, origin.x, origin.y);
			var nudge_x = lengthdir_x(1, dir_to_problem_point);
			var nudge_y = lengthdir_y(1, dir_to_problem_point);
			var fine_test_x = test_x + nudge_x;
			var fine_test_y = test_y + nudge_y;
				
			// try repeatedly to get out of the wall
			var tries = 100;
			while (!place_meeting(fine_test_x, fine_test_y, wall) and tries > 0){
				fine_test_x += nudge_x;
				fine_test_y += nudge_y;
					
				tries -= 1;
			}
				
			// enter this attempt into the grid, ranked by the number of tries it took
			var grid_h = ds_grid_height(spots_grid);
			ds_grid_resize(spots_grid, 3, grid_h + 1);
				
			spots_grid[# 0, grid_h] = fine_test_x - nudge_x;
			spots_grid[# 1, grid_h] = fine_test_y - nudge_y;
			spots_grid[# 2, grid_h] = tries;
		}
	}
		
	// if at least one solution was found, take the best fix found in the grid
	grid_h = ds_grid_height(spots_grid);
	if grid_h > 1 {
		ds_grid_resize(spots_grid, 3, grid_h - 1);
		ds_grid_sort(spots_grid, 2, true);
		result_spot = new Point(spots_grid[# 0, 0], spots_grid[# 1, 0]);
	}
		
	ds_grid_destroy(spots_grid);
	
	return result_spot;
}