package modchart.internal;

import glm.Mat4;
import haxe.ds.StringMap;
import lime.graphics.WebGL2RenderContext;
import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.math.Matrix4;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import modchart.math.Transform;
import modchart.math.View;
import openfl.display3D.textures.RectangleTexture;
import openfl.display3D.textures.TextureBase;

class Renderer {
	public static var instance:Renderer;

	static var quadVBO:GLBuffer;
	static var quadEBO:GLBuffer;

	static var basicProgram:GLProgram;
	static var basicVertexShader:GLShader;
	static var basicFragShader:GLShader;

	static var uTex:GLUniformLocation;
	static var uModel:GLUniformLocation;
	static var uView:GLUniformLocation;
	static var uProj:GLUniformLocation;

	static var basicSetup:Bool = false;

	public var view:View = new View();

	var programs:StringMap<GLProgram> = new StringMap();

	var _wasDepthTest:Bool = false;
	var _wasBlend:Bool = false;
	var _matBuffer:Float32Array = new Float32Array(4 * 4);

	var gl(get, null):WebGLRenderContext;

	inline function get_gl()
		return Global.gl;

	public function new() {
		if (!basicSetup) {
			_initBuffers();
			_initShaders();
			basicSetup = true;
		}

		Renderer.instance = this;
	}

	// fake backbuffer or whatever
	var currentTarget:Null<TextureBase>;

	inline public function bindTarget(tex:Null<TextureBase>) {
		currentTarget = tex;
		setRenderToBackbuffer();
	}

	inline public function setRenderTexture(tex:TextureBase) {
		Global.context3D.setRenderToTexture(tex);
	}

	inline public function setRenderToBackbuffer() {
		if (currentTarget != null) {
			setRenderTexture(currentTarget);
			return;
		}

		Global.context3D.setRenderToBackBuffer();
	}

	public function prepare():Void {
		gl.enable(gl.DEPTH_TEST);
		gl.depthMask(true);

		gl.depthFunc(gl.LESS);

		gl.clearColor(0, 1, 0, 1);
		gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
	}

	public function flush():Void {
		gl.disable(gl.DEPTH_TEST);

		gl.depthMask(false);
		// I FUCKING HATE OPENFL I SPENT 2 HOURS DEBUGGING THIS
		gl.depthFunc(gl.GREATER);
	}

	public function drawQuad(texture:TextureBase, antialiasing:Bool, modelMatrix:Mat4, ?program:String):Void {
		var glProgram:GLProgram = (program != null) ? (programs.get(program) ?? basicProgram) : basicProgram;

		gl.useProgram(glProgram);

		var uModelLoc:GLUniformLocation;
		var uViewLoc:GLUniformLocation;
		var uProjLoc:GLUniformLocation;
		var uTexLoc:GLUniformLocation;

		if (glProgram == basicProgram) {
			uModelLoc = uModel;
			uViewLoc = uView;
			uProjLoc = uProj;
			uTexLoc = uTex;
		} else {
			uModelLoc = gl.getUniformLocation(glProgram, "model");
			uViewLoc = gl.getUniformLocation(glProgram, "view");
			uProjLoc = gl.getUniformLocation(glProgram, "projection");
			uTexLoc = gl.getUniformLocation(glProgram, "tex");
		}

		_uploadMatrix(uModelLoc, modelMatrix);
		_uploadMatrix(uViewLoc, view.getViewMatrix());
		_uploadMatrix(uProjLoc, view.getProjMatrix());

		gl.activeTexture(gl.TEXTURE0);
		@:privateAccess
		gl.bindTexture(texture.__textureTarget, texture.__textureID);

		var mode = antialiasing ? gl.LINEAR : gl.NEAREST;

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, mode);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, mode);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		gl.uniform1i(uTexLoc, 0);

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
		gl.useProgram(null);
	}

	public function registerProgram(name:String, program:GLProgram):Void {
		programs.set(name, program);
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
			1.0, // top-left
			0.5,
			0.5,
			0.0,
			1.0,
			1.0, // top-right
			- 0.5,
			-0.5,
			0.0,
			0.0,
			0.0, // bottom-left
			0.5,
			-0.5,
			0.0,
			1.0,
			0.0 // bottom-right
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
		basicVertexShader = gl.createShader(gl.VERTEX_SHADER);
		gl.shaderSource(basicVertexShader, VERTEX_SHADER_SRC);
		gl.compileShader(basicVertexShader);

		var vertStatus = gl.getShaderParameter(basicVertexShader, gl.COMPILE_STATUS);
		if (!vertStatus)
			ModchartLog("Failed to compile vertex shader: " + gl.getShaderInfoLog(basicVertexShader));

		basicFragShader = gl.createShader(gl.FRAGMENT_SHADER);
		gl.shaderSource(basicFragShader, FRAGMENT_SHADER_SRC);
		gl.compileShader(basicFragShader);

		var fragStatus = gl.getShaderParameter(basicFragShader, gl.COMPILE_STATUS);
		if (!fragStatus)
			ModchartLog("Failed to compile fragment shader: " + gl.getShaderInfoLog(basicFragShader));

		basicProgram = gl.createProgram();
		gl.attachShader(basicProgram, basicVertexShader);
		gl.attachShader(basicProgram, basicFragShader);
		gl.linkProgram(basicProgram);

		var linkStatus = gl.getProgramParameter(basicProgram, gl.LINK_STATUS);
		if (!linkStatus)
			ModchartLog("Failed to link basic shader program: " + gl.getProgramInfoLog(basicProgram));

		gl.detachShader(basicProgram, basicVertexShader);
		gl.detachShader(basicProgram, basicFragShader);
		gl.deleteShader(basicVertexShader);
		gl.deleteShader(basicFragShader);

		uTex = gl.getUniformLocation(basicProgram, "tex");
		uModel = gl.getUniformLocation(basicProgram, "model");
		uView = gl.getUniformLocation(basicProgram, "view");
		uProj = gl.getUniformLocation(basicProgram, "projection");
	}

	static final VERTEX_SHADER_SRC:String = "
        #version 330 core

        layout(location = 0) in vec3 aPos;
        layout(location = 1) in vec2 aUV;

        uniform mat4 model;
        uniform mat4 view;
        uniform mat4 projection;

        out vec2 vUV;

        void main()
        {
            gl_Position = projection * view * model * vec4(aPos, 1.0);
            vUV = aUV;
        }
    ";

	static final FRAGMENT_SHADER_SRC:String = "
        #version 330 core

        in vec2 vUV;

        out vec4 FragColor;

        uniform sampler2D tex;

        void main()
        {
            FragColor = texture(tex, vUV);
        }
    ";
}
