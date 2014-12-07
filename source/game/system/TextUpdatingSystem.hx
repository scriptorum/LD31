package game.system;

import ash.core.Entity;
import flaxen.component.Text;
import flaxen.component.Updated;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import flaxen.util.StringUtil;
import game.component.Counter;
import game.node.CounterTextNode;

class TextUpdatingSystem extends FlaxenSystem
{

	public function new(f:Flaxen)
	{
		super(f);
	}

	override public function update(t:Float)
	{
		for(node in f.ash.getNodeList(CounterTextNode))
		{
			node.text.message = StringUtil.formatCommas(node.counter.value);
			node.entity.remove(Updated);
		}
	}
}

