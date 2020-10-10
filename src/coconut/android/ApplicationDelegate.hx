package coconut.android;

import android.os.Bundle;
import androidx.fragment.app.FragmentActivity;
import android.widget.LinearLayout;
import coconut.diffing.*;
import coconut.ui.*;
import android.view.Gravity;
import android.view.ViewGroup.ViewGroup_LayoutParams;
import android.util.DisplayMetrics;
import coconut.android.Isolated;
using coconut.android.Util;



class ApplicationDelegate extends FragmentActivity {
	public static var instance:ApplicationDelegate;

	public var mainView:LinearLayout;

	public static function getInstance() {
		return instance;
	}

	@:overload override public function onCreate(savedInstanceState:Bundle) {
		super.onCreate(savedInstanceState);
        instance = this;

        var displayMetrics = new DisplayMetrics();
		getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
		var height = displayMetrics.heightPixels;
        var width = displayMetrics.widthPixels;

        mainView = new LinearLayout(this);
        mainView.setId(1);
        mainView.setTag("CoconutAndroidMain");
        mainView.setLayoutParams(new ViewGroup_LayoutParams(width, height));
        var G = Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL;
        mainView.setGravity(G);
        #if (coco_android_debug==1)
        setContentView(mainView);
        var fragmentManager = getSupportFragmentManager();
        var trans = fragmentManager.beginTransaction();
        trans.add(mainView.getId(), new HostFragment());
        trans.commit();
        #end
	}
}
