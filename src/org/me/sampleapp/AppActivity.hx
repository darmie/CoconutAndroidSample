package org.me.sampleapp;

import coconut.android.ApplicationDelegate;
import android.os.Bundle;

class AppActivity extends coconut.android.ApplicationDelegate {
    public static function main(){}

    @:overload override public function onCreate(savedInstanceState:Bundle) {
        super.onCreate(savedInstanceState);
        coconut.android.ApplicationDelegate.instance = this;
        #if (coco_android_debug==0)
        AppLauncher.mount(this.mainView);
        setContentView(this.mainView);
        #end
    }
}