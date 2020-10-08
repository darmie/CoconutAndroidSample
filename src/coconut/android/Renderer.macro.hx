package coconut.android;

class Renderer {
	static public function hxx(e) {
		return coconut.android.macros.HXX.parse(e);
	}

	static function mount(target, markup) {
		return coconut.ui.macros.Helpers.mount(macro coconut.android.Renderer.mountInto, target, markup, hxx);
	}
}