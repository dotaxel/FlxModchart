package modchart.internal;

import flixel.FlxG;
import glm.Mat4;
import haxe.ds.IntMap;
import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import modchart.math.View;
import openfl.display3D.Context3DCompareMode;
import openfl.display3D.textures.TextureBase;

@:access(openfl.display.BitmapData)
@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.textures.TextureBase)
@:access(lime.graphics.WebGLRenderContext)
@:access(modchart.internal.Renderer)
class Renderer {
	public static var instance:Renderer;

	static var quadVBO:GLBuffer;
	static var quadEBO:GLBuffer;

	static var basicShader:Shader;
	static var basicSetup:Bool = false;

	public var view:View = new View();

	var __viewTexture:TextureBase;

	var _matBuffer:Float32Array = new Float32Array(4 * 4);
	var _identityMatrix:Mat4;

	var gl(get, null):WebGLRenderContext;

	inline function get_gl()
		return Global.gl;

	public function new() {
		if (!basicSetup) {
			_initBuffers();
			_initShaders();
			basicSetup = true;
		}
		__viewTexture = Global.context3D.createRectangleTexture(FlxG.width, FlxG.height, BGRA, true);
		_identityMatrix = Mat4.identity(new Mat4());
		Renderer.instance = this;
	}

	// fake backbuffer or whatever
	var targetStack:Array<TextureBase> = [];
	var prepareQueue:IntMap<TextureBase> = new IntMap();

	var currentTarget:Null<TextureBase>;

	inline public function prepareTarget(tex:TextureBase) {
		prepareQueue.set(@:privateAccess tex.__textureID.id, tex);
	}

	inline public function pushTarget(tex:TextureBase) {
		targetStack.push(tex);
		setRenderTexture(tex);

		Global.context3D.__flushGLFramebuffer();
		Global.context3D.__flushGLDepth();
		Global.context3D.__flushGLViewport();

		if (prepareQueue.exists(@:privateAccess tex.__textureID.id)) {
			gl.clearColor(0, 1, 0, 1);
			gl.clearDepth(1.0);
			gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
			prepareQueue.remove(@:privateAccess tex.__textureID.id);
		}
	}

	inline public function popTarget() {
		if (targetStack.length == 0)
			throw "No target to pop";

		targetStack.pop();

		if (targetStack.length == 0) {
			setRenderToBackbuffer();
		} else {
			setRenderTexture(targetStack[targetStack.length - 1]);
		}
		Global.context3D.__flushGLFramebuffer();
		Global.context3D.__flushGLDepth();
		Global.context3D.__flushGLViewport();
	}

	inline public function setRenderTexture(tex:TextureBase) {
		currentTarget = tex;
		Global.context3D.setRenderToTexture(tex, true);
	}

	inline public function setRenderToBackbuffer() {
		currentTarget = null;
		Global.context3D.setRenderToBackBuffer();
	}

	public function prepare():Void {
		Global.context3D.setDepthTest(true, Context3DCompareMode.LESS);

		prepareTarget(__viewTexture);
		pushTarget(__viewTexture);
	}

	public function flush():Void {
		popTarget();
		Global.context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
		// I FUCKING HATE OPENFL I SPENT 2 HOURS DEBUGGING THIS
		// gl.depthFunc(gl.GREATER);
	}

	public function drawQuad(texture:TextureBase, antialiasing:Bool, modelMatrix:Mat4, ?shader:Null<Shader>, ?skipCamera:Bool = false):Void {
		var shader:Shader = shader ?? basicShader;
		shader.use();

		@:privateAccess
		shader._uploadMVP(modelMatrix, view.getViewMatrix(), view.getProjMatrix());

		gl.activeTexture(gl.TEXTURE0);
		@:privateAccess
		gl.bindTexture(texture.__textureTarget, texture.__textureID);

		var mode = antialiasing ? gl.LINEAR : gl.NEAREST;

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, mode);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, mode);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		@:privateAccess
		shader._bindTex();

		gl.bindBuffer(GL.ARRAY_BUFFER, quadVBO);
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, quadEBO);

		gl.vertexAttribPointer(0, 3, gl.FLOAT, false, 5 * 4, 0);
		gl.enableVertexAttribArray(0);

		gl.vertexAttribPointer(1, 2, gl.FLOAT, false, 5 * 4, 3 * 4);
		gl.enableVertexAttribArray(1);

		gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);

		gl.disableVertexAttribArray(0);
		gl.disableVertexAttribArray(1);
		gl.bindBuffer(GL.ARRAY_BUFFER, null);
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
		gl.bindTexture(gl.TEXTURE_2D, null);

		shader.stopUsing();
	}

	inline function _uploadMatrix(loc:GLUniformLocation, m:Mat4):Void {
		var _ = _matBuffer;
		_[0] = m.r0c0;
		_[1] = m.r1c0;
		_[2] = m.r2c0;
		_[3] = m.r3c0;

		_[4] = m.r0c1;
		_[5] = m.r1c1;
		_[6] = m.r2c1;
		_[7] = m.r3c1;

		_[8] = m.r0c2;
		_[9] = m.r1c2;
		_[10] = m.r2c2;
		_[11] = m.r3c2;

		_[12] = m.r0c3;
		_[13] = m.r1c3;
		_[14] = m.r2c3;
		_[15] = m.r3c3;

		gl.uniformMatrix4fv(loc, false, _);
	}

	function _initBuffers():Void {
		// xyzuv
		var vertices:Array<Float> = [
			-0.5,
			0.5,
			0.0,
			0.0,
			0.0, // top-left
			0.5,
			0.5,
			0.0,
			1.0,
			0.0, // top-right
			- 0.5,
			-0.5,
			0.0,
			0.0,
			1.0, // bottom-left
			0.5,
			-0.5,
			0.0,
			1.0,
			1.0 // bottom-right
		];

		var indices:Array<Int> = [
			0, 1, 2,
			2, 1, 3
		];

		var vertBytes = new Float32Array(vertices.length);
		for (i in 0...vertices.length)
			vertBytes[i] = vertices[i];

		var idxBytes = new UInt16Array(indices.length);
		for (i in 0...indices.length)
			idxBytes[i] = indices[i];

		quadVBO = gl.createBuffer();
		gl.bindBuffer(GL.ARRAY_BUFFER, quadVBO);
		gl.bufferData(GL.ARRAY_BUFFER, vertBytes, GL.STATIC_DRAW);

		quadEBO = gl.createBuffer();
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, quadEBO);
		gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, idxBytes, GL.STATIC_DRAW);

		gl.bindBuffer(GL.ARRAY_BUFFER, null);
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, null);
	}

	function _initShaders():Void {
		basicShader = new Shader(null, null);
	}
}
