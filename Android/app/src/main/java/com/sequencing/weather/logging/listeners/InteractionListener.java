package com.sequencing.weather.logging.listeners;

import android.content.Context;

import com.sequencing.weather.activity.RTPApplication;
import com.sequencing.weather.database.LoggingQueries;
import com.sequencing.weather.logging.events.Interaction;
import com.sequencing.weather.logging.events.UpdateInteraction;

import org.greenrobot.eventbus.Subscribe;

import javax.inject.Inject;

/**
 * Created by omazurova on 5/16/2017.
 */

public class InteractionListener {

    private static boolean isInteractionListenerRegistered;
    Context context;

    public InteractionListener (Context context){
        this.context = context;
        RTPApplication application = RTPApplication.create(context);
        application.getDaggerComponent().inject(this);
    }

    @Inject
    LoggingQueries loggingQueries;

    @Subscribe
    public void onInteraction(Interaction interaction) {
        loggingQueries.addInteraction(interaction);
    }

    @Subscribe
    public void updateInteraction(UpdateInteraction interaction) {
        loggingQueries.updateInteractionDurationByTimestamp(interaction.ts, interaction.duration);
    }

    public void setIsInteractionListenerRegistered(final boolean registered){
        isInteractionListenerRegistered = registered;
    }

    public boolean isRegistered(){
        return isInteractionListenerRegistered;
    }
}
