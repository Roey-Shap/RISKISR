/// @description

event_inherited();

hspd = 0;
vspd = 0;

life = -1;		//lives forever

target_spot = new Point(0, 0);
collide = true;
collided = false;

can_graze = false;
can_graze_timer = 10;

stunnable_create();