/// @description

var grid = depth_sorting_grid;

//var cx = CAM_X;
//var cy = CAM_Y;
//var cw = CAM_W;
//var ch = CAM_H;

var instances = instance_number(depthsort_parent);
ds_grid_resize(grid, 2, instances);
var cur_h = 0;
with(depthsort_parent) {
	//get all of the IDS and y values of each existing object to start
	grid[# 0, cur_h] = id;
	grid[# 1, cur_h] = y; // - sprite_yoffset;
	
	cur_h++;
}

//sort the grid so that drawing it in order will cause the instances to draw in that order
ds_grid_sort(grid, 1, true);

cur_grid_h = ds_grid_height(depth_sorting_grid);
