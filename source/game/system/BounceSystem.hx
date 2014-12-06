/**
	Ensures slaved entities do not stay beyond their screen boundaries, by bouncing them off the walls
*/
package game.system;

import game.component.Being;
import flaxen.component.Position;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.node.MasterNode;

// Ideally there should be a separate ContainmentSystem from this to handle a player striking the wall.
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
			if(node.position.x < Config.BOUNCE_MIN_X)
			{
				node.position.x = (2 * Config.BOUNCE_MIN_X - node.position.x);
				node.velocity.x = -node.velocity.x;
			}

			else if(node.position.x >= Config.BOUNCE_MAX_X)
			{
				node.position.x = (2 * Config.BOUNCE_MAX_X - node.position.x);
				node.velocity.x = -node.velocity.x;
			}

			if(node.position.y < Config.BOUNCE_MIN_Y)
			{
				node.position.y = (2 * Config.BOUNCE_MIN_Y - node.position.y);
				node.velocity.y = -node.velocity.y;
			}

			else if(node.position.y >= Config.BOUNCE_MAX_Y)
			{
				node.position.y = (2 * Config.BOUNCE_MAX_Y - node.position.y);
				node.velocity.y = -node.velocity.y;
			}
 		}
	}
}
