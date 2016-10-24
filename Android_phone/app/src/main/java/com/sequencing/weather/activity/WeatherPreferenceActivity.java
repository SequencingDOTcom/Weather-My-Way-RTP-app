package com.sequencing.weather.activity;


import android.Manifest;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;
import android.media.Ringtone;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceFragment;
import android.preference.PreferenceManager;
import android.preference.RingtonePreference;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.telephony.TelephonyManager;
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
import com.sequencing.weather.service.RegistrationIntentService;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

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

        StartActivity.refreshSettings(getApplicationContext(), InstancesContainer.getoAuth2Client().getToken());

        getFragmentManager().beginTransaction().replace(
                R.id.fragment_content,
                new PrefsFragment()).commit();
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
    public void onStop () {
        if(isSettingChanged) {
            sendSettingsToServer();
            isSettingChanged = false;
        }

        if(isPushCheckChanged) {
            RegistrationIntentService.sendRegistrationToServer(getApplicationContext());
            isPushCheckChanged = false;
        }

        super.onStop();
    }


    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }

    private void sendSettingsToServer() {
        ExecutorService service = Executors.newSingleThreadExecutor();

        Runnable run = new Runnable() {
            @Override
            public void run() {
                SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
                String defaultTimezone = "(GMT0:00) UTC";

                Map<String, String> params = new HashMap<>(12);
                params.put("temperature", settings.getString("temperature", "C"));
                params.put("emailChk", String.valueOf(settings.getBoolean("email_daily_forecast", false)));
                params.put("email", settings.getString("email_address", null));
                params.put("smsChk", String.valueOf(settings.getBoolean("text_daily_forecast", false)));
                params.put("phone", settings.getString("phone_number", null));
                params.put("wakeupDay", settings.getString("wake_up_weekdays", null));
                params.put("wakeupEnd", settings.getString("wake_up_weekends", null));
                params.put("timezoneSelect", settings.getString("timezone", defaultTimezone).split("\\) ")[1]);

                String timezoneOffset = settings.getString("timezone", defaultTimezone).substring(4).split("\\) ")[0];
                if(timezoneOffset.split(":")[1].contains(":3"))
                    timezoneOffset = String.format("%s.5", timezoneOffset.split(":")[0]);
                else
                    timezoneOffset = String.format("%s.0", timezoneOffset.split(":")[0]);

                params.put("timezoneOffset", timezoneOffset);
                params.put("weekendMode", settings.getString("weekend_notifications", "None"));
                params.put("token", InstancesContainer.getoAuth2Client().getToken().getAccessToken());

                String url = "https://weathermyway.rocks/ExternalSettings/ChangeNotification";
                String response = HttpHelper.doPost(url, null, params);

                Log.i(TAG, "Settings have been sent to server");
            }
        };

        service.submit(run);

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
        private ListPreference timezoneList;
        private TimePreference wake_up_weekdays;
        private TimePreference wake_up_weekends;
        private ListView list;
        private int userTimeZoneIndex;

        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);

            addPreferencesFromResource(R.xml.pref_general);
            addPreferencesFromResource(R.xml.pref_personal);
            addPreferencesFromResource(R.xml.pref_notification);

            locationPreference = (LocationPreference) findPreference("location");
            bindPreferenceSummaryToValue( findPreference("temperature") );
            bindPreferenceSummaryToValue( locationPreference );

            timezoneList = (ListPreference)findPreference("timezone");
            String[] timezones = TimezoneHelper.getTimezonesAsArray();
            timezoneList.setEntries(timezones);
            timezoneList.setEntryValues(timezones);
            String timezone = timezoneList.getValue();

            if(timezone == null || timezone.equals("-1")) {
                int defaultTimeZoneId = Arrays.asList(timezones).indexOf(TimezoneHelper.getTimezoneById(TimeZone.getTimeZone(TimeZone.getDefault().getID())));
                if(defaultTimeZoneId >= 0 && defaultTimeZoneId < timezones.length)
                    timezoneList.setValueIndex(defaultTimeZoneId);
            } else {
                timezoneList.setValueIndex(Arrays.asList(timezones).indexOf(timezone));
            }

            bindPreferenceSummaryToValue( findPreference("email_address") );
            bindPreferenceSummaryToValue( findPreference("phone_number") );
            wake_up_weekdays = (TimePreference)findPreference("wake_up_weekdays");
            wake_up_weekends = (TimePreference)findPreference("wake_up_weekends");
            bindPreferenceSummaryToValue( wake_up_weekdays );
            bindPreferenceSummaryToValue( wake_up_weekends );
            bindPreferenceSummaryToValue( findPreference("weekend_notifications") );
            bindPreferenceSummaryToValue( timezoneList );

            bindPreferenceSummaryToValue( findPreference("email") );
            bindPreferenceSummaryToValue (findPreference("genetic_data_file") );

            SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getActivity());
            if(settings.getString("phone_number", null) == null) {
                setDefaultPhoneNumber(settings);
                findPreference("phone_number").setSummary(settings.getString("phone_number",""));
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

            SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getActivity());

            GeneticFilePreference geneticFilePreference = (GeneticFilePreference) findPreference("genetic_data_file");
            geneticFilePreference.setSummary(settings.getString("genetic_data_file", null));

            if(wake_up_weekdays.getSummary().equals(null) || wake_up_weekdays.getSummary().equals(""))
                wake_up_weekdays.setSummary("7:00");
            if(wake_up_weekends.getSummary().equals(null) || wake_up_weekends.getSummary().equals(""))
                wake_up_weekends.setSummary("8:00");

            locationPreference.setSummary(settings.getString("location", null));
            list.setPadding(0, 0, 0, 0);
        }

        @Override
        public void onPause() {
            getPreferenceManager().getSharedPreferences().unregisterOnSharedPreferenceChangeListener(this);
            super.onPause();
        }

        @Override
        public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
            if(key.equals("push_daily_forecast")) {
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
                obtainedPhoneNumber = obtainedPhoneNumber.contains("+") ? obtainedPhoneNumber : "+" + obtainedPhoneNumber;
                SharedPreferences.Editor editor = settings.edit();
                editor.putString("phone_number", obtainedPhoneNumber).commit();
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
}
