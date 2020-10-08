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

    

    var added = new Map();

    function addAttr(fn, name, pos, type:ComplexType, ret:Null<ComplexType>, args:Array<Null<ComplexType>>, ?mandatory) {
      var defaultMeta = [];
      if (!added[name]) {
        added[name] = true;
      
        var fname = fn.name;
        var pname = "attrParam";
        var i = 0;
        var fn = macro _context.$fname;
        var arg2 = macro $i{pname};
        
        var _case = macro {
            var _contextObj:java.lang.Object = cast _context;
            for(m in _contextObj.getClass().getMethods()){
              if(m.getParameterCount() == $arg2.length && m.getName() == $v{fname}){
                var _params:java.NativeArray<java.lang.Object> = new java.NativeArray($arg2.length);
                var i = 0;
                for(a in $arg2) _params[i] = cast a;
                m.invoke(_contextObj, _params);
                break;
              }
            }
        }
       
   
        var i = 0;
        var setterFunc:Function = { 
          expr: macro $_case,
          ret: TPath({pack:[], name:"Void", params:[]}), // ret = return type
          args:[{type:self, name:"_context"}, {type: type, name:pname}] // no arguments here
        };

        fields.push({
          name: "set__" + name,
          access: [AStatic, AInline, APublic],
          kind: FieldType.FFun(setterFunc),
          pos: pos,
        });
        
      }
    }

    function crawl(_target:ClassType) {
      final fields = _target.fields.get();
      for (f in fields){
        if (f.isPublic) {
          switch f.kind {
            case FMethod(MethNormal):{
              if(f.name.startsWith("set")){
                var attrName = f.name.substr(3).toLowerCase();
                switch f.type {
                  case TFun(args, ret):{
        
                    // trace(f.meta.has(":overload"));
                    addAttr(f, attrName, f.pos, TPath({pack:[], name:"Array", params:[TPType(TDynamic(null).toComplex())]}), ret.toComplex(), [for(p in args) p.t.toComplex()]);
                  }
                  case _:
                }
              }
            }
            case _:
          }
        }
      }

      if (_target.superClass != null) {
        crawl(_target.superClass.t.get()); // TODO: do something about params
      }
    }

    crawl(cl);

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

    

    var added = new Map();

    function addAttr(fn, name, pos, type:ComplexType, ret:Null<ComplexType>, args:Array<Null<ComplexType>>, ?mandatory) {
      var defaultMeta = [];
      if (!added[name]) {
        added[name] = true;
      
        var fname = fn.name;
        var pname = "attrParam";
        var i = 0;
        var fn = macro _context.$fname;
        var arg2 = macro $i{pname};
        
        var _case = macro {
            var _contextObj:java.lang.Object = cast _context;
            for(m in _contextObj.getClass().getMethods()){
              if(m.getParameterCount() == $arg2.length && m.getName() == $v{fname}){
                var _params:java.NativeArray<java.lang.Object> = new java.NativeArray($arg2.length);
                var i = 0;
                for(a in $arg2) _params[i] = cast a;
                m.invoke(_contextObj, _params);
                break;
              }
            }
        }
       
   
        var i = 0;
        var setterFunc:Function = { 
          expr: macro $_case,
          ret: TPath({pack:[], name:"Void", params:[]}), // ret = return type
          args:[{type:self, name:"_context"}, {type: type, name:pname}] // no arguments here
        };

        fields.push({
          name: "set__" + name,
          access: [AStatic, AInline, APublic],
          kind: FieldType.FFun(setterFunc),
          pos: pos,
        });
        
      }
    }

    function crawl(_target:ClassType) {
      final fields = _target.fields.get();
      for (f in fields){
        if (f.isPublic) {
          switch f.kind {
            case FMethod(MethNormal):{
              if(f.name.startsWith("set")){
                var attrName = f.name.substr(3).toLowerCase();
                switch f.type {
                  case TFun(args, ret):{
        
                    // trace(f.meta.has(":overload"));
                    addAttr(f, attrName, f.pos, TPath({pack:[], name:"Array", params:[TPType(TDynamic(null).toComplex())]}), ret.toComplex(), [for(p in args) p.t.toComplex()]);
                  }
                  case _:
                }
              }
            }
            case _:
          }
        }
      }

      if (_target.superClass != null) {
        crawl(_target.superClass.t.get()); // TODO: do something about params
      }
    }

    crawl(cl);

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
