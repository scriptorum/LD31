package game.handler; 

import ash.core.Entity;
import com.haxepunk.utils.Key;
import flaxen.component.*;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenHandler;
import flaxen.core.Log;
import flaxen.service.InputService;
import game.component.*;
import game.service.*;

class PlayHandler extends FlaxenHandler
{	
	private var imgTiles:Image;
	private var gsTiles:ImageGrid;
	private var layerBeing:Layer;
	private var posScreen:Array<Position>;
	private var offTile:Offset;
	private var arrScreen:Array<Screen>;
	
	public var f:Flaxen;

	public function new(f:Flaxen)
	{
		super();
		this.f = f;
	}

	override public function start(_)
	{
		f.newSingleton("frame-overlay")
			.add(new Image("art/overlay.png"))
			.add(Position.zero())
			.add(new Layer(0));

		imgTiles = new Image("art/tiles.png");
		gsTiles = new ImageGrid(Config.TILE_W, Config.TILE_H);
		posScreen = [new Position(50, 60), new Position(50, 340), new Position(330,340)];
		arrScreen = [new Screen(0), new Screen(1), new Screen(2)];
		layerBeing = new Layer(50);
		offTile = new Offset(-Config.TILE_W / 2, -Config.TILE_H / 2);

		var screenImage = new Image("art/screen.png");
		var screenLayer = new Layer(100);

		for(i in 0...3)
			f.newSingleton("screen" + i)
				.add(screenImage)
				.add(posScreen[i])
				.add(screenLayer);

		var coverLayer = new Layer(10);
		var coverImage = new Image("art/screen-inactive.png");
		var coverAlpha = new Alpha(.35);

		for(i in 0...3)
		{
			var e = f.newSingleton("screen" + i + "cover")
				.add(coverImage)
				.add(posScreen[i])
				.add(coverLayer)
				.add(coverAlpha);
			if(i == Config.currentScreen)
				e.add(Invisible.instance);
		}

		addPlayer();

		for(i in 0...Config.INIT_BEINGS)
			addBeing();

		f.addSystem(new game.system.BounceSystem(f));
		f.addSystem(new game.system.SlaveSystem(f));
		f.addSystem(new flaxen.system.MovementSystem(f));
		f.addSystem(new game.system.CollisionSystem(f));
	}

	public function addPlayer()
	{
		// Spawn player
		var playerEnt = f.newSingleton("player") // master player control
			.add(new Position(Config.SCREEN_W / 2, Config.SCREEN_H / 2))
			.add(new Velocity(0,0))
			.add(Master.instance);

		// Spawn slave players
		for(screen in 0...3)
		{
			var pos = posScreen[screen];
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
	}

	public function addBeing()
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
			var pos = posScreen[screen];
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

	override public function update(_)
	{
		var key = InputService.lastKey();

		#if (debug)
		if(key == Key.D)
		{
			#if (windows || mac || linux)
				trace("Dumping log(s)");
				var path =  sys.FileSystem.fullPath ("../../../../../../../");
				flaxen.util.LogUtil.dumpLog(f, path + "/entities.txt");
				for(setName in f.getComponentSetKeys())
					trace(setName + ":{" + f.getComponentSet(setName) + "}");			
			#end
		}
		#end

		var screen = switch(key)
		{
			case Key.DIGIT_1: 0;
			case Key.DIGIT_2: 1;
			case Key.DIGIT_3: 2;
			default: -1;
		};		
		if(screen >= 0)
			switchScreen(screen);

		checkPlayerMovement();

		InputService.clearLastKey();
	}

	public function checkPlayerMovement()
	{
		var velocity:Velocity = f.getComponent("player", Velocity);
		if(velocity == null)
			return;

		if(InputService.check(Key.LEFT))
			velocity.x = -Config.PLAYER_SPEED;
		else if(InputService.check(Key.RIGHT))
			velocity.x = Config.PLAYER_SPEED;
		else velocity.x = 0;

		if(InputService.check(Key.UP))
			velocity.y = -Config.PLAYER_SPEED;
		else if(InputService.check(Key.DOWN))
			velocity.y = Config.PLAYER_SPEED;
		else velocity.y = 0;
	}

	public function switchScreen(screen:Int)
	{
		if(screen == Config.currentScreen)
			return;

		// Hide screen cover on new active screen, and show cover on old screen
		var e = f.demandEntity("screen" + Config.currentScreen + "cover");
		e.remove(Invisible);
		e = f.demandEntity("screen" + screen + "cover");
		e.add(Invisible.instance);

		// Remove all player colliders from old screen slaves and add them to new screen slaves
		for(node in f.ash.getNodeList(game.node.BeingSlaveNode))
			if(node.screen.value == Config.currentScreen)
				node.entity.remove(PlayerCollider);
			else if(node.screen.value == screen)
				node.entity.add(PlayerCollider.instance);

		// Switch is complete
		Config.currentScreen = screen;		
	}
}
