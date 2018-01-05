package com.sequencing.weather.service;

import android.Manifest;
import android.app.AlarmManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.preference.PreferenceManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.NotificationCompat;

import com.google.gson.JsonSyntaxException;
import com.sequencing.weather.R;
import com.sequencing.weather.activity.RTPApplication;
import com.sequencing.weather.entity.WeatherEntity;
import com.sequencing.weather.exceptions.WUndergroundException;
import com.sequencing.weather.helper.WeatherHelper;
import com.sequencing.weather.logging.events.Request;
import com.sequencing.weather.logging.listeners.RequestEventListener;

import org.androidannotations.annotations.Background;
import org.androidannotations.annotations.EReceiver;
import org.androidannotations.annotations.UiThread;
import org.greenrobot.eventbus.EventBus;

import java.util.Date;
import java.util.Map;

import javax.inject.Inject;

import me.leolin.shortcutbadger.ShortcutBadger;

import static java.util.concurrent.TimeUnit.MILLISECONDS;
import static java.util.concurrent.TimeUnit.MINUTES;

/**
 * Created by omazurova on 12.04.2017.
 */

@EReceiver
public class WeatherSyncReceiver extends BroadcastReceiver {
    private Context context;
    private static LocationManager locationManager;
    private Location location;
    private double latitude;
    private double longitude;
    private SharedPreferences settings;

    @Inject
    RequestEventListener requestEventListener;
    private static String MY_ACTION = "com.sequecing.weather.syncweather";

    @Override
    public void onReceive(Context context, Intent intent) {
            this.context = context;
            this.settings = PreferenceManager.getDefaultSharedPreferences(context);
            RTPApplication application = RTPApplication.create(context);
            application.getDaggerComponent().inject(this);
            if (!requestEventListener.isRegistered()) {
                EventBus.getDefault().register(requestEventListener);
                requestEventListener.setIsRequestListenerRegistered(true);
            }
            checkLocation();
    }

