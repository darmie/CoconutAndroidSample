package coconut.android.macros;


#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.MacroStringTools;
using StringTools;
using haxe.macro.Tools;
using tink.MacroApi;
using Lambda;
#else
@:genericBuild(coconut.android.macros.Attributes.build())
#end
class Attributes<T> {
	#if macro
	static function build()
		return tink.macro.BuildCache.getType("coconut.android.macros.Attributes", function(ctx) {
			final fields:Array<Field> = [], added = new Map();
			final cl:ClassType = ctx.type.getClass();

			function addAttr(name, pos, type:ComplexType, ?mandatory) {
				var defaultMeta = []; //[{name: ':attribute', params: [], pos: pos}];
				if (!added[name]) {
					added[name] = true;
					fields.push({
						name: name,
						pos: pos,
						kind: FProp('default', "default", type),
						meta: if (mandatory) defaultMeta else defaultMeta.concat([{name: ':optional', params: [], pos: pos}]),
					});
				}
			}
				
			function crawl(target:ClassType) {
                final fields = target.fields.get();
				for (f in fields)
					if (f.isPublic) {
						function add(?t) {
							if (t == null)
								add(f.type)
							else {
								addAttr(f.name, f.pos, f.type.toComplex());
							}
						}
						switch f.kind {
							case FMethod(MethNormal):{
								f.meta.add(':keep', [], f.pos); // keep the function
								if(f.name.startsWith("set")){
									var attrName = f.name.substr(3).charAt(0).toLowerCase()+f.name.substring(4);
									switch f.type {
										case TFun(args, ret):{
											if(args.length == 0){
												addAttr(attrName, f.pos, args[0].t.toComplex());
											} else {
												addAttr(attrName, f.pos, TPath({pack:[], name:"Array", params:[TPType(TDynamic(null).toComplex())]}));
											}
											
										}
										case _:
									}
								}
							}
							case FVar(_, AccCall):
								fields.find(v -> v.name == 'set_' + f.name).meta.add(':keep', [], f.pos); // keep the setter
								add();
							case FVar(_, AccNormal):
								f.meta.add(':keep', [], f.pos);
								add();
							default:
						}
					}
				if (target.superClass != null) {
					crawl(target.superClass.t.get()); // TODO: do something about params
				}
					
			}
			crawl(cl);
			return {
				name: ctx.name,
				pack: [],
				pos: ctx.pos,
				fields: fields,
				kind: TDAlias(TAnonymous(fields))
			};
		});
	#end
}