package com.sequencing.weather.activity;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.TimePickerDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.Typeface;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.percent.PercentRelativeLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.SwitchCompat;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.TimePicker;

import com.google.android.gms.common.api.GoogleApiClient;
import com.sequencing.fileselector.FileEntity;
import com.sequencing.fileselector.core.ISQFileCallback;
import com.sequencing.fileselector.core.SQUIFileSelectHandler;
import com.sequencing.oauth.core.SequencingOAuth2Client;
import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.AccountHelper;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.PhoneCodes;
import com.sequencing.weather.helper.TimeHelper;
import com.sequencing.weather.helper.ValidationHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;
import com.sequencing.weather.preference.PhoneNumberPreference;
import com.sequencing.weather.service.RegistrationIntentService;
import com.sequencing.weather.service.WeatherSyncReceiver_;

import org.androidannotations.annotations.AfterTextChange;
import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Bean;
import org.androidannotations.annotations.CheckedChange;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ItemSelect;
import org.androidannotations.annotations.UiThread;
import org.androidannotations.annotations.ViewById;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Created by omazurova on 23.09.2016.
 */
@EActivity(R.layout.activity_preferences)
public class SettingsActivity extends AppCompatActivity implements WeekendNotificationsBean.NotificationSelectionListener {

    private static String TAG = SettingsActivity.class.getSimpleName();

    @Bean
    WeekendNotificationsBean weekendNotifications;

    @ViewById(R.id.toolbar)
    Toolbar toolbar;

    @ViewById(R.id.video_view)
    CVideoView videoView;

    @ViewById(R.id.contentLayout)
    PercentRelativeLayout contentPrefsScreen;

    @ViewById(R.id.tvLocationTitle)
    TextView tvLocationTitle;

    @ViewById(R.id.tvLocation)
    TextView location;

    @ViewById(R.id.btnChangeLocation)
    Button changeLocation;

    @ViewById(R.id.tvTempUnitsTitle)
    TextView tvTempUnitsTitle;

    @ViewById(R.id.tvTempUnitsTitle)
    TextView temperature;

    @ViewById(R.id.radioGroup)
    RadioGroup radioGroup;

    @ViewById(R.id.radioF)
    RadioButton tempUnitF;

    @ViewById(R.id.radioC)
    RadioButton tempUnitC;

    @ViewById(R.id.tvAccount)
    TextView connectedAccount;

    @ViewById(R.id.btnSignOut)
    Button signOut;

    @ViewById(R.id.tvGenericDataFileName)
    TextView geneticDataFile;

    @ViewById(R.id.btnChangeFile)
    Button changedGeneticFile;

    @ViewById(R.id.switchPushNotifications)
    SwitchCompat switchPushNotifications;

    @ViewById(R.id.switchEmail)
    SwitchCompat switchEmail;

    @ViewById(R.id.etEmail)
    EditText editEmail;

    @ViewById(R.id.invalidTextEmail)
    ImageView invalidTextEmail;

    @ViewById(R.id.switchSMS)
    SwitchCompat switchSMS;

    @ViewById(R.id.spCountriesCodes)
    Spinner countriesCodes;

    @ViewById(R.id.etPhone)
    EditText etPhone;

    @ViewById(R.id.invalidTextPhone)
    ImageView invalidText;

    @ViewById(R.id.spWeekendNotifications)
    TextView spWeekendNotifications;

    @ViewById(R.id.tvWakeUpWeekDays)
    TextView tvWakeUpWeekDays;

    @ViewById(R.id.tvWakeUpWeekends)
    TextView tvWakeUpWeekends;

    private SharedPreferences settings;
    private Typeface typeface;

    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    private GoogleApiClient client;
    private boolean isSettingChanged;
    private boolean isPushCheckChanged;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
//        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
//            setTheme(R.style.PreferencesThemeTransparentBackground);
//        }
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        super.onCreate(savedInstanceState);
        try {
            StartActivity.refreshSettings(getApplicationContext(), InstancesContainer.getoAuth2Client().getToken());
        } catch (Exception e) {
            showErrorRefreshSettings();
            e.printStackTrace();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        String fileName = settings.getString("genetic_data_file", null);
        if (geneticDataFile != null) {
            geneticDataFile.setText(fileName);
        }
        init();
        playVideo();
    }

