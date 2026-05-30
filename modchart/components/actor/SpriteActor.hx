package modchart.components.actor;

import glm.GLM;
import glm.Mat4;
import glm.Vec3;
import modchart.components.actor.base.ActorImpl;
import modchart.internal.Renderer;
import modchart.internal.Shader;
import openfl.display.BitmapData;
import openfl.display3D.textures.TextureBase;

class SpriteActor extends ActorImpl {
	public var bitmap:BitmapData;
	public var shader:Null<Shader>;

	var tex:TextureBase;
	var sizeMat:Mat4;
	var vec:Vec3;

	public function new(bitmap:BitmapData) {
		super();

		this.bitmap = bitmap;
		this.tex = bitmap.getTexture(Global.context3D);
		this.vec = new Vec3();
		this.sizeMat = new Mat4();
	}

	override function render(worldMatrix:Mat4):Void {
		Mat4.identity(sizeMat);
		Vec3.set(vec, bitmap.width, bitmap.height, 1);
		GLM.scale(vec, sizeMat);
		Renderer.instance.drawQuad(tex, false, worldMatrix * sizeMat, shader);
	}
}
