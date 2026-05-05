package modchart.components.actor.base;

@:nullSafety(Strict)
abstract class ActorImpl implements IActor {
	public var parent(default, null):IActor;

	@:noCompletion
	private var _children(default, null):Array<IActor>;

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
			ModchartLog("addChild: child already has a parent.");
			return false;
		}
		return true;
	}
}
