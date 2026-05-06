package modchart.data.mods;

import modchart.data.arrows.*;
import modchart.data.mods.ModEntryFlags;

typedef ModInputData = {
	// The entry value of this mod.
	value:Float,

	// The entry flag of this mod.
	currentFlag:ModEntryFlags,

	// Relative distance from the arrow to the receptor, in miliseconds.
	distance:Float,

	// Arrow data.
	lane:Int,
	player:Int,

	// The type of this note.
	type:ArrowType,
}
