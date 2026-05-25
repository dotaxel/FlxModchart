package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import glm.GLM;
import glm.Mat4;
import glm.Quat;
import glm.Vec3;
import glm.Vec4;
import modchart.components.actor.Actor;
import modchart.components.actor.SpriteActor;
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

	var screenTexture:RectangleTexture;
	var screenBitmapWrap:BitmapData;

	var mainActor:Actor;
	var sprite1:SpriteActor;
	var sprite2:SpriteActor;

	override function create():Void
	{
		super.create();

		renderer = new Renderer();

		mainActor = new Actor();

		for (i in 0...2 * 5)
		{
			var sprite1 = new SpriteActor(Assets.getBitmapData("assets/images/juan.png"));
			sprite1.scaleX = sprite1.bitmap.width * .25;
			sprite1.scaleY = sprite1.bitmap.height * .25;
			var fovRad = (renderer.view.fov * Math.PI) / 180.0;
			mainActor.addChild(sprite1);

			var xR = i % 2;
			var zR = Math.floor(i / 2);

			sprite1.x = 100 * FlxMath.signOf((i % 2) - 1);
			sprite1.z = zR * 100;
		}

		// sprite2 = new SpriteActor(Assets.getBitmapData("assets/images/pera.png"));
		// sprite2.scaleX = sprite2.bitmap.width;
		// sprite2.scaleY = sprite2.bitmap.height;
		// sprite2.z = 1;
		// sprite1.addChild(sprite2);

		screenTexture = Global.context3D.createRectangleTexture(1280, 720, BGRA, true);
		screenBitmapWrap = BitmapData.fromTexture(screenTexture);
	}

	var dir:Vec4 = new Vec4();
	var mat:Mat4 = new Mat4();
	var quat:Quat = new Quat();

	override function update(dt:Float):Void
	{
		super.update(dt);

		Quat.fromEuler(renderer.view.rotationX * Math.PI / 180, renderer.view.rotationY * Math.PI / 180, 0, quat);
		GLM.rotate(quat, mat);

		Vec4.set(dir);

		if (FlxG.keys.pressed.A)
			dir.x -= 1;
		if (FlxG.keys.pressed.D)
			dir.x += 1;
		if (FlxG.keys.pressed.W)
			dir.z += 1;
		if (FlxG.keys.pressed.S)
			dir.z -= 1;

		if (dir.x != 0 || dir.z != 0)
		{
			dir = Vec4.normalize(dir, dir);
			dir = Mat4.multVec(mat, dir, dir);

			dir = Vec4.multiplyScalar(dir, 150 * dt, dir);

			renderer.view.x += dir.x;
			renderer.view.y += dir.y;
			renderer.view.z += dir.z;
		}

		if (FlxG.keys.pressed.LEFT)
			renderer.view.rotationY -= 50 * dt;
		if (FlxG.keys.pressed.RIGHT)
			renderer.view.rotationY += 50 * dt;

		renderer.bindTarget(screenTexture);
		FlxG.stage.context3D.__flushGLFramebuffer();

		renderer.prepare();

		mainActor.update(dt);
		mainActor.draw(null);

		renderer.bindTarget(null);
		renderer.flush();
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
