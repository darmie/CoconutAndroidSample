package coconut.android;


class View {
    static function hxx(_, e)
      return coconut.android.macros.HXX.parse(e);
  
    static function autoBuild()
      return
        coconut.diffing.macros.ViewBuilder.autoBuild(macro : coconut.android.RenderResult);
  }