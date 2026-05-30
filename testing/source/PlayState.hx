package;

import flixel.FlxG;
import flixel.FlxState;
import glm.GLM;
import glm.Mat4;
import glm.Quat;
import glm.Vec4;
import modchart.components.actor.Actor;
import modchart.components.actor.ActorFrameTexture;
import modchart.components.actor.ActorProxy.ProxyActor;
import modchart.components.actor.SpriteActor;
import modchart.internal.Renderer;
import modchart.internal.Shader;
import openfl.Assets;
import openfl.Vector;
import openfl.display.BitmapData;

@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.textures.TextureBase)
@:access(ime.graphics.WebGLRenderContext)
class PlayState extends FlxState
{
	var renderer:Renderer;

	var screenBitmapWrap:BitmapData;

	var mainActor:Actor;
	var shader:Shader;
	var shader2:Shader;

	var aft:ActorFrameTexture;

	var sprite:SpriteActor;
	var sprite2:SpriteActor;

	var proxy:ProxyActor;
	var proxy2:ProxyActor;

	override function create():Void
	{
		super.create();

		renderer = new Renderer();

		mainActor = new Actor();

		shader2 = new Shader(null, Assets.getText("assets/data/tv.frag"));
		shader = new Shader(Assets.getText("assets/data/test.vert"), Assets.getText("assets/data/test.frag"));

		var t = Assets.getBitmapData("assets/images/juan.png");
		var t2 = Assets.getBitmapData("assets/images/pera.png");

		sprite = new SpriteActor(t);
		sprite.x = -100;
		sprite.scaleX = 0.25;
		sprite.scaleY = 0.25;
		sprite.z = 200;
		sprite.shader = shader;
		mainActor.addChild(sprite);

		sprite2 = new SpriteActor(t2);
		sprite2.x = 100;
		sprite2.scaleX = 0.25;
		sprite2.scaleY = 0.25;
		sprite2.z = 200;
		sprite2.shader = shader;
		mainActor.addChild(sprite2);

		aft = new ActorFrameTexture(Std.int(t.width * .25), Std.int(t.height * .25));
		aft.shader = shader2;
		mainActor.addChild(aft);

		proxy = new ProxyActor(sprite);
		proxy.z = -100;
		aft.addChild(proxy);

		proxy2 = new ProxyActor(sprite2);
		proxy2.z = -100;
		aft.addChild(proxy2);

		@:privateAccess
		screenBitmapWrap = BitmapData.fromTexture(renderer.__viewTexture);

		FlxG.console.autoPause = false;
	}

	var dir:Vec4 = new Vec4();
	var mat:Mat4 = new Mat4();
	var quat:Quat = new Quat();

	var tmr = 0.;
	var frame = 0;

	override function update(dt:Float):Void
	{
		super.update(dt);

		tmr += dt;
		frame++;

		shader.use();
		shader.setFloat("iTime", tmr);
		shader.stopUsing();

		shader2.use();
		@:privateAccess
		shader2.setVec2("iResolution", aft.w, aft.h);
		shader2.setFloat("iTime", tmr);
		shader2.setInt("iFrame", frame);
		shader2.stopUsing();

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

		mainActor.update(dt);
	}

	override function draw():Void
	{
		renderer.prepare();

		mainActor.draw(null);

		renderer.flush();

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
