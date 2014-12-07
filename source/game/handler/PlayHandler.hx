package game.handler; 

import ash.core.Entity;
import com.haxepunk.utils.Key;
import flaxen.component.*;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenHandler;
import flaxen.core.Log;
import flaxen.service.InputService;
import game.component.*;
import game.component.Spawn;

class PlayHandler extends FlaxenHandler
{	
	public var f:Flaxen;

	public function new(f:Flaxen)
	{
		super();
		this.f = f;
	}

	override public function start(_)
	{
		initSystems();
		initUI();
		spawnPlayer();
	}

	public function initUI()
	{
		f.newSingleton("frame-overlay")
			.add(new Image("art/overlay.png"))
			.add(Position.zero())
			.add(new Layer(0));

		Config.posScreen = [new Position(50, 60), new Position(50, 340), new Position(330,340)];
		var screenImage = new Image("art/screen.png");
		var screenLayer = new Layer(100);

		for(i in 0...3)
			f.newSingleton("screen" + i)
				.add(screenImage)
				.add(Config.posScreen[i])
				.add(screenLayer);

		var coverLayer = new Layer(10);
		var coverImage = new Image("art/screen-inactive.png");
		var coverAlpha = new Alpha(.35);

		for(i in 0...3)
		{
			var e = f.newSingleton("screen" + i + "cover")
				.add(coverImage)
				.add(Config.posScreen[i])
				.add(coverLayer)
				.add(coverAlpha);
			if(i == Config.currentScreen)
				e.add(Invisible.instance);
		}
	}

	public function spawnPlayer()
	{
		f.newEntity("spawn")
			.add(new Spawn(0, SpawnPlayer));
	}

	public function initSystems()
	{
		f.addSystem(new game.system.SpawnSystem(f));
		f.addSystem(new game.system.BounceSystem(f));
		f.addSystem(new game.system.SlaveSystem(f));
		f.addSystem(new flaxen.system.MovementSystem(f));
		f.addSystem(new game.system.CollisionSystem(f));
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
