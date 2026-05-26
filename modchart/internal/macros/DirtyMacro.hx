package modchart.internal.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Printer;

class DirtyMacro {
	public static function build():Array<Field> {
		var fields:Array<Field> = Context.getBuildFields();
		var dirtySetters:Array<Field> = [];

		for (field in fields) {
			for (meta in field.meta) {
				if (meta.name == ":dirty") {
					var t = null;
					var e = null;

					switch (field.kind) {
						case FVar(tt, ee):
							t = tt;
							e = ee;
						case _:
							Context.fatalError("q pndejooo", Context.currentPos());
					}

					field.kind = FProp("default", "set", t, e);

					dirtySetters.push({
						name: 'set_${field.name}',
						kind: FFun({
							args: [
								{
									name: "vv_",
									type: t
								}
							],
							expr: macro {
								$e{meta.params[0]} = true;
								return $i{field.name} = vv_;
							},
							ret: switch (field.kind) {
								case FVar(t, e): t;
								case _: null;
							}
						}),
						access: [AInline],
						pos: field.pos
					});

					break;
				}
			}
		}
		fields = fields.concat(dirtySetters);

		return fields;
	}
}
