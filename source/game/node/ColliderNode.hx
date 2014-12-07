package game.node;

import ash.core.Node;
import game.component.PlayerCollider;
import game.component.Being;
import game.component.Slave;
import flaxen.component.Position;

class ColliderNode extends Node<ColliderNode>
{
	public var playerCollider:PlayerCollider;
	public var position:Position;
	public var slave:Slave;
	public var being:Being;
}
