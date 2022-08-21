// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function try_graze(){
	var is_hbox = is_hitbox(self);
	if is_hbox {
		// if this is a hitbox, check that something in the group hasn't grazed already
		if group != -1 {
			if group.graze_timer > 0 {
				// no graze
				return 0;
			}  
		}
	} else {
		if can_graze_timer != -1 {
			can_graze_timer -= TIMESTEP;
			if can_graze_timer <= 0 can_graze = true;
		} 
	}
	if can_graze {
		if !is_hitbox(self)	can_graze_timer = -1;
		var here = new Point(x, y);
		var me = self;
		with(o_player) {
			var has_horns = has_charm(charms.devils_horns);
			if invinciblility_timer <= 0 and has_horns {
				var horn_mult = has_horns > 1? devil_horns_dup_range_bonus : 1;
				if point_distance(x, y + graze_offset_y - 4, here.x, here.y) <= graze_radius * horn_mult {
					me.can_graze = false;
					if is_hbox {
						if me.group != -1 {
							me.group.graze_timer = me.group.graze_frequency;
						}
					}
					handle_graze();
				}
			}
		}
	}
}