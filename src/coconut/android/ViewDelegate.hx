package coconut.android;

import haxe.ds.Either;

abstract ViewDelegate(Dynamic) from android.view.View from androidx.fragment.app.Fragment to Dynamic to Dynamic {
	@:to inline function to():Dynamic
		return cast this;
}
