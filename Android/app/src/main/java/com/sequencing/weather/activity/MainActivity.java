package com.sequencing.weather.activity;

import android.Manifest;
import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.app.AlertDialog;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Typeface;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.NotificationCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.appindexing.Thing;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;
import com.google.android.gms.location.LocationServices;
import com.google.gson.JsonSyntaxException;
import com.nhaarman.supertooltips.ToolTip;
import com.nhaarman.supertooltips.ToolTipRelativeLayout;
import com.nhaarman.supertooltips.ToolTipView;
import com.sequencing.androidoauth.core.SQUIoAuthHandler;
import com.sequencing.appchains.AndroidAppChainsImpl;
import com.sequencing.appchains.DefaultAppChainsImpl;
import com.sequencing.appchains.DefaultAppChainsImpl.Report;
import com.sequencing.appchains.DefaultAppChainsImpl.ResultType;
import com.sequencing.oauth.core.SequencingOAuth2Client;
import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.database.LoggingQueries;
import com.sequencing.weather.database.SQLiteAccessData;
import com.sequencing.weather.entity.ForecastRequestEntity;
import com.sequencing.weather.entity.ForecastResponseEntity;
import com.sequencing.weather.entity.WeatherEntity;
import com.sequencing.weather.exceptions.WUndergroundException;
import com.sequencing.weather.helper.AccountHelper;
import com.sequencing.weather.helper.ConnectionHelper;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.GeoHelper;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.InternalStorage;
import com.sequencing.weather.helper.JsonHelper;
import com.sequencing.weather.helper.MediaTypeUtil;
import com.sequencing.weather.helper.VideoGeneratorHelper;
import com.sequencing.weather.helper.WeatherHelper;
import com.sequencing.weather.logging.events.Interaction;
import com.sequencing.weather.logging.events.Request;
import com.sequencing.weather.logging.events.UpdateInteraction;
import com.sequencing.weather.logging.listeners.InteractionListener;
import com.sequencing.weather.logging.listeners.RequestEventListener;
import com.sequencing.weather.logging.listeners.UsageEventListener;
import com.sequencing.weather.preference.GeneticFilePreference;
import com.sequencing.weather.service.RegistrationIntentService;
import com.sequencing.weather.service.SendLoggingReceiver_;
import com.sequencing.weather.service.WeatherSyncReceiver;
import com.sequencing.weather.service.WeatherSyncReceiver_;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Background;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.UiThread;
import org.androidannotations.annotations.ViewById;
import org.greenrobot.eventbus.EventBus;

import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

import javax.inject.Inject;

import me.leolin.shortcutbadger.ShortcutBadger;
import pl.droidsonroids.gif.GifImageView;

import static java.util.concurrent.TimeUnit.MILLISECONDS;
import static java.util.concurrent.TimeUnit.MINUTES;

