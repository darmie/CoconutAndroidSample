package coconut.android.macros;


#if macro
import tink.hxx.*;

class HXX {
  static final generator = new Generator();

  static public function parse(e)
    return coconut.ui.macros.Helpers.parse(e, generator, 'coconut.diffing.VNode.fragment');
}
#end