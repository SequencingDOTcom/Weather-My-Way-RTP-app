package com.sequencing.weather.service;

import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.sequencing.weather.helper.NotificationHelper;

public class PushGcmListenerService extends FirebaseMessagingService {

    private static final String TAG = "WeatherGcmListener";

    @Override
    public void onMessageReceived(RemoteMessage push) {
        final String message = push.getData().get("message");
        final String title = "Genetically tailored forecast";

        NotificationHelper.sendNotification(getApplicationContext(), title, message);

        Log.d(TAG, "Notification has been sent");
    }
}
