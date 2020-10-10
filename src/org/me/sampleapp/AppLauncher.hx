package org.me.sampleapp;

import coconut.diffing.*;
import coconut.ui.*;
import coconut.android.*;

class AppLauncher {
   @:keep public static function mount(parent:android.view.View):Bool {
        try{
            trace(parent);
            Renderer.mount(parent, <Isolated><App /></Isolated>);
            return true;
        }catch(e:Dynamic){
            throw e;
            return false;
        }
    }
}