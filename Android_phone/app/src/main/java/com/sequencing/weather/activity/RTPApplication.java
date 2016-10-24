package com.sequencing.weather.activity;

import android.app.Application;

import com.sequencing.weather.helper.LifecycleHandler;

public class RTPApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        // Simply add the handler, and that's it! No need to add any code
        // to every activity. Everything is contained in MyLifecycleHandler
        // with just a few lines of code. Now *that's* nice.
        registerActivityLifecycleCallbacks(new LifecycleHandler());
    }
}