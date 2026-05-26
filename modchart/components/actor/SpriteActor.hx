package modchart.components.actor;

import flixel.FlxSprite;
import glm.Mat4;
import modchart.components.actor.base.ActorImpl;
import modchart.internal.Renderer;
import openfl.display.BitmapData;
import openfl.display3D.textures.TextureBase;

class SpriteActor extends ActorImpl {
	public var bitmap:BitmapData;

	var tex:TextureBase;

	public function new(bitmap:BitmapData) {
		super();

		this.bitmap = bitmap;
		this.tex = bitmap.getTexture(Global.context3D);
	}

	override function draw(parentMatrix:Null<Mat4>) {
		var localMat = parentMatrix * _localTransform.getMatrix();
		Renderer.instance.drawQuad(tex, false, localMat);
		super.draw(localMat);
	}
}
