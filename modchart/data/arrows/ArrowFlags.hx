package modchart.data.arrows;

enum abstract ArrowFlags(Int) from Int to Int {
	public var NONE = 0;

	public var HOLDING = 1 << 0;

	public var JUST_HIT = 1 << 1;
	public var JUST_MISS = 1 << 2;
	public var JUST_HELD = 1 << 3;
}
