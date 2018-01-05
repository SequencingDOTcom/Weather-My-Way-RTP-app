package com.sequencing.weather.activity;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.multidex.MultiDex;
import android.support.multidex.MultiDexApplication;
import android.util.Log;

import com.sequencing.weather.dagger.DaggerComponent;
import com.sequencing.weather.dagger.DaggerDaggerComponent;
import com.sequencing.weather.dagger.DatabaseModule;
import com.sequencing.weather.dagger.IventListenerModule;
import com.sequencing.weather.dagger.WMWAppModule;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.LifecycleHandler;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class RTPApplication extends MultiDexApplication {
    private DaggerComponent daggerComponent;

    @Override
    public void onCreate() {
        super.onCreate();
        // Simply add the handler, and that's it! No need to add any code
        // to every activity. Everything is contained in MyLifecycleHandler
        // with just a few lines of code. Now *that's* nice.
        registerActivityLifecycleCallbacks(new LifecycleHandler());
        daggerComponent = DaggerDaggerComponent.builder()
                .wMWAppModule(new WMWAppModule(this))
                .iventListenerModule(new IventListenerModule(getApplicationContext()))
                .databaseModule(new DatabaseModule(getApplicationContext()))
                .build();

    }

    public DaggerComponent getDaggerComponent(){
        return daggerComponent;
    }

    @Override
    protected void attachBaseContext(Context base)
    {
        super.attachBaseContext(base);
        MultiDex.install(RTPApplication.this);
    }

    public static RTPApplication create(Context context) {
        return (RTPApplication) context.getApplicationContext();
    }
}