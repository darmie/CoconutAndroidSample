package org.me.sampleapp;

import android.widget.LinearLayout;
import coconut.diffing.*;
import coconut.ui.*;
import coconut.android.*;

class AppLauncher {
   public static function mount(parent:LinearLayout):Bool {
        try{
            Renderer.mount(parent, <Isolated><App /></Isolated>);
            return true;
        }catch(e:Dynamic){
            throw e;
            return false;
        }
    }
}