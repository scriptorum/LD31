package game.component;

import game.type.SpawnType;

class Spawn
{
	public var secRemaining:Float;
	public var type:SpawnType;

	public function new(secRemaining:Float, type:SpawnType)
	{
		this.secRemaining = secRemaining;
		this.type = type;
	}
}
