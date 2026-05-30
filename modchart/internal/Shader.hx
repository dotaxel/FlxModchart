package modchart.internal;

import glm.Mat4;
import haxe.ds.StringMap;
import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;

class Shader {
	// should i even do dis
	static inline final INJECT_PREFIX = "// @modchart_injected";

	static final INJECT_VERT = INJECT_PREFIX
		+ "
		#version 330 core

		layout(location = 0) in vec3 aPos;
		layout(location = 1) in vec2 aUV;
		uniform mat4 model;
		uniform mat4 view;
		uniform mat4 projection;
    ";

	static final INJECT_FRAG = INJECT_PREFIX + "
		#version 330 core

		uniform sampler2D tex;
    ";

	static var _matBuffer:Float32Array = new Float32Array(16);

	public var program(default, null):GLProgram;

	// cached locations bc gl uniform loc is expensive
	public var uModel(default, null):GLUniformLocation;
	public var uView(default, null):GLUniformLocation;
	public var uProj(default, null):GLUniformLocation;
	public var uTex(default, null):GLUniformLocation;

	var _locs:StringMap<GLUniformLocation> = new StringMap();

	var gl(get, null):WebGLRenderContext;

	inline function get_gl()
		return Global.gl;

	public function new(vertSrc:Null<String>, fragSrc:Null<String>) {
		if (fragSrc == null)
			fragSrc = DEFAULT_FRAG;
		if (vertSrc == null)
			vertSrc = DEFAULT_VERTEX;

		var vert = _compile(gl.VERTEX_SHADER, _inject(vertSrc, INJECT_VERT));
		var frag = _compile(gl.FRAGMENT_SHADER, _inject(fragSrc, INJECT_FRAG));

		program = _link(vert, frag);

		uModel = gl.getUniformLocation(program, "model");
		uView = gl.getUniformLocation(program, "view");
		uProj = gl.getUniformLocation(program, "projection");
		uTex = gl.getUniformLocation(program, "tex");
	}

	// some friendly api??
	public inline function use():Void
		gl.useProgram(program);

	public inline function stopUsing():Void
		gl.useProgram(null);

	public function setFloat(name:String, v:Float):Void
		gl.uniform1f(_loc(name), v);

	public function setInt(name:String, v:Int):Void
		gl.uniform1i(_loc(name), v);

	public function setVec2(name:String, x:Float, y:Float):Void
		gl.uniform2f(_loc(name), x, y);

	public function setVec3(name:String, x:Float, y:Float, z:Float):Void
		gl.uniform3f(_loc(name), x, y, z);

	public function setVec4(name:String, x:Float, y:Float, z:Float, w:Float):Void
		gl.uniform4f(_loc(name), x, y, z, w);

	public function setMat4(name:String, m:Mat4):Void
		_uploadMat(_loc(name), m);

	inline function _uploadMVP(model:Mat4, viewMat:Mat4, proj:Mat4):Void {
		_uploadMat(uModel, model);
		_uploadMat(uView, viewMat);
		_uploadMat(uProj, proj);
	}

	inline function _bindTex():Void
		gl.uniform1i(uTex, 0);

	inline function _loc(name:String):GLUniformLocation {
		if (!_locs.exists(name))
			_locs.set(name, gl.getUniformLocation(program, name));
		return _locs.get(name);
	}

	inline function _uploadMat(loc:GLUniformLocation, m:Mat4):Void {
		// tuff function lmfao
		var b = _matBuffer;
		b[0] = m.r0c0;
		b[1] = m.r1c0;
		b[2] = m.r2c0;
		b[3] = m.r3c0;
		b[4] = m.r0c1;
		b[5] = m.r1c1;
		b[6] = m.r2c1;
		b[7] = m.r3c1;
		b[8] = m.r0c2;
		b[9] = m.r1c2;
		b[10] = m.r2c2;
		b[11] = m.r3c2;
		b[12] = m.r0c3;
		b[13] = m.r1c3;
		b[14] = m.r2c3;
		b[15] = m.r3c3;
		gl.uniformMatrix4fv(loc, false, b);
	}

	function _inject(src:String, block:String):String {
		if (src.indexOf(INJECT_PREFIX) != -1)
			return src;
		return block + "\n" + src;
	}

	function _compile(type:Int, src:String):GLShader {
		var shader = gl.createShader(type);
		gl.shaderSource(shader, src);
		gl.compileShader(shader);

		if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
			var typeName = (type == gl.VERTEX_SHADER) ? "vertex" : "fragment";
			ModchartLog('[$typeName shader] ' + gl.getShaderInfoLog(shader));
			ModchartLog('--- source ---\n$src');

			return _compile(type, _inject(type == gl.VERTEX_SHADER ? DEFAULT_VERTEX : ERROR_FRAG, type == gl.VERTEX_SHADER ? INJECT_VERT : INJECT_FRAG));
		}

		return shader;
	}

	function _link(vert:GLShader, frag:GLShader):GLProgram {
		var prog = gl.createProgram();
		gl.attachShader(prog, vert);
		gl.attachShader(prog, frag);
		gl.linkProgram(prog);

		if (!gl.getProgramParameter(prog, gl.LINK_STATUS))
			ModchartLog("[shader link] " + gl.getProgramInfoLog(prog));

		gl.detachShader(prog, vert);
		gl.detachShader(prog, frag);
		gl.deleteShader(vert);
		gl.deleteShader(frag);

		return prog;
	}

	public function dispose():Void {
		gl.deleteProgram(program);
		program = null;
		_locs = null;
	}

	static final DEFAULT_VERTEX:String = "
		out vec2 vUV;

		void main() {
			gl_Position = projection * view * model * vec4(aPos, 1.0);
			vUV = aUV;
		}
    ";

	static final DEFAULT_FRAG:String = "
		in vec2 vUV;
		out vec4 FragColor;

		void main() {
			FragColor = texture(tex, vUV);
		}
    ";

	// jajjajaja
	static final ERROR_FRAG:String = "
		in vec2 vUV;
		out vec4 FragColor;

		void main() {
			float check = mod(floor(vUV.x * 8.0) + floor(vUV.y * 8.0), 2.0);
			FragColor = vec4(check, 0.0, check, 1.0);
		}
	";
}
