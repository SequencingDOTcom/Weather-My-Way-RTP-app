package com.sequencing.weather.helper;

import android.app.Activity;
import android.app.Application;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;

import com.sequencing.weather.activity.StartActivity;

public class LifecycleHandler implements Application.ActivityLifecycleCallbacks {

    private int resumed;
    private int stopped;

    public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
    }

    public void onActivityStarted(Activity activity) {
    }

    public void onActivityResumed(Activity activity) {
        ++resumed;
    }

    public void onActivityPaused(Activity activity) {
    }

    public void onActivityStopped(Activity activity) {
        ++stopped;
        Log.w("LifecycleHandler", "Application is being backgrounded: " + (resumed == stopped));

        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(activity);
        SharedPreferences.Editor editor = settings.edit();

//        boolean isMainActivityCreate = settings.getBoolean("isMainActivityCreate", true);
        if(resumed == stopped) {
            editor.putBoolean("should_refresh", true);
            editor.commit();
        }
    }

    public void onActivityDestroyed(Activity activity) {
    }

    public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
    }
}
