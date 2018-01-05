package com.sequencing.weather.logging.listeners;

import android.content.Context;

import com.sequencing.weather.activity.RTPApplication;
import com.sequencing.weather.database.LoggingQueries;
import com.sequencing.weather.logging.events.Usage;
import com.sequencing.weather.logging.events.Event;

import org.greenrobot.eventbus.Subscribe;

import javax.inject.Inject;

public class UsageEventListener {

    private static boolean isUserEventListenerRegistered;
    private Context context;

    public UsageEventListener(Context context){
        this.context = context;
        RTPApplication application = RTPApplication.create(context);
        application.getDaggerComponent().inject(this);
    }

    @Inject
    LoggingQueries loggingQueries;

    @Subscribe
    public void onUsageEvent(Usage usageEvent) {
        loggingQueries.startUsage(usageEvent.start);
    }

    @Subscribe
    public void onAddEvent(Event event) {
        loggingQueries.addEvent(event.timestamp, event.type);
    }

    public void setIsUsageEventListenerRegistered(final boolean registered){
        isUserEventListenerRegistered = registered;
    }

    public boolean isRegistered(){
        return isUserEventListenerRegistered;
    }
}
