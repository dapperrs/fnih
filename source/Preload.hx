#if sys
package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class Preload extends MusicBeatState // https://www.youtube.com/watch?v=WrGV3lMkS5w taken from here, thx for the tutorial // god i wish i could stop copying code
{
	public static var bitmapData:Map<String,FlxGraphic>;
	public static var bitmapData2:Map<String,FlxGraphic>;

	var imagesShared = [];
    var imagesBruh = [];
    var imagesButtons = [];
	var music = [];

    var balls:Int;
    var cock = 0;

    var fuckYeah:Float;

	var shitz:FlxText;

	override function create()
	{
        FlxG.save.bind('funkin', 'ninjamuffin99');

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();
		bitmapData2 = new Map<String,FlxGraphic>();

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('placeholder'));
		menuBG.screenCenter();
        menuBG.setGraphicSize(Std.int(menuBG.width * 0.7));
		add(menuBG);

        shitz = new FlxText(550, 650, 0, "LOADING", 12);
		shitz.scrollFactor.set();
		shitz.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(shitz);

		#if cpp
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images")))
		{
			if (!i.endsWith(".png"))
				continue;
			imagesShared.push(i);
		}
        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/buttonThings")))
        {
            if (!i.endsWith(".png"))
                continue;
            imagesButtons.push(i);
        }

        for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/bruh/images/angeles")))
        {
            if (!i.endsWith(".png"))
                continue;
            imagesBruh.push(i);
        }

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
		#end

		sys.thread.Thread.create(() -> {
			cache();
		});

        balls = imagesBruh.length + music.length + imagesShared.length;

		super.create();
	}

	override function update(elapsed) 
	{
		super.update(elapsed);
	}

	function cache()
	{

		for (i in imagesShared)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/" + i);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			trace(i);
            cock++;
		}

		for (i in imagesBruh)
        {
            var replaced = i.replace(".png","");
            var data:BitmapData = BitmapData.fromFile("assets/bruh/images/angeles" + i);
            var graph = FlxGraphic.fromBitmapData(data);
            graph.persist = true;
            graph.destroyOnNoUse = false;
            bitmapData.set(replaced,graph);
            trace(i);
            cock++;
        }

        for (i in imagesButtons)
        {
            var replaced = i.replace(".png","");
            var data:BitmapData = BitmapData.fromFile("assets/shared/images/buttonThings" + i);
            var graph = FlxGraphic.fromBitmapData(data);
            graph.persist = true;
            graph.destroyOnNoUse = false;
            bitmapData.set(replaced,graph);
            trace(i);
        }

		for (i in music)
		{
			trace(i);
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));  
            cock++;         
		}

		#end

        trace(fuckYeah);

        if (cock == balls)
        {
            remove(shitz);
            shitz = new FlxText(580, 650, 0, "Done!", 12);
            shitz.scrollFactor.set();
            shitz.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            add(shitz);  
        }    

        var transition:FlxSprite;
        transition = new FlxSprite();
		transition.frames = Paths.getSparrowAtlas('transition');
		transition.animation.addByPrefix('idle', 'transitionLol', 24, false);
		transition.antialiasing = false;
		transition.screenCenter();
		add(transition);

        transition.animation.play('idle');

        new FlxTimer().start(2, function(tmre:FlxTimer)
        {
            FlxG.switchState(new TitleState());	
        });    	
	}

}