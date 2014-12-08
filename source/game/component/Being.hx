package game.component;

import game.type.BeingType;

class Being
{
	public var type:BeingType;

	public function new(type:BeingType)
	{
		this.type = type;
	}

	public function getPrey() // return other being that this being preys on
	{
		return Being.preyForType(type);
	}

	public function getPredator() // return other being that preys on this being
	{
		return Being.predatorForType(type);
	}

	public function toString(): String
	{
		return "" + type;
	}

	public function toInt(): Int
	{
		return typeToInt(type);

	}

	/**** STATIC ****/

	public static var CYCLE:Array<BeingType> = [ Fireman, Fire, Snowman, Fireman, Fire ];

	public static function preyForType(type:BeingType): BeingType
	{
		return CYCLE[typeToInt(type) + 1];
	}

	public static function predatorForType(type:BeingType): BeingType
	{
		return CYCLE[typeToInt(type) + 2];
	}

	public static function random(): Being
	{
		return new Being(CYCLE[cast(Math.random() * 3)]);
	}

	public static function typeToInt(type:BeingType): Int
	{
		return switch(type)
		{
			case Fireman:0;
			case Fire:1;
			case Snowman:2;
		}
	}

	public static function intToType(i:Int): BeingType
	{
		return switch(i)
		{
			case 0:Fireman;
			case 1:Fire;
			case 2:Snowman;
			default:null;
		}
	}
}
