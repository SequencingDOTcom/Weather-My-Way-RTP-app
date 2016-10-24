package com.sequencing.weather.service;

import android.app.IntentService;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.google.android.gms.gcm.GcmPubSub;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;
import com.google.firebase.iid.FirebaseInstanceId;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class RegistrationIntentService extends IntentService {

    private static final String TAG = "RegIntentService";
    public static final String REGISTRATION_COMPLETE = "registrationComplete";

    public RegistrationIntentService() {
        super(TAG);
    }

    public void onCreate() {
        super.onCreate();
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(this);

        String deviceToken = FirebaseInstanceId.getInstance().getToken();
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("oldDeviceToken", settings.getString("newDeviceToken", null));
        editor.putString("newDeviceToken", deviceToken);
        editor.commit();

        Intent registrationComplete = new Intent(REGISTRATION_COMPLETE);
        LocalBroadcastManager.getInstance(this).sendBroadcast(registrationComplete);
    }

    /**
     * Persist registration to third-party servers.
     *
     * Modify this method to associate the user's GCM registration token with any server-side account
     * maintained by your application.
     */
    public static void sendRegistrationToServer(Context context) {
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
        final Map<String, String> params = new HashMap<>(4);
        params.put("pushCheck", String.valueOf(settings.getBoolean("push_daily_forecast", true)));
        params.put("deviceToken", settings.getString("newDeviceToken", null));
        params.put("deviceType", "2");
        params.put("accessToken", String.valueOf(InstancesContainer.getoAuth2Client().getToken().getAccessToken()));

        final String url = "https://weathermyway.rocks//ExternalSettings/SubscribePushNotification";

        String response = HttpHelper.doPost(url, null, params);

        Log.i(TAG, "Push check has been sent to server: " + response);
    }
}

