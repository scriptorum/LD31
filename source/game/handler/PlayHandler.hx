package game.handler; 

import com.haxepunk.utils.Key;
import flaxen.component.*;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenHandler;
import flaxen.core.Log;
import flaxen.service.InputService;
import game.component.*;
import ash.core.Entity;

class PlayHandler extends FlaxenHandler
{	
	private var imgTiles:Image;
	private var gsTiles:ImageGrid;
	private var layerBeing:Layer;
	private var posScreen:Array<Position>;
	private var offTile:Offset;
	
	public var f:Flaxen;
	public var newBeingSpeed:Int = Config.START_BEING_SPEED; 

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
		posScreen = [new Position(50, 60), new Position(50, 340), new Position(330,340) ];
		layerBeing = new Layer(50);
		offTile = new Offset(-Config.TILE_W / 2, -Config.TILE_H / 2);

		var screenImage = new Image("art/screen.png");
		var screenLayer = new Layer(100);

		f.newSingleton("screen1")
			.add(screenImage)
			.add(posScreen[0])
			.add(screenLayer);
		f.newSingleton("screen2")
			.add(screenImage)
			.add(posScreen[1])
			.add(screenLayer);
		f.newSingleton("screen3")
			.add(screenImage)
			.add(posScreen[2])
			.add(screenLayer);

		var coverLayer = new Layer(10);
		var coverImage = new Image("art/screen-inactive.png");
		var coverAlpha = new Alpha(.35);

		f.newSingleton("screen1-cover")
			.add(coverImage)
			.add(posScreen[0])
			.add(coverLayer)
			.add(coverAlpha)
			.add(Invisible.instance);
		f.newSingleton("screen2-cover")
			.add(coverImage)
			.add(posScreen[1])
			.add(coverLayer)
			.add(coverAlpha);
		f.newSingleton("screen3-cover")
			.add(coverImage)
			.add(posScreen[2])
			.add(coverLayer)
			.add(coverAlpha);

		addPlayer();

		for(i in 0...10)
			addBeing();

		f.addSystem(new game.system.BounceSystem(f));
		f.addSystem(new game.system.SlaveSystem(f));
		f.addSystem(new flaxen.system.MovementSystem(f));
	}

	public function addPlayer()
	{
		f.newSingleton("player") // master player control
			.add(new Position(Config.SCREEN_W / 2, Config.SCREEN_H / 2))
			.add(new Velocity(0,0))
			.add(Master.instance);

		for(screen in 0...3)
		{
			var pos = posScreen[screen];
			var slaveEnt:Entity = f.newEntity("scr" + screen + "player")
				.add(imgTiles)
				.add(gsTiles)
				.add(layerBeing)
				.add(new Tile(screen + 3))
				.add(new Position(Config.SCREEN_W / 2, Config.SCREEN_H / 2))
				.add(new Velocity(0,0))
				.add(new Slave("player", pos))
				.add(offTile);
		}
	}

	public function addBeing()
	{
		var beings = [Being.random(), Being.random(), Being.random()];

		// Spawn master
		var masterPos = new Position(Config.SCREEN_W * Math.random(), Config.SCREEN_H * Math.random());
		var masterPt = openfl.geom.Point.polar(newBeingSpeed, Math.PI * Math.random());
		var masterEnt:Entity = f.newEntity("master")
			.add(masterPos)
			.add(new Velocity(masterPt.x, masterPt.y))
			.add(Master.instance);

		for(screen in 0...3)
		{
			var pos = posScreen[screen];
			var being = beings[screen];
			var slaveEnt:Entity = f.newEntity("scr" + screen + "slave")
				.add(new Position(masterPos.x + pos.x, masterPos.y + pos.y))
				.add(new Slave(masterEnt.name, pos))
				.add(imgTiles)
				.add(being)
				.add(gsTiles)
				.add(new Tile(being.toInt()))
				.add(offTile)
				.add(layerBeing);
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
			changeScreen(screen);

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

	public function changeScreen(screen:Int)
	{
		//
	}
}
