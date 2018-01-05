package com.sequencing.weather.logging.listeners;

import android.content.Context;

import com.sequencing.weather.activity.RTPApplication;
import com.sequencing.weather.database.LoggingQueries;
import com.sequencing.weather.logging.events.Request;

import org.greenrobot.eventbus.Subscribe;

import javax.inject.Inject;

/**
 * Created by omazurova on 5/16/2017.
 */

public class RequestEventListener {

    private static boolean isRequestListenerRegistered;
    Context context;

    public RequestEventListener(Context context){
        this.context = context;
        RTPApplication application = RTPApplication.create(context);
        application.getDaggerComponent().inject(this);
    }

    @Inject
    LoggingQueries loggingQueries;

    @Subscribe
    public void onRequest(Request request) {
        loggingQueries.addRequest(request, request.interactionTimestamp);
    }

    public void setIsRequestListenerRegistered(final boolean registered){
        isRequestListenerRegistered = registered;
    }

    public boolean isRegistered(){
        return isRequestListenerRegistered;
    }
}
