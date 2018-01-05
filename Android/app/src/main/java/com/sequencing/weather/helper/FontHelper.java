package com.sequencing.weather.helper;


import android.content.Context;
import android.graphics.Typeface;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

public class FontHelper {

    private static final String FONT_TYPE_NAME = "SystemSanFranciscoDisplayThin.ttf";
    private static final String FONT_TYPE_NAME_ULTRALIGHT = "SystemSanFranciscoDisplayUltralight.ttf";
    private static final String FONT_TYPE_NAME_REGULAR = "SystemSanFranciscoDisplayRegular.ttf";
    private static final String FONT_TYPE_NAME_BOLD = "SystemSanFranciscoDisplayBold.ttf";

   public static Typeface getTypeface(Context context){
       return Typeface.createFromAsset(context.getAssets(), FONT_TYPE_NAME);
   }

    public static Typeface getTypefaceUltraLight(Context context){
        return Typeface.createFromAsset(context.getAssets(), FONT_TYPE_NAME_ULTRALIGHT);
    }

    public static Typeface getTypefaceRegular(Context context){
        return Typeface.createFromAsset(context.getAssets(), FONT_TYPE_NAME_REGULAR);
    }

    public static Typeface getTypefaceBold(Context context){
        return Typeface.createFromAsset(context.getAssets(), FONT_TYPE_NAME_BOLD);
    }

    public static void overrideFonts(final View v, Typeface typeface) {
        try {
            if (v instanceof ViewGroup) {
                ViewGroup vg = (ViewGroup) v;
                for (int i = 0; i < vg.getChildCount(); i++) {
                    View child = vg.getChildAt(i);
                    overrideFonts(child,typeface);
                }
            } else if (v instanceof TextView) {
                ((TextView) v).setTypeface(typeface);
            }
        } catch (Exception e) {
        }
    }
}
