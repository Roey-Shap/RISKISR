/// @description

image_speed = open;
var done = hold_sprite(sprite_index);

if done and !spawned_contents {
	spawned_contents = true;
	var near_player = instance_nearest(x, y, o_player);
//	var dir = point_direction(x, y, near_player.x, near_player.y);
	var charm = instance_create_layer((x + near_player.x)/2, (y + near_player.y)/2,
	
									LAYER_UNDER, o_charm);
	charm.charm_type = charm_type;
	var ang = irandom(359);
	charm.hspd = lengthdir_x(4, ang);
	charm.vspd = lengthdir_y(4, ang);
	
	make_sprite_FX_ext(x + sprite_width/2, y + sprite_height/2, global.circle_sprites, -1, 
				irandom_range(7, 9), new Point(-3, -3), new Point(3, 3), 
				[-2, 2], [-2, 2], 
				[0.7, 0.95], [c_white, c_white, c_ltblue, c_black]);
}