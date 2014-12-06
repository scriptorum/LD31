package game.component;

import flaxen.component.Position;

class Slave
{
	public var master:String; // entity name
	public var screenOffset:Position; // offset for the screen this being is on

	public function new(master:String, offset:Position)
	{
		this.master = master;
		this.screenOffset = offset;
	}
}
