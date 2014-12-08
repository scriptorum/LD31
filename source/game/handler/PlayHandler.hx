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
import openfl.Assets;

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
	}

	public function initUI()
	{
		f.newSingleton("SpawnBox");

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

		// art	TITLE		GAME 		LOGO
		// FMan 46,196		10,20
		// Fire 84,441		243,20
		// SM 	328,441		380,20
		// V1 	110,318		183,20
		// V2 	258, 441	330,20


		addPlacards();
		addTitling();
	}

	public function addTitling()
	{
		var fireman = f.newSingleton("title-fireman")
			.add(new Image("art/title-fireman.png"))
			.add(new Position(46,196))
			.add(Invisible.instance)
			.add(new Layer(4));

		var fire = f.newSingleton("title-fire")
			.add(new Image("art/title-fire.png"))
			.add(new Position(84,441))
			.add(Invisible.instance)
			.add(new Layer(4));

		var snowman = f.newSingleton("title-snowman")
			.add(new Image("art/title-snowman.png"))
			.add(new Position(328,441))
			.add(Invisible.instance)
			.add(new Layer(4));

		var vs1 = f.newSingleton("title-vs1")
			.add(new Image("art/title-vs.png"))
			.add(new Position(110,318))
			.add(Invisible.instance)
			.add(new Layer(4));

		var vs2 = f.newSingleton("title-vs2")
			.add(new Image("art/title-vs.png"))
			.add(Invisible.instance)
			.add(new Position(258,441))
			.add(new Layer(4));		

		f.newActionQueue()
			.removeComponent(fireman, Invisible)
			.addCallback(function() { f.newSound("sound/spawn.wav"); })
			.delay(1.0)
			.removeComponent(vs1, Invisible)
			.addCallback(function() { f.newSound("sound/spawn.wav"); })
			.delay(1.0)
			.removeComponent(fire, Invisible)
			.addCallback(function() { f.newSound("sound/spawn.wav"); })
			.delay(1.0)
			.removeComponent(vs2, Invisible)
			.addCallback(function() { f.newSound("sound/spawn.wav"); })
			.delay(1.0)
			.removeComponent(snowman, Invisible)
			.addCallback(function() { f.newSound("sound/spawn.wav"); })
			.delay(1.0)
			.addCallback(function()
			{
				f.newTween(fireman.get(Position), { x:10, y:20 }, 0.5);
				f.newTween(vs1.get(Position),     { x:183,y:20 }, 0.5);
				f.newTween(fire.get(Position),    { x:235,y:20 }, 0.5);
				f.newTween(vs2.get(Position),     { x:330,y:20 }, 0.5);
				f.newTween(snowman.get(Position), { x:380,y:20 }, 0.5);
			})
			.addCallback(function()
			{
				Config.offerStart(f);
			});
	}

	public function addPlacards()
	{
		f.newSingleton("rules")
			.add(new Image("art/instructions.png"))
			.add(new Position(319,148))
			.add(new Layer(5))
			.add(new Rotation(-15));

		var start = f.newSingleton("start")
			.add(new Image("art/start.png"))
			.add(new Position(321,265))
			.add(new Layer(8))
			.add(new Rotation(16));

		f.newSingleton("counter-bg")
			.add(new Image("art/score.png"))
			.add(new Position(473,294))
			.add(new Layer(5));

		f.newSingleton("deathsign")
			.add(new Image("art/youdied.png"))
			.add(new Position(348,72))
			.add(new Layer(6))
			.add(new Rotation(34));
	}

	public function addCounter()
	{
		f.newSingleton("score")
			.add(new Image("art/font1.png"))
			.add(new Position(538, 324))
			.add(new Layer(3))
			.add(new Text("0"))
			.add(new Counter(0))
			.add(Updated.instance)
			.add(TextStyle.createBitmap(false, Center, Center, 0, -2, 0, "2", false, "0123456789,"));
	}

	public function startGame()
	{
		Config.mode = "play"; 
		f.resetSingleton("BoxOfBeing");
		f.newChildEntity("SpawnBox", "spawn").add(new Spawn(0, SpawnPlayer));
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
		if(Config.mode == "start" && f.isPressed("start"))
		{
			f.stopSounds();
			f.newSound("sound/click.wav");
			Config.mode = "starting";
			var scoreEnt = f.demandEntity("score");
			scoreEnt.get(Counter).value = 0;
			scoreEnt.add(Updated.instance);

			var t = f.newTween(f.demandComponent("start", Position), { x:321, y:265 }, Config.UI_SPEED);
			f.newTween(f.demandComponent("start", Rotation), { angle:16 }, Config.UI_SPEED);
			f.newTween(f.demandComponent("deathsign", Position), { x:348, y:72 }, Config.UI_SPEED);
			f.newTween(f.demandComponent("deathsign", Rotation), { angle:34 }, Config.UI_SPEED);
			t.destroyEntity = false;
			f.newActionQueue()
				.waitForProperty(t, "complete", true)
				.removeEntityByName(f.ash, t.name)
				.addCallback(function() 
				{ 
					startGame();
				});
		}

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

		InputService.clearLastKey();

		if(!f.entityExists("player"))
			return;

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

		f.newSound("sound/switch.wav");			

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
