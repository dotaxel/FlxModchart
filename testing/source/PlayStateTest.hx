package;

import flixel.FlxG;
import flixel.FlxState;
import modchart.internal.Global;
import modchart.internal.Renderer;
import modchart.math.Transform;
import openfl.Assets;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;

@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.textures.TextureBase)
@:access(ime.graphics.WebGLRenderContext)
class PlayState extends FlxState
{
	var renderer:Renderer;

	var spriteBitmap:BitmapData;
	var spriteTexture:RectangleTexture;
	var spriteTransform:Transform;

	var screenTexture:RectangleTexture;
	var screenBitmapWrap:BitmapData;

	override function create():Void
	{
		super.create();

		renderer = new Renderer();

		spriteBitmap = Assets.getBitmapData("assets/images/juan.png");
		spriteTexture = Global.context3D.createRectangleTexture(spriteBitmap.width, spriteBitmap.height, BGRA, false);
		spriteTexture.uploadFromBitmapData(spriteBitmap);

		spriteTransform = new Transform();
		spriteTransform.scaleX = spriteBitmap.width;
		spriteTransform.scaleY = spriteBitmap.height;

		var fovRad = (renderer.view.fov * Math.PI) / 180.0;
		spriteTransform.z = -(FlxG.height * 0.5) / Math.tan(fovRad * 0.5);

		screenTexture = Global.context3D.createRectangleTexture(1280, 720, BGRA, true);
		screenBitmapWrap = BitmapData.fromTexture(screenTexture);
	}

	override function update(dt:Float):Void
	{
		super.update(dt);

		spriteTransform.rotationY += 100 * dt;

		Global.context3D.setRenderToTexture(screenTexture);

		FlxG.stage.context3D.__flushGLFramebuffer();

		var m = spriteTransform.getMatrix();

		renderer.prepare();
		renderer.drawQuad(spriteTexture, m);
		renderer.flush();

		Global.context3D.setRenderToBackBuffer();
	}

	override function draw():Void
	{
		super.draw();

		camera.canvas.graphics.beginBitmapFill(screenBitmapWrap);
		camera.canvas.graphics.drawQuads(Vector.ofArray([0., 0, 1280, 720]), Vector.ofArray([0]));
		camera.canvas.graphics.endFill();
	}

	override function destroy():Void
	{
		super.destroy();
	}
}
