package org.me.sampleapp;

import androidx.fragment.app.Fragment;
import android.widget.Button;
import android.view.ViewGroup;
import coconut.android.ApplicationDelegate;
import android.view.LayoutInflater;
import android.os.Bundle;

class DetailFragment extends Fragment {
    public var init:DetailFragment->android.view.View->Void;

	@:overload override public function onCreateView(inflater:LayoutInflater, container:ViewGroup, bundle:Bundle) {
        var btn = new Button(ApplicationDelegate.getInstance());
        if(init != null){
            init(this, btn);
        }
		return btn;
    }

    @:keep public function setInit(callback:DetailFragment->android.view.View->Void){
        init = callback;
    }
}