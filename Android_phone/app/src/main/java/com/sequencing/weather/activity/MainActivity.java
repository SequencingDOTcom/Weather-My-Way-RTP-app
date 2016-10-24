package com.sequencing.weather.activity;

import android.Manifest;
import android.animation.Animator;
import android.animation.ObjectAnimator;
import android.animation.PropertyValuesHolder;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Typeface;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.design.widget.NavigationView;
import android.support.v4.app.ActivityCompat;
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
import android.view.Window;
import android.view.WindowManager;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationServices;
import com.sequencing.androidoauth.core.SQUIoAuthHandler;
import com.sequencing.appchains.AndroidAppChainsImpl;
import com.sequencing.appchains.AppChains;
import com.sequencing.appchains.DefaultAppChainsImpl.Report;
import com.sequencing.appchains.DefaultAppChainsImpl.Result;
import com.sequencing.appchains.DefaultAppChainsImpl.ResultType;
import com.sequencing.appchains.DefaultAppChainsImpl.TextResultValue;
import com.sequencing.oauth.core.SequencingOAuth2Client;
import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.entity.ForecastRequestEntity;
import com.sequencing.weather.entity.ForecastResponseEntity;
import com.sequencing.weather.entity.WeatherEntity;
import com.sequencing.weather.exceptions.WUndergroundException;
import com.sequencing.weather.helper.CSVHelper;
import com.sequencing.weather.helper.ConnectionHelper;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.GeoHelper;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.InternalStorage;
import com.sequencing.weather.helper.JsonHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;
import com.sequencing.weather.helper.WeatherHelper;
import com.sequencing.weather.service.RegistrationIntentService;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener, GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener, View.OnClickListener {
    private static final String WEATHET_MY_WAY_EMAIL = "feedback@weathermyway.rocks";
    private static final String TAG = "MainActivity";
    private static final int LOCATION_REQUEST_DELAY = 1000 * 60;
    private static final int ACCESS_FINE_LOCATION = 9;
    private WeatherEntity weatherEntity = null;

    private String currentLocation;
    private double latitude;
    private double longitude;
    private AppLocationListener locationListener;
    private LocationManager locationManager;
    private ScheduledExecutorService locationMonitor = Executors.newSingleThreadScheduledExecutor();

    private DrawerLayout drawer;

    private ScrollView svMainLayout;
    private WebView wvCubeMain;
    private RelativeLayout rlSpinner;
    private TextView tvMessWait;

    private Typeface typeface;
    private CVideoView videoView;
    private Toolbar toolbar;
    private GoogleApiClient mGoogleApiClient;

    private NavigationView navigationView;

    private TextView tvToolbarTitle;
    private TextView tvToolbarSubTitle;

    private TextView tvCurrentTemp;
    private TextView tvTempLogo;
    private ImageView ivToday;

    private TextView tvSubWeatherInfo;
    private TextView tvTodayWeather;
    private TextView tvTodayTempH;
    private TextView tvTodayTempL;

    private ImageView ivSequencingLogo;
    private TextView tvPersonalPrediction;
    private Button btnAlert;
    private LinearLayout llAlertArea;
    private TextView tvBanner;
    private TextView tvExtendedForecast;

    private ScheduledExecutorService weatherAutomaticRefresher = Executors.newSingleThreadScheduledExecutor();
    private String alterMessage;
    private SharedPreferences settings;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);

        if (mGoogleApiClient == null) {
            mGoogleApiClient = new GoogleApiClient.Builder(this)
                    .addConnectionCallbacks(this)
                    .addOnConnectionFailedListener(this)
                    .addApi(LocationServices.API)
                    .build();
        }

        mGoogleApiClient.connect();

        settings = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean("isMainActivityCreate", true).commit();

        videoView = (CVideoView) findViewById(R.id.video_view);
        init();

        typeface = FontHelper.getTypeface(this);

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

        toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();

        navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        ImageView ivFooter = (ImageView) findViewById(R.id.ivFooter);
        ivFooter.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://sequencing.com/"));
                startActivity(browserIntent);
            }
        });

        wvCubeMain = (WebView) findViewById(R.id.wvCubeMain);
        wvCubeMain.setBackgroundColor(Color.TRANSPARENT);
        wvCubeMain.loadUrl("file:///android_res/drawable/cube_gif.gif");
        rlSpinner = (RelativeLayout) findViewById(R.id.rlSpinner);
        tvMessWait = (TextView) findViewById(R.id.tvMessWait);
        tvMessWait.setTypeface(typeface);

        svMainLayout = (ScrollView) findViewById(R.id.svMainLayout);

        if (settings.getBoolean("load_app", false))
            svMainLayout.setVisibility(View.GONE);

        tvToolbarTitle = (TextView) findViewById(R.id.tvToolbarTitle);
        tvToolbarTitle.setTypeface(typeface);
        tvToolbarSubTitle = (TextView) findViewById(R.id.tvToolbarSubTitle);
        tvToolbarSubTitle.setTypeface(typeface);

        View headerLayout = navigationView.getHeaderView(0);
        TextView tvNavAppBrand = (TextView) headerLayout.findViewById(R.id.tvNavAppBrand);
        tvNavAppBrand.setTypeface(typeface);

        tvCurrentTemp = (TextView) findViewById(R.id.tvCurrentTemp);
        tvCurrentTemp.setTypeface(FontHelper.getTypefaceUltraLight(this));
        tvTempLogo = (TextView) findViewById(R.id.tvTempLogo);
        tvTempLogo.setTypeface(FontHelper.getTypefaceUltraLight(this));

        ivToday = (ImageView) findViewById(R.id.ivToday);

        tvSubWeatherInfo = (TextView) findViewById(R.id.tvSubWeatherInfo);
        tvSubWeatherInfo.setTypeface(typeface);
        tvTodayWeather = (TextView) findViewById(R.id.tvTodayWeather);
        tvTodayWeather.setTypeface(typeface);
        tvTodayTempH = (TextView) findViewById(R.id.tvTodayTempH);
        tvTodayTempL = (TextView) findViewById(R.id.tvTodayTempL);
        tvTodayTempH.setTypeface(typeface);
        tvTodayTempL.setTypeface(typeface);

        tvPersonalPrediction = (TextView) findViewById(R.id.tvPersonalPrediction);
        tvPersonalPrediction.setTypeface(typeface);
        ivSequencingLogo = (ImageView)findViewById(R.id.ivSequencingLogo);

        showImageAnim(ivSequencingLogo);

        btnAlert = (Button) findViewById(R.id.btnAlert);
        btnAlert.setOnClickListener(this);
        llAlertArea = (LinearLayout) findViewById(R.id.llAlertArea);
        llAlertArea.setVisibility(View.GONE);

        tvBanner = (TextView) findViewById(R.id.tvBanner);
        tvBanner.setTypeface(typeface);

        TextView tvPersonalPredictionTitle = (TextView) findViewById(R.id.tvPersonalPredictionTitle);
        tvPersonalPredictionTitle.setTypeface(typeface);
        TextView tvNavPoweredBy = (TextView) findViewById(R.id.tvNavPoweredBy);
        tvNavPoweredBy.setTypeface(typeface);

        tvExtendedForecast = (TextView) findViewById(R.id.tvExtendedForecast);
        tvExtendedForecast.setTypeface(typeface);
        TextView tvExtendedForecastTitle = (TextView) findViewById(R.id.tvExtendedForecastTitle);
        tvExtendedForecastTitle.setTypeface(typeface);

        locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        locationListener = new AppLocationListener();

        int permissionCheck = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION);
        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, ACCESS_FINE_LOCATION);
        } else {
            locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, LOCATION_REQUEST_DELAY, 0, locationListener);
        }

        startLocationMonitoring();
        if (settings.getString("city_id", null) != null) {
            automaticWeatherRefresh();
        }

        Log.i(TAG, "FCM Registration Token: " + settings.getString("newDeviceToken", ""));
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
                            StartActivity.refreshSettings(getApplicationContext(), InstancesContainer.getoAuth2Client().getToken());
                        }
                    }
                });
            }

        }, 30, 30, TimeUnit.MINUTES);
    }

    private void startLocationMonitoring() {
        locationMonitor.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                if (isShouldRefresh(AppLocationListener.latitude, AppLocationListener.longitude)) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            forceWeatherRefresh();
                        }
                    });
                }
            }
        }, LOCATION_REQUEST_DELAY, LOCATION_REQUEST_DELAY, TimeUnit.MILLISECONDS);
    }

    private boolean isShouldRefresh(final double lat, final double lon) {
        int metersRange = 1000; // meters
        Log.d(TAG, String.format("Changing location on %s meters. Lat=%s. Lon=%s", GeoHelper.getDistance(latitude, longitude, lat, lon), lat, lon));

        if (latitude == 0 && longitude == 0) {
            latitude = lat;
            longitude = lon;
            return false;

        } else if (GeoHelper.getDistance(latitude, longitude, lat, lon) >= metersRange) {
            latitude = lat;
            longitude = lon;
            return true;
        }

        return false;
    }

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    protected void onResume() {
        super.onResume();
        refreshWeather();

        toolbar.setBackgroundColor(VideoGeneratorHelper.getTextColorAgainstVideo(this));
        playVideo();
    }

    @Override
    public void onPause() {
        super.onPause();
    }

    @Override
    public void onStop() {
        super.onStop();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
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
        editor.putBoolean("should_refresh", true);

        Map<String, String> cityCodeAndName = new HashMap<String, String>(2);
        try {
            cityCodeAndName.putAll(WeatherHelper.getCityIdByGeoData(AppLocationListener.latitude, AppLocationListener.longitude));
        } catch (WUndergroundException e) {
            manuallySettingLocation();
        }
        editor.putString("city_id", cityCodeAndName.get("code"));
        editor.commit();

        LocationActivity.updateLocation(this, cityCodeAndName.get("name"), AppLocationListener.latitude,
                AppLocationListener.longitude, cityCodeAndName.get("code"));

        refreshWeather();
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        int id = item.getItemId();

        switch (id) {
            case R.id.nav_about:
                Intent about = new Intent(getApplicationContext(), AboutActivity.class);
                about.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                getApplicationContext().startActivity(about);
                break;

            case R.id.nav_settings:
                Intent settings = new Intent(getApplicationContext(), WeatherPreferenceActivity.class);
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
        showCube();

        SharedPreferences.Editor editor = settings.edit();
        String temperatureMeasurement = "fahrenheit";

        if (settings.getString("temperature", "F").equals("C")) {
            temperatureMeasurement = "celsius";
        }

        if (weatherEntity == null || settings.getBoolean("should_refresh", false)) {

            try {
                weatherEntity = WeatherHelper.getCurrentWeather(settings.getString("city_id", "/q/zmw:94105.1.99999"));
            } catch (WUndergroundException e) {
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

                hideCube();
                svMainLayout.setVisibility(View.GONE);
                tvToolbarTitle.setVisibility(View.GONE);
                tvToolbarSubTitle.setVisibility(View.GONE);
                drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);

                editor.putBoolean("should_refresh", false);
                editor.commit();

                return;
            }


            tvToolbarTitle.setVisibility(View.VISIBLE);
            tvToolbarSubTitle.setVisibility(View.VISIBLE);

            if (weatherEntity == null) {
                Toast.makeText(this, "Unable to get weather for your location, please select other location", Toast.LENGTH_LONG).show();

                Intent intent = new Intent(this, LocationActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                this.startActivity(intent);

                return;
            }
        }

        boolean isDay = WeatherHelper.isDay(weatherEntity);
        editor.putString("weather", weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getConditions());
        editor.putBoolean("isDay", isDay);
        editor.commit();

        String[] lastUpdated = weatherEntity.getCurrentObservation().getLocalTimeRfc822().split(" ");
        tvToolbarTitle.setText(weatherEntity.getCurrentObservation().getDisplayLocation().get("full"));
        tvToolbarSubTitle.setText(lastUpdated[0] + " " + lastUpdated[2] + " " + lastUpdated[1] + ", " + lastUpdated[3]);

        tvTodayTempH.setText("H:" + weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getHigh().get(temperatureMeasurement) + "°");
        tvTodayTempL.setText("L:" + weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getLow().get(temperatureMeasurement) + "°");
        tvTodayWeather.setText(weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getConditions());

        String wind = null;
        if (temperatureMeasurement.equals("celsius")) {
            tvCurrentTemp.setText(weatherEntity.getCurrentObservation().getTempC().split("\\.")[0]);
            tvTempLogo.setText("°C");
            tvExtendedForecast.setText(weatherEntity.getForecast().getTxtForecast().getForecastday().get(0).get("fcttext_metric"));
            wind = "wind: " + weatherEntity.getCurrentObservation().getWindKph() + "km/h, " + weatherEntity.getCurrentObservation().getWindDir() + "\n";
        } else {
            tvCurrentTemp.setText(weatherEntity.getCurrentObservation().getTempF().split("\\.")[0]);
            tvTempLogo.setText("°F");
            tvExtendedForecast.setText(weatherEntity.getForecast().getTxtForecast().getForecastday().get(0).get("fcttext"));
            wind = "wind: " + weatherEntity.getCurrentObservation().getWindMph() + "mph, " + weatherEntity.getCurrentObservation().getWindDir() + "\n";
        }

        String iconName = weatherEntity.getForecast().getSimpleForecast().getForecastDays().get(0).getIcon();
        if (isDay)
            iconName = "day_" + iconName;
        else
            iconName = "night_" + iconName;

        int ivTodayId = getBaseContext().getResources().getIdentifier(iconName, "drawable", getBaseContext().getPackageName());
        ivToday.setBackgroundResource(ivTodayId);

        String subWeatherInfo = "";
        subWeatherInfo += wind;
        subWeatherInfo += "humidity: " + weatherEntity.getCurrentObservation().getRelativeHumidity() + "\n";
        subWeatherInfo += "chance of precipitation: " + weatherEntity.getForecast().getTxtForecast().getForecastday().get(0).get("pop") + "%";
        tvSubWeatherInfo.setText(subWeatherInfo);

        int lineCount = tvExtendedForecast.getLineCount();
        if(lineCount == 1) {
            tvExtendedForecast.setGravity(Gravity.CENTER);
        } else {
            tvExtendedForecast.setGravity(Gravity.LEFT);
        }

        setAlert();

        fillWeatherPredictionInBottom(temperatureMeasurement, isDay);

        if (settings.getString("genetic_data_file", null) != null) {
            new PersonalPredictionAsyncTask().execute();
        }

        playVideo();
    }

    private void setAlert() {
        String message = weatherEntity.getAlerts().size() > 0 ? weatherEntity.getAlerts().get(0).getMessage() : null;
        if (message == null) {
            llAlertArea.setVisibility(View.GONE);
            return;
        }

        alterMessage = message.replaceAll("\\n\\n", "\n").replaceAll("\\b\n\\b", " ");
        llAlertArea.setVisibility(View.VISIBLE);
    }

    private void fillWeatherPredictionInBottom(String temperatureMeasurement, boolean isDay) {
        LinearLayout llWeatherForecast = (LinearLayout) findViewById(R.id.llWeatherForecast);
        llWeatherForecast.removeAllViews();

        for (int i = 2, j = 1; i < 9; i += 2, j++) {

            LayoutInflater inflater = (LayoutInflater) this.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            LinearLayout llSubWeatherForecast = (LinearLayout) inflater.inflate(R.layout.sub_weather_future_prediction, null);

            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT);
            lp.weight = 1;
            llSubWeatherForecast.setLayoutParams(lp);

            TextView tvDayName = (TextView) llSubWeatherForecast.findViewById(R.id.tvDayName);
            tvDayName.setText(weatherEntity.getForecast().getTxtForecast().getForecastday().get(i).get("title"));
            tvDayName.setTypeface(typeface);

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
    }

    private void getPersonalRecommendation() {
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
        SharedPreferences.Editor editor = settings.edit();

        String hasVitD = settings.getString("hasVitD", null);
        String riskDescription = settings.getString("riskDescription", null);

        if (settings.getBoolean("should_refresh", true)) {

            SequencingOAuth2Client oAuth2Client = InstancesContainer.getoAuth2Client();
            if(oAuth2Client == null) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        tvPersonalPrediction.setText(getResources().getString(R.string.error_during_receive_genetically_forecast));
                    }
                });
                return;
            }

            String accessToken = oAuth2Client.getToken().getAccessToken();
            String fileId = settings.getString("genetic_file_id", null);

            AppChains chains = new AndroidAppChainsImpl(accessToken, "api.sequencing.com");

            Report resultChain9;
            Report resultChain88;
            try {
                resultChain9 = chains.getReport("StartApp", "Chain9", fileId);
                resultChain88 = chains.getReport("StartApp", "Chain88", fileId);
            } catch (Exception e) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        tvPersonalPrediction.setText(getResources().getString(R.string.error_during_receive_genetically_forecast));
                    }
                });
                return;
            }

            if (resultChain9.isSucceeded() == false || resultChain88.isSucceeded() == false) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        tvPersonalPrediction.setText(getResources().getString(R.string.error_during_receive_genetically_forecast));
                    }
                });
                return;
            }

            for (Result r : resultChain9.getResults()) {
                ResultType type = r.getValue().getType();
                if (type == ResultType.TEXT) {
                    TextResultValue v = (TextResultValue) r.getValue();

                    if (r.getName().equals("RiskDescription"))
                        riskDescription = v.getData();
                }
            }

            for (Result r : resultChain88.getResults()) {
                ResultType type = r.getValue().getType();
                if (type == ResultType.TEXT) {
                    TextResultValue v = (TextResultValue) r.getValue();

                    if (r.getName().equals("result"))
                        hasVitD = v.getData().equals("No") ? "False" : "True";
                }
            }

            editor.putString("hasVitD", hasVitD);
            editor.putString("riskDescription", riskDescription);
            editor.commit();

        }

        String weather = settings.getString("weather", null);

        ForecastRequestEntity forecastRequest = new ForecastRequestEntity();
        forecastRequest.setMelanomaRisk(riskDescription);
        forecastRequest.setVitaminD(Boolean.parseBoolean(hasVitD));
        forecastRequest.setAuthToken(InstancesContainer.getoAuth2Client().getToken().getAccessToken());

        ForecastRequestEntity.DateForecastEntity dateForecastEntity = new ForecastRequestEntity.DateForecastEntity();
        dateForecastEntity.setWeather(weather);
        SimpleDateFormat sdf = new SimpleDateFormat("MM.dd.yyyy");
        dateForecastEntity.setDate(sdf.format(new Date()));

        forecastRequest.setForecastRequest(dateForecastEntity);

        Map<String, String> headers = new HashMap<String, String>(2);
        headers.put("Content-Type", "application/json");

        String response = HttpHelper.doPost("https://weathermyway.rocks/ExternalForecastRetrieve/GetForecast", headers, JsonHelper.convertToJson(forecastRequest));
        ForecastResponseEntity responseEntity = null;
        if(response == null) {
            return;
        } else {
            responseEntity = JsonHelper.convertToJavaObject(response, ForecastResponseEntity.class);
        }

