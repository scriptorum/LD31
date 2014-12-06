package game.component;

enum BeingType { Rock; Paper; Scissors; }

class Being
{
	public var type:BeingType;

	public function new(type:BeingType)
	{
		this.type = type;
	}

	public function getPrey() // return other being that this being preys on
	{
		return CYCLE[typeToInt(type) + 2];
	}

	public function getPredator() // return other being that preys on this being
	{
		return CYCLE[typeToInt(type) + 1];
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

	public static var CYCLE:Array<BeingType> = [ Rock, Paper, Scissors, Rock, Paper ];

	public static function random(): Being
	{
		return new Being(CYCLE[cast(Math.random() * 3)]);
	}

	public static function typeToInt(type:BeingType): Int
	{
		return switch(type)
		{
			case Rock:0;
			case Paper:1;
			case Scissors:2;
		}
	}
}
