package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	private static var curWeek:Int = 0;
	
	var optionShit:Array<String> = ['story', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', 'options'];

	var magenta:FlxSprite;
	var magentadrawing:FlxSprite;
	var bge:FlxSprite;
	var bgee:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var logo:FlxSprite;
	var transition:FlxSprite;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxG.camera.zoom = 0.80;
		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		var bg:FlxSprite = new FlxSprite(1, -400);
		bg.frames = Paths.getSparrowAtlas('mainmenu/menubg');
		bg.animation.addByPrefix('idle', 'bgDope', 24, true);
		bg.animation.play('idle');
		bg.setGraphicSize(Std.int(bg.width * 1.4));
		bg.updateHitbox();
		bg.scrollFactor.set(0, 0);
		bg.screenCenter(X);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var sketch:FlxSprite = new FlxSprite(-1150, -400).loadGraphic(Paths.image('mainmenu/sketch'));
		sketch.setGraphicSize(Std.int(bg.width * 1.7));
		sketch.updateHitbox();
		sketch.alpha = 0.7;
		sketch.scrollFactor.set(0, 0);
		sketch.antialiasing = ClientPrefs.globalAntialiasing;
		add(sketch);

		var lights:FlxSprite = new FlxSprite(0, -800);
		lights.frames = Paths.getSparrowAtlas('mainmenu/lightsLol');
		lights.animation.addByPrefix('idle', 'lightsLoop', 24, true);
		lights.animation.play('idle');
		lights.setGraphicSize(Std.int(lights.width * 2.7));
		lights.updateHitbox();
		lights.scrollFactor.set(0, 0);
		lights.screenCenter(X);
		lights.antialiasing = ClientPrefs.globalAntialiasing;
		add(lights);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(1, -400);
		magenta.frames = Paths.getSparrowAtlas('mainmenu/menubgpink');
		magenta.animation.addByPrefix('idle', 'bgMagenta', 24, true);
		magenta.setGraphicSize(Std.int(magenta.width * 1.5));
		magenta.updateHitbox();
		magenta.animation.play('idle');
		magenta.scrollFactor.set(0, 0);
		magenta.screenCenter(X);
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		add(magenta);

		logo = new FlxSprite(1, -100);
		logo.frames = Paths.getSparrowAtlas('mainmenu/logoBumpin');
		logo.animation.addByPrefix('idle', 'logo bumpin', 24, true);
		logo.animation.play('idle');
		logo.setGraphicSize(Std.int(logo.width * 0.8));
		logo.updateHitbox();
		logo.scrollFactor.set(0, 0);
		logo.screenCenter(X);
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		add(logo);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			switch(i) { // hhhhhhhh
				case 0:
					menuItem.setPosition(380, 260);
				case 1:
					menuItem.setPosition(650, 260);
				case 2:
					menuItem.setPosition(380, 380);
				case 3:
					menuItem.setPosition(650, 380);
				case 4:
					menuItem.setPosition(510, 480);	
			}	
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " untouched", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " touched", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.65));
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			menuItems.add(menuItem);				
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(450, 580);
		leftArrow.frames = Paths.getSparrowAtlas('FNF_main_menu_assets');
		leftArrow.animation.addByPrefix('idle', "arrowLeft untouched");
		leftArrow.animation.addByPrefix('press', "arrowLeft touched");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();
		add(sprDifficultyGroup);
		
		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 40, leftArrow.y).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}
		changeDifficulty();

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 340, leftArrow.y);
		rightArrow.frames = Paths.getSparrowAtlas('FNF_main_menu_assets');
		rightArrow.animation.addByPrefix('idle', "arrowRight untouched");
		rightArrow.animation.addByPrefix('press', "arrowRight touched");
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		var versionShit:FlxText = new FlxText(-160, FlxG.height + 47, 0, "Psych Engine v" + psychEngineVersion, 160);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(-160, FlxG.height + 60, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 180);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		transition = new FlxSprite();
		transition.frames = Paths.getSparrowAtlas('transition');
		transition.animation.addByPrefix('idle', 'transitionLol', 24, false);
		transition.antialiasing = ClientPrefs.globalAntialiasing;
		transition.antialiasing = false;
		transition.screenCenter();
		transition.visible = false;
		add(transition);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;
	
	var curDifficulty:Int = 1;

	override function update(elapsed:Float)
	{
		var redo:Bool = true;
		var done:Bool = false;
	
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
    		//lazy code but cmon it works!!

		    var justhitM:Bool = false;
		    var justhitE:Bool = false;
		    var justhitT:Bool = false;

		    if (FlxG.keys.justPressed.M)
		    {
			    justhitM = true;
		        trace(justhitM);
		    }	
		    if (FlxG.keys.justPressed.E)
		    {
		     	if (justhitM)
		     	    justhitE = true;
			    trace(justhitE);
		    }	
		    if (FlxG.keys.justPressed.T)
		    {
		      	if (justhitE)
		    	    justhitT = true;
		    	trace(justhitT);
		    }	

			if (justhitT)
				{
					selectedSomethin = true;
					trace('shit');
					PlayState.SONG = Song.loadFromJson('meeting-hard', 'meeting');
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = 2;
					PlayState.storyWeek = 1;
			
					new FlxTimer().start(1, function(tmre:FlxTimer)
						{
							transition.visible = true;
							transition.animation.play('idle');
							FlxG.sound.play(Paths.sound('zoooom'));
						});
					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						LoadingState.loadAndSwitchState(new PlayState(), true);
					});
				}	
			
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			if (controls.UI_LEFT_P)
				changeDifficulty(-1);

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'story':			
									//ripped from storymenu lol											
									// Nevermind that's stupid lmao
									PlayState.storyPlaylist = ['Star', 'Cali', "Hostage"];
									PlayState.isStoryMode = true;
									PlayState.seenCutscene = false;
								
									var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
									if(diffic == null) diffic = '';
								
									PlayState.storyDifficulty = curDifficulty;
								
									PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
									PlayState.storyWeek = 1;
									PlayState.campaignScore = 0;
									PlayState.campaignMisses = 0;
								
								    new FlxTimer().start(0.5, function(tmre:FlxTimer)
									{
										transition.visible = true;
										transition.animation.play('idle');
								  		FlxG.sound.play(Paths.sound('zoooom'));
									});
									new FlxTimer().start(2, function(tmr:FlxTimer)
									{
										LoadingState.loadAndSwitchState(new PlayState(), true);
										FreeplayState.destroyFreeplayVocals();
									});
								case 'freeplay':
									new FlxTimer().start(0.5, function(tmre:FlxTimer)
										{
											transition.visible = true;
											transition.animation.play('idle');
											  FlxG.sound.play(Paths.sound('zoooom'));
										});
										new FlxTimer().start(2, function(tmr:FlxTimer)
										{
											MusicBeatState.switchState(new FreeplayState());
										});
								case 'awards':
									new FlxTimer().start(0.5, function(tmre:FlxTimer)
										{
											transition.visible = true;
											transition.animation.play('idle');
											  FlxG.sound.play(Paths.sound('zoooom'));
										});
										new FlxTimer().start(2, function(tmr:FlxTimer)
										{
											MusicBeatState.switchState(new AchievementsMenuState());
										});								
								case 'credits':
									new FlxTimer().start(0.5, function(tmre:FlxTimer)
										{
											transition.visible = true;
											transition.animation.play('idle');
											  FlxG.sound.play(Paths.sound('zoooom'));
										});
										new FlxTimer().start(2, function(tmr:FlxTimer)
										{
											MusicBeatState.switchState(new CreditsState());
										});
								case 'options':
									new FlxTimer().start(0.5, function(tmre:FlxTimer)
										{
											transition.visible = true;
											transition.animation.play('idle');
											  FlxG.sound.play(Paths.sound('zoooom'));
										});
										new FlxTimer().start(2, function(tmr:FlxTimer)
										{
											MusicBeatState.switchState(new options.OptionsState());
										});
							}
						}
					});
				}
			}

			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});*/

		//NO

	}

	function changeDifficulty(change:Int = 0):Void
		{
			curDifficulty += change;
	
			if (curDifficulty < 0)
				curDifficulty = CoolUtil.difficultyStuff.length-1;
			if (curDifficulty >= CoolUtil.difficultyStuff.length)
				curDifficulty = 0;
	
			sprDifficultyGroup.forEach(function(spr:FlxSprite) {
				spr.visible = false;
				if(curDifficulty == spr.ID) {
					spr.visible = true;
					spr.alpha = 0;
					spr.y = leftArrow.y - 15;
					FlxTween.tween(spr, {y: leftArrow.y + 15, alpha: 1}, 0.07);
				}
			});
	
			#if !switch
			//intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
			#end
		}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.offset.x = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.y -= -5;
				spr.offset.x += 30;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
