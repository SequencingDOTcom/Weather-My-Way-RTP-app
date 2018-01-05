package com.sequencing.weather.activity;

import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import com.google.android.gms.appindexing.AppIndex;
import com.sequencing.oauth.core.DefaultSequencingOAuth2Client;
import com.sequencing.oauth.core.Token;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.AccountHelper;
import com.sequencing.weather.helper.ConnectionHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.InternalStorage;
import com.sequencing.weather.logging.EventEntity;
import com.sequencing.weather.logging.events.Event;
import com.sequencing.weather.logging.listeners.UsageEventListener;
import com.sequencing.weather.service.RegistrationIntentService;
import com.sequencing.weather.service.SendLoggingReceiver_;

import org.androidannotations.annotations.Background;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.UiThread;
import org.greenrobot.eventbus.EventBus;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.concurrent.Executors;

import javax.inject.Inject;

@EActivity(R.layout.activity_prestarted)
public class PreStartedActivity extends AppCompatActivity {

    private Intent secondActivity;
    private static final String TAG = "PreStartedActivity";
    private int countRetryAttempts = 5;
    private static int APPLICATION_INSTALLED_EVENT_TYPE = 0;

    @Inject
    UsageEventListener usageEventListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ((RTPApplication)this.getApplicationContext()).getDaggerComponent().inject(this);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        Intent registrationIntent = new Intent(this, RegistrationIntentService.class);
        startService(registrationIntent);

        if(!ConnectionHelper.isConnectionAvailable(this)) {
            showException("Check your internet connection and try again");
            finish();
            return;
        }


        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean("load_app", true).commit();

        boolean isFirstLoadApp = settings.getBoolean("firstLoadApp", true);
        if(isFirstLoadApp){
            if(!usageEventListener.isRegistered()){
                EventBus.getDefault().register(usageEventListener);
                usageEventListener.setIsUsageEventListenerRegistered(true);
                Event event = new Event();
                event.timestamp = System.currentTimeMillis();
                event.type = APPLICATION_INSTALLED_EVENT_TYPE;
                usageEventListener.onAddEvent(event);
            }
            editor.putBoolean("firstLoadApp", false).commit();
        }
        refreshToken();
        setLogReportingSync();
    }

    private void setLogReportingSync() {
        if (!SendLoggingReceiver_.checkAlarmIsSet(this)) {
            SendLoggingReceiver_.setAlarm(this);
        }
    }

    @Override
    public void onRequestPermissionsResult(int permsRequestCode, String[] permissions, int[] grantResults){
        switch(permsRequestCode){
            case 200:
                boolean audioAccepted = grantResults[0]==PackageManager.PERMISSION_GRANTED;
                boolean cameraAccepted = grantResults[1]==PackageManager.PERMISSION_GRANTED;
                break;
        }
    }

    @Background
    public void refreshToken(){
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        DefaultSequencingOAuth2Client oAuth2Client = null;
        try {
            oAuth2Client = (DefaultSequencingOAuth2Client) InternalStorage.readObject(getApplicationContext(), "oAuth2Client");

            if (oAuth2Client != null && oAuth2Client.isAuthorized()) {
                InstancesContainer.setoAuth2Client(oAuth2Client);
                InternalStorage.writeObject(getApplicationContext(), "oAuth2Client", oAuth2Client);

                secondActivity = new Intent(getApplicationContext(), MainActivity_.class);
                secondActivity.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            }
        } catch (FileNotFoundException e) {
            Log.e(TAG, "Unable to read SequencingOAuth2Client instance from Android internal storage");
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            retryRequestWithDelay();
            return;
        }

        if (oAuth2Client == null || !oAuth2Client.isAuthorized()) {
            secondActivity = new Intent(getApplicationContext(), StartActivity_.class);
            secondActivity.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            getApplicationContext().startActivity(secondActivity);
        }

        Token token = null;
        if (oAuth2Client != null) {
            token = InstancesContainer.getoAuth2Client().getToken();
            long timeDifference = System.currentTimeMillis() - token.getLastRefreshDate().getTime();
            while (token.getLastRefreshDate() == null || timeDifference > (token.getLifeTime() * 1000)) {
                token = InstancesContainer.getoAuth2Client().getToken();
                timeDifference = System.currentTimeMillis() - InstancesContainer.getoAuth2Client().getToken().getLastRefreshDate().getTime();
            }
        }
        getEmail();
    }

    @UiThread
    void retryRequestWithDelay(){
        if(countRetryAttempts > 0){
            countRetryAttempts = countRetryAttempts - 1;
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    refreshToken();
                }
            }, 3000);
        } else {
            showException("Please, try again later!");
        }
    }

    @UiThread
    public void getEmail(){
        DefaultSequencingOAuth2Client oAuth2Client = null;
        try {
            oAuth2Client = (DefaultSequencingOAuth2Client) InternalStorage.readObject(getApplicationContext(), "oAuth2Client");
        } catch (IOException e) {
            Log.e(TAG, "Unable to read SequencingOAuth2Client instance from Android internal storage");
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }

        if(oAuth2Client != null) {
            // Set connected account
            Executors.newSingleThreadExecutor().submit(new Runnable() {
                @Override
                public void run() {
                    SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
                    settings.edit().putString("email", AccountHelper.getUserEmail(InstancesContainer.getoAuth2Client().getToken().getAccessToken())).commit();
                }
            });

            try {
                StartActivity.refreshSettings(getApplicationContext(), InstancesContainer.getoAuth2Client().getToken());
            } catch (Exception e) {
                showErrorRefreshSettings();
                e.printStackTrace();
            }
            getApplicationContext().startActivity(secondActivity);
        }
    }

    @UiThread
    protected void showErrorRefreshSettings() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(this);
        builder.setTitle("Sorry, there was an error while getting data")
                .setMessage("Please, try again later")
                .setCancelable(false)
                .setPositiveButton("Ok",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                finish();
                                dialog.cancel();
                            }
                        });
        android.app.AlertDialog alert = builder.create();
        alert.show();
    }

    @UiThread
    void showException(String error){
        Toast.makeText(this, error, Toast.LENGTH_LONG).show();
    }

    @Override
    public void onStop() {
        super.onStop();
        EventBus.getDefault().unregister(usageEventListener);
        usageEventListener.setIsUsageEventListenerRegistered(false);
    }
}
