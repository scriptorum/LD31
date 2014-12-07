/**
	Detects collisions between player and beings.
*/
package game.system;

import ash.core.Entity;
import flaxen.component.Image;
import flaxen.component.Layer;
import flaxen.component.Position;
import flaxen.component.Text;
import flaxen.component.Updated;
import flaxen.component.Velocity;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import flaxen.core.Log;
import flaxen.util.MathUtil;
import game.component.Being;
import game.component.Counter;
import game.component.Spawn;
import game.component.Stunned;
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
		var playerPos = f.getComponent("scr" + Config.currentScreen + "player", Position);
		if(playerPos == null)
			return; // Player must be dead or having a cup of joe

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

	// TODO Add a stunned, shake effect
	// TODO? All stunned objects (or just one encountered) are stunned as well, perhaps for even longer than the player is stunned
	public function playerStunned()
	{
		var playerEnt = f.demandEntity("player");
		playerEnt.add(new Stunned(Config.STUN_DURATION));
		playerEnt.get(Velocity).set(0,0);
	}

	// TODO Add some explosion or devour animation
	public function playerDevours(master:Entity)
	{
		// Find entity holding score && increment score counter
		var scoreEnt = f.demandEntity("score");
		scoreEnt.get(Counter).value++;
		scoreEnt.add(Updated.instance);

		// This should kill the master entity and its children
		ash.removeEntity(master); 

		// After fixed delay, spawn two new master beings
		for(i in 0...2)
			f.newEntity("spawn")
				.add(new Spawn(Config.SPAWN_DELAY, SpawnBeing));			
	}

	// TODO Add a death animation
	// TODO Move font2 into compomnent set, eliminate font1
	public function playerDevoured()
	{
		var msgEnt = f.newSingleton("youdied")
			.add(new Image("art/font2.png"))
			.add(Position.center())
			.add(new Layer(5))
			.add(new Text("YOU DIED!"))
			.add(TextStyle.createBitmap(false, Center, Center, 0, -2, 0, "M", false, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ,.!"));
		f.removeEntity("player");
		f.newActionQueue()
			.delay(3)
			.addCallback(function(){ f.resetSingleton("BoxOfBeing"); })
			.addEntity(ash, f.newEntity("spawn", false).add(new Spawn(0, SpawnPlayer)))
			.removeEntity(ash, msgEnt);
	}
}
