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
	public var newBeingSpeed:Int = 80; // 40 px/sec

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
		var coverAlpha = new Alpha(0.2);

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

		addBeing();
		addBeing();
		addBeing();

		var masterPos = f.demandComponent("master0", Position);
		trace(masterPos);

		f.addSystem(new flaxen.system.MovementSystem(f));
		f.addSystem(new game.system.BounceSystem(f));
		f.addSystem(new game.system.SlaveSystem(f));
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
			#if (windows || mac || linux))
				trace("Dumping log(s)");
				var path =  sys.FileSystem.fullPath ("../../../../../../../");
				flaxen.util.LogUtil.dumpLog(f, path + "/entities.txt");
				for(setName in f.getComponentSetKeys())
					trace(setName + ":{" + f.getComponentSet(setName) + "}");			
			#end
		}
		#end

		InputService.clearLastKey();
	}
}
