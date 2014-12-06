package game.node;

import ash.core.Node;
import game.component.Slave;
import flaxen.component.Position;

class SlaveNode extends Node<SlaveNode>
{
	public var slave:Slave;
	public var position:Position;
}
