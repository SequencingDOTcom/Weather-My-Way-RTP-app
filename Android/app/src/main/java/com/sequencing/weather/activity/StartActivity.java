package com.sequencing.weather.activity;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.Typeface;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.design.widget.CoordinatorLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.appindexing.Thing;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.gson.Gson;
import com.google.gson.JsonParseException;
import com.google.gson.annotations.SerializedName;
import com.sequencing.androidoauth.core.ISQAuthCallback;
import com.sequencing.androidoauth.core.OAuth2Parameters;
import com.sequencing.androidoauth.core.SQUIoAuthHandler;
import com.sequencing.androidoauth.core.registration.SQRegistrationHandler;
import com.sequencing.oauth.config.AuthenticationParameters;
import com.sequencing.oauth.core.SequencingOAuth2Client;
import com.sequencing.oauth.core.Token;
import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.AccountHelper;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.InternalStorage;
import com.sequencing.weather.helper.TimezoneHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;
import com.sequencing.weather.logging.listeners.UsageEventListener;
import com.sequencing.weather.service.RegistrationIntentService;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.Touch;
import org.androidannotations.annotations.UiThread;
import org.androidannotations.annotations.ViewById;
import org.androidannotations.annotations.WindowFeature;
import org.greenrobot.eventbus.EventBus;
//import org.androidannotations.rest.spring.annotations.RestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.Executors;

import javax.inject.Inject;

@WindowFeature(Window.FEATURE_NO_TITLE)
@EActivity(R.layout.activity_start)
public class StartActivity extends AppCompatActivity implements ISQAuthCallback {

    private SQUIoAuthHandler ioAuthHandler;
    private SharedPreferences settings;
    private static final String TAG = "StartActivity";
    private GoogleApiClient client;

    @ViewById(R.id.rootLayout)
    CoordinatorLayout rootLayout;

    @ViewById(R.id.toolbar)
    Toolbar toolbar;

    @ViewById(R.id.btnLogin)
    ImageButton btnLogin;

    @ViewById(R.id.tvAppName)
    TextView tvAppName;

    @ViewById(R.id.tvAppSubName)
    TextView tvAppSubName;

    @ViewById(R.id.tvRegisterAccount)
    TextView tvRegisterAccount;

    @ViewById(R.id.video_view)
    CVideoView videoView;

    @ViewById(R.id.llAboutView)
    LinearLayout llAboutView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        Intent registrationIntent = new Intent(this, RegistrationIntentService.class);
        startService(registrationIntent);

        settings = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("client_secret", "client_secret_сode");
        editor.putBoolean("load_app", true);
        editor.commit();
        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();
    }

    @AfterViews
    public void initViews() {
        setSupportActionBar(toolbar);
        Typeface typeface = FontHelper.getTypefaceRegular(this);
        FontHelper.overrideFonts(rootLayout, typeface);
        AuthenticationParameters parameters = new AuthenticationParameters.ConfigurationBuilder()
                .withRedirectUri("wmw://login")
                .withClientId("Weather My Way (Android)")
                .withMobileMode("1")
                .withClientSecret("client_secret_сode")
                .build();

        ioAuthHandler = new SQUIoAuthHandler(this);
        ioAuthHandler.authenticate(btnLogin, this, parameters);
    }

    @Click(R.id.llAboutView)
    public void onAboutClick() {
        Log.i(TAG, "Start AboutActivity");
        Intent intent = new Intent(getApplicationContext(), AboutActivity_.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getApplicationContext().startActivity(intent);
    }

    @Touch(R.id.llAboutView)
    public boolean onAboutTouch(View v, MotionEvent event) {
        final TextView textView = (TextView) llAboutView.getChildAt(1);
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                textView.setTextColor(getResources().getColor(R.color.colorAccent));
                break;

            case MotionEvent.ACTION_UP:
                textView.setTextColor(getResources().getColor(android.R.color.white));
                break;
        }
        return false;
    }

    @Override
    protected void onResume() {
        super.onResume();
        init();
        playVideo();
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onStop() {
        super.onStop();// ATTENTION: This was auto-generated to implement the App Indexing API.
// See https://g.co/AppIndexing/AndroidStudio for more information.
        AppIndex.AppIndexApi.end(client, getIndexApiAction());
        stopVideo();
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client.disconnect();
    }

    private void init() {
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mp.setLooping(true);
                videoView.setOnCorrectVideoDimensions(getCorrectVideoDimensions());

                mp.setOnVideoSizeChangedListener(new MediaPlayer.OnVideoSizeChangedListener() {
                    public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
                        videoView.onVideoSizeChanged(mp);
                    }
                });
            }
        });
    }

    private void playVideo() {
        int orientation = getResources().getConfiguration().orientation;
        if (orientation == Configuration.ORIENTATION_PORTRAIT) {
            videoView.setAlignment(CVideoView.ALIGN_WIDTH);
        } else {
            videoView.setAlignment(CVideoView.ALIGN_NONE);
        }
        videoView.setVisibility(View.VISIBLE);
        String videoName = VideoGeneratorHelper.getVideo(this);
        String videoNameWithoutExtension = videoName.split("\\.")[0];
        int raw_id = getResources().getIdentifier(videoNameWithoutExtension, "raw", getPackageName());
        String path = "android.resource://" + getPackageName() + "/" + raw_id;
        videoView.setVideoURI(Uri.parse(path));
        videoView.start();
    }

    private void stopVideo() {
        videoView.stopPlayback();
        videoView.setVisibility(View.GONE);
    }

    /**
     * Adjust video layout according to video dimensions
     */
    private CVideoView.OnCorrectVideoDimensions getCorrectVideoDimensions() {
        return new CVideoView.OnCorrectVideoDimensions() {
            @Override
            public void correctDimensions(int width, int height) {
                AppUIHelper.resizeLayout(videoView, height, width, 300, null);
            }
        };
    }

    @Override
    public void onAuthentication(Token token) {
        Log.i(TAG, "User has been authenticated");

        SequencingOAuth2Client oAuth2Client = OAuth2Parameters.getInstance().getOauth();

        try {
            InternalStorage.writeObject(getBaseContext(), "oAuth2Client", oAuth2Client);
            InstancesContainer.setoAuth2Client(oAuth2Client);
        } catch (IOException e) {
            Log.e(TAG, "Unable to write SequencingOAuth2Client instance to Android internal storage");
        }

        try {
            refreshSettings(this, InstancesContainer.getoAuth2Client().getToken());
        } catch (Exception e) {
            showErrorRefreshSettings();
            e.printStackTrace();
        }

        // Set connected account
        Executors.newSingleThreadExecutor().submit(new Runnable() {
            @Override
            public void run() {
                SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
                settings.edit().putString("email", AccountHelper.getUserEmail(InstancesContainer.getoAuth2Client().getToken().getAccessToken())).commit();
            }
        });

        settings.edit().putBoolean("isAppLogout", false).commit();

        Intent intent = new Intent(this, MainActivity_.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
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

    @Override
    public void onFailedAuthentication(Exception e) {
        Toast.makeText(this, "Server error. Failure to authenticate user", Toast.LENGTH_LONG).show();
        Log.w(TAG, "Server error. Failure to authenticate user", e);

        Intent intent = new Intent(getApplicationContext(), StartActivity_.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getApplicationContext().startActivity(intent);
    }

    @Click(R.id.tvRegisterAccount)
    public void onRegisterClick() {
        initRegistrationDialog();
    }

    private void initRegistrationDialog() {
        String secretCode = settings.getString("client_secret", null);
        SQRegistrationHandler sqRegistrationHandler = new SQRegistrationHandler(this);
        sqRegistrationHandler.registerResetAccount(tvRegisterAccount, secretCode);
    }

    public static void refreshSettings(Context context, Token token) throws Exception {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);

        String url = "https://weathermyway.rocks/ExternalSettings/RetrieveUserSettings";
        Map<String, String> params = new HashMap<>(9);

        params.put("accessToken", token.getAccessToken());
        params.put("expiresIn", String.valueOf(token.getLifeTime()));
        params.put("tokenType", "Bearer");
        params.put("scope", "external");
        params.put("refreshToken", token.getRefreshToken());
        params.put("deviceType", String.valueOf(2));
        params.put("appVersion", RegistrationIntentService.getAppVersion(context));

        if (settings.getBoolean("push_daily_forecast", true) == true) {
            params.put("newDeviceToken", settings.getString("newDeviceToken", null));
            params.put("oldDeviceToken", settings.getString("oldDeviceToken", null));
            params.put("sendPush", "true");
        } else {
            params.put("newDeviceToken", null);
            params.put("oldDeviceToken", null);
            params.put("sendPush", "false");
        }

        String response = HttpHelper.doPost(url, null, params);

        if (response != null) {
            SettingsEntity responseEntity;
            try {
                responseEntity = new Gson().fromJson(response, SettingsEntity.class);
            } catch (JsonParseException | IllegalStateException e){
                throw e;
            }
            Map<String, Object> data = responseEntity.getData();

            if (data == null || data.size() == 0)
                return;

            SharedPreferences.Editor editor = settings.edit();
            editor.putString("email_address", (String) data.get("UserEmail"));
            editor.putString("username", data.get("UserName").toString());
            editor.putString("phone_number", (String) data.get("UserPhone"));
            if (data.get("SendEmail") == null) {
                editor.putBoolean("email_daily_forecast", (Boolean) Boolean.valueOf((String) data.get("SendEmail")));
            } else {
                editor.putBoolean("email_daily_forecast", (Boolean) data.get("SendEmail"));
            }

            if (data.get("SendSms") == null) {
                editor.putBoolean("text_daily_forecast", Boolean.valueOf((String) data.get("SendSms")));
            } else {
                editor.putBoolean("text_daily_forecast", (Boolean) data.get("SendSms"));
            }
            editor.putString("genetic_data_file", (String) data.get("DataFileName"));
            editor.putString("genetic_file_id", (String) data.get("DataFileId"));
            editor.putString("wake_up_weekdays", (String) data.get("TimeWeekDay"));
            editor.putString("wake_up_weekends", (String) data.get("TimeWeekEnd"));
            String weekendNotifications = context.getResources().getStringArray(R.array.weekend_notifications_values)[((Double) (data.get("WeekendMode"))).intValue()];
            editor.putString("weekend_notifications", weekendNotifications);
            String tempDate;
            if (data.get("Temperature") != null) {
                tempDate = data.get("Temperature").toString();
            } else {
                tempDate = (String) data.get("Temperature");
            }
            String temp = tempDate == null ? context.getResources().getStringArray(R.array.temperature_units)[0] :
                    context.getResources().getStringArray(R.array.temperature_units)[((Double) (data.get("Temperature"))).intValue()];
            editor.putString("temperature", temp);
            if (data.get("TimeZoneValue") != null) {
                String timezone = TimezoneHelper.getTimezoneById(TimeZone.getTimeZone((String) data.get("TimeZoneValue")));
                editor.putString("timezone", timezone);
            }

            editor.commit();
        }

        Log.i(TAG, "Settings has been refreshed");
    }

    public Action getIndexApiAction() {
        Thing object = new Thing.Builder()
                .setName("Start Page") // TODO: Define a title for the content shown.
                // TODO: Make sure this auto-generated URL is correct.
                .setUrl(Uri.parse("http://[ENTER-YOUR-URL-HERE]"))
                .build();
        return new Action.Builder(Action.TYPE_VIEW)
                .setObject(object)
                .setActionStatus(Action.STATUS_TYPE_COMPLETED)
                .build();
    }

    @Override
    public void onStart() {
        super.onStart();
        client.connect();
        AppIndex.AppIndexApi.start(client, getIndexApiAction());
    }

    public class SettingsEntity {

        @SerializedName("Data")
        private Map<String, Object> data;

        public Map<String, Object> getData() {
            return data;
        }

        public void setData(Map<String, Object> data) {
            this.data = data;
        }
    }
}
