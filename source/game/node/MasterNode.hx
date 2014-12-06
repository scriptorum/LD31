package game.node;

import ash.core.Node;
import game.component.Master;
import flaxen.component.Position;
import flaxen.component.Velocity;

class MasterNode extends Node<MasterNode>
{
	public var Master:Master;
	public var position:Position;
	public var velocity:Velocity;
}