//        final String forecast = CSVHelper.getGeneticallyTailoredForecast(this, riskDescription, hasVitD, weather);

        final String gtForecast = responseEntity.getData().get(0).getGtForecast();
        editor.putString("genetically_forecast", gtForecast);
        editor.commit();
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                tvPersonalPrediction.setText(gtForecast);
            }
        });
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


    public class PersonalPredictionAsyncTask extends AsyncTask<Void, Void, Void> {

        @Override
        protected void onPreExecute() {
            Log.d(TAG, "Start compute genetically forecast");
        }

        @Override
        protected Void doInBackground(Void... params) {
            getPersonalRecommendation();
            return null;
        }

        @Override
        protected void onPostExecute(Void v) {
            hideCube();
            SharedPreferences.Editor editor = settings.edit();
            editor.putBoolean("should_refresh", false).commit();
            Log.i(TAG, "Finish compute genetically forecast");
            Log.i(TAG, "Weather has been refreshed");
        }
    }

    private void showCube() {
        drawer.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
        toolbar.setVisibility(View.GONE);
        rlSpinner.setVisibility(View.VISIBLE);
        svMainLayout.setVisibility(View.GONE);
    }

    private void hideCube() {
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
                        RegistrationIntentService.sendRegistrationToServer(context);

                        SQUIoAuthHandler ioAuthHandler = new SQUIoAuthHandler(context);
                        PreferenceManager.getDefaultSharedPreferences(context).edit().clear().commit();

                        try {
                            ioAuthHandler.logout();
                            InternalStorage.writeObject(context, "oAuth2Client", null);
                        } catch (IOException e) {
                            Log.e(TAG, e.getMessage(), e);
                        }

                        CookieSyncManager.createInstance(context);
                        CookieManager cookieManager = CookieManager.getInstance();
                        cookieManager.removeAllCookie();

                        Intent intent = new Intent(context, StartActivity.class);
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
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
            return;
        }
        SharedPreferences.Editor editor = settings.edit();
        if (!settings.getBoolean("load_app", false))
            return;

        Location mLastLocation = LocationServices.FusedLocationApi.getLastLocation(
                mGoogleApiClient);
        if (mLastLocation != null) {
            double latitude = mLastLocation.getLatitude();
            double longitude = mLastLocation.getLongitude();

            LocationActivity locationActivity = new LocationActivity();

            String location = locationActivity.getCurrentLocation(getApplicationContext(), latitude, longitude);
            if (location == null)
                return;

            refreshWeather();
            editor.putBoolean("should_refresh", true).putBoolean("load_app", false).commit();
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
        outState.putString("currentLocation", currentLocation);
        outState.putSerializable("weatherEntity", weatherEntity);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        currentLocation = savedInstanceState.getString("currentLocation");
        weatherEntity = (WeatherEntity) savedInstanceState.getSerializable("weatherEntity");
    }

    private void manuallySettingLocation() {
        Toast.makeText(this, "Unable to auto detect your location, please select location manually", Toast.LENGTH_LONG).show();
        Intent intent = new Intent(this, LocationActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.startActivity(intent);
    }


    public static class AppLocationListener implements LocationListener {
        public static double latitude;
        public static double longitude;

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
//                        return;
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
}