package org.me.sampleapp;

import android.view.View.View_OnClickListener;
import com.google.android.material.button.MaterialButton as Button;
import android.widget.LinearLayout;
import android.view.ViewGroup.ViewGroup_LayoutParams;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.view.Gravity;
import coconut.android.View;
import android.view.ViewGroup;
import coconut.android.ApplicationDelegate;
import android.view.LayoutInflater;
import android.os.Bundle;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import tink.state.*;
import coconut.ui.*;
import tink.core.*;

class Text extends View {
	@:attribute var children:String;

	function render() <TextView text={[children]} />;
}

class App extends View implements View_OnClickListener {
	// @:attribute var gravity:Int = Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL;
	@:ref var btn:Button;
	var counter:Int = 0;
	@:state var counterString:String = '$counter';

	@:ref var mainLayout:LinearLayout;

	@:keep public function onClick(v:android.view.View) {
		// trace("Button Trigger!!!");
		counter++;
		btn.setText('${counter}');
		counterString = '${counter}';
	}

	function render()
				<LinearLayout ref=${mainLayout} layoutParams={[new ViewGroup_LayoutParams(ViewGroup_LayoutParams.MATCH_PARENT, ViewGroup_LayoutParams.MATCH_PARENT)]} orientation={[LinearLayout.VERTICAL]}  gravity={[Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL]}>
					<Button 
						ref=${btn}
						backgroundTintList={[ColorStateList.valueOf(0xFFFF0000)]} 
						cornerRadius={[40]}
						textColor={[Color.parseColor("#ffffff")]} 
						text={["Click Me!"]}  
						layoutParams={[new ViewGroup_LayoutParams(400, 400)]}
						elevation={[50.0]}
						onClickListener={[this]}
					/>
					<Text>${counterString}</Text>
				</LinearLayout>
		;
}
