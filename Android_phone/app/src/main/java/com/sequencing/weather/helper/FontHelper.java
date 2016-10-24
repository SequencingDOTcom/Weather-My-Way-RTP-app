package com.sequencing.weather.helper;


import android.content.Context;
import android.graphics.Typeface;

public class FontHelper {

    private static final String FONT_TYPE_NAME = "SystemSanFranciscoDisplayThin.ttf";
    private static final String FONT_TYPE_NAME_ULTRALIGHT = "SystemSanFranciscoDisplayUltralight.ttf";

   public static Typeface getTypeface(Context context){
       return Typeface.createFromAsset(context.getAssets(), FONT_TYPE_NAME);
   }

    public static Typeface getTypefaceUltraLight(Context context){
        return Typeface.createFromAsset(context.getAssets(), FONT_TYPE_NAME_ULTRALIGHT);
    }
}
