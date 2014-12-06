/**
	Ensures the slave beings follow the movements and actions of the master.
*/
package game.system;

import game.component.Being;
import flaxen.component.Position;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.node.SlaveNode;

class SlaveSystem extends FlaxenSystem
{
	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(_)
	{
		for(node in ash.getNodeList(SlaveNode))
		{
			// Copy position of master
			var masterPos = f.demandComponent(node.slave.master, Position);
			var x = masterPos.x + node.slave.screenOffset.x;
			var y = masterPos.y + node.slave.screenOffset.y;
			node.position.set(x, y);
 		}
	}
}
