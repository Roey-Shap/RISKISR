// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


function Hitbox(_x, _y, _width, _height, _shape, _startup, _active_duration, _damage, _parent, _parent_offset) constructor {
	if !ds_exists(global.hitboxes, ds_type_list) {
		global.hitboxes = ds_list_create();
	}
	ds_list_add(global.hitboxes, self);

	x = _x;
	y = _y;
	width = _width;
	height = _height;
	startup = _startup;
	active_dur = _active_duration;
	life = startup + active_dur + 1;
	// activate eternal hitbox with active_dur = -1
	if active_dur == -1 life = -1;
	
	shape = _shape;
	
	hit_function = (shape == hitbox_shape.rectangle? hitbox_rectangle : hitbox_ellipse);
	damage = _damage;
	hitstun_time = 4 + (3 * damage);
	
	parent = _parent;
	parent_offset = _parent_offset; // <-- this is a Vector2
	if parent_offset != -1 {
		x += parent_offset.x;
		y += parent_offset.y;
	}
	destroy_parent = false;
	group = -1;						// a HitboxGroup object tracking whether something in the group has already hit/grazed an object
		
	// to give immunity to specific instances
	no_hits = [];
	// same for objects
	no_hits_objects = [];
	// objecs already hit
	hit_list = [];
	
	can_graze = true;
	//can_graze_timer = -1;
	
	// removes from the global list of hitbox structs to manage
	static remove = function() {
		var glob_ind = ds_list_find_index(global.hitboxes, self);
		if is_hitboxGroup(group) {
			var group_ind = ds_list_find_index(group.hitboxes, self);
			if group_ind != -1 ds_list_delete(group.hitboxes, group_ind);
		}
		if glob_ind == -1 {
			// failed removal; for now, don't consider that...
			return 0;
		}
		
		ds_list_delete(global.hitboxes, glob_ind);
		// removal successful
		return 1;
	}

	static step = function() {
				
		// if there's no parent, stop considering this hitbox
		if !instance_exists(parent) {
			remove();
			return 1;
		} 
		
		// update timers
		startup -= TIMESTEP;
		
		if life != -1 life -= TIMESTEP;
		if life <= 0 and life != -1 {
			if instance_exists(parent) and destroy_parent {
				instance_destroy(parent);
			}
			remove();
			return 1;
		}
		
		// update with parent if you have an offset
		if parent_offset != -1 {
			x = parent.x + parent_offset.x;
			y = parent.y + parent_offset.y;
		}
		
		// look for hits
		if startup <= 0 {
			try_graze();
			hit_function(x - width/2, y - height/2, x + width/2, y + height/2);
		}
			
			
		// didn't die this frame
		return 0;
	}

	static add_to_group = function(_group) {
		group = _group;
		group.add_child(self);
	}

	static draw = function() {
		var x1 = x - width/2, y1 = y - height/2;
		var x2 = x + width/2, y2 = y + height/2;
		
		draw_set_color(startup > 0? c_white : c_orange);
		draw_set_alpha(0.2);
		
		if (shape == hitbox_shape.rectangle) {
			draw_rectangle(x1, y1, x2, y2, false);
		} else {
			draw_ellipse(x1, y1, x2, y2, false);
		}
		
		draw_set_color(c_white);
		draw_set_alpha(1);
		
		//var rad = 2;
		//draw_rectangle(x - rad, y - rad, x + rad, y + rad, false);
	}
}
	
	
// manages groups of hitboxes
function HitboxGroup(_children = ds_list_create()) constructor {
	hitboxes = _children;
	num_hitboxes = ds_list_size(hitboxes);
	graze_timer = 0;
	graze_frequency = 25;
	
	static add_child = function(child) {
		ds_list_add(hitboxes, child);
	}
	 
	static update = function() {
		graze_timer -= TIMESTEP * (graze_timer > 0);

		if ds_exists(hitboxes, ds_type_list) {
			num_hitboxes = ds_list_size(hitboxes);
			if ds_list_size(hitboxes) == 0 {
				return (list_delete_safe(hitboxes));
			}
		}
	}
}

