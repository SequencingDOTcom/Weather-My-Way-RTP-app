package com.sequencing.weather.activity;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.method.LinkMovementMethod;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.annotations.SerializedName;
import com.sequencing.androidoauth.core.ISQAuthCallback;
import com.sequencing.androidoauth.core.OAuth2Parameters;
import com.sequencing.androidoauth.core.SQUIoAuthHandler;
import com.sequencing.oauth.config.AuthenticationParameters;
import com.sequencing.oauth.core.DefaultSequencingOAuth2Client;
import com.sequencing.oauth.core.SequencingOAuth2Client;
import com.sequencing.oauth.core.Token;
import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.entity.AccountEntity;
import com.sequencing.weather.helper.AccountHelper;
import com.sequencing.weather.helper.ConnectionHelper;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.InternalStorage;
import com.sequencing.weather.helper.TimeHelper;
import com.sequencing.weather.helper.TimezoneHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;
import com.sequencing.weather.service.RegistrationIntentService;

import org.w3c.dom.Text;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class StartActivity extends AppCompatActivity implements ISQAuthCallback, View.OnClickListener{

    private ImageButton btnLogin;
    private SQUIoAuthHandler ioAuthHandler;
    private CVideoView videoView;
    private TextView tvRegisterAccount;
    private SharedPreferences settings;

    private static final String TAG = "StartActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_start);

        Intent registrationIntent = new Intent(this, RegistrationIntentService.class);
        startService(registrationIntent);

        settings = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean("load_app", true).commit();

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        btnLogin = (ImageButton) findViewById(R.id.btnLogin);

        tvRegisterAccount = (TextView) findViewById(R.id.tvRegisterAccount);
        tvRegisterAccount.setMovementMethod(LinkMovementMethod.getInstance());
//        tvRegisterAccount.setTypeface(FontHelper.getTypeface(this));
        tvRegisterAccount.setOnClickListener(this);

        TextView tvAppName = (TextView) findViewById(R.id.tvAppName);
        tvAppName.setTypeface(FontHelper.getTypeface(this));
        TextView tvAppSubName = (TextView) findViewById(R.id.tvAppSubName);
        tvAppSubName.setTypeface(FontHelper.getTypeface(this));

        videoView = (CVideoView) findViewById(R.id.video_view);

        AuthenticationParameters parameters = new AuthenticationParameters.ConfigurationBuilder()
                .withRedirectUri("wmw://login")
                .withClientId("Client ID") // here is your client id
                .withMobileMode("1")
                .withClientSecret("Client Secret") // here is your client secret
                .build();

        ioAuthHandler = new SQUIoAuthHandler(this);
        ioAuthHandler.authenticate(btnLogin, this, parameters);

        final LinearLayout llAboutView = (LinearLayout) findViewById(R.id.llAboutView);
        final TextView textView = (TextView)llAboutView.getChildAt(1);
        llAboutView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
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
        });
        llAboutView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.i(TAG, "Start AboutActivity");

                Intent intent = new Intent(getApplicationContext(), AboutActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(intent);
            }
        });
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
        videoView.setVisibility(View.VISIBLE);
        String videoName = VideoGeneratorHelper.getVideo(this);
        videoView.setVideoURI(Uri.parse(videoName));
        videoView.start();
        videoView.setAlignment(CVideoView.ALIGN_WIDTH);
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
                AppUIHelper.resizeLayout(videoView, height, -1, 300, null);
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

        refreshSettings(this, InstancesContainer.getoAuth2Client().getToken());

        // Set connected account
        Executors.newSingleThreadExecutor().submit(new Runnable() {
            @Override
            public void run() {
                SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
                settings.edit().putString("email", AccountHelper.getUserEmail(InstancesContainer.getoAuth2Client().getToken().getAccessToken())).commit();
            }
        });

        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
    }

    @Override
    public void onFailedAuthentication(Exception e) {
        Toast.makeText(this, "Server error. Failure to authenticate user", Toast.LENGTH_LONG).show();
        Log.w(TAG, "Server error. Failure to authenticate user", e);

        Intent intent = new Intent(getApplicationContext(), StartActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        getApplicationContext().startActivity(intent);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if(id == R.id.tvRegisterAccount) {
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://sequencing.com/user/register/"));
            startActivity(browserIntent);
        }
    }

    public static void refreshSettings(Context context, Token token) {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        SharedPreferences settings  = PreferenceManager.getDefaultSharedPreferences(context);

        String url = "https://weathermyway.rocks/ExternalSettings/RetrieveUserSettings";
        Map<String, String> params = new HashMap<>(9);

        params.put("accessToken", token.getAccessToken());
        params.put("expiresIn", String.valueOf(token.getLifeTime()));
        params.put("tokenType", "Bearer");
        params.put("scope", "external");
        params.put("refreshToken", token.getRefreshToken());
        params.put("deviceType", String.valueOf(2));

        if(settings.getBoolean("push_daily_forecast", true) == true) {
            params.put("newDeviceToken", settings.getString("newDeviceToken", null));
            params.put("oldDeviceToken", settings.getString("oldDeviceToken", null));
            params.put("sendPush", "true");
        } else {
            params.put("newDeviceToken", null);
            params.put("oldDeviceToken", null);
            params.put("sendPush", "false");
        }

        String response = HttpHelper.doPost(url, null, params);

        if(response != null) {
            SettingsEntity responseEntity = new Gson().fromJson(response, SettingsEntity.class);
            Map<String, Object> data = responseEntity.getData();

            if(data == null || data.size() == 0)
                return;

            SharedPreferences.Editor editor = settings.edit();
            editor.putString("email_address", data.get("UserEmail").toString());
            editor.putString("username", data.get("UserName").toString());
            editor.putString("phone_number", data.get("UserPhone").toString());
            editor.putBoolean("email_daily_forecast", (Boolean)data.get("SendEmail"));
            editor.putBoolean("text_daily_forecast", (Boolean)data.get("SendSms"));
            editor.putString("genetic_data_file", data.get("DataFileName").toString());
            editor.putString("genetic_file_id", data.get("DataFileId").toString());
            editor.putString("wake_up_weekdays", data.get("TimeWeekDay").toString());
            editor.putString("wake_up_weekends", data.get("TimeWeekEnd").toString());
            String weekendNotifications = context.getResources().getStringArray(R.array.weekend_notifications_values)[((Double)(data.get("WeekendMode"))).intValue()];
            editor.putString("weekend_notifications", weekendNotifications);
            String tempDate = data.get("Temperature").toString();
            String temp = tempDate == null ? context.getResources().getStringArray(R.array.temperature_units)[0] :
                    context.getResources().getStringArray(R.array.temperature_units)[((Double)(data.get("Temperature"))).intValue()];
            editor.putString("temperature", temp);
            if(data.get("TimeZoneValue") != null ) {
                String timezone = TimezoneHelper.getTimezoneById(TimeZone.getTimeZone(data.get("TimeZoneValue").toString()));
                editor.putString("timezone", timezone);
            }

            editor.commit();
            }

            Log.i(TAG, "Settings has been refreshed");
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
