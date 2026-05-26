package modchart.components.actor;

import modchart.components.actor.base.ActorImpl;
import modchart.internal.Global;
import openfl.display3D.textures.RectangleTexture;

class ActorFrameTexture extends ActorImpl {
	var __renderTarget:RectangleTexture;

	public function new() {
		__renderTarget = Global.context3D.createRectangleTexture(FlxG.width, FlxG.height, BGRA, true);
		Global.textures.push(__renderTarget);
	}

	override public function draw(parentMatrix:Null<Mat4>):Void {
		Renderer.instance.setRenderToTexture(__renderTarget);

		// clear the texture
		Global.gl.clearColor(0, 0, 0, 0);
		Global.gl.clear(Global.gl.COLOR_BUFFER_BIT);

		// first draw the tree to the texture
		super.draw(parentMatrix);
		Renderer.instance.setRenderToBackBuffer();

		// THEN render the actual texture to the backbuffer or whatever
		Renderer.instance.drawQuad(__renderTarget, parentMatrix);
	}

	override public function destroy() {
		Global.textures.remove(__renderTarget);

		__renderTexture.dispose();
		__renderTexture = null;
	}
}
