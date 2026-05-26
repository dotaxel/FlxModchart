package modchart.data.mods;

/**
 * Defines how a modifier participates in the arrow transform pipeline.
 * Order: SCROLL → POSITION → OFFSET
 */
enum ModKind {
	/**
	 * Warps the Y timeline before any spatial transform occurs.
	 * Affects how time maps to the column distance.
	 * Examples: reverse, boost, brake, boomerang, expand, scroll speed multipliers.
	 *
	 * Ignores axis flags, always returns a scalar Y distance,
	 * since it operates on the timeline, not on spatial axes.
	 */
	SCROLL;

	/**
	 * Redefines where/how a note travels through space.
	 * Evaluated after SCROLL. The resulting Y output is used as the spline lookup key.
	 * Examples: centered, tornado, flip, invert.
	 */
	POSITION;

	/**
	 * Displaces a note from its POSITION-established transform.
	 * Evaluated after splines are sampled and applied.
	 * Examples: drunk, bumpy, tipsy, beat.
	 */
	OFFSET;
}
