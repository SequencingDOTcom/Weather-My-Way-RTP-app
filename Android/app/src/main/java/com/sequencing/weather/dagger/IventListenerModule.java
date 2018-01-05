package com.sequencing.weather.dagger;

import android.content.Context;

import com.sequencing.weather.logging.listeners.InteractionListener;
import com.sequencing.weather.logging.listeners.RequestEventListener;
import com.sequencing.weather.logging.listeners.UsageEventListener;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;

@Module
public class IventListenerModule {

    Context context;

    public IventListenerModule(Context context){
        this.context = context;
    }

    @Provides
    @Singleton
    InteractionListener interactionListener(){
        return new InteractionListener(context);
    }

    @Provides
    @Singleton
    RequestEventListener requestEventListener(){
        return new RequestEventListener(context);
    }

    @Provides
    @Singleton
    UsageEventListener usageEventListener(){
        return new UsageEventListener(context);
    }





}
