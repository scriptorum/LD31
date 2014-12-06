/**
	Ensures beings do not extend beyond their screen boundaries, by bouncing them off the walls
*/
package game.system;

import game.component.Being;
import flaxen.component.Position;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.node.MasterNode;

class BounceSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(_)
	{
		for(node in ash.getNodeList(MasterNode))
		{
			if(node.position.x < Config.BOUNCE_MIN_X || node.position.x >= Config.BOUNCE_MAX_X)
				node.velocity.x = -node.velocity.x;

			if(node.position.y < Config.BOUNCE_MIN_Y || node.position.y >= Config.BOUNCE_MAX_Y)
				node.velocity.y = -node.velocity.y;
 		}
	}
}
