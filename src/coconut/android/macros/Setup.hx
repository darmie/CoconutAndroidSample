package coconut.android.macros;

#if macro
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using tink.MacroApi;
using sys.FileSystem;
using haxe.io.Path;
import haxe.macro.MacroStringTools;
using StringTools;
using Lambda;



class Setup {
	static function all() {
		var cl = Context.getType('android.view.View').getClass();
    cl.meta.add(':autoBuild', [macro @:pos(cl.pos) coconut.android.macros.Setup.hxxAugment()], cl.pos);
    
    var cl1 = Context.getType('androidx.fragment.app.Fragment').getClass();
		cl1.meta.add(':autoBuild', [macro @:pos(cl.pos) coconut.android.macros.Setup.hxxAugment1()], cl.pos);
	}

	static function hxxAugment() {
		var fields = Context.getBuildFields(),
      cl = Context.getLocalClass().get();

		var self = Context.getLocalType().toComplex(); // TODO: type params

		var typePath:haxe.macro.TypePath = {
			pack: cl.pack,
			name: cl.name
    }
    
    var moduleName:String = cl.module;

		return fields.concat((macro class {

			// static inline var COCONUT_NODE_TYPE =
			static public inline function fromHxx(hxxMeta:{
				@:optional var key(default, never):coconut.diffing.Key;
				@:optional var ref(default, never):coconut.ui.Ref<$self>;
			},
				attr:coconut.android.macros.Attributes<$self>, ?children:coconut.android.Children):coconut.android.RenderResult {
        var attrFields = Reflect.fields(attr);
        var target:android.view.View = cast(new $typePath(coconut.android.ApplicationDelegate.getInstance()));
      
				return coconut.diffing.VNode.native(new coconut.android.Renderer.AndroidViewNodeType<coconut.android.macros.Attributes<$self>,
					android.view.View>(() -> cast target),
					cast hxxMeta.ref, hxxMeta.key, attr, children);
			}
		}).fields);
  }
  
	static function hxxAugment1() {
		var fields = Context.getBuildFields(),
      cl = Context.getLocalClass().get();

		var self = Context.getLocalType().toComplex(); // TODO: type params

		var typePath:haxe.macro.TypePath = {
			pack: cl.pack,
			name: cl.name
    }
    
    var moduleName:String = cl.module;

		return fields.concat((macro class {

			// static inline var COCONUT_NODE_TYPE =
			static public inline function fromHxx(hxxMeta:{
				@:optional var key(default, never):coconut.diffing.Key;
				@:optional var ref(default, never):coconut.ui.Ref<$self>;
			},
				attr:coconut.android.macros.Attributes<$self>, ?children:coconut.android.Children):coconut.android.RenderResult {
    
        var target:androidx.fragment.app.Fragment = cast(new $typePath());
      
				return coconut.diffing.VNode.native(new coconut.android.Renderer.AndroidViewNodeType<coconut.android.macros.Attributes<$self>,
					androidx.fragment.app.Fragment>(() -> cast target),
					cast hxxMeta.ref, hxxMeta.key, attr, children);
			}
		}).fields);
	}
}
#end