    @AfterViews
    public void setViews() {
        if (toolbar != null) {
            setSupportActionBar(toolbar);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setDisplayShowTitleEnabled(false);
        }

        typeface = FontHelper.getTypeface(this);
        FontHelper.overrideFonts(contentPrefsScreen, typeface);
        settings = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());

        String locationPref = settings.getString("location", null);
        location.setText(locationPref);

        String emailAddress = settings.getString("email", null);
        if (emailAddress == null || emailAddress.equals("")) {
            emailAddress = AccountHelper.getUserEmail(InstancesContainer.getoAuth2Client().getToken().getAccessToken());
        }
        connectedAccount.setText(emailAddress);

        String email = settings.getString("email_address", null);
        editEmail.setText(email);

        String geneticDataFilePref = settings.getString("genetic_data_file", null);
        geneticDataFile.setText(geneticDataFilePref);

        String phoneNumber = settings.getString("phone_number", null);
        etPhone.setText(phoneNumber);
        etPhone.addTextChangedListener(new PhoneModifyListener());

        setTemperatureUnit();

        boolean pushNotifPref = settings.getBoolean("push_daily_forecast", false);
        if (pushNotifPref) {
            switchPushNotifications.setChecked(true);
        }

        boolean emailDailyPref = settings.getBoolean("email_daily_forecast", false);
        if (!emailDailyPref) {
            switchEmail.setChecked(false);
            editEmail.setEnabled(false);
        } else {
            switchEmail.setChecked(true);
            editEmail.setEnabled(true);
        }

        boolean textDailyPref = settings.getBoolean("text_daily_forecast", false);
        if (!textDailyPref) {
            switchSMS.setChecked(false);
            countriesCodes.setEnabled(false);
            etPhone.setEnabled(false);
        } else {
            switchSMS.setChecked(true);
            countriesCodes.setEnabled(true);
            etPhone.setEnabled(true);
        }

        tvWakeUpWeekDays.setTag("wake_up_weekdays");
        setWakeUpTimeNotification(tvWakeUpWeekDays, "08:00");
        tvWakeUpWeekends.setTag("wake_up_weekends");
        setWakeUpTimeNotification(tvWakeUpWeekends, "09:00");

        setWeekendNotifications();

