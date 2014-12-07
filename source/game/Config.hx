package game; 

class Config
{
	// Shared Constants
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
	public static var HITBOX:Int = 10;
	public static var INIT_BEINGS:Int = 1;
	public static var SPAWN_DELAY:Float = 1; // sec TODO scale spawn delay by number of spawns queued at once
	public static var STUN_DURATION:Float = 0.75;

	// Shared Data 
	public static var newBeingSpeed:Int = Config.START_BEING_SPEED; 
	public static var currentScreen:Int = 0;
	public static var posScreen:Array<flaxen.component.Position>;
}
