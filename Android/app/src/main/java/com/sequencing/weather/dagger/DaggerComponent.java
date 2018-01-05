package com.sequencing.weather.dagger;

import com.sequencing.weather.activity.LocationActivity;
import com.sequencing.weather.activity.MainActivity;
import com.sequencing.weather.activity.PreStartedActivity;
import com.sequencing.weather.logging.listeners.InteractionListener;
import com.sequencing.weather.logging.listeners.RequestEventListener;
import com.sequencing.weather.logging.listeners.UsageEventListener;
import com.sequencing.weather.service.SendLoggingReceiver;
import com.sequencing.weather.service.WeatherSyncReceiver;

import javax.inject.Singleton;

import dagger.Component;

/**
 * Created by omazurova on 2/2/2017.
 */
@Singleton
@Component(modules = {WMWAppModule.class, DatabaseModule.class, IventListenerModule.class})
public interface DaggerComponent {

    void inject(PreStartedActivity preStartedActivity);

    void inject(UsageEventListener usageEvent);

    void inject(InteractionListener interactionListener);

    void inject(RequestEventListener requestEventListener);

    void inject(MainActivity mainActivity);

    void inject(LocationActivity locationActivity);

    void inject(WeatherSyncReceiver weatherSyncReceiver);

    void inject(SendLoggingReceiver sendLoggingReceiver);
}
