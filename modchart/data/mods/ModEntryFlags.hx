package modchart.data.mods;

abstract ModEntryFlags(Int) from Int to Int {
	// @formatter:off
	public static final ALL_BASE:Array<ModEntryFlags> = [
		X,
		Y,
		Z,

		ROTATION_X,
		ROTATION_Y,
		ROTATION_Z,

		SCALE_X,
		SCALE_Y,

		SKEW_X,
		SKEW_Y,

		COLOR_R,
		COLOR_G,
		COLOR_B,
		COLOR_A,

		COLOR_R_OFFSET,
		COLOR_G_OFFSET,
		COLOR_B_OFFSET,
		COLOR_A_OFFSET
	]; // @formatter:on
	public static inline var X:ModEntryFlags = 1 << 0;
	public static inline var Y:ModEntryFlags = 1 << 1;
	public static inline var Z:ModEntryFlags = 1 << 2;

	public static inline var ROTATION_X:ModEntryFlags = 1 << 3;
	public static inline var ROTATION_Y:ModEntryFlags = 1 << 4;
	public static inline var ROTATION_Z:ModEntryFlags = 1 << 5;

	public static inline var SCALE_X:ModEntryFlags = 1 << 6;
	public static inline var SCALE_Y:ModEntryFlags = 1 << 7;

	public static inline var SKEW_X:ModEntryFlags = 1 << 8;
	public static inline var SKEW_Y:ModEntryFlags = 1 << 9;

	public static inline var COLOR_R:ModEntryFlags = 1 << 10;
	public static inline var COLOR_G:ModEntryFlags = 1 << 11;
	public static inline var COLOR_B:ModEntryFlags = 1 << 12;
	public static inline var COLOR_A:ModEntryFlags = 1 << 13;

	public static inline var COLOR_R_OFFSET:ModEntryFlags = 1 << 14;
	public static inline var COLOR_G_OFFSET:ModEntryFlags = 1 << 15;
	public static inline var COLOR_B_OFFSET:ModEntryFlags = 1 << 16;
	public static inline var COLOR_A_OFFSET:ModEntryFlags = 1 << 17;

	// combinations
	public static inline var XYZ:ModEntryFlags = X | Y | Z;
	public static inline var ROTATION:ModEntryFlags = ROTATION_X | ROTATION_Y | ROTATION_Z;
	public static inline var SCALE:ModEntryFlags = SCALE_X | SCALE_Y;
	public static inline var SKEW:ModEntryFlags = SKEW_X | SKEW_Y;
	public static inline var COLOR:ModEntryFlags = COLOR_R | COLOR_G | COLOR_B | COLOR_A;
	public static inline var COLOR_OFFSETS:ModEntryFlags = COLOR_R_OFFSET | COLOR_G_OFFSET | COLOR_B_OFFSET | COLOR_A_OFFSET;

	@:pure
	public inline function has(axis:ModEntryFlags):Bool
		return this & axis != 0;

	@:pure
	public inline function combine(axis:ModEntryFlags):ModEntryFlags
		return this | axis;

	// TODO: bit scanning?? with that we can remove the iterator + making this function pure
	public inline function each(fn:ModEntryFlags->Void):Void {
		for (flag in ALL_BASE)
			if (has(flag))
				fn(flag);
	}
}
