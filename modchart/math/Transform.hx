package modchart.math;

import glm.GLM;
import glm.Mat4;
import glm.Quat;
import glm.Vec3;
import glm.Vec4;
import lime.utils.Float32Array;

@:build(modchart.internal.macros.DirtyMacro.build())
class Transform {
	@:dirty(_dirty) public var x:Float = 0;
	@:dirty(_dirty) public var y:Float = 0;
	@:dirty(_dirty) public var z:Float = 0;

	@:dirty(_dirty) public var rotationX:Float = 0;
	@:dirty(_dirty) public var rotationY:Float = 0;
	@:dirty(_dirty) public var rotationZ:Float = 0;

	@:dirty(_dirty) public var scaleX:Float = 1;
	@:dirty(_dirty) public var scaleY:Float = 1;
	@:dirty(_dirty) public var scaleZ:Float = 1;

	public var alpha:Float = 1;

	var _matrix:Mat4;
	var _matrixArray:Float32Array;

	var _pos:Vec3;
	var _scale:Vec3;
	var _quat:Quat;

	var _dirty:Bool = true;

	public function new() {
		_matrix = new Mat4();
		_matrixArray = new Float32Array(4 * 4);

		_pos = new Vec3();
		_scale = new Vec3();
		_quat = new Quat();
	}

	// @formatter:off
	public function getMatrix():Mat4 {
		if (_dirty) {
			Vec3.set(_pos, x, y, z);
			Quat.fromEuler(
				rotationX * Math.PI / 180.0,
				rotationY * Math.PI / 180.0,
				rotationZ * Math.PI / 180.0,
				_quat
			);
			Vec3.set(_scale, scaleX, scaleY, scaleZ);

			GLM.transform(_pos, _quat, _scale, _matrix);

			_dirty = false;
		}

		return _matrix;
	}
	// @formatter:on
	public inline function reset():Void {
		x = 0;
		y = 0;
		z = 0;
		rotationX = 0;
		rotationY = 0;
		rotationZ = 0;
		scaleX = 1;
		scaleY = 1;
		scaleZ = 1;
		alpha = 1;
		_dirty = true;
	}
}
