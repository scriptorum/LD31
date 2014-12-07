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
import ash.core.Entity;

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
					playerDevours(f.demandEntity(node.slave.master));
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

	public function playerDevours(master:Entity)
	{
		// Find entity holding score
		// Increment score counter
		// Add TextUpdaterSystem
		// Find all children of this entity
		// Mark all three children of this entity as dying, removing Being and Slave, removing master
		// Change animation of three children to explode

		// At end of explosion, remove or fade out remaining entity, removing it completely

		// This should kill the master entity and its children
		ash.removeEntity(master); 

		// After fixed delay, spawn two new master beings
	}

	public function playerDevoured()
	{
		trace("Player is killed!");
	}
}
