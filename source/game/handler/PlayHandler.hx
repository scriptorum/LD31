package game.handler; 

import ash.core.Entity;
import com.haxepunk.utils.Key;
import flaxen.common.LoopType;
import flaxen.common.TextAlign;
import flaxen.component.*;
import flaxen.component.Text;
import flaxen.core.Flaxen;
import flaxen.core.FlaxenHandler;
import flaxen.core.Log;
import flaxen.service.InputService;
import game.component.*;
import game.component.Spawn;
import openfl.geom.Rectangle;

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
			.add(new Layer(10));

		Config.posScreen = [new Position(20, 120), new Position(20, 370), new Position(320,370)];
		var screenImage = new Image("art/screen.png");
		var screenLayer = new Layer(100);

		for(i in 0...3)
			f.newSingleton("screen" + i)
				.add(screenImage)
				.add(Config.posScreen[i])
				.add(screenLayer);

		var coverLayer = new Layer(10);
		var coverAlpha = new Alpha(.4);

		for(i in 0...3)
		{
			var clip = new Rectangle(0, 0, Config.SCREEN_W, Config.SCREEN_H);
			var img = new Image("art/screen-inactive.png", clip);
			var e = f.newSingleton("screen" + i + "cover")
				.add(Config.posScreen[i])
				.add(coverLayer)
				.add(img)
				.add(coverAlpha)
				.add(new Tween(clip, { y:Config.SCREEN_H }, 0.3 + i * 0.2, null, LoopType.Forward));

			if(i == Config.currentScreen)
				e.add(Invisible.instance);
		}

		addCounter();
	}

	public function addCounter()
	{
		f.newSingleton("score")
			.add(new Image("art/font1.png"))
			.add(Position.topRight().add(0,5))
			.add(new Layer(5))
			.add(new Text("0"))
			.add(new Counter(0))
			.add(TextStyle.createBitmap(false, Right, Top, 0, -2, 0, "2", false, "0123456789,"));
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
		f.addSystem(new game.system.TextUpdatingSystem(f));
		f.addSystem(new game.system.StunSystem(f));
	}

	override public function update(_)
	{
		var key = InputService.lastKey();
		InputService.clearLastKey();

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

		if(f.hasComponent("player", Stunned))
			return;

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
