package com.sequencing.weather.service;

import android.app.IntentService;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
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
import com.sequencing.weather.helper.TimezoneHelper;
import com.sequencing.weather.logging.EventEntity;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

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
        params.put("appVersion", getAppVersion(context));

        final String url = "https://weathermyway.rocks//ExternalSettings/SubscribePushNotification";

        String response = HttpHelper.doPost(url, null, params);

        Log.i(TAG, "Push check has been sent to server: " + response);
    }

    public static String getAppVersion(Context context) {
        PackageManager manager = context.getPackageManager();
        PackageInfo info = null;
        try {
            info = manager.getPackageInfo(context.getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return info.versionName;
    }

    public static void sendSettingsToServer(final Context context) {
        ExecutorService service = Executors.newSingleThreadExecutor();

        Runnable run = new Runnable() {
            @Override
            public void run() {
                SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
                String currentTimezone = TimezoneHelper.getTimezoneById(TimeZone.getDefault());

                Map<String, String> params = new HashMap<>(12);
                params.put("temperature", settings.getString("temperature", "C"));
                params.put("emailChk", String.valueOf(settings.getBoolean("email_daily_forecast", false)));
                params.put("email", settings.getString("email_address", null));
                params.put("smsChk", String.valueOf(settings.getBoolean("text_daily_forecast", false)));
                params.put("phone", settings.getString("phone_number", null));
                params.put("wakeupDay", settings.getString("wake_up_weekdays", null));
                params.put("wakeupEnd", settings.getString("wake_up_weekends", null));
                params.put("timezoneSelect", settings.getString("timezone", currentTimezone).split("\\) ")[1]);

                String timezoneOffset = settings.getString("timezone", currentTimezone).substring(4).split("\\) ")[0];
                if(timezoneOffset.split(":")[1].contains(":3"))
                    timezoneOffset = String.format("%s.5", timezoneOffset.split(":")[0]);
                else
                    timezoneOffset = String.format("%s.0", timezoneOffset.split(":")[0]);

                params.put("timezoneOffset", timezoneOffset);
                params.put("weekendMode", settings.getString("weekend_notifications", "None"));
                params.put("token", InstancesContainer.getoAuth2Client().getToken().getAccessToken());

                String url = "https://weathermyway.rocks/ExternalSettings/ChangeNotification";
                String response = HttpHelper.doPost(url, null, params);
                String s = "dd";
                Log.i(TAG, "Settings have been sent to server");
            }
        };
        service.submit(run);
    }
}

