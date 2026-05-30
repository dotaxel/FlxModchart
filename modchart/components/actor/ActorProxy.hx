package modchart.components.actor;

import glm.Mat4;
import modchart.components.actor.base.ActorImpl;
import modchart.components.actor.base.IActor;

class ProxyActor extends ActorImpl {
	public var source:IActor;
	public var skipSourceTransform:Bool = true;

	public function new(source:IActor) {
		this.source = source;
		super();
	}

	override function render(worldMatrix:Mat4) {
		source.draw(worldMatrix);
		super.render(worldMatrix);
	}
}
