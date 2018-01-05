package com.sequencing.weather.service;

import android.content.Intent;

import com.google.firebase.iid.FirebaseInstanceIdService;

public class FireBaseInstanceIDListenerService extends FirebaseInstanceIdService {

    public void onTokenRefresh() {
        Intent intent = new Intent(this, RegistrationIntentService.class);
        startService(intent);
    }

}