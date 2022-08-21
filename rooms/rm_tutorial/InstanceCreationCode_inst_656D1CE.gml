
func_endstep = function() {

// trick the state manager into thinking this is a valid play space
global.room_generated = true;
exec(global.tutorial_functions[global.tutorial_function_index]);

layer_set_visible(LAYER_COLLISION, false);

var manager = instance_create_layer(x, y, LAYER_META, o_draw_manager);
var cam = instance_create_layer(x, y, LAYER_META, o_camera);

mask_index = spr_collision_check_mask;

var col = o_collision_basic;
var tilemap_id = layer_tilemap_get_id(LAYER_TILES_COLLISION);

var me = id;
with (col) {
	if in_rectangle(x, y, 0, 0, room_width, room_height) {
		for (var w = 0; w < image_xscale; w++) {
			for (var h = 0; h < image_yscale; h++) {
				var xx = x + (TILE_W*w);
				var yy = y + (TILE_H*h);
			
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
}

instance_destroy(id);

}