@EActivity(R.layout.activity_main)
public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener, GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener, View.OnClickListener {
    private static final String WEATHET_MY_WAY_EMAIL = "feedback@weathermyway.rocks";
    private static final String TAG = "MainActivity";
    private static final int LOCATION_REQUEST_DELAY = 1000 * 60;
    private static final int ACCESS_FINE_LOCATION = 9;
    private WeatherEntity weatherEntity = null;

    public static String currentLocation;
    public static String chosenLocation;
    public static String geneticFileId;
    private double oldLatitude;
    private double oldLongitude;
    public double latitude;
    public double longitude;
    private boolean isPredictionWeatherOpen;
    private AppLocationListener locationListener;
    private LocationManager locationManager;
    private ScheduledExecutorService locationMonitor = Executors.newSingleThreadScheduledExecutor();
    private Typeface typeface;
    private GoogleApiClient mGoogleApiClient;

    private ScheduledExecutorService weatherAutomaticRefresher = Executors.newSingleThreadScheduledExecutor();
    private String alterMessage;
    private SharedPreferences settings;
    private int countRetryAttempts = 5;

    @ViewById(R.id.toolbar)
    Toolbar toolbar;

    @ViewById(R.id.video_view)
    CVideoView videoView;

    @ViewById(R.id.drawer_layout)
    DrawerLayout drawer;

    @ViewById(R.id.nav_view)
    NavigationView navigationView;

    @ViewById(R.id.ivFooter)
    ImageView ivFooter;

    @ViewById(R.id.wvCubeMain)
    GifImageView wvCubeMain;

    @ViewById(R.id.rlSpinner)
    RelativeLayout rlSpinner;

    @ViewById(R.id.tvMessWait)
    TextView tvMessWait;

    @ViewById(R.id.svMainLayout)
    ScrollView svMainLayout;

    @ViewById(R.id.tvToolbarTitle)
    TextView tvToolbarTitle;

    @ViewById(R.id.tvToolbarSubTitle)
    TextView tvToolbarSubTitle;

    @ViewById(R.id.titleWeather)
    TextView titleWeather;

    @ViewById(R.id.tvCurrentTemp)
    TextView tvCurrentTemp;

    @ViewById(R.id.tvTempLogo)
    TextView tvTempLogo;

    @ViewById(R.id.ivToday)
    ImageView ivToday;

    @ViewById(R.id.tvSubWeatherInfo)
    TextView tvSubWeatherInfo;

    @ViewById(R.id.tvTodayWeather)
    TextView tvTodayWeather;

    @ViewById(R.id.tvTodayTempH)
    TextView tvTodayTempH;

    @ViewById(R.id.tvTodayTempL)
    TextView tvTodayTempL;

    @ViewById(R.id.rlCubeWaitSmall)
    RelativeLayout rlCubeMainSmall;

    @ViewById(R.id.wvCubeMainSmall)
    GifImageView wvCubeMainSmall;

    @ViewById(R.id.tvWait)
    TextView tvWait;

    @ViewById(R.id.tvPersonalPrediction)
    TextView tvPersonalPrediction;

    @ViewById(R.id.ivSequencingLogo)
    ImageView ivSequencingLogo;

    @ViewById(R.id.btnAlert)
    Button btnAlert;

    @ViewById(R.id.tvBanner)
    TextView tvBanner;

    @ViewById(R.id.tvPersonalPredictionTitle)
    TextView tvPersonalPredictionTitle;

    @ViewById(R.id.tvNavPoweredBy)
    TextView tvNavPoweredBy;

    @ViewById(R.id.tvExtendedForecast)
    TextView tvExtendedForecast;

    @ViewById(R.id.tvExtendedForecastTitle)
    TextView tvExtendedForecastTitle;

    @ViewById(R.id.rlToolTip)
    ToolTipRelativeLayout rlToolTip;

    @ViewById(R.id.llCurrentWeather)
    ViewGroup llCurrentWeather;

    @ViewById(R.id.llTailoredForecast)
    ViewGroup llTailoredForecast;

    @ViewById(R.id.llExtendedForecast)
    ViewGroup llExtendedForecast;

    @ViewById(R.id.rlBottom)
    ViewGroup rlBottom;

    @Inject
    UsageEventListener usageEventListener;

    @Inject
    InteractionListener interactionListener;

    @Inject
    RequestEventListener requestEventListener;

    private String temperatureMeasurement;
    private boolean isTablet;
    private ForecastRequestEntity.DateForecastEntity[] dateForecastEntities;
    private HashMap<String, String> forecasts;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        if (mGoogleApiClient == null) {
            // ATTENTION: This "addApi(AppIndex.API)"was auto-generated to implement the App Indexing API.
            // See https://g.co/AppIndexing/AndroidStudio for more information.
            mGoogleApiClient = new GoogleApiClient.Builder(this)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .addApi(LocationServices.API)
                    .addApi(AppIndex.API).build();
        }
        mGoogleApiClient.connect();

        settings = PreferenceManager.getDefaultSharedPreferences(getApplicationContext());
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean("isMainActivityCreate", true).commit();

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        initLocationServices();
        Log.i(TAG, "FCM Registration Token: " + settings.getString("newDeviceToken", ""));
        setWeatherSync();

        getDeviceToken();

    }

    private void initLocationServices() {
        locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        locationListener = new AppLocationListener();

        int permissionCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION);
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, ACCESS_FINE_LOCATION);
        } else {
            if (!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
                buildAlertMessageNoGps();
            } else {
                locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, LOCATION_REQUEST_DELAY * 15, 0, locationListener);
            }
        }
    }

    @Background
    protected void getDeviceToken(){
        //get device token
        try {
            InstanceID instanceID = InstanceID.getInstance(this);

            String token = instanceID.getToken(getString(R.string.gcm_defaultSenderId),
                    GoogleCloudMessaging.INSTANCE_ID_SCOPE, null);

            Log.i(TAG, "GCM Registration Token: " + token);

        }catch (Exception e) {
            Log.d(TAG, "Failed to complete token refresh", e);
        }
    }

    private void buildAlertMessageNoGps() {
        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage("Your GPS seems to be disabled, do you want to enable it?")
                .setCancelable(false)
                .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                    public void onClick(@SuppressWarnings("unused") final DialogInterface dialog, @SuppressWarnings("unused") final int id) {
                        startActivity(new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS));
                    }
                })
                .setNegativeButton("No", new DialogInterface.OnClickListener() {
                    public void onClick(final DialogInterface dialog, @SuppressWarnings("unused") final int id) {
                        manuallySettingLocation();
                        dialog.cancel();
                    }
                });
        final AlertDialog alert = builder.create();
        alert.show();
    }

    private void setWeatherSync() {
        if (!WeatherSyncReceiver_.checkAlarmIsSet(this) && settings.getBoolean("push_daily_forecast", true)){
            WeatherSyncReceiver_.setAlarm(this);
        }
    }

    @Click(R.id.ivFooter)
    protected void onIvFooter() {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://sequencing.com/"));
        startActivity(browserIntent);
    }

    @AfterViews
    protected void setViews() {
        isTablet = getResources().getBoolean(R.bool.is_tablet);
        initVideoView();
        typeface = FontHelper.getTypeface(this);
        FontHelper.overrideFonts(drawer, typeface);

        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();

        navigationView.setNavigationItemSelectedListener(this);
        View headerLayout = navigationView.getHeaderView(0);
        TextView tvNavAppBrand = (TextView) headerLayout.findViewById(R.id.tvNavAppBrand);
        tvNavAppBrand.setTypeface(typeface);

        tvCurrentTemp.setTypeface(FontHelper.getTypefaceUltraLight(this));
        tvTempLogo.setTypeface(FontHelper.getTypefaceUltraLight(this));

        showImageAnim(ivSequencingLogo);

        btnAlert.setOnClickListener(this);
        btnAlert.setVisibility(View.GONE);
    }

    private void showProgressGettingForecast() {
        tvWait.setVisibility(View.VISIBLE);
        rlCubeMainSmall.setVisibility(View.VISIBLE);
        wvCubeMainSmall.setVisibility(View.VISIBLE);
        ivSequencingLogo.setVisibility(View.GONE);
        tvPersonalPrediction.setVisibility(View.GONE);
    }

    private void automaticWeatherRefresh() {
        weatherAutomaticRefresher.scheduleWithFixedDelay(new Runnable() {

            @Override
            public void run() {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (ConnectionHelper.isConnectionAvailable(getApplicationContext())) {
                            forceWeatherRefresh();
                            try {
                                StartActivity.refreshSettings(getApplicationContext(), InstancesContainer.getoAuth2Client().getToken());
                            } catch (Exception e) {
                                showErrorRefreshSettings();
                                e.printStackTrace();
                            }
                        }
                    }
                });
            }

        }, 2, 2, MINUTES);
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

    private void startLocationMonitoring() {
        locationMonitor.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                if (isShouldRefresh(latitude, longitude)) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            forceWeatherRefresh();
                        }
                    });
                }
            }
        }, LOCATION_REQUEST_DELAY, LOCATION_REQUEST_DELAY * 16, MILLISECONDS);
    }

    private boolean isShouldRefresh(final double lat, final double lon) {
        int metersRange = 1000; // meters
        Log.d(TAG, String.format("Changing location on %s meters. Lat=%s. Lon=%s", GeoHelper.getDistance(oldLatitude, oldLongitude, lat, lon), lat, lon));

        if (oldLatitude == 0 && oldLongitude == 0) {
            oldLatitude = lat;
            oldLongitude = lon;
            return false;

        } else if (GeoHelper.getDistance(oldLatitude, oldLongitude, lat, lon) >= metersRange) {
            oldLatitude = lat;
            oldLongitude = lon;
            return true;
        }
        return false;
    }

    @Override
    public void onStart() {
        ((RTPApplication)this.getApplicationContext()).getDaggerComponent().inject(this);
        super.onStart();// ATTENTION: This was auto-generated to implement the App Indexing API.
// See https://g.co/AppIndexing/AndroidStudio for more information.
        mGoogleApiClient.connect();
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        AppIndex.AppIndexApi.start(mGoogleApiClient, getIndexApiAction());
        if(!usageEventListener.isRegistered()){
            EventBus.getDefault().register(usageEventListener);
            usageEventListener.setIsUsageEventListenerRegistered(true);
        }

        if(!requestEventListener.isRegistered()){
            EventBus.getDefault().register(requestEventListener);
            requestEventListener.setIsRequestListenerRegistered(true);
        }

        if(!interactionListener.isRegistered()){
            EventBus.getDefault().register(interactionListener);
            interactionListener.setIsInteractionListenerRegistered(true);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        String savedLocation = settings.getString("location", "");
        String fileId = settings.getString("genetic_file_id", null);
        if (fileId == null) {
            selectGeneticFile();
            return;
        }
        toolbar.setBackgroundColor(VideoGeneratorHelper.getTextColorAgainstVideo(this));
        initVideoView();
        playVideo();

        if(currentLocation == null){
            showCube();
            return;
        }

        if ((chosenLocation != null && chosenLocation.equals(savedLocation))) {
            settings.edit().putBoolean("should_refresh", false).commit();
        } else {
            settings.edit().putBoolean("should_refresh", true).commit();
        }

        if(isTimeRefreshExpired(settings, 15)){
            forceWeatherRefresh();
            return;
        }

        refreshWeather();

    }

    @Override
    public void onPause() {
        super.onPause();
        rlToolTip.removeAllViews();
        isPredictionWeatherOpen = false;
//        unregisterManagers();
    }

    @Override
    public void onStop() {
        super.onStop();// ATTENTION: This was auto-generated to implement the App Indexing API.
// See https://g.co/AppIndexing/AndroidStudio for more information.
        AppIndex.AppIndexApi.end(mGoogleApiClient, getIndexApiAction());
        stopVideo();
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        mGoogleApiClient.disconnect();
        EventBus.getDefault().unregister(usageEventListener);
        usageEventListener.setIsUsageEventListenerRegistered(false);
        EventBus.getDefault().unregister(requestEventListener);
        requestEventListener.setIsRequestListenerRegistered(false);
        EventBus.getDefault().unregister(interactionListener);
        interactionListener.setIsInteractionListenerRegistered(false);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

    private void initVideoView() {
        if (videoView != null) {
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
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_refresh) {
            forceWeatherRefresh();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private void forceWeatherRefresh() {
        SharedPreferences.Editor editor = settings.edit();
        String currentCityId = settings.getString("city_id", "");

        if (latitude != 0 && longitude != 0) {
            Map<String, String> cityCodeAndName = new HashMap<String, String>(2);
            long startStamp = System.currentTimeMillis();
            try {
                cityCodeAndName.putAll(WeatherHelper.getCityIdByGeoData(latitude, longitude));
            } catch (WUndergroundException | JsonSyntaxException e) {
                long endStamp = System.currentTimeMillis();
                int timeRequest = (int) (endStamp - startStamp);
                sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_WU, settings.getLong("timeStampInteraction", 0), endStamp, e.getMessage());
                manuallySettingLocation();
                return;
            }

            long endStamp = System.currentTimeMillis();
            int timeRequest = (int) (endStamp - startStamp);
            sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_WU, settings.getLong("timeStampInteraction", 0), 0, null);

            if (!cityCodeAndName.get("code").equals(currentCityId) || isTimeRefreshExpired(settings, 15)) {
                endLastInteraction(this);

                Interaction interaction = new Interaction();
                interaction.lat = latitude;
                interaction.lng = longitude;
                interaction.media = MediaTypeUtil.getNetworkClass(this);
                interaction.place = cityCodeAndName.get("name");
                interaction.ts = System.currentTimeMillis();
                EventBus.getDefault().post(interaction);
                editor.putLong("timeStampInteraction", interaction.ts);

                editor.putBoolean("should_refresh", true);
                editor.putString("city_id", cityCodeAndName.get("code"));
                editor.commit();

                currentLocation = cityCodeAndName.get("name");
                LocationActivity.updateLocation(this, cityCodeAndName.get("name"), latitude,
                        longitude, cityCodeAndName.get("code"));
            } else {
                editor.putBoolean("should_refresh", false);
                editor.commit();
            }
        } else {
            initLocationServices();
        }
        refreshWeather();
    }

    private static void endLastInteraction(Context context){
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
        long currentTimestampInteraction = settings.getLong("timeStampInteraction", 0);
        int sessionDuration = (int) (System.currentTimeMillis() - currentTimestampInteraction);
        if(currentTimestampInteraction != 0){
            UpdateInteraction updateInteraction = new UpdateInteraction();
            updateInteraction.ts = currentTimestampInteraction;
            updateInteraction.duration = sessionDuration;
            EventBus.getDefault().post(updateInteraction);
        }
    }

    public static boolean isTimeRefreshExpired(SharedPreferences settings, int intervalMinutes) {
        long maxInterval = MILLISECONDS.convert(intervalMinutes, MINUTES);
        Date lastUpdateDate = null;
        String lastTimeRefresh = settings.getString("lastTimeRefresh", null);
        if (lastTimeRefresh == null) {
            return true;
        }
        DateFormat dateFormat = new SimpleDateFormat("HH:mm");

        Date currentDate = new Date();
        String currentTime = dateFormat.format(currentDate);
        try {
            lastUpdateDate = dateFormat.parse(lastTimeRefresh);
            currentDate = dateFormat.parse(currentTime);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        long currentInterval = currentDate.getTime() - lastUpdateDate.getTime();
        if (currentInterval > maxInterval) {
            return true;
        }
        return false;
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        switch (id) {
            case R.id.nav_about:
                Intent about = new Intent(getApplicationContext(), AboutActivity_.class);
                about.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(about);
                break;

            case R.id.nav_settings:
                Intent settings;
                if (isTablet) {
                    settings = new Intent(getApplicationContext(), SettingsActivity_.class);
                } else {
                    settings = new Intent(getApplicationContext(), WeatherPreferenceActivity.class);
                }
                settings.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(settings);
                break;

            case R.id.nav_location:
                Intent location = new Intent(getApplicationContext(), LocationActivity.class);
                location.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(location);
                break;

            case R.id.nav_feedback:
                openEmailClient();
                break;

            case R.id.nav_signout:
                signOut(this);
                break;

            case R.id.nav_share:
                Intent share = new Intent(getApplicationContext(), ShareActivity.class);
                share.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(share);
                break;
        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
    }

    private void refreshWeather() {
        String fileId = settings.getString("genetic_file_id", null);
        if (weatherEntity == null || settings.getBoolean("should_refresh", false)) {
            showCube();
            showProgressGettingForecast();
            getWeatherEntity();
        } else if (weatherEntity != null && geneticFileId != null && !geneticFileId.equals(fileId)) {
            showProgressGettingForecast();
            getPersonalRecommendationsForWeek();
        } else {
            setDataViews();
        }
    }

    @Background
    protected void getWeatherEntity() {
        SharedPreferences.Editor editor = settings.edit();
        String cityId = settings.getString("city_id", "");
        if (!cityId.equals("")) {
            long startStamp = System.currentTimeMillis();
            try {
                this.weatherEntity = WeatherHelper.getCurrentWeather(cityId);
            } catch (WUndergroundException | JsonSyntaxException e) {
                long endStamp = System.currentTimeMillis();
                int timeRequest = (int) (endStamp - startStamp);
                sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_WU, settings.getLong("timeStampInteraction", 0), endStamp, e.toString());
                retryRequestWithDelay();
                return;
            } catch (RuntimeException e) {
                long endStamp = System.currentTimeMillis();
                int timeRequest = (int) (endStamp - startStamp);
                sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_WU, settings.getLong("timeStampInteraction", 0), endStamp, e.toString());
                retryRequestWithDelay();
                return;
            }

            if (weatherEntity == null) {
                showExceptionToast();
                return;
            } else {
                long endStamp = System.currentTimeMillis();
                int timeRequest = (int) (endStamp - startStamp);
                sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_WU, settings.getLong("timeStampInteraction", 0), 0, null);

                DateFormat dateFormat = new SimpleDateFormat("HH:mm");
                Date date = new Date();
                String lastTimeRefresh = dateFormat.format(date);
                editor.putString("lastTimeRefresh", lastTimeRefresh);

                if (settings.getString("location", null) == null || settings.getString("location", null).equals("")) {
                    editor.putString("location", weatherEntity.getCurrentObservation().getDisplayLocation().get("full"));
                }
                editor.commit();

                if(chosenLocation != null && currentLocation.equals(chosenLocation)){
                    updateTempBadge();
                }
                setDataViews();
                getPersonalRecommendationsForWeek();
            }
        } else {
            return;
        }
    }

    private void updateTempBadge(){
        String currentTemp;
        String temperatureMeasurement = "°F";
        if (settings.getString("temperature", "F").equals("C")) {
            temperatureMeasurement = "°C";
            currentTemp = weatherEntity.getCurrentObservation().getTempC().split("\\.")[0];
        } else {
            currentTemp = weatherEntity.getCurrentObservation().getTempF().split("\\.")[0];
        }

        NotificationManager mNotifyMgr =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.android_icon_weather_my_way)
                .setTicker(currentTemp + "" + temperatureMeasurement)
                .setContentTitle("Current weather forecast")
                .setContentText(currentTemp + temperatureMeasurement)
                .setOngoing(false)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true);
        Intent i = new Intent(this, MainActivity_.class);
        PendingIntent pendingIntent =
                PendingIntent.getActivity(
                        this,
                        0,
                        i,
                        PendingIntent.FLAG_ONE_SHOT
                );
        mBuilder.setContentIntent(pendingIntent);
        mNotifyMgr.notify(12345, mBuilder.build());

        int count = Integer.parseInt(currentTemp);
        if (count <= 0) {
            count = 1;
        }
        ShortcutBadger.applyCount(getApplicationContext(), count);
    }

    private void sendRequestEvent(int requestTime, int background, int service, long interactionTimestamp, long failureTimestamp, String failureReason) {
        if(!requestEventListener.isRegistered()){
            EventBus.getDefault().register(requestEventListener);
            requestEventListener.setIsRequestListenerRegistered(true);
        }
        Request request = new Request();
        request.requestTime = requestTime;
        request.requestBackground = background;
        request.requestService = service;
        request.failureTimestamp = failureTimestamp;
        request.failureReason = failureReason;
        request.interactionTimestamp = interactionTimestamp;
        EventBus.getDefault().post(request);
    }

    @UiThread
    void retryRequestWithDelay() {
        if (countRetryAttempts > 0) {
            countRetryAttempts = countRetryAttempts - 1;
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    getWeatherEntity();
                }
            }, 3000);
        } else {
            showErrorGettingWeather();
        }
    }

    @UiThread
    void showExceptionToast() {
        Toast.makeText(this, "Unable to get weather for your location, please select other location", Toast.LENGTH_LONG).show();
        Intent intent = new Intent(this, LocationActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.startActivity(intent);
        return;
    }

    @UiThread
    protected void showErrorGettingWeather() {
        SharedPreferences.Editor editor = settings.edit();
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);
        builder.setTitle("Sorry, there was an error while getting weather")
                .setMessage("Check your Internet connection, check whether Location services are enabled and try to refresh forecast")
                .setCancelable(false)
                .setPositiveButton("Ok",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        });
        AlertDialog alert = builder.create();
        alert.show();

        svMainLayout.setVisibility(View.GONE);
        tvToolbarTitle.setVisibility(View.GONE);
        tvToolbarSubTitle.setVisibility(View.GONE);
        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);

        editor.putBoolean("should_refresh", false);
        editor.commit();
    }

    @UiThread
    protected void setDataViews() {
        hideCube();
        tvToolbarTitle.setVisibility(View.VISIBLE);
        tvToolbarSubTitle.setVisibility(View.VISIBLE);

        llCurrentWeather.setBackgroundColor(ContextCompat.getColor(this, R.color.main_layouts_background_darker));
        llTailoredForecast.setBackgroundColor(ContextCompat.getColor(this, R.color.main_layouts_background_darker));
        llExtendedForecast.setBackgroundColor(ContextCompat.getColor(this, R.color.main_layouts_background_darker));
        rlBottom.setBackgroundColor(ContextCompat.getColor(this, R.color.main_layouts_background_darker));

        temperatureMeasurement = "fahrenheit";
        if (settings.getString("temperature", "F").equals("C")) {
            temperatureMeasurement = "celsius";
        }

        SharedPreferences.Editor editor = settings.edit();
        boolean isDay = WeatherHelper.isDay(weatherEntity);
        editor.putString("weather", weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getConditions());
        editor.putBoolean("isDay", isDay);
        editor.commit();

        int indexDayEntity;
        if (isDay) {
            indexDayEntity = 0;
        } else {
            indexDayEntity = 1;
        }

        String[] lastUpdated = weatherEntity.getCurrentObservation().getLocalTimeRfc822().split(" ");
        tvToolbarTitle.setText(weatherEntity.getCurrentObservation().getDisplayLocation().get("full"));
        tvToolbarSubTitle.setText(lastUpdated[0] + " " + lastUpdated[2] + " " + lastUpdated[1] + ", " + lastUpdated[3]);


        tvTodayWeather.setText(weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getConditions());

        String wind = null;
        String currentTemp = weatherEntity.getCurrentObservation().getTempC().split("\\.")[0];

        if (temperatureMeasurement.equals("celsius")) {
            if (currentTemp.equals("-0")) {
                tvCurrentTemp.setText("0");
            } else {
                tvCurrentTemp.setText(weatherEntity.getCurrentObservation().getTempC().split("\\.")[0]);
            }
            tvTempLogo.setText("°C");
            tvExtendedForecast.setText(weatherEntity.getForecast().getTxtForecast().getForecastday().get(indexDayEntity).get("fcttext_metric"));
            wind = "wind: " + weatherEntity.getCurrentObservation().getWindKph() + "km/h, " + weatherEntity.getCurrentObservation().getWindDir() + "\n";
        } else {
            currentTemp = weatherEntity.getCurrentObservation().getTempF().split("\\.")[0];
            tvCurrentTemp.setText(currentTemp);
            tvTempLogo.setText("°F");
            tvExtendedForecast.setText(weatherEntity.getForecast().getTxtForecast().getForecastday().get(indexDayEntity).get("fcttext"));
            wind = "wind: " + weatherEntity.getCurrentObservation().getWindMph() + "mph, " + weatherEntity.getCurrentObservation().getWindDir() + "\n";
        }

        String tempHigh = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getHigh().get(temperatureMeasurement);
        String tempLow = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getLow().get(temperatureMeasurement);
        if (!tempHigh.equals("") && Integer.valueOf(currentTemp) > Integer.valueOf(tempHigh)) {
            tvTodayTempH.setText("H:" + currentTemp + "°");
        } else {
            tvTodayTempH.setText("H:" + tempHigh + "°");
        }

        if (!tempLow.equals("") && Integer.valueOf(currentTemp) < Integer.valueOf(tempLow)) {
            tvTodayTempL.setText("L:" + currentTemp + "°");
        } else {
            tvTodayTempL.setText("L:" + tempLow + "°");
        }

        String iconName = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getIcon();
        if (isDay) {
            iconName = "day_" + iconName;
        } else {
            iconName = "night_" + iconName;
        }

        int ivTodayId = getBaseContext().getResources().getIdentifier(iconName, "drawable", getBaseContext().getPackageName());
        ivToday.setBackgroundResource(ivTodayId);

        String subWeatherInfo = "";
        subWeatherInfo += wind;
        subWeatherInfo += "humidity: " + weatherEntity.getCurrentObservation().getRelativeHumidity() + "\n";
        subWeatherInfo += "chance of precipitation: " + weatherEntity.getForecast().getTxtForecast().getForecastday().get(0).get("pop") + "%";
        tvSubWeatherInfo.setText(subWeatherInfo);

        int lineCount = tvExtendedForecast.getLineCount();
        if (lineCount <= 1) {
            tvExtendedForecast.setGravity(Gravity.CENTER);
        } else {
            tvExtendedForecast.setGravity(Gravity.LEFT);
        }

        setAlert();
        fillWeatherPredictionInBottom();
        playVideo();
    }

    @UiThread
    protected void setPersonalForecast() {
        tvWait.setVisibility(View.GONE);
        rlCubeMainSmall.setVisibility(View.GONE);
        wvCubeMainSmall.setVisibility(View.GONE);
        tvPersonalPrediction.setVisibility(View.VISIBLE);
        ivSequencingLogo.setVisibility(View.VISIBLE);
        Map<String, String> day = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getDate();
        String datePrediction = day.get("month") + "/" + day.get("day") + "/" + day.get("year");
        String dateKey = datePrediction + " 12:00:00 AM";
        if (forecasts != null) {
            String forecastPrediction = forecasts.get(dateKey);
            if (forecastPrediction != null) {
                tvPersonalPrediction.setText(forecastPrediction);
            } else {
                tvPersonalPrediction.setText(getString(R.string.error_during_receive_genetically_forecast));
            }
        }
    }

    @Background
    protected void getPersonalRecommendationsForWeek() {
        dateForecastEntities = new ForecastRequestEntity.DateForecastEntity[10];
        for (int i = 0, j = 0; i < 10; i++, j++) {
            addDataToForecastRequest(i, j);
        }
        getPersonalRecommendation(dateForecastEntities);
    }

    private void setAlert() {
        String message = weatherEntity.getAlerts().size() > 0 ? weatherEntity.getAlerts().get(0).getMessage() : null;
        if (message == null) {
            btnAlert.setVisibility(View.GONE);
            return;
        }

        alterMessage = message.replaceAll("\\n\\n", "\n").replaceAll("\\b\n\\b", " ");
        btnAlert.setVisibility(View.VISIBLE);

        FontHelper.overrideFonts(btnAlert, FontHelper.getTypefaceBold(this));
    }

    private void fillWeatherPredictionInBottom() {
        LinearLayout llWeatherForecast = (LinearLayout) findViewById(R.id.llWeatherForecast);
        llWeatherForecast.removeAllViews();
        int orientation = getResources().getConfiguration().orientation;
        if (isTablet) {
            if (orientation == Configuration.ORIENTATION_PORTRAIT) {
                for (int i = 2, j = 1; i < 16; i += 2, j++) {
                    fillWeatherPrediction(llWeatherForecast, i, j);
                }
            } else {
                for (int i = 0, j = 0; i < 20; i += 2, j++) {
                    fillWeatherPrediction(llWeatherForecast, i, j);
                }
            }
        } else {
            for (int i = 2, j = 1; i < 9; i += 2, j++) {
                fillWeatherPrediction(llWeatherForecast, i, j);
            }
        }

    }

    private void fillWeatherPrediction(LinearLayout llWeatherForecast, final int i, final int j) {
        LayoutInflater inflater = (LayoutInflater) this.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        final LinearLayout llSubWeatherForecast = (LinearLayout) inflater.inflate(R.layout.sub_weather_future_prediction, null);
        setPredictionWeatherListener(i, j, llSubWeatherForecast);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.weight = 1;
        llSubWeatherForecast.setLayoutParams(lp);

        TextView tvDayName = (TextView) llSubWeatherForecast.findViewById(R.id.tvDayName);
        tvDayName.setTypeface(typeface);
        String dayWeek = weatherEntity.getForecast().getTxtForecast().getForecastday().get(i).get("title");
        Map<String, String> day = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(j).getDate();
        String datePrediction = day.get("month") + "/" + day.get("day") + "/" + day.get("year");
        String formattedDay = formateDate("EEE MM/dd", datePrediction);
        if (dayWeek.equals("Saturday") || dayWeek.equals("Sunday")) {
            tvDayName.setTextColor(getResources().getColor(R.color.green));
        } else {
            tvDayName.setTextColor(getResources().getColor(R.color.tw__solid_white));
        }
        tvDayName.setText(formattedDay);

        ImageView ivDayIcon = (ImageView) llSubWeatherForecast.findViewById(R.id.ivDayIcon);
        String iconName = "day_" + weatherEntity.getForecast().getTxtForecast().getForecastday().get(i).get("icon");

        int ivDayIconId = this.getResources().getIdentifier(iconName, "drawable", this.getPackageName());
        ivDayIcon.setBackgroundResource(ivDayIconId);

        TextView tvTempH = (TextView) llSubWeatherForecast.findViewById(R.id.tvTempH);
        tvTempH.setTypeface(typeface);
        TextView tvTempL = (TextView) llSubWeatherForecast.findViewById(R.id.tvTempL);
        tvTempL.setTypeface(typeface);

        tvTempH.setText("H:" + weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(j).getHigh().get(temperatureMeasurement) + "°");
        tvTempL.setText("L:" + weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(j).getLow().get(temperatureMeasurement) + "°");

        llWeatherForecast.addView(llSubWeatherForecast);
    }

    private void addDataToForecastRequest(int indexArray, int indexEntity) {
        ForecastRequestEntity.DateForecastEntity forecastEntity = new ForecastRequestEntity.DateForecastEntity();
        Map<String, String> day = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(indexEntity).getDate();
        String datePrediction = day.get("month") + "." + day.get("day") + "." + day.get("year");
        String weather = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(indexEntity).getConditions();
        List<WeatherEntity.Alert> alerts = weatherEntity.getAlerts();
        if (alerts == null || alerts.size() == 0) {
            forecastEntity.setAlertCode("--");
        } else if (alerts.get(0).getAlertCode() != null) {
            forecastEntity.setAlertCode(alerts.get(0).getAlertCode());
        }
        forecastEntity.setDate(datePrediction);
        forecastEntity.setWeather(weather);
        dateForecastEntities[indexArray] = forecastEntity;
    }

    private void setPredictionWeatherListener(final int i, final int j, final LinearLayout llSubWeatherForecast) {
        llSubWeatherForecast.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isPredictionWeatherOpen) {
                    rlToolTip.setVisibility(View.GONE);
                    isPredictionWeatherOpen = false;
                    rlToolTip.removeAllViews();
                    rlToolTip.invalidate();
                } else {
                    isPredictionWeatherOpen = true;
                    onPredictionWeatherClick(llSubWeatherForecast, i, j);
                }
            }
        });
    }

    private void onPredictionWeatherClick(LinearLayout llSubWeatherForecast, int i, int j) {
        LayoutInflater layoutInflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View popUpPredictionLayout = layoutInflater.inflate(R.layout.popup_weather_screen, null);
        FontHelper.overrideFonts(popUpPredictionLayout, typeface);
        TextView popupTitleDay = (TextView) popUpPredictionLayout.findViewById(R.id.tvDayTitle);
        TextView popUpPersonalPrediction = (TextView) popUpPredictionLayout.findViewById(R.id.tvPersonalPredictionDay);
        ProgressBar progressBar = (ProgressBar) popUpPredictionLayout.findViewById(R.id.progressBarForecast);
        TextView popUpForecastDay = (TextView) popUpPredictionLayout.findViewById(R.id.tvExtendedForecastDay);

        if (temperatureMeasurement.equals("celsius")) {
            popUpForecastDay.setText(weatherEntity.getForecast().getTxtForecast().getForecastday().get(i).get("fcttext_metric"));
        } else {
            popUpForecastDay.setText(weatherEntity.getForecast().getTxtForecast().getForecastday().get(i).get("fcttext"));
        }

        Map<String, String> day = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(j).getDate();
        String datePrediction = day.get("month") + "/" + day.get("day") + "/" + day.get("year");
        String dateKey = datePrediction + " 12:00:00 AM";
        String formattedDate = formateDate("EEEE, MMMM d", datePrediction);
        popupTitleDay.setText(formattedDate);
        if (forecasts != null) {
            String forecastPrediction = forecasts.get(dateKey);
            popUpPersonalPrediction.setText(forecastPrediction);
            progressBar.setVisibility(View.GONE);
            popUpPersonalPrediction.setVisibility(View.VISIBLE);
        } else {
            popUpPersonalPrediction.setVisibility(View.GONE);
            progressBar.setVisibility(View.VISIBLE);
        }

        rlToolTip.setVisibility(View.VISIBLE);
        ToolTip toolTip = new ToolTip()
                .withShadow()
                .withContentView(popUpPredictionLayout)
                .withAnimationType(ToolTip.AnimationType.NONE);

        RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(dpToInt(400), RelativeLayout.LayoutParams.WRAP_CONTENT);
        ToolTipView myToolTipView = rlToolTip.showToolTipForView(toolTip, llSubWeatherForecast);
        myToolTipView.setLayoutParams(lp);
    }

    private int dpToInt(int dps) {
        float pxs = dps * getResources().getDisplayMetrics().density;
        return (int) pxs;
    }

    private String formateDate(String patternFormattedDate, String datePrediction) {
        Date date = null;
        SimpleDateFormat formatte = new SimpleDateFormat("MM/dd/yyyy");
        SimpleDateFormat formatter = new SimpleDateFormat(patternFormattedDate, Locale.ENGLISH);

        try {
            date = formatte.parse(datePrediction);
        } catch (ParseException e) {
            e.printStackTrace();
        }
        String formattedDate = formatter.format(date);
        return formattedDate;
    }

    @UiThread
    void selectGeneticFile() {
        Toast.makeText(this, "Please select genetic data file", Toast.LENGTH_LONG).show();
        GeneticFilePreference.runFileSelector(this, false);
    }

    @Background
    void getPersonalRecommendation(ForecastRequestEntity.DateForecastEntity[] dateForecastEntities) {
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
        SharedPreferences.Editor editor = settings.edit();

        String hasVitD = settings.getString("hasVitD", null);
        String riskDescription = settings.getString("riskDescription", null);

        String fileId = settings.getString("genetic_file_id", null);
        if (fileId == null) {
            selectGeneticFile();
            return;
        } else {
            geneticFileId = fileId;
        }
        SequencingOAuth2Client oAuth2Client = InstancesContainer.getoAuth2Client();
        if (oAuth2Client == null) {
            return;
        }

        String accessToken = oAuth2Client.getToken().getAccessToken();
        AndroidAppChainsImpl chains = new AndroidAppChainsImpl(accessToken, "api.sequencing.com");

        Map<String, String> appChainsParams = new HashMap<>();
        appChainsParams.put("Chain9", fileId);
        appChainsParams.put("Chain88", fileId);
        long startStamp = System.currentTimeMillis();
        try {
            Map<String, Report> resultChain = chains.getReportBatch("StartAppBatch", appChainsParams);
            for (String key : resultChain.keySet()) {
                Report report = resultChain.get(key);
                List<DefaultAppChainsImpl.Result> results = report.getResults();
                for (DefaultAppChainsImpl.Result result : results) {
                    ResultType type = result.getValue().getType();
                    if (type == ResultType.TEXT) {
                        DefaultAppChainsImpl.TextResultValue textResultValue = (DefaultAppChainsImpl.TextResultValue) result.getValue();
                        if (result.getName().equals("RiskDescription") && key.equals("Chain9")) {
                            riskDescription = textResultValue.getData();
                        }
                        if (result.getName().equals("result") && key.equals("Chain88")) {
                            hasVitD = textResultValue.getData().equals("No") ? "False" : "True";
                        }
                    }
                }
            }
        } catch (Exception e) {
            long endStamp = System.currentTimeMillis();
            int timeRequest = (int) (endStamp - startStamp);
            sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_APPCHAINS, settings.getLong("timeStampInteraction", 0), endStamp, e.toString());
            setDataViews();
            return;
        }

        long endStamp = System.currentTimeMillis();
        int timeRequest = (int) (endStamp - startStamp);
        sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_APPCHAINS, settings.getLong("timeStampInteraction", 0), 0, null);

        editor.putString("hasVitD", hasVitD);
        editor.putString("riskDescription", riskDescription);
        editor.commit();
        ForecastRequestEntity forecastRequest = new ForecastRequestEntity();
        forecastRequest.setMelanomaRisk(riskDescription);
        forecastRequest.setVitaminD(Boolean.parseBoolean(hasVitD));
        forecastRequest.setAuthToken(InstancesContainer.getoAuth2Client().getToken().getAccessToken());
        forecastRequest.setForecastRequest(dateForecastEntities);

        Map<String, String> headers = new HashMap<String, String>(2);
        headers.put("Content-Type", "application/json");

        startStamp = System.currentTimeMillis();
        String response = HttpHelper.doPost("https://weathermyway.rocks/ExternalForecastRetrieve/GetForecast", headers, JsonHelper.convertToJson(forecastRequest));
        ForecastResponseEntity responseEntity = null;
        if (response == null) {
            endStamp = System.currentTimeMillis();
            timeRequest = (int) (endStamp - startStamp);
            sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_APPCHAINS, settings.getLong("timeStampInteraction", 0), endStamp, null);
            return;
        } else {
            endStamp = System.currentTimeMillis();
            timeRequest = (int) (endStamp - startStamp);
            try {
                responseEntity = JsonHelper.convertToJavaObject(response, ForecastResponseEntity.class);
            } catch (JsonSyntaxException e) {
                sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_APPCHAINS, settings.getLong("timeStampInteraction", endStamp), 0, e.getMessage());
                setDataViews();
                return;
            }
        }

        if (responseEntity != null && responseEntity.getData() != null) {
            sendRequestEvent(timeRequest, 0, Request.REQUEST_SERVICE_APPCHAINS, settings.getLong("timeStampInteraction", 0), 0, null);

            final String gtForecast = responseEntity.getData().get(0).getGtForecast();
            forecasts = new HashMap<>();
            for (ForecastResponseEntity.DaysForecast forecast : responseEntity.getData()) {
                forecasts.put(forecast.getDate(), forecast.getGtForecast());
            }

            editor.putString("genetically_forecast", gtForecast);
            editor.putBoolean("should_refresh", false);
            editor.commit();
        }
        setPersonalForecast();
