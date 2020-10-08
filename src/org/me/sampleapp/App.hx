package org.me.sampleapp;

import android.view.View.View_OnClickListener;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.view.Gravity;
import coconut.android.View;
import android.view.ViewGroup;
import coconut.android.ApplicationDelegate;
import android.view.LayoutInflater;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import tink.state.*;
import coconut.ui.*;
import tink.core.*;

class BaseFragment extends Fragment {
	@:overload override public function onCreateView(inflater:LayoutInflater, container:ViewGroup, bundle:Bundle) {
		var layout = new LinearLayout(ApplicationDelegate.getInstance());
		return layout;
	}
}

class Text extends View {
	@:attribute var children:String;

	// @:attribute var _children:ObservableArray<String> = new ObservableArray<String>();

	function viewDidMount() {
		// _children.push(children);
	}

	function render()'<TextView text={_children} />';
}

class App extends View implements View_OnClickListener {
	@:attribute var gravity:Int = Gravity.CENTER_HORIZONTAL;

	@:ref var btn:Button;
	@:ref var txt:TextView;

	var counter:Int = 0;
	@:state var counterString:String = '$counter';

	var gdDefault:GradientDrawable = new GradientDrawable();

	function viewDidMount() {
		gdDefault.setColor(0xFFFF0000);
		gdDefault.setCornerRadius(120);
		gdDefault.setStroke(1, 0xFFFF0000);
		btn.setBackground(gdDefault);
	}

	@:keep public function onClick(v:android.view.View) {
		// trace("Button Trigger!!!");
		counter++;
		btn.setText('${counter}');
		counterString = '${counter}';
	}

	@:keep public function detailFragmentInit(f:DetailFragment, v:android.view.View) {
		cast(v, Button).setText("frag!");
	}

	function render()
			<LinearLayout gravity={[gravity]}>
				<BaseFragment>
					<DetailFragment init={detailFragmentInit} />
				</BaseFragment>
				<Button 
					ref=${btn}
					background={[${gdDefault}]}
					backgroundTintList={[ColorStateList.valueOf(0xFFFF0000)]} 
					textColor={[Color.parseColor("#ffffff")]} 
					text={["Click Me!"]}  
					width={[200]}
					height={[200]}
					onClickListener={[this]}
				/>
				<Text>${counterString}</Text>
			</LinearLayout>
		;
}
