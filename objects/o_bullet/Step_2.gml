/// @description

if state != stun_state.stun {
	// Inherit the parent event
	event_inherited();

	if !is_hitbox(hitbox) {
		hitbox = new Hitbox(x, y, radius*image_xscale/2, radius*image_yscale/2, hitbox_shape.ellipse, 0, -1, 1, id, new Vector2_xy(0, 0))
		hitbox.no_hits = [parent, id];
		hitbox.no_hits_objects = [o_nme_parent];
	}
}