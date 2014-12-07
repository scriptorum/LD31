package game.system;

import ash.core.Entity;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import game.component.Stunned;
import game.node.StunnedNode;

class StunSystem extends FlaxenSystem
{

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(t:Float)
	{
		for(node in f.ash.getNodeList(StunnedNode))
		{
			node.stunned.secRemaining -= t;			
			if(node.stunned.secRemaining <= 0)
				node.entity.remove(Stunned);
		}
	}
}

