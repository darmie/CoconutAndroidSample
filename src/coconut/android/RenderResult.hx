package coconut.android;

import coconut.diffing.VNode;
import android.view.View as AndroidView;
import androidx.fragment.app.Fragment as AndroidFragment;
import haxe.ds.Either;


// typedef RenderResult = coconut.diffing.VNode<Dynamic>;
@:pure
@:keepSub
abstract RenderResult(VNode<AndroidView>) to VNode<AndroidView> from VNode<AndroidView> {
	inline function new(n) {
		this = n;
	}

	@:from static function ofNode(n:AndroidView):RenderResult {
		return VNativeInst(n);
	}

    // @:from static function ofNode1(n:AndroidFragment):RenderResult {
	// 	return VNativeInst(n);
	// }

	@:from static function ofView(v:View):RenderResult {
		return VWidgetInst(v);
	}
}