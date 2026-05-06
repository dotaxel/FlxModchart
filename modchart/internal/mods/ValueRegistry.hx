package modchart.internal.mods;

import haxe.ds.StringMap;

@:allow(modchart.internal.mods.ModifierProcessor)
class ValueRegistry {
	static var nextId:Int = 0;
	static var nameToId:StringMap<Int> = new StringMap<Int>();

	static inline function register(name:String):Int {
		var id = nextId++;
		nameToId.set(name, id);
		return id;
	}

	static inline function getId(name:String):Int
		return nameToId.get(name);
}
