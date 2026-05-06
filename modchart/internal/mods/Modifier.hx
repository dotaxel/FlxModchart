package modchart.internal.mods;

import modchart.data.mods.ModEntryFlags;
import modchart.data.mods.ModInputData;

typedef Modifier = {
	name:String,
	fn:ModInputData->Float,
	entries:Map<ModEntryFlags, String>,

	// Entry "hashed" IDs.
	// Make sure to leave this empty unless you know what are you doing.
	?entriesID:Array<Int>
}
