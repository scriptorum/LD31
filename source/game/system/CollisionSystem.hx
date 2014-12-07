/**
	Detects collisions between player and beings.
*/
package game.system;

import ash.core.Entity;
import flaxen.component.Position;
import flaxen.component.Updated;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import flaxen.core.Log;
import flaxen.util.MathUtil;
import game.component.Being;
import game.component.Counter;
import game.component.Spawn;
import game.node.ColliderNode;
import game.type.BeingType;
import game.type.SpawnType;

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
				var playerBT:BeingType = Being.intToType(Config.currentScreen);
				if(playerBT == node.being.type)
					playerStunned();
				else if(playerBT == node.being.getPredator())
					playerDevours(f.demandEntity(node.slave.master));
				else if(playerBT == node.being.getPrey())
					playerDevoured();
				else Log.log("Unknown relationship between player " + playerBT + 
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
		// Find entity holding score && increment score counter
		var scoreEnt = f.demandEntity("score");
		scoreEnt.get(Counter).value++;
		scoreEnt.add(Updated.instance);

		// Add TextUpdaterSystem
		// Find all children of this entity
		// Mark all three children of this entity as dying, removing Being and Slave, removing master
		// Change animation of three children to explode

		// At end of explosion, remove or fade out remaining entity, removing it completely

		// This should kill the master entity and its children
		ash.removeEntity(master); 

		// After fixed delay, spawn two new master beings
		for(i in 0...2)
			f.newEntity("spawn")
				.add(new Spawn(Config.SPAWN_DELAY, SpawnBeing));			
	}

	public function playerDevoured()
	{
		trace("Player is killed!");
	}
}
