package game.node;

import ash.core.Node;
import game.component.Counter;
import flaxen.component.Text;
import flaxen.component.Updated;

class CounterTextNode extends Node<CounterTextNode>
{
	public var counter:Counter;
	public var text:Text;
	public var updated:Updated;
}
