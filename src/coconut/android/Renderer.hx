package coconut.android;

import android.content.Context;
import android.view.ViewGroup as AndroidViewGroup;
import androidx.fragment.app.FragmentManager as AndroidFragmentManager;
import coconut.diffing.*;
import deepequal.custom.ArrayContains;
import deepequal.DeepEqual.compare;

using StringTools;

class Renderer {
	static var DIFFER = new coconut.diffing.Differ(new AndroidViewBackend());

	public static function mountInto(target:AndroidViewGroup, virtual:RenderResult) {
		AndroidViewBackend.context = target.getContext();
		DIFFER.render([virtual], cast target);
	}

	static public function getNative(view:View):Null<Dynamic>
		return cast getAllNative(view)[0];

	static public function getAllNative(view:View):Array<Dynamic>
		return switch @:privateAccess view._coco_lastRender {
			case null: [];
			case r: r.flatten(null);
		}

	static public inline function updateAll()
		tink.state.Observable.updateAll();

	static public macro function hxx(e);

	static public macro function mount(context:Context, target, markup);
}

private class AndroidViewCursor implements Cursor<Dynamic> {
	var pos:Int;
	var container:AndroidViewGroup;
	var fragmentManager = ApplicationDelegate.getInstance().getSupportFragmentManager();

	public function new(container:AndroidViewGroup, pos:Int) {
		this.container = container;
		this.pos = pos;
	}

	public function insert(real:Dynamic):Bool {
		if (Std.is(real, androidx.fragment.app.Fragment)) {
			// if (!Std.is(container, AndroidViewGroup))
			//   throw "Fragment parent must be a type of android.view.ViewGroup";
			var manager = fragmentManager;
			var inserted = real.isAdded();
			var fragmentTransaction = manager.beginTransaction();
			var _container = container;
			if (_container == null)
				_container = ApplicationDelegate.mainView;
			fragmentTransaction.add(_container.getId(), real);
			fragmentTransaction.commit();
			return inserted;
		}

		if (container != null && Std.is(real, android.view.View)) {
			var inserted = real.getParent() != container;
			real.setId(pos);
			container.addView(real, pos);
			return inserted;
		}

		return false;
	}

	public function delete():Bool {
		if (container != null && pos <= container.getChildCount()) {
			container.removeViewAt(pos);
			return true;
		}
		var manager = fragmentManager;
		if (manager.findFragmentById(pos) != null) {
			var f = manager.findFragmentById(pos);
			var fragmentTransaction = manager.beginTransaction();
			fragmentTransaction.remove(f);
			fragmentTransaction.commit();
			return true;
		}
		return false;
	}

	public function step():Bool
		return if (pos >= container.getChildCount()) false; else ++pos == container.getChildCount();

	public function current():Dynamic {
		var manager = fragmentManager;
		if (container != null && container.getChildAt(pos) != null)
			return cast container.getChildAt(pos);
		if (manager.findFragmentById(pos) != null)
			return cast manager.findFragmentById(pos);
		return null;
	}
}

private class AndroidViewBackend implements Applicator<Dynamic> {
	public static var context:Context;

	public function new() {}

	var registry:Map<java.lang.Object, Rendered<Dynamic>> = new Map();

	public function unsetLastRender(target:Dynamic):Rendered<Dynamic> {
		var ret = registry[cast target];
		registry.remove(target);
		return ret;
	}

	public function setLastRender(target:Dynamic, r:Rendered<Dynamic>):Void
		registry[target] = r;

	public function getLastRender(target:Dynamic):Null<Rendered<Dynamic>>
		return registry[target];

	public function traverseSiblings(target:Dynamic):Cursor<Dynamic> {
		if (Std.is(target, android.view.View))
			return new AndroidViewCursor(cast target.getParent(), cast(target.getParent(), AndroidViewGroup).indexOfChild(target));
		if (Std.is(target, androidx.fragment.app.Fragment))
			return new AndroidViewCursor(cast ApplicationDelegate.mainView, target.getId());
		return null;
	}

	public function traverseChildren(target:Dynamic):Cursor<Dynamic> {
		if (target.getId() == -1) {
			target.setId(ApplicationDelegate.mainView.getId());
		}
		if (Std.is(target, android.view.View))
			return new AndroidViewCursor(cast target, 0);
		if (Std.is(target, androidx.fragment.app.Fragment))
			return new AndroidViewCursor(cast target.getView(), 0);

		return null;
	}

	public function placeholder(forTarget:Widget<Dynamic>):VNode<Dynamic>
		return VNode.native(cast PLACEHOLDER, null, null, null, null);

	static final PLACEHOLDER = new coconut.android.AndroidViewNodeType(() -> {
		var target = new android.view.ViewGroup(ApplicationDelegate.getInstance());
		target.setId(ApplicationDelegate.mainView.getId() + 1);
		return target;
	});
}



class AndroidViewNodeType<Attr:{}, Real:{}> implements NodeType<Attr, Real> {
	var factory:() -> Real;

	public function new(view) {
		this.factory = view;
	}

	inline function refresh(target:Real, prop, val, old) {
		// We need a better way to call Android view setters, they are methods and that is why we are using reflection.

		var args:Array<Dynamic> = [];
		if (Std.is(val, Array)) {
			args = cast val;
		} else {
			args.push(val);
		}
		var _contextObj:java.lang.Object = cast target;
		for (m in _contextObj.getClass().getMethods()) {
			var p:String = prop;
			var mName = "set" + p.charAt(0).toUpperCase() + p.substring(1);

			if (m.getName() == mName) {
				var _params:java.NativeArray<java.lang.Object> = new java.NativeArray(args.length);
				var aType = cast(args[0], java.lang.Object).getClass();
				var found = false;

				// Check types or interfaces against similar primitive Java types
				if (aType == java.lang.Class.forName("java.lang.String")) {
					switch java.util.Arrays.asList(m.getParameterTypes()).get(0).toString() {
						case "interface java.lang.CharSequence" | "class java.lang.String":
							{
								found = m.getParameterCount() == args.length;
							}
						case _:
							found = false;
					}
				} else if (aType == java.lang.Class.forName("java.lang.Integer")) {
					found = m.getParameterCount() == args.length
						&& java.util.Arrays.asList(m.getParameterTypes()).get(0).toString() == "int";
				} else if (aType.toString().contains("$")) {
					found = m.getParameterCount() == args.length
						&& java.util.Arrays.asList(m.getParameterTypes()).get(0).toString() == "class haxe.jvm.Function";
				} else {
					if (m.getParameterCount() == args.length
						&& java.util.Arrays.asList(m.getParameterTypes()).get(0).toString().startsWith("interface")) {
						// wild guess that developer knows what they are doing.
						found = true;
					} else if (m.getParameterCount() == args.length && java.util.Arrays.asList(m.getParameterTypes()).contains(aType)) {
						found = true;
					}
				}

				// trace(mName, aType, found, java.util.Arrays.asList(m.getParameterTypes()).get(0));
				if (found) {
					var i = 0;
					for (a in args) {
						_params[i] = cast a;
					}

					m.invoke(_contextObj, _params);
					break;
				}
			}
		}
	}

	inline function set(target, prop, val, old) {
		try{
			if (Std.is(val, Array)) {
				var args:Array<Dynamic> = cast val;
				var oldArgs:Array<Dynamic> = cast old;
				var older = new ArrayContains(oldArgs);
	
				if (oldArgs != null && args.length == oldArgs.length) {
					switch compare(older, args) {
						case Success(_): // do nothing
						case Failure(_):
							refresh(target, prop, cast val, cast old);
					}
				} else {
					refresh(target, prop, cast val, cast old);
				}
			} else {
				if (val != old) {
					refresh(target, prop, cast val, cast old);
				}
			}
		}catch(e:java.lang.reflect.InvocationTargetException){
			Sys.println(e.getTargetException().getMessage());
			throw e;
		}
	}

	public function create(a:Attr):Real {
		var ret = factory();
		if (ret != null) {
			Differ.updateObject(ret, a, null, set);
		}
		return ret;
	}

	public function update(r:Real, old:Attr, nu:Attr):Void {
		trace("UPDATE!!!");
		Differ.updateObject(r, nu, old, set);
	}
}
