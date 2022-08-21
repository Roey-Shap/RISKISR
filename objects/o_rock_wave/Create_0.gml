/// @description

event_inherited();

stunnable_create();

parent = noone;
invinciblility_timer = 0;
hitbox = -1;
hp = 2;

cur_action = -1;

sprite_index = choose(spr_rock_wave_1, spr_rock_wave_2, spr_rock_wave_3);
life = sprite_get_time(sprite_index) * 1.1;	// so it holds the last frame for a bit
life_timer = life;
image_xscale = choose(-1, 1);
image_angle = irandom_range(-8, 8);
hitbox = -1;

function rock_wave_step() {

	if !is_hitbox(hitbox) and image_index > 0 {
		hitbox = new Hitbox(x, y, bbox_get_width(sprite_index) * abs(image_xscale), bbox_get_height(sprite_index) * abs(image_yscale), 
						hitbox_shape.rectangle, 0, 7, 1, id, new Vector2_xy(0, 0));
		hitbox.no_hits_objects = [o_nme_parent, object_index];	// can't hit themselves
		//hitbox.hitstun_time *= 1.3;
				
	var range = 5;
	var colors = [c_spark, c_spark_dark];
	make_sprite_FX_master(x, y, global.spark_sprites, 1, irandom_range(6, 9), 
				new Point(-range, -range), new Point(range, range), [-1, 1], [-2.5, -1], [0.9, 1.05], colors, 0.988, 0.1);

	}
	
	hold_sprite(sprite_index);
	
	life_timer -= TIMESTEP;
	if life_timer <= 0 {
		instance_destroy(id);
	}
}