/**
	Detects collisions between player and beings.
*/
package game.system;

import game.component.Being;
import flaxen.component.Position;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.node.ColliderNode;
import flaxen.util.MathUtil;
import flaxen.core.Log;

class CollisionSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(_)
	{
		var playerPos = f.demandComponent("scr" + Config.currentScreen + "player", Position);
		for(node in f.ash.getNodeList(ColliderNode))
		{
			if(MathUtil.diff(node.position.x, playerPos.x) < Config.HITBOX &&
				MathUtil.diff(node.position.y, playerPos.y) < Config.HITBOX)
			{
				// Collision occurred!
				var playerBeing = Being.intToType(Config.currentScreen);
				if(playerBeing == node.being.type)
					playerStunned();
				else if(playerBeing == node.being.getPredator())
					playerDevours();
				else if(playerBeing == node.being.getPrey())
					playerDevoured();
				else Log.log("Unknown relationship between player " + playerBeing + 
					" and being " + node.being.type);
			}
 		}
	}

	public function playerStunned()
	{
		trace("Player is stunned");
	}

	public function playerDevours()
	{
		trace("Player devours a being");
	}

	public function playerDevoured()
	{
		trace("Player is killed!");
	}
}