// runs from a hitbox struct
// performs a hit on a single instance
function handle_hit_helper(targ){
	var hitter = self;
	var hit_related = false;
	
	// check for specific off-limits instances
	var no_hits_len = array_length(no_hits);
	for (var i = 0; i < no_hits_len; i++) {
		if targ == no_hits[i] {
			hit_related = true;
			break;
		}
	}
	
	// check for off-limits objects as a whole
	if !hit_related {
		var no_hits_len = array_length(no_hits_objects);
		for (var i = 0; i < no_hits_len; i++) {
			if object_is_ancestor_self(targ.object_index, no_hits_objects[i]) {
				hit_related = true;
				break;
			}
		}
	}
	
	// if they're whoever made the hitbox or invicible, don't hit them
	var is_invinc = targ.invinciblility_timer > 0 or targ.invinciblility_timer == -1; 
	if (is_invinc or targ == parent or hit_related) {
		// no hit
		return 0;
	}
	// separated to avoid needlessly checking a potentially long list
	if array_find(hit_list, targ) != -1 {
		return 0;
	}
	
	// continue on to the hit
	array_push(hit_list, targ);		// mark this instance as hit by this hitbox already
	with(targ){
		
		// put them into stun and deal damage
		var prev_hp = hp;
		hp -= hitter.damage;
		being_hit = true;
		state = stun_state.stun;
		stun_timer = hitter.hitstun_time;
		
		// players get more invinicibility
		var invinc = 0;// No invinicibility for enemies for the time being - works more simply for multiple hits per frame   0.35 * SECOND;
		if object_index == o_player {
			
			play_sound_random_pitch([snd_player_hurt]);
			
			if global.player_using_slowmo hp -= 1;
			
			var hp_difference = prev_hp - hp;
			
			invinc = 3 * SECOND;
			
			hit_effect_timer = hit_effect_duration;
			hit_effect_hp_add = hp_difference;
			var prev_temp_hp = temp_hp;
			temp_hp = max(temp_hp - hp_difference, 0);
			var temp_hp_used = prev_temp_hp - temp_hp;
			hp += temp_hp_used;
			
			var shake = map(1, 3, hp_difference, 4, 7);
			cam_shake(shake, shake, floor(hitter.damage * 5.5), 0);
			
			if hp - deactivated_hearts <= 0 {
				stun_timer += 0.25 * SECOND;
			}

		}
		
		invinciblility_timer = invinc;
	}
	
	// this happens in the step function, where we've already verified that the parent exists
	with(parent) {
		being_hit = false;
		state = stun_state.stun;
		stun_timer = hitter.hitstun_time;
	}
}

// runs with the hitbox struct instance
// hits all instances within an rectangle
function hitbox_rectangle(x1, y1, x2, y2) {
	var hit_list = ds_list_create();
	var hits = collision_rectangle_list(x1, y1, x2, y2, o_hit_parent, false, false, hit_list, false);
	for (var i = 0; i < hits; i++) {
		var cur = hit_list[| i];
		handle_hit_helper(cur);
	}
	
	ds_list_destroy(hit_list);
}

// runs with the hitbox struct instance
// hits all instances within an ellipse
function hitbox_ellipse(x1, y1, x2, y2, hitbox_obj) {
	var hit_list = ds_list_create();
	var hits = collision_ellipse_list(x1, y1, x2, y2, o_hit_parent, false, false, hit_list, false);
	for (var i = 0; i < hits; i++) {
		var cur = hit_list[| i];
		handle_hit_helper(cur);
	}
	
	ds_list_destroy(hit_list);
}
	
	
function is_hitbox(struct) {
	return (instanceof(struct) == "Hitbox");
}

function is_hitboxGroup(struct) {
	return (instanceof(struct) == "HitboxGroup");
}