    public static void setAlarm(Context context) {
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        Intent i = new Intent(context, WeatherSyncReceiver_.class);
        PendingIntent pi = PendingIntent.getBroadcast(context, 111, i, 0);
        am.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis(), AlarmManager.INTERVAL_HALF_HOUR, pi);

        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = settings.edit();
        editor.putLong("lastTimeBackgroundSync", 0).commit();
    }

    public static void cancelAlarm(Context context) {
        Intent intent = new Intent(context, WeatherSyncReceiver_.class);
        PendingIntent sender = PendingIntent.getBroadcast(context, 111, intent, 0);
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (sender != null) {
            alarmManager.cancel(sender);
            sender.cancel();
            ShortcutBadger.removeCount(context.getApplicationContext());
            if (locationManager != null) {
                if (ActivityCompat.checkSelfPermission(context.getApplicationContext(), Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(context.getApplicationContext(), Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    return;
                }
            }
        }
    }

    public static boolean checkAlarmIsSet(Context context) {
        Intent intent = new Intent(context, WeatherSyncReceiver_.class);
        return PendingIntent.getBroadcast(context, 111, intent, PendingIntent.FLAG_NO_CREATE) != null;
    }

    public void checkLocation() {
        locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        if (ActivityCompat.checkSelfPermission(context.getApplicationContext(), android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(context.getApplicationContext(), android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }

        if(isGPSEnabled()){
            if (locationManager != null) {
                location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
                if (location != null) {
                    latitude = location.getLatitude();
                    longitude = location.getLongitude();
                    checkChangedLocation(latitude, longitude);
                    return;
                }
            }
        } else {
            checkLastTimeRefresh();
        }

        if(isNetworkEnabled()){
            if (locationManager != null) {
                location = locationManager
                        .getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                if (location != null) {
                    latitude = location.getLatitude();
                    longitude = location.getLongitude();
                    checkChangedLocation(latitude, longitude);
                    return;
                }
            }
        } else {
            checkLastTimeRefresh();
        }
    }

    private void checkLastTimeRefresh(){
        if(isTimeRefreshExpired(480)){
            ShortcutBadger.removeCount(context.getApplicationContext());
        }
    }

    @UiThread
    protected void showToast() {
//        Toast.makeText(context, "Location updated", Toast.LENGTH_SHORT).show();
    }

    @Background
    protected void checkChangedLocation(double latitude, double longitude) {
        SharedPreferences.Editor editor = settings.edit();
        String lastCityId = settings.getString("city_id", "");
        String cityId = "";
        long startStamp = System.currentTimeMillis();
        try {
            Map<String, String> location = WeatherHelper.getCityIdByGeoData(latitude, longitude);
            cityId = location.get("code");
        } catch (WUndergroundException | JsonSyntaxException e) {
            long endStamp = System.currentTimeMillis();
            int timeRequest = (int) (endStamp - startStamp);
            sendBackgroundEvent(timeRequest, Request.REQUEST_SERVICE_WU, endStamp, e.toString());
            return;
        }
        long endStamp = System.currentTimeMillis();
        int timeRequest = (int) (endStamp - startStamp);
        sendBackgroundEvent(timeRequest, Request.REQUEST_SERVICE_WU, 0, null);

        if (lastCityId.equals("") || !lastCityId.equals(cityId) || isTimeRefreshExpired(2)) {
            editor.putString("city_id", cityId);
            editor.commit();
            getWeatherEntity(cityId);
        } else {
            EventBus.getDefault().unregister(requestEventListener);
            requestEventListener.setIsRequestListenerRegistered(false);
        }
    }

    private void sendBackgroundEvent(int requestTime, int service, long failureTimestamp, String failureReason) {
        Request request = new Request();
        request.requestTime = requestTime;
        request.requestBackground = 1;
        request.requestService = service;
        request.failureTimestamp = failureTimestamp;
        request.failureReason = failureReason;
        request.interactionTimestamp = 0;
        EventBus.getDefault().post(request);
    }

    public boolean isTimeRefreshExpired(int intervalMinutes) {
        long maxInterval = MILLISECONDS.convert(intervalMinutes, MINUTES);
        Date lastUpdateDate = null;
        long lastTimeRefresh = settings.getLong("lastTimeBackgroundSync", 0);
        if(lastTimeRefresh == 0){
            return true;
        }

        Date currentDate = new Date();
        long currentInterval = currentDate.getTime() - lastTimeRefresh;
        if (currentInterval > maxInterval) {
            return true;
        }
        return false;
    }

    @Background
    protected void getWeatherEntity(String cityId) {
        WeatherEntity weatherEntity;
        long startStamp = System.currentTimeMillis();
        try {
            weatherEntity = WeatherHelper.getCurrentWeather(cityId);
        } catch (WUndergroundException | JsonSyntaxException e) {
            long endStamp = System.currentTimeMillis();
            int timeRequest = (int) (endStamp - startStamp);
            sendBackgroundEvent(timeRequest, Request.REQUEST_SERVICE_WU, endStamp, e.toString());
            EventBus.getDefault().unregister(requestEventListener);
            requestEventListener.setIsRequestListenerRegistered(false);
//            retryRequestWithDelay();
            return;
        } catch (RuntimeException e) {
            long endStamp = System.currentTimeMillis();
            int timeRequest = (int) (endStamp - startStamp);
            sendBackgroundEvent(timeRequest, Request.REQUEST_SERVICE_WU, endStamp, e.toString());
            EventBus.getDefault().unregister(requestEventListener);
            requestEventListener.setIsRequestListenerRegistered(false);
//            retryRequestWithDelay();
            return;
        }

        if (weatherEntity == null) {
            return;
        } else {
            long endStamp = System.currentTimeMillis();
            int timeRequest = (int) (endStamp - startStamp);
            sendBackgroundEvent(timeRequest, Request.REQUEST_SERVICE_WU, 0, null);
            updateTimeRefresh();
            updateWeather(weatherEntity);
        }
    }

    @UiThread
    protected void updateWeather(WeatherEntity weatherEntity) {
        String currentTemp;
        String temperatureMeasurement = "°F";
        if (settings.getString("temperature", "F").equals("C")) {
            temperatureMeasurement = "°C";
            currentTemp = weatherEntity.getCurrentObservation().getTempC().split("\\.")[0];
        } else {
            currentTemp = weatherEntity.getCurrentObservation().getTempF().split("\\.")[0];
        }

        NotificationManager mNotifyMgr =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(context)
                .setSmallIcon(R.drawable.android_icon_weather_my_way)
                .setTicker(currentTemp + "" + temperatureMeasurement)
                .setContentTitle("Current weather forecast")
                .setContentText(currentTemp + temperatureMeasurement)
                .setOngoing(false)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setAutoCancel(true);
        Intent i = new Intent(context, WeatherSyncReceiver.class);
        PendingIntent pendingIntent =
                PendingIntent.getActivity(
                        context,
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
        ShortcutBadger.applyCount(context.getApplicationContext(), count);
        EventBus.getDefault().unregister(requestEventListener);
    }

    @UiThread
    protected void updateTimeRefresh() {
        SharedPreferences.Editor editor = settings.edit();
        Date currentDate = new Date();
        editor.putLong("lastTimeBackgroundSync", currentDate.getTime()).commit();
    }

    public static boolean isInternetConnected(Context ctx) {
        ConnectivityManager connectivityMgr = (ConnectivityManager) ctx
                .getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo wifi = connectivityMgr.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        NetworkInfo mobile = connectivityMgr.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
        // Check if wifi or mobile network is available or not. If any of them is
        // available or connected then it will return true, otherwise false;
        if (wifi != null) {
            if (wifi.isConnected()) {
                return true;
            }
        }
        if (mobile != null) {
            if (mobile.isConnected()) {
                return true;
            }
        }
        return false;
    }

    public boolean isGPSEnabled() {
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
    }

    public boolean isNetworkEnabled() {
        return locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
    }
}
