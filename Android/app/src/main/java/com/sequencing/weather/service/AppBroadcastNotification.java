package com.sequencing.weather.service;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

public class AppBroadcastNotification extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED))
        {
            SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
            boolean isAppExist = settings.getBoolean("isAppLogout", true);
            if(!isAppExist){
                WeatherSyncReceiver syncReceiver = new WeatherSyncReceiver_();
                syncReceiver.setAlarm(context);

                SendLoggingReceiver sendLoggingReceiver = new SendLoggingReceiver_();
                sendLoggingReceiver.setAlarm(context);
            }
        }
    }
}
