package game.node;

import ash.core.Node;
import game.component.Slave;
import game.component.Being;
import game.component.Screen;

class BeingSlaveNode extends Node<BeingSlaveNode>
{
	public var being:Being;
	public var slave:Slave;
	public var screen:Screen;
}
