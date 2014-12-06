package game; 

class Config
{
	public static var SCREEN_W:Int = 220;
	public static var SCREEN_H:Int = 220;
	public static var TILE_W:Int = 16;
	public static var TILE_H:Int = 16;
	public static var BOUNCE_MIN_X:Float = TILE_W / 2;
	public static var BOUNCE_MIN_Y:Float = TILE_H / 2;
	public static var BOUNCE_MAX_X:Float = SCREEN_W - TILE_W / 2;
	public static var BOUNCE_MAX_Y:Float = SCREEN_H - TILE_H / 2;

	public static var START_BEING_SPEED:Int = 60;
	public static var PLAYER_SPEED:Int = 80;
}
