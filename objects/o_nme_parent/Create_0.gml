/// @description

stunnable_create();

player_search_range = 250;
reward = 5;

push_spd = 0.25;
maxspd_when_pushed = 4.5;

sprite_idle = spr_nme_test;
sprite_move_slow = spr_nme_test;
sprite_move_fast = spr_nme_test;
sprite_charge = spr_nme_test;
sprite_attack = spr_nme_test;
sprite_cooldown = spr_nme_test;
draw_self_custom = false;

get_out_of_wall_ext(new Point(x, y), 16, o_collision_basic, TILE_W*2, TILE_H*2);

nme_default_push_func = function() {
	push_from_object(o_nme_parent, push_spd);
}