//        setDataViews();
    }

    private void makeFirebaseReport(String hasVitD, String riskDescription, String fileId, String weather) {
        String emailAddress = AccountHelper.getUserEmail(InstancesContainer.getoAuth2Client().getToken().getAccessToken());
        String s1 = emailAddress.split("@")[0];
        String s2 = emailAddress.split("@")[1];
        String em2 = s1 + "#" + s2;
//        FirebaseCrash.report(new JsonSyntaxException("Personalization is not possible due to insufficient genetic data in the selected file.  Choose a different genetic data file." +
//                " File id:"+ fileId +
//                " /n User email: " + emailAddress +
//                " /n Melanoma risk: " + riskDescription +
//                " /n Vitamin D: " + hasVitD +
//                " /n Weather: " + weather));
//        FirebaseCrash.log("User email: " + em2);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.btnAlert) {
            Intent intent = new Intent(this, AlertActivity.class);
            intent.putExtra("alertText", alterMessage);
            startActivity(intent);
        }
    }

    private void showCube() {
        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
        toolbar.setVisibility(View.GONE);
        rlSpinner.setVisibility(View.VISIBLE);
        svMainLayout.setVisibility(View.GONE);
    }

    @UiThread
    void hideCube() {
        rlSpinner.setVisibility(View.GONE);
        svMainLayout.setVisibility(View.VISIBLE);
        toolbar.setVisibility(View.VISIBLE);
        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
    }

    public static void signOut(final Context context) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setMessage("Are you sure you want to sign out?")
                .setCancelable(true)
                .setNegativeButton("Cancel",
                        new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        })
                .setPositiveButton("Confirm", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {

                        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
                        settings.edit().putBoolean("push_daily_forecast", false).commit();
                        settings.edit().putBoolean("isAppLogout", true).commit();
                        RegistrationIntentService.sendRegistrationToServer(context);

                        settings.edit().putBoolean("push_daily_forecast", true).commit();
                        SQUIoAuthHandler ioAuthHandler = new SQUIoAuthHandler(context);

                        try {
                            ioAuthHandler.logout();
                            InternalStorage.writeObject(context, "oAuth2Client", null);
                        } catch (IOException e) {
                            Log.e(TAG, e.getMessage(), e);
                        }

                        endLastInteraction(context);
                        WeatherSyncReceiver_.cancelAlarm(context);
                        SendLoggingReceiver_.cancelAlarm(context);

                        CookieSyncManager.createInstance(context);
                        CookieManager cookieManager = CookieManager.getInstance();
                        cookieManager.removeAllCookie();

                        Intent intent = new Intent(context, StartActivity_.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK);
                        context.startActivity(intent);
                    }
                });
        AlertDialog alert = builder.create();
        alert.show();
    }

    private void openEmailClient() {
        String URI = "mailto:" + WEATHET_MY_WAY_EMAIL;

        Intent intent = new Intent(Intent.ACTION_VIEW);
        Uri data = Uri.parse(URI);
        intent.setData(data);
        startActivity(intent);
    }

    @Override
    public void onConnected(Bundle bundle) {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
        }
        SharedPreferences.Editor editor = settings.edit();


        Location mLastLocation = LocationServices.FusedLocationApi.getLastLocation(
                mGoogleApiClient);
        if (mLastLocation != null) {
            latitude = mLastLocation.getLatitude();
            longitude = mLastLocation.getLongitude();

            if (!settings.getBoolean("load_app", false))
                return;
            LocationActivity locationActivity = new LocationActivity();
            currentLocation = settings.getString("location", null);
            String location = locationActivity.getCurrentLocation(getApplicationContext(), latitude, longitude);
            if (location == null) {
                return;
            }

            if (currentLocation != null && currentLocation.equals(location)) {
                editor.putBoolean("should_refresh", false);
            } else {
                editor.putBoolean("should_refresh", true);
                currentLocation = location;
                settings.edit().putString("location", location).commit();
                endLastInteraction(this);

                Interaction interaction = new Interaction();
                interaction.lat = latitude;
                interaction.lng = longitude;
                interaction.media = MediaTypeUtil.getNetworkClass(this);
                interaction.place = location;
                interaction.ts = System.currentTimeMillis();
                EventBus.getDefault().post(interaction);

                editor.putLong("timeStampInteraction", interaction.ts);
            }
            editor.putBoolean("load_app", false);
            editor.commit();
            refreshWeather();
        }
    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        if (!settings.getBoolean("load_app", false))
            return;
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean("should_refresh", true).putBoolean("load_app", false).commit();
        manuallySettingLocation();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
    }

    private void manuallySettingLocation() {
        Toast.makeText(this, "Unable to auto detect your location, please select location manually", Toast.LENGTH_LONG).show();
        Intent intent = new Intent(this, LocationActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.startActivity(intent);
    }

    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    public Action getIndexApiAction() {
        Thing object = new Thing.Builder()
                .setName("Main Page") // TODO: Define a title for the content shown.
                // TODO: Make sure this auto-generated URL is correct.
                .setUrl(Uri.parse("http://[ENTER-YOUR-URL-HERE]"))
                .build();
        return new Action.Builder(Action.TYPE_VIEW)
                .setObject(object)
                .setActionStatus(Action.STATUS_TYPE_COMPLETED)
                .build();
    }


    public class AppLocationListener implements LocationListener {

        @Override
        public void onLocationChanged(final Location loc) {
            latitude = loc.getLatitude();
            longitude = loc.getLongitude();
        }

        @Override
        public void onProviderDisabled(String provider) {
            Log.d(TAG, "Gps Disabled");
        }

        @Override
        public void onProviderEnabled(String provider) {
            if(mGoogleApiClient != null){
                mGoogleApiClient.connect();
            }
            Log.d(TAG, "Gps Enabled");
        }

        @Override
        public void onStatusChanged(String provider, int status, Bundle extras) {
        }
    }

    private void showImageAnim(ImageView image) {
        ObjectAnimator pulseAnim = ObjectAnimator.ofPropertyValuesHolder(image,
                PropertyValuesHolder.ofFloat("scaleX", 1.1f),
                PropertyValuesHolder.ofFloat("scaleY", 1.1f));
        pulseAnim.setDuration(1000);
        pulseAnim.setRepeatCount(ObjectAnimator.INFINITE);
        pulseAnim.setRepeatMode(ObjectAnimator.REVERSE);
        pulseAnim.start();

        final ObjectAnimator rotateAnim = ObjectAnimator.ofPropertyValuesHolder(image,
                PropertyValuesHolder.ofFloat("rotation", 0f, 360f));
        rotateAnim.setDuration(1000);
        rotateAnim.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                rotateAnim.setStartDelay(5000);
                rotateAnim.start();
            }

            @Override
            public void onAnimationCancel(Animator animation) {
            }

            @Override
            public void onAnimationRepeat(Animator animation) {
            }
        });
        rotateAnim.start();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case ACCESS_FINE_LOCATION: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    }
                    locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, LOCATION_REQUEST_DELAY, 0, locationListener);

                } else {
                    manuallySettingLocation();
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        setContentView(R.layout.activity_main);
        setViews();
        playVideo();
        if (weatherEntity != null && forecasts != null) {
            setDataViews();
            setPersonalForecast();
        } else {
            getWeatherEntity();
        }
    }
}