package coconut.android;

import android.content.Context;
import android.view.ViewGroup as AndroidViewGroup;
import android.view.View as AndroidView;
import androidx.fragment.app.FragmentManager as AndroidFragmentManager;
import androidx.fragment.app.Fragment as AndroidFragment;
import coconut.diffing.*;
import deepequal.custom.ArrayContains;
import deepequal.DeepEqual.compare;

using StringTools;

class Renderer {
	static var DIFFER = new coconut.diffing.Differ(new AndroidViewBackend());

	public static function mountInto(target:AndroidView, virtual:RenderResult) {
		AndroidViewBackend.context = target.getContext() != null ? target.getContext() : ApplicationDelegate.getInstance();
		DIFFER.render([virtual], cast target);
	}

	static public function getNative(view:View):Null<AndroidView>
		return cast getAllNative(view)[0];

	static public function getAllNative(view:View):Array<AndroidView>
		return switch @:privateAccess view._coco_lastRender {
			case null: [];
			case r: r.flatten(null);
		}

	static public inline function updateAll()
		tink.state.Observable.updateAll();

	static public macro function hxx(e);

	static public macro function mount(context:Context, target, markup);
}

private class AndroidViewCursor implements Cursor<AndroidView> {
	var pos:Int;
	var container:AndroidViewGroup;
	var fragmentManager = ApplicationDelegate.getInstance().getSupportFragmentManager();

	public function new(container:AndroidViewGroup, pos:Int) {
		this.container = container;
		this.pos = pos;
	}

	public function insert(real:AndroidView):Bool {
		var inserted = real.getParent() != container;
		real.setId(pos++);
		var v:android.view.View = cast real;
		container.addView(real);
		return inserted;
	}

	public function delete():Bool {
		if (container != null && pos <= container.getChildCount()) {
			container.removeViewAt(pos);
			container.invalidate();
			return true;
		}
		return false;
	}

	public function step():Bool
		return if (pos >= container.getChildCount()) false; else ++pos == container.getChildCount();

	public function current():AndroidView
		return container.getChildAt(pos);
}

private class AndroidViewBackend implements Applicator<AndroidView> {
	public static var context:Context;

	var counter:Int = 0;

	public function new() {}

	var registry:Map<AndroidView, Rendered<AndroidView>> = new Map();

	public function unsetLastRender(target:AndroidView):Rendered<AndroidView> {
		var ret = registry[cast target];
		registry.remove(target);
		return ret;
	}

	public function setLastRender(target:AndroidView, r:Rendered<AndroidView>):Void
		registry[target] = r;

	public function getLastRender(target:AndroidView):Null<Rendered<AndroidView>>
		return registry[target];

	public function traverseSiblings(target:AndroidView):Cursor<AndroidView>
		return new AndroidViewCursor(cast target.getParent(), cast(target.getParent(), AndroidViewGroup).indexOfChild(target));

	public function traverseChildren(target:AndroidView):Cursor<AndroidView> return new AndroidViewCursor(cast target, 0);

	public function placeholder(forTarget:Widget<AndroidView>):VNode<AndroidView>
		return VNode.native(cast PLACEHOLDER, null, null, null, null);

	static final PLACEHOLDER = new coconut.android.AndroidViewNodeType(() -> {
		var target = new android.view.ViewGroup(ApplicationDelegate.getInstance());
		target.setId(ApplicationDelegate.mainView.getId() - 1);
		return target;
	});
}

class AndroidViewNodeType<Attr:{}, Real:AndroidView> implements NodeType<Attr, Real> {
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
				var i = 0;
				var found = false;
				for (arg in args) {
					var aType = cast(arg, java.lang.Object).getClass();
					// Check types or interfaces against similar primitive Java types
					if (aType == java.lang.Class.forName("java.lang.String")) {
						switch java.util.Arrays.asList(m.getParameterTypes()).get(i).toString() {
							case "interface java.lang.CharSequence" | "class java.lang.String":
								{
									found = m.getParameterCount() == args.length;
								}
							case _:
								found = false;
						}
					} else if (aType == java.lang.Class.forName("java.lang.Integer")) {
						found = m.getParameterCount() == args.length
							&& java.util.Arrays.asList(m.getParameterTypes()).get(i).toString() == "int";
					} else if (aType == java.lang.Class.forName("java.lang.Double")) {
						found = m.getParameterCount() == args.length
							&& java.util.Arrays.asList(m.getParameterTypes()).get(i).toString() == "float";
						if (found)
							arg = java.lang.Float.fromFloat(arg); // = java.util.Arrays.asList(m.getParameterTypes()).get(i)._cast(arg);
					} else if (aType.toString().contains("$")) {
						found = m.getParameterCount() == args.length
							&& java.util.Arrays.asList(m.getParameterTypes()).get(i).toString() == "class haxe.jvm.Function";
						if (!found) {
							found = m.getParameterCount() == args.length && java.util.Arrays.asList(m.getParameterTypes()).contains(aType);
						}
					} else {
						if (m.getParameterCount() == args.length
							&& java.util.Arrays.asList(m.getParameterTypes()).get(i).toString().startsWith("interface")) {
							// wild guess that developer knows what they are doing.
							found = true;
						} else if (m.getParameterCount() == args.length
							&& java.util.Arrays.asList(m.getParameterTypes()).contains(aType)) {
							found = true;
						}
					}
					_params[i] = arg;
					// trace(mName, aType, found, java.util.Arrays.asList(m.getParameterTypes()).get(i));
				}

				if (found) {
					m.invoke(_contextObj, _params);
					break;
				}
			}
		}
	}

	inline function set(target, prop, val, old) {
		try {
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
		} catch (e:java.lang.reflect.InvocationTargetException) {
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
