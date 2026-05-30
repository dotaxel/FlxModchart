package modchart.math;

import flixel.FlxG;
import flixel.math.FlxMath;
import glm.GLM;
import glm.Mat4;
import glm.Quat;
import glm.Vec3;

@:build(modchart.internal.macros.DirtyMacro.build())
class View {
	@:dirty(_viewDirty) public var x:Float = 0;
	@:dirty(_viewDirty) public var y:Float = 0;
	@:dirty(_viewDirty) public var z:Float = 0;

	@:dirty(_viewDirty) public var rotationX:Float = 0;
	@:dirty(_viewDirty) public var rotationY:Float = 0;
	@:dirty(_viewDirty) public var rotationZ:Float = 0;

	@:dirty(_projDirty) public var width:Int = 0;
	@:dirty(_projDirty) public var height:Int = 0;

	@:dirty(_projDirty) public var fov:Float = 60;
	@:dirty(_projDirty) public var near:Float = 0.1;
	@:dirty(_projDirty) public var far:Float = 1000;
	@:dirty(_projDirty) public var aspect:Float = 1.0;

	var _viewMatrix:Mat4;
	var _projMatrix:Mat4;

	var _vec3:Vec3;
	var _quat:Quat;
	var _scale:Vec3;

	var _viewDirty:Bool = true;
	var _projDirty:Bool = true;

	public function new(?width:Null<Int>, ?height:Null<Int>) {
		this.width = width ?? FlxG.width;
		this.height = height ?? FlxG.height;

		_viewMatrix = new Mat4();
		_projMatrix = new Mat4();

		_vec3 = new Vec3();
		_quat = new Quat();
		_scale = new Vec3(1, 1, 1);

		reset();
	}

	public inline function markDirty() {
		_viewDirty = true;
		_projDirty = true;
	}

	public function reset():Void {
		x = 0;
		y = 0;
		z = 0;

		rotationX = 0;
		rotationY = 0;
		rotationZ = 0;

		fov = 60;
		near = 0.1;
		far = 1000;

		markDirty();
	}

	var _eye = new Vec3();
	var _look = new Vec3();
	var _up = new Vec3(0, 1, 0);

	public function getViewMatrix():Mat4 {
		if (_viewDirty) {
			Mat4.identity(_viewMatrix);

			final r = Math.PI / 180;

			Vec3.set(_eye, x, y, z);

			final sinX = FlxMath.fastSin(rotationX * r);
			final cosX = FlxMath.fastCos(rotationX * r);

			final sinY = FlxMath.fastSin(rotationY * r);
			final cosY = FlxMath.fastCos(rotationY * r);

			final sinZ = FlxMath.fastSin(rotationZ * r);
			final cosZ = FlxMath.fastCos(rotationZ * r);

			Vec3.set(_look, cosX * sinY, sinX, cosX * cosY);
			Vec3.set(_up, sinZ * cosY, -cosZ, sinZ * sinY);

			GLM.lookAt(_eye, _look + _eye, _up, _viewMatrix);
		}

		return _viewMatrix;
	}

	public function getProjMatrix():Mat4 {
		aspect = width / height;

		if (_projDirty) {
			GLM.perspective(fov * Math.PI / 180.0, aspect, near, far, _projMatrix);

			_projDirty = false;
		}

		return _projMatrix;
	}
}
