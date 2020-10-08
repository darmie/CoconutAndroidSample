package coconut.android;

import android.os.Bundle;
import androidx.fragment.app.FragmentActivity;
import android.widget.LinearLayout;
import coconut.diffing.*;
import coconut.ui.*;
import android.view.Gravity;


import org.me.sampleapp.App;

class ApplicationDelegate extends FragmentActivity {
    static var instance:ApplicationDelegate;

    public static var mainView:LinearLayout;

    public static function getInstance(){
        return instance;
    }

    @:overload override public function onCreate(savedInstanceState:Bundle){
        super.onCreate(savedInstanceState);
        instance = this;
        mainView = new LinearLayout(this); 
        mainView.setId(1);
        mainView.setTag("CoconutAndroidMain");
        Renderer.mount(mainView, '<App gravity={Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL} />');
        mainView.setGravity(Gravity.CENTER_HORIZONTAL|Gravity.CENTER_VERTICAL);
        setContentView(mainView);
    }
}