package modchart.components.actor;

import glm.GLM;
import glm.Mat4;
import glm.Vec3;
import modchart.components.actor.base.ActorImpl;
import modchart.internal.Global;
import modchart.internal.Renderer;
import modchart.internal.Shader;
import modchart.math.View;
import openfl.display3D.textures.RectangleTexture;

class ActorFrameTexture extends ActorImpl {
	public var shader:Null<Shader>;

	var _view:View;

	var __renderTarget:RectangleTexture;
	var w:Int;
	var h:Int;
	var sizeMat:Mat4;
	var vec:Vec3;

	public function new(width:Int, height:Int) {
		super();

		this.w = width;
		this.h = height;

		vec = new Vec3();
		sizeMat = new Mat4();

		_view = new View();
		__renderTarget = Global.context3D.createRectangleTexture(width, height, BGRA, true);
	}

	// FIXME: not drawing a shit
	override public function draw(parentMatrix:Null<Mat4>):Void {
		if (!visible)
			return;
		var worldMatrix = parentMatrix != null ? parentMatrix * _localTransform.getMatrix() : _localTransform.getMatrix();
		Renderer.instance.prepareTarget(__renderTarget);
		Renderer.instance.pushTarget(__renderTarget);

		var lastView = Renderer.instance.view;
		Renderer.instance.view = _view;

		for (child in _children)
			child.draw(null);

		Renderer.instance.view = lastView;

		Renderer.instance.popTarget();

		render(worldMatrix);
	}

	override function render(worldMatrix:Mat4):Void {
		Mat4.identity(sizeMat);
		Vec3.set(vec, w, h, 1);
		GLM.scale(vec, sizeMat);
		Renderer.instance.drawQuad(__renderTarget, false, worldMatrix * sizeMat, shader);
	}

	override public function destroy() {
		__renderTarget.dispose();
		__renderTarget = null;
	}
}
