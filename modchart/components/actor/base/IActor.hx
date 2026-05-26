package modchart.components.actor.base;

import glm.Mat4;
import modchart.math.Transform;

interface IActor {
	public var ID(default, null):Int;
	public var parent(default, null):IActor;

	// transform
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	public var rotationX(get, set):Float;
	public var rotationY(get, set):Float;
	public var rotationZ(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var alpha(get, set):Float;

	public var visible:Bool;

	// internal
	private var _children(default, null):Array<IActor>;
	private var _localTransform(default, null):Transform;

	// tree
	public function addChild(child:IActor):Void;
	public function removeChild(child:IActor):Void;
	public function forEachActor(fn:IActor->Void):Void;

	// lifecycle
	public function update(elapsed:Float):Void;
	public function draw(parentMatrix:Mat4):Void;
	public function destroy():Void;
}
