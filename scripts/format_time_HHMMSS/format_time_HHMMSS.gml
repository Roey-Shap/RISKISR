// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function format_time_HHMMSS(frames){
	var seconds = frames/game_get_speed(gamespeed_fps);
	var hours = floor(seconds / 3600);
	seconds -= hours * 3600;
	var minutes = floor(seconds / 60);
	seconds -= hours;

	seconds = floor(seconds);

	var strHours = hours < 10? "0" + string(hours) : string(hours);
	if hours == 0 strHours = "00";
	
	var strMinutes = minutes < 10? "0" + string(minutes) : string(minutes);
	if minutes == 0 strMinutes = "00";
	
	var strSeconds = seconds < 10? "0" + string(seconds) : string(seconds);
	if seconds == 0 strSeconds = "00";
	return(strHours + ":" + strMinutes + ":" + strSeconds);
}


function format_time_HHMMSS_from_ms(milliseconds){
	var seconds = milliseconds/1000;
	var hours = floor(seconds / 3600);
	seconds -= hours * 3600;
	var minutes = floor(seconds / 60);
	seconds -= hours;

	seconds = floor(seconds);

	var strHours = hours < 10? "0" + string(hours) : string(hours);
	if hours == 0 strHours = "00";
	
	var strMinutes = minutes < 10? "0" + string(minutes) : string(minutes);
	if minutes == 0 strMinutes = "00";
	
	var strSeconds = seconds < 10? "0" + string(seconds) : string(seconds);
	if seconds == 0 strSeconds = "00";
	return(strHours + ":" + strMinutes + ":" + strSeconds);
}