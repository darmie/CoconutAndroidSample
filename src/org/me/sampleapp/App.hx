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

@:keepSub
class Text extends View {
	@:keep @:attribute var children:String;

	function render() '<TextView text={[children]} />';
}

@:keepSub
class App extends View implements View_OnClickListener {
	@:ref var btn:Button;
	var counter:Int = 0;
	@:state var counterString:String = '$counter';

	@:ref var mainLayout:LinearLayout;

	@:keep public function onClick(v:android.view.View) {
		counter++;
		btn.setText('${counter}');
		counterString = '${counter}';
	}

	function render()
				'<LinearLayout ref=${mainLayout} layoutParams={[new ViewGroup_LayoutParams(ViewGroup_LayoutParams.MATCH_PARENT, ViewGroup_LayoutParams.MATCH_PARENT)]} orientation={[LinearLayout.VERTICAL]}  gravity={[Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL]}>
					<Button 
						ref=${btn}
						backgroundTintList={[ColorStateList.valueOf(Color.parseColor("#20B2AA"))]} 
						cornerRadius={[400]}
						textColor={[Color.parseColor("#f3f3f3")]} 
						text={["Click Me!"]}  
						layoutParams={[new ViewGroup_LayoutParams(400, 400)]}
						elevation={[50.0]}
						onClickListener={[this]}
					/>
					<Text>${counterString}</Text>
				</LinearLayout>'
		;
}