        setCountries();
    }

    private void setTemperatureUnit() {
        String tempUnit = settings.getString("temperature", "F");
        if (tempUnit.equals("F")) {
            tempUnitF.setTextColor(getResources().getColor(android.R.color.holo_blue_light));
            tempUnitC.setTextColor(getResources().getColor(android.R.color.darker_gray));
        } else {
            tempUnitF.setTextColor(getResources().getColor(android.R.color.darker_gray));
            tempUnitC.setTextColor(getResources().getColor(android.R.color.holo_blue_light));
        }
    }

    void setWeekendNotifications() {
        String weekendNotifPref = settings.getString("weekend_notifications", "None");
        String[] notificationsValues = getResources().getStringArray(R.array.weekend_notifications_values);
        int position = Arrays.asList(notificationsValues).indexOf(weekendNotifPref);
        String[] notifications = getResources().getStringArray(R.array.weekend_notifications);
        String notificationType = notifications[position];
        spWeekendNotifications.setText(notificationType);
    }

    private void setWakeUpTimeNotification(TextView timeText, String defaultTime) {
        String wakeUpNotifications = settings.getString(timeText.getTag().toString(), null);
        if (wakeUpNotifications == null || wakeUpNotifications.equals("")) {
            wakeUpNotifications = TimeHelper.transform24ClockFormatTo12(defaultTime);
        }
        timeText.setText(wakeUpNotifications);
    }

    private int[] getInitTime(String defaultTime) {
        String hoursAndMinutes = defaultTime.split(" ")[0];
        if (!hoursAndMinutes.contains(":")) {
            defaultTime = hoursAndMinutes + ":00" + " " + defaultTime.split(" ")[1];
        }
        int hour = Integer.parseInt(defaultTime.split(":")[0]);
        int minute = Integer.parseInt(defaultTime.split(":")[1].split(" ")[0]);
        return new int[]{hour, minute};
    }

    private void setCountries() {
        ArrayAdapter<String> countriesCodesAdapter = new ArrayAdapter<String>(this,
                R.layout.spinner_item_text, PhoneCodes.COUNTRY_NAMES);
        countriesCodesAdapter.setDropDownViewResource(android.R.layout.select_dialog_singlechoice);
        countriesCodes.setAdapter(countriesCodesAdapter);

        String countryCode = PhoneNumberPreference.getUserCountry(this);
        int codeIndex = Arrays.asList(PhoneCodes.COUNTRY_CODES).indexOf(countryCode);
        countriesCodes.setSelection(settings.getInt("phone_code_position", codeIndex));
    }

    @Click({R.id.radioF, R.id.radioC})
    public void changeTemperatureUnit() {
        String tempUnit = null;
        int idRadioButton = radioGroup.getCheckedRadioButtonId();
        RadioButton radioButton = (RadioButton) findViewById(idRadioButton);
        tempUnit = (String) radioButton.getTag();

        if (radioButton.getText().equals("°F")) {
            tempUnitF.setTextColor(getResources().getColor(android.R.color.holo_blue_light));
            tempUnitC.setTextColor(getResources().getColor(android.R.color.darker_gray));
        } else {
            tempUnitF.setTextColor(getResources().getColor(android.R.color.darker_gray));
            tempUnitC.setTextColor(getResources().getColor(android.R.color.holo_blue_light));
        }
        updatePreference("temperature", tempUnit);
        changeAlarm();
    }

    private void changeAlarm(){
        WeatherSyncReceiver_.setAlarm(getApplicationContext());
    }

    @Click(R.id.btnChangeFile)
    public void changeFile() {
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(this);
        SQUIFileSelectHandler fileSelectHandler = new SQUIFileSelectHandler(this);
        SequencingOAuth2Client oAuth2Client = InstancesContainer.getoAuth2Client();
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        fileSelectHandler.selectFile(oAuth2Client, weatherISQFileCallback, settings.getString("genetic_file_id", null));
    }

    public ISQFileCallback weatherISQFileCallback = new ISQFileCallback() {
        @Override
        public void onFileSelected(FileEntity entity, Activity activity) {
            Log.i(TAG, "File has been selected");

            String filename = getGeneticFileName(entity);

            SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
            SharedPreferences.Editor editor = settings.edit();
            editor.putString("genetic_data_file", filename);
            editor.putString("genetic_file_id", entity.getId());
            editor.putBoolean("should_refresh_genetically", true);
            editor.putBoolean("should_refresh", true);
            editor.commit();
            isSettingChanged = true;
            sendFileIdToServer(entity.getId(), filename, InstancesContainer.getoAuth2Client().getToken().getAccessToken());

            activity.finish();
        }
    };

    private static void sendFileIdToServer(final String selectedId, final String selectedName, final String token) {
        Runnable run = new Runnable() {
            @Override
            public void run() {
                Map<String, String> params = new HashMap<>(11);
                params.put("selectedId", selectedId);
                params.put("selectedName", selectedName);
                params.put("token", token);

                String url = "https://weathermyway.rocks//ExternalSettings/SaveFile";
                String response = HttpHelper.doPost(url, null, params);
            }
        };
        ExecutorService service = Executors.newSingleThreadExecutor();
        service.submit(run);

        Log.i(TAG, "File id has been sent to server");
    }

    private static String getGeneticFileName(FileEntity entity) {

        if (entity.getName().equals("Sample genome"))
            return entity.getFriendlyDesc1() + " - " + entity.getFriendlyDesc2();
        else
            return entity.getName();
    }

    @ItemSelect(R.id.spCountriesCodes)
    public void onCountrySelected(boolean b) {
        int position = countriesCodes.getSelectedItemPosition();
        if(settings.getInt("phone_code_position", -1) == position  && (settings.getString("phone_number", "") != "" && settings.getString("phone_number", "") != null)){
            etPhone.setText(settings.getString("phone_number", ""));
        } else {
            etPhone.setText("+" + PhoneCodes.COUNTRY_AREA_CODES[position]);
            etPhone.setSelection(etPhone.getText().length());
            isSettingChanged = true;
        }
    }

    @Click(R.id.spWeekendNotifications)
    public void selectWeekendNotifications() {
        weekendNotifications.createAlert();
    }

    @Click(R.id.btnChangeLocation)
    public void onChangeLocation() {
        Intent intent = new Intent(this, LocationActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    @Click(R.id.btnSignOut)
    public void onSignOut() {
        MainActivity.signOut(this);
    }

    @Click(R.id.tvWakeUpWeekDays)
    public void onWakeUpWeekdaysChange() {
        String wakeUpWeekDaysNotifications = settings.getString("wake_up_weekdays", null);
        if (wakeUpWeekDaysNotifications == null || wakeUpWeekDaysNotifications.equals("")) {
            wakeUpWeekDaysNotifications = "08:00";
        }
        int[] initTime = getInitTime(wakeUpWeekDaysNotifications);
        showTime(tvWakeUpWeekDays, initTime[0], initTime[1]);
    }

    @Click(R.id.tvWakeUpWeekends)
    public void onWakeUpWeekendsChange() {
        String wakeUpWeekendsNotification = settings.getString("wake_up_weekends", null);
        if (wakeUpWeekendsNotification == null || wakeUpWeekendsNotification.equals("")) {
            wakeUpWeekendsNotification = "09:00";
        }
        int[] initTime = getInitTime(wakeUpWeekendsNotification);
        showTime(tvWakeUpWeekends, initTime[0], initTime[1]);
    }

    @AfterTextChange(R.id.etEmail)
    public void onEmailChanged() {
        if (!ValidationHelper.isValidEmail(editEmail.getText().toString().trim())) {
            invalidTextEmail.setVisibility(View.VISIBLE);
        } else {
            invalidTextEmail.setVisibility(View.GONE);
        }
    }

    @CheckedChange(R.id.switchPushNotifications)
    public void changePushNotification() {
        if (switchPushNotifications.isChecked()) {
            updatePushPreference("push_daily_forecast", true);
            WeatherSyncReceiver_.setAlarm(this);
        } else {
            updatePushPreference("push_daily_forecast", false);
            WeatherSyncReceiver_.cancelAlarm(this);
        }
        isPushCheckChanged = true;
    }

    @CheckedChange(R.id.switchEmail)
    public void changeEmailDailyForecast() {
        if (switchEmail.isChecked()) {
            updatePushPreference("email_daily_forecast", true);
            editEmail.setEnabled(true);
            onEmailChanged();
        } else {
            updatePushPreference("email_daily_forecast", false);
            editEmail.setEnabled(false);
            invalidTextEmail.setVisibility(View.GONE);
        }
    }

    @CheckedChange(R.id.switchSMS)
    public void changeTextDailyForecast() {
        if (switchSMS.isChecked()) {
            updatePushPreference("text_daily_forecast", true);
            countriesCodes.setEnabled(true);
            etPhone.setEnabled(true);
            checkPhoneNumber();
        } else {
            updatePushPreference("text_daily_forecast", false);
            countriesCodes.setEnabled(false);
            etPhone.setEnabled(false);
            invalidText.setVisibility(View.GONE);
        }
    }

    public void showTime(final TextView textView, int initHour, int initMinute) {
        TimePickerDialog mTimePicker;
        mTimePicker = new TimePickerDialog(this, new TimePickerDialog.OnTimeSetListener() {
            @Override
            public void onTimeSet(TimePicker timePicker, int selectedHour, int selectedMinute) {
                String minuteStr = selectedMinute < 10 ? "0" + selectedMinute : String.valueOf(selectedMinute);
                String hourStr = selectedHour != 0 ? String.valueOf(selectedHour) : "00";

                String time = hourStr + ":" + minuteStr;
                String displayTime = TimeHelper.transform24ClockFormatTo12(time);
                textView.setText(displayTime);
                updatePreference(textView.getTag().toString(), displayTime);
            }
        }, initHour, initMinute, false);
        mTimePicker.show();
    }

    private void updatePreference(String key, String value) {
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(key, value);
        editor.commit();
        isSettingChanged = true;
    }

    private void updatePushPreference(String key, boolean value) {
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean(key, value);
        editor.commit();
        isSettingChanged = true;
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

    @Override
    public void onBackPressed() {
        checkAndSaveChanges();
    }

    @Override
    public boolean onSupportNavigateUp() {
        return checkAndSaveChanges();
    }

    private boolean checkAndSaveChanges() {
        if (isPushCheckChanged) {
            RegistrationIntentService.sendRegistrationToServer(getApplicationContext());
            isPushCheckChanged = false;
        }

        if (isSettingChanged) {
            if (editEmail.isEnabled() && !ValidationHelper.isValidEmail(editEmail.getText().toString().trim())) {
                showDialog("Provided email is invalid", "Please, provide valid email address.");
            } else if (etPhone.isEnabled() && !ValidationHelper.isValidMobile(etPhone.getText().toString().trim())) {
                showDialog("Provided a phone number is invalid", "Please, provide a valid phone number.");
            } else {
                updatePreference("email_address", editEmail.getText().toString());
                updatePreference("phone_number", etPhone.getText().toString());
                int position = countriesCodes.getSelectedItemPosition();
                settings.edit().putInt("phone_code_position", position).commit();
                RegistrationIntentService.sendSettingsToServer(getApplicationContext());
                isSettingChanged = false;
                super.onBackPressed();
            }
        } else {
            super.onBackPressed();
        }
        return true;
    }

    private void showDialog(String title, String message) {
        AlertDialog.Builder builder;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder = new AlertDialog.Builder(this, R.style.Theme_AlertStyle);
        } else {
            builder = new AlertDialog.Builder(this);
        }

        builder.setMessage(message)
                .setTitle(title)
                .setCancelable(false)
                .setPositiveButton("OK",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        });
        AlertDialog alert = builder.create();
        alert.show();
        int textViewId = alert.getContext().getResources().getIdentifier("android:id/alertTitle", null, null);
        TextView tv = (TextView) alert.findViewById(textViewId);
        tv.setTextColor(getResources().getColor(R.color.black));
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onStop() {
        super.onStop();
        stopVideo();
    }

    private void stopVideo() {
        videoView.stopPlayback();
        videoView.setVisibility(View.GONE);
    }

    @Override
    public void onNotificationSelected() {
        setWeekendNotifications();
    }

    private class PhoneModifyListener implements TextWatcher {
        private CharSequence beforeText;
        private boolean cancel = false;

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            beforeText = s;
            int codeLength = PhoneCodes.COUNTRY_AREA_CODES[countriesCodes.getSelectedItemPosition()].length() + 1;

            if (start < codeLength && (count == 1 || after == 1))
                cancel = true;

            etPhone.removeTextChangedListener(this);
            if (cancel) {
                etPhone.setText(beforeText);
                etPhone.setSelection(beforeText.length());
                cancel = false;
            }
            etPhone.addTextChangedListener(this);
        }

        @Override
        public void onTextChanged(final CharSequence s, int start, int before, int count) {
        }

        @Override
        public void afterTextChanged(Editable editable) {
            checkPhoneNumber();
        }
    }

    private void checkPhoneNumber() {
        if (!ValidationHelper.isValidMobile(etPhone.getText().toString().trim())) {
            invalidText.setVisibility(View.VISIBLE);
        } else {
            invalidText.setVisibility(View.GONE);
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
}
