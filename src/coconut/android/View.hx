package coconut.android;


@:build(coconut.ui.macros.ViewBuilder.build((_:coconut.android.RenderResult)))
@:autoBuild(coconut.android.View.autoBuild())
class View extends coconut.diffing.Widget<android.view.View> {
  macro function hxx(e);
}