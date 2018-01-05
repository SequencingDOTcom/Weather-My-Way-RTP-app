package com.sequencing.weather.activity;


import android.Manifest;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.media.MediaPlayer;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceCategory;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.preference.RingtonePreference;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.telephony.TelephonyManager;
import android.text.Html;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ListView;

import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.TimeHelper;
import com.sequencing.weather.helper.TimezoneHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;
import com.sequencing.weather.preference.GeneticFilePreference;
import com.sequencing.weather.preference.LocationPreference;
import com.sequencing.weather.preference.TimePreference;
import com.sequencing.weather.preference.WeekendNotifications;
import com.sequencing.weather.service.RegistrationIntentService;
import com.sequencing.weather.service.WeatherSyncReceiver_;

import org.androidannotations.annotations.Background;
import org.androidannotations.annotations.UiThread;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static com.sequencing.weather.R.array.weekend_notifications;

public class WeatherPreferenceActivity extends AppCompatActivity {

    private static final String TAG = "WeatherPreference";
    private CVideoView videoView;
    private static boolean isSettingChanged;
    private static boolean isPushCheckChanged;

    private static Preference.OnPreferenceChangeListener sBindPreferenceSummaryToValueListener = new Preference.OnPreferenceChangeListener() {
        @Override
        public boolean onPreferenceChange(Preference preference, Object value) {
            String stringValue = value.toString();

            if (preference instanceof ListPreference) {
                // For list preferences, look up the correct display value in
                // the preference's 'entries' list.
                ListPreference listPreference = (ListPreference) preference;
                int index = listPreference.findIndexOfValue(stringValue);

                // Set the summary to reflect the new value.
                preference.setSummary(
                        index >= 0
                                ? listPreference.getEntries()[index]
                                : null);

            } else if (preference instanceof RingtonePreference) {
                // For ringtone preferences, look up the correct display value
                // using RingtoneManager.
                if (TextUtils.isEmpty(stringValue)) {
                    // Empty values correspond to 'silent' (no ringtone).
                    preference.setSummary(R.string.pref_ringtone_silent);

                } else {
                    Ringtone ringtone = RingtoneManager.getRingtone(
                            preference.getContext(), Uri.parse(stringValue));

                    if (ringtone == null) {
                        // Clear the summary if there was a lookup error.
                        preference.setSummary(null);
                    } else {
                        // Set the summary to reflect the new ringtone display
                        // name.
                        String name = ringtone.getTitle(preference.getContext());
                        preference.setSummary(name);
                    }
                }

            } else {
                // For all other preferences, set the summary to the value's
                // simple string representation.
                preference.setSummary(stringValue);
            }
            return true;
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            setTheme(R.style.PreferencesThemeTransparentBackground);
        }
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            setSupportActionBar(toolbar);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setDisplayShowTitleEnabled(false);
        }

        videoView = (CVideoView) findViewById(R.id.video_view);

        try {
            StartActivity.refreshSettings(getApplicationContext(), InstancesContainer.getoAuth2Client().getToken());
        } catch (Exception e) {
            showErrorRefreshSettings();
            e.printStackTrace();
        }

        getFragmentManager().beginTransaction().replace(
                R.id.fragment_content,
                new PrefsFragment()).commit();
    }

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
        if (isSettingChanged) {
            WeatherSyncReceiver_.cancelAlarm(getApplicationContext());
            WeatherSyncReceiver_.setAlarm(getApplicationContext());
            RegistrationIntentService.sendSettingsToServer(getApplicationContext());
            isSettingChanged = false;
        }

        if (isPushCheckChanged) {

            RegistrationIntentService.sendRegistrationToServer(getApplicationContext());
            isPushCheckChanged = false;
        }

        stopVideo();
        super.onStop();
    }


    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
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
        if(orientation == Configuration.ORIENTATION_PORTRAIT){
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

    public static class PrefsFragment extends PreferenceFragment implements SharedPreferences.OnSharedPreferenceChangeListener {
        private static final int READ_PHONE_STATE = 5;
        private LocationPreference locationPreference;
        //        private ListPreference timezoneList;
        private WeekendNotifications weekendNotifications;
        private TimePreference wake_up_weekdays;
        private TimePreference wake_up_weekends;

        private ListView list;
        private int userTimeZoneIndex;
        private SharedPreferences settings;


        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.pref_general);
            addPreferencesFromResource(R.xml.pref_personal);
            addPreferencesFromResource(R.xml.pref_notification);

            locationPreference = (LocationPreference) findPreference("location");
            bindPreferenceSummaryToValue(findPreference("temperature"));
            bindPreferenceSummaryToValue(locationPreference);
            bindPreferenceSummaryToValue(findPreference("email_address"));
            bindPreferenceSummaryToValue(findPreference("phone_number"));
            wake_up_weekdays = (TimePreference) findPreference("wake_up_weekdays");
            wake_up_weekends = (TimePreference) findPreference("wake_up_weekends");
            weekendNotifications = (WeekendNotifications) findPreference("weekend_notifications");
            bindPreferenceSummaryToValue(wake_up_weekdays);
            bindPreferenceSummaryToValue(wake_up_weekends);
            bindPreferenceSummaryToValue(weekendNotifications);

            bindPreferenceSummaryToValue(findPreference("email"));
            bindPreferenceSummaryToValue(findPreference("genetic_data_file"));

            SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getActivity());
            if (settings.getString("phone_number", null) == null) {
                setDefaultPhoneNumber(settings);
                findPreference("phone_number").setSummary(settings.getString("phone_number", ""));
            }
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
            View view = super.onCreateView(inflater, container, savedInstanceState);
            list = (ListView) view.findViewById(android.R.id.list);
            list.setBackgroundColor(getResources().getColor(R.color.main_layouts_background));
            return view;
        }

        @Override
        public void onResume() {
            super.onResume();
            getPreferenceManager().getSharedPreferences().registerOnSharedPreferenceChangeListener(this);

            settings = PreferenceManager.getDefaultSharedPreferences(getActivity());
            GeneticFilePreference geneticFilePreference = (GeneticFilePreference) findPreference("genetic_data_file");
            geneticFilePreference.setSummary(settings.getString("genetic_data_file", null));

            if (wake_up_weekdays.getSummary().equals(null) || wake_up_weekdays.getSummary().equals(""))
                wake_up_weekdays.setSummary("7:00");
            if (wake_up_weekends.getSummary().equals(null) || wake_up_weekends.getSummary().equals(""))
                wake_up_weekends.setSummary("8:00");

            locationPreference.setSummary(settings.getString("location", null));
            setSummaryWeekendNotifications();
            list.setPadding(0, 0, 0, 0);
        }

        void setSummaryWeekendNotifications() {
            String weekendNotifPref = settings.getString("weekend_notifications", "None");
            String[] notificationsValues = getResources().getStringArray(R.array.weekend_notifications_values);
            int position = Arrays.asList(notificationsValues).indexOf(weekendNotifPref);
            String[] notifications = getResources().getStringArray(R.array.weekend_notifications);
            String notificationType = notifications[position];
            weekendNotifications.setSummary(notificationType);
        }

        @Override
        public void onPause() {
            getPreferenceManager().getSharedPreferences().unregisterOnSharedPreferenceChangeListener(this);
            super.onPause();
        }

        @Override
        public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
            if (key.equals("push_daily_forecast")) {
                if(!settings.getBoolean("push_daily_forecast", true)){
                    WeatherSyncReceiver_.cancelAlarm(getActivity());
                } else {
                    WeatherSyncReceiver_.setAlarm(getActivity());
                }
                isPushCheckChanged = true;
                return;
            }
            isSettingChanged = true;
        }

        private String setDefaultPhoneNumber(SharedPreferences settings) {
            // Assume thisActivity is the current activity
            int permissionCheck = ContextCompat.checkSelfPermission(getActivity(),
                    Manifest.permission.READ_PHONE_STATE);
            if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(getActivity(),
                        new String[]{Manifest.permission.READ_PHONE_STATE},
                        READ_PHONE_STATE);
            } else {
                TelephonyManager tMgr = (TelephonyManager) getActivity().getSystemService(Context.TELEPHONY_SERVICE);
                String obtainedPhoneNumber = tMgr.getLine1Number();
                if(obtainedPhoneNumber != null) {
                    obtainedPhoneNumber = obtainedPhoneNumber.contains("+") ? obtainedPhoneNumber : "+" + obtainedPhoneNumber;
                    SharedPreferences.Editor editor = settings.edit();
                    editor.putString("phone_number", obtainedPhoneNumber).commit();
                }
                return obtainedPhoneNumber;
            }
            return "";
        }
    }

    private static void bindPreferenceSummaryToValue(Preference preference) {
        // Set the listener to watch for value changes.
        preference.setOnPreferenceChangeListener(sBindPreferenceSummaryToValueListener);

        // Trigger the listener immediately with the preference's
        // current value.
        sBindPreferenceSummaryToValueListener.onPreferenceChange(preference,
                PreferenceManager
                        .getDefaultSharedPreferences(preference.getContext())
                        .getString(preference.getKey(), ""));
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 5: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(this);
                    TelephonyManager tMgr = (TelephonyManager) getSystemService(Context.TELEPHONY_SERVICE);
                    String obtainedPhoneNumber = tMgr.getLine1Number();
                    obtainedPhoneNumber = obtainedPhoneNumber.contains("+") ? obtainedPhoneNumber : "+" + obtainedPhoneNumber;
                    SharedPreferences.Editor editor = settings.edit();
                    editor.putString("phone_number", obtainedPhoneNumber).commit();
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    private void stopVideo() {
        videoView.stopPlayback();
        videoView.setVisibility(View.GONE);
    }
}
