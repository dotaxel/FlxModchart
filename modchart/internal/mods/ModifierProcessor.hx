package modchart.internal.mods;

import haxe.ds.StringMap;
import haxe.ds.Vector;
import modchart.data.arrows.ArrowType;
import modchart.data.mods.ModInputData;
import modchart.data.mods.ModSample;

class ModifierProcessor {
	static var _modInput:ModInputData = {
		value: 0,
		currentFlag: 0,
		distance: 0,
		lane: 0,
		player: 0,
		type: Tap,
	};

	var modLookup:StringMap<Modifier>;
	var modList:Array<Modifier>;

	var entryValues:Vector<Float>;

	public function new() {
		modList = [];
		modLookup = new StringMap<Modifier>();

		entryValues = new Vector(Settings.MAX_MODS * Settings.MAX_PLAYERS * Settings.MAX_COLS, 0.);
	}

	inline public function getSample(distance:Float, lane:Int, player:Int, type:ArrowType):ModSample {
		var modSample:ModSample = {
			posX: 0,
			posY: 0,
			posZ: 0,
			rotationX: 0,
			rotationY: 0,
			rotationZ: 0,
			scaleX: 0,
			scaleY: 0,
			skewX: 0,
			skewY: 0,
			colorR: 0,
			colorG: 0,
			colorB: 0,
			colorA: 0,
			colorROffset: 0,
			colorGOffset: 0,
			colorBOffset: 0,
			colorAOffset: 0,
		};

		for (mod in modList) {
			var i:Int = 0;
			var fn = mod.fn;

			for (flags in mod.entries.keys()) {
				var entryId = mod.entriesID[i];

				var value = getValue(entryId, player, lane);

				// Skip this mod if its value its 0
				if (value == 0) {
					i++;
					continue;
				}

				_modInput = {
					value: value,
					currentFlag: flags,
					distance: distance,
					lane: lane,
					player: player,
					type: type,
				};

				flags.each((flag) -> {
					_modInput.currentFlag = flag;
					var result = fn(_modInput);

					switch (flag) {
						case X: modSample.posX += result;
						case Y: modSample.posY += result;
						case Z: modSample.posZ += result;
						case ROTATION_X: modSample.rotationX += result;
						case ROTATION_Y: modSample.rotationY += result;
						case ROTATION_Z: modSample.rotationZ += result;
						case SCALE_X: modSample.scaleX += result;
						case SCALE_Y: modSample.scaleY += result;
						case SKEW_X: modSample.skewX += result;
						case SKEW_Y: modSample.skewY += result;
						case COLOR_R: modSample.colorR += result;
						case COLOR_G: modSample.colorG += result;
						case COLOR_B: modSample.colorB += result;
						case COLOR_A: modSample.colorA += result;
						case COLOR_R_OFFSET: modSample.colorROffset += result;
						case COLOR_G_OFFSET: modSample.colorGOffset += result;
						case COLOR_B_OFFSET: modSample.colorBOffset += result;
						case COLOR_A_OFFSET: modSample.colorAOffset += result;
					}
				});

				i++;
			}
		}

		return modSample;
	}

	public function registerModifier(modifier:Null<Modifier>) {
		if (!validateModifier(modifier))
			return;

		// Generate entries IDs.
		// I leaved this as an optional in the Modifier struct just to not have to make another struct for internal stuff
		// Also if you really know what are you doing you can just give the entries an id by yourself, following the way we do internally.
		// But why you would that?? idk
		if (modifier.entriesID == null) {
			modifier.entriesID = [];

			for (name in modifier.entries)
				modifier.entriesID.push(ValueRegistry.register(name));
		}

		modLookup.set(modifier.name, modifier);
		modList.push(modifier);
	}

	inline private function validateModifier(modifier:Null<Modifier>):Bool {
		// I dont really need to check entries content or name because its types cannot be null on most of the platforms.
		// I think??
		if (modifier == null || modifier.entries == null || modifier.fn == null) {
			ModchartLog("Failed to register modifier: The given modifier its null or one of its properties is. ");
			return false;
		}

		if (modLookup.exists(modifier.name)) {
			ModchartLog("Failed to register modifier: The name of the given modifier is already in the list, is it already added? ");
			return false;
		}

		return true;
	}

	inline public function setValue(value:Float, entryID:Int, player:Int, col:Int)
		entryValues[
			entryID * Settings.MAX_PLAYERS * Settings.MAX_COLS + player * Settings.MAX_COLS + col
		] = value;

	inline public function setValueByName(value:Float, entryName:String, player:Int, col:Int)
		setValue(value, ValueRegistry.getId(entryName), player, col);

	@:pure
	inline public function getValue(entryID:Int, player:Int, col:Int):Float
		return entryValues[
			entryID * Settings.MAX_PLAYERS * Settings.MAX_COLS + player * Settings.MAX_COLS + col
		];
}
