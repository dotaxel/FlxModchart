package;

import modchart.data.mods.ModEntryFlags;
import modchart.data.mods.ModInputData;
import modchart.internal.mods.Modifier;
import modchart.internal.mods.ModifierProcessor;

class Main {
	static var processor:ModifierProcessor;

	static var translateMod:Modifier;

	static function main() {
		processor = new ModifierProcessor();

		translateMod = {
			name: "Translate",
			entries: [
				ModEntryFlags.X => "translatex",
				ModEntryFlags.Y => "translatey",
				ModEntryFlags.Z => "translatez"
			],
			fn: (input:ModInputData) -> {
				return input.value * 100;
			}
		};

		processor.registerModifier(translateMod);

		processor.setValueByName(1, "translatex", 0, 0);
		processor.setValueByName(0.25, "translatey", 0, 0);

		var sample = processor.getSample(0, 0, 0, Tap);
		trace(sample.posX);
		trace(sample.posY);
		trace(sample.posZ);
	}
}
