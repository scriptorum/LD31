package game.system;

import flaxen.core.Flaxen;
import flaxen.core.FlaxenSystem;
import ash.core.Entity;
import game.node.SpawnNode;
import flaxen.component.*;
import game.component.*;
import game.type.*;

class SpawnSystem extends FlaxenSystem
{
	private var imgTiles:Image;
	private var gsTiles:ImageGrid;
	private var layerBeing:Layer;
	private var offTile:Offset;
	private var arrScreen:Array<Screen>;

	public function new(f:Flaxen)
	{
		super(f);
		imgTiles = new Image("art/tiles.png");
		gsTiles = new ImageGrid(Config.TILE_W, Config.TILE_H);
		arrScreen = [new Screen(0), new Screen(1), new Screen(2)];
		layerBeing = new Layer(50);
		offTile = new Offset(-Config.TILE_W / 2, -Config.TILE_H / 2);
	}

	override public function update(t:Float)
	{
		for(node in f.ash.getNodeList(SpawnNode))
		{
			// If time expires, spawn another feller
			node.spawn.secRemaining -= t;			
			if(node.spawn.secRemaining <= 0)			
			{
				switch(node.spawn.type)
				{
					case SpawnBeing: spawnBeing();
					case SpawnPlayer: spawnPlayer();
				}
				ash.removeEntity(node.entity);
			}

			return; // Only process one spawn entity per loop
		}
	}

	public function spawnPlayer()
	{
		// Spawn master player
		var playerEnt = f.newSingleton("player") // master player control
			.add(new Position(Config.SCREEN_W / 2, Config.SCREEN_H / 2))
			.add(new Velocity(0,0))
			.add(Master.instance);

		// Spawn slave players
		for(screen in 0...3)
		{
			var pos = Config.posScreen[screen];
			var slaveEnt:Entity = f.newChildSingleton(playerEnt, "scr" + screen + "player")
				.add(imgTiles)
				.add(gsTiles)
				.add(layerBeing)
				.add(new Tile(screen + 3))
				.add(new Position(Config.SCREEN_W / 2, Config.SCREEN_H / 2))
				.add(new Velocity(0,0))
				.add(new Slave("player", pos))
				.add(arrScreen[screen])
				.add(offTile);
		}

		// Queue up some being spawns
		for(i in 0...Config.INIT_BEINGS)
			f.newEntity("spawn")
				.add(new Spawn(Config.SPAWN_DELAY, SpawnBeing));
	}

	public function spawnBeing()
	{
		// Randomize beings, but ensure at least one being is prey for the screen
		// This will ensure the game is solvable (beatable is another matter)
		var beings:Array<Being> = [Being.random(), Being.random(), Being.random()];
		var b = Being.random();
		beings[Being.typeToInt(b.getPredator())] = b;

		// Spawn master being
		var masterPos = new Position(Config.SCREEN_W * Math.random(), Config.SCREEN_H * Math.random());
		var masterPt = openfl.geom.Point.polar(Config.newBeingSpeed, Math.PI * Math.random());
		var masterEnt:Entity = f.newEntity("master")
			.add(masterPos)
			.add(new Velocity(masterPt.x, masterPt.y))
			.add(Master.instance);

		// Spawn slave beings
		for(screen in 0...3)
		{
			var pos = Config.posScreen[screen];
			var being = beings[screen];
			var slaveEnt:Entity = f.newChildEntity(masterEnt, "scr" + screen + "slave")
				.add(new Position(masterPos.x + pos.x, masterPos.y + pos.y))
				.add(new Slave(masterEnt.name, pos))
				.add(imgTiles)
				.add(being)
				.add(gsTiles)
				.add(new Tile(being.toInt()))
				.add(offTile)
				.add(arrScreen[screen])
				.add(layerBeing);
			if(screen == Config.currentScreen)
				slaveEnt.add(PlayerCollider.instance);
		}
	}
}
