// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function exec(func) {
	func();
}

function tutorial_button(_x, _y) {
	var button = instance_create_layer(_x, _y, LAYER_COLLISION, o_tutorial_button);
	return button;
}


function set_tutorial_text(string){
	global.tutorial_text = string;
}

function get_temp_spot(far) {
	// get a spot far from the player
	var maxDis = far? 0 : infinity;
	var px = o_player.x, py = o_player.y;
	with (o_singleton) {
		if variable_instance_exists(id, "isSpot") {
			var dis = point_distance(x, y, o_player.x, o_player.y);
			if far {
				if dis > maxDis {
					maxDis = dis;
					px = x;
					py = y;
				}
			} else {
				if dis < maxDis {
					maxDis = dis;
					px = x;
					py = y;
				}
			}
		}
	}
	return (new Point(px, py));
}


function tutorial_button_rand() {
	var singletons = array_create(instance_number(o_singleton));
	var i = 0;
	with (o_singleton) {
		if variable_instance_exists(id, "isSpot") {
			singletons[i] = id;
			i++;
		}
	}
	array_resize(singletons, i);
	var rand = singletons[irandom(i-1)];
	while (point_distance(rand.x, rand.y, o_player.x, o_player.y) <= 64) {
		rand = singletons[irandom(i-1)];
	}
	var p = new Point(rand.x, rand.y);
	var b = tutorial_button(p.x, p.y);
	return b;
}

/*

function tutorial_button_rand_xy(_x, _y) {
	var singletons = array_create(instance_number(o_singleton));
	var i = 0;
	with (o_singleton) {
		if variable_instance_exists(id, "isSpot") {
			singletons[i] = id;
			i++;
		}
	}
	array_resize(singletons, i);
	var rand = singletons[irandom(i-1)];
	while (point_distance(rand.x, rand.y, _x, _y) <= 64) {
		rand = singletons[irandom(i-1)];
	}
	var p = new Point(rand.x, rand.y);
	var b = tutorial_button(p.x, p.y);
	return b;
}
*/