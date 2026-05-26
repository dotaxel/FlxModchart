package modchart.internal;

import lime.graphics.WebGLRenderContext;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import modchart.data.MusicSync;
import openfl.Lib;
import openfl.display.Stage;
import openfl.display3D.Context3D;
import openfl.display3D.textures.RectangleTexture;
#if macro
import haxe.macro.Expr;
#end

class Global {
	private static var _nextActorID:Int = 0;

	public static var musicSync:MusicSync;

	public static var gl(get, null):WebGLRenderContext;
	public static var context3D(get, null):Context3D;

	inline static function get_gl()
		return @:privateAccess Lib.current.stage.context3D.gl;

	inline static function get_context3D()
		return @:privateAccess Lib.current.stage.context3D;

	public static function init() {}

	public static function resetVariables() {
		_nextActorID = 0;
	}

	public static function updateVariables() {}

	macro public static function log(message:Expr) {
		#if !FLX_MODCHART_NO_LOGS
		return macro {};
		#else
		return macro {trace("[ FunkinModchart ] " + $message)};
		#end
	}
}
