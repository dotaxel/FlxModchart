package modchart.components.actor.base;

import glm.Mat4;
import modchart.math.Transform;

// @:nullSafety(Strict)
abstract class ActorImpl implements IActor {
	public var parent(default, null):IActor;
	public var ID(default, null):Int;

	public var visible:Bool = true;

	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	public var rotationX(get, set):Float;
	public var rotationY(get, set):Float;
	public var rotationZ(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var scaleZ(get, set):Float;
	public var alpha(get, set):Float;

	@:noCompletion
	private var _children(default, null):Array<IActor> = [];

	@:noCompletion
	private var _localTransform(default, null):Transform = new Transform();

	public function new() {
		ID = @:privateAccess Global._nextActorID++;
	}

	public function update(elapsed:Float):Void {
		if (!visible)
			return;
		for (child in _children)
			child.update(elapsed);
	}

	public function draw(parentMatrix:Null<Mat4>):Void {
		if (!visible)
			return;
		var worldMatrix = parentMatrix != null ? parentMatrix * _localTransform.getMatrix() : _localTransform.getMatrix();
		render(worldMatrix);
		for (child in _children)
			child.draw(worldMatrix);
	}

	private function render(worldMatrix:Mat4):Void {}

	public function destroy():Void {
		for (child in _children)
			child.destroy();
		_children = [];
		parent = null;
	}

	public function addChild(actor:Null<IActor>):Void {
		if (!validateChild(actor))
			return;
		actor.parent = this;
		_children.push(actor);
	}

	public function removeChild(actor:Null<IActor>):Void {
		if (actor.parent != this) {
			ModchartLog("removeChild: actor is not a child of this actor.");
			return;
		}
		actor.parent = null;
		_children.remove(actor);
	}

	public function forEachActor(fn:IActor->Void):Void {
		for (child in _children)
			fn(child);
	}

	private function validateChild(child:Null<IActor>):Bool {
		if (child == null) {
			ModchartLog("addChild: child is null.");
			return false;
		}
		if (child == this) {
			ModchartLog("addChild: cannot parent an actor to itself.");
			return false;
		}
		if (child.parent != null) {
			ModchartLog("addChild: child already has a parent, remove it first.");
			return false;
		}
		return true;
	}

	inline function get_x()
		return _localTransform.x;

	inline function get_y()
		return _localTransform.y;

	inline function get_z()
		return _localTransform.z;

	inline function get_rotationX()
		return _localTransform.rotationX;

	inline function get_rotationY()
		return _localTransform.rotationY;

	inline function get_rotationZ()
		return _localTransform.rotationZ;

	inline function get_scaleX()
		return _localTransform.scaleX;

	inline function get_scaleY()
		return _localTransform.scaleY;

	inline function get_scaleZ()
		return _localTransform.scaleZ;

	inline function get_alpha()
		return _localTransform.alpha;

	inline function set_x(v) {
		_localTransform.x = v;
		return v;
	}

	inline function set_y(v) {
		_localTransform.y = v;
		return v;
	}

	inline function set_z(v) {
		_localTransform.z = v;
		return v;
	}

	inline function set_rotationX(v) {
		_localTransform.rotationX = v;
		return v;
	}

	inline function set_rotationY(v) {
		_localTransform.rotationY = v;
		return v;
	}

	inline function set_rotationZ(v) {
		_localTransform.rotationZ = v;
		return v;
	}

	inline function set_scaleX(v) {
		_localTransform.scaleX = v;
		return v;
	}

	inline function set_scaleY(v) {
		_localTransform.scaleY = v;
		return v;
	}

	inline function set_scaleZ(v) {
		_localTransform.scaleZ = v;
		return v;
	}

	inline function set_alpha(v) {
		_localTransform.alpha = v;
		return v;
	}
}
