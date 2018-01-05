package com.sequencing.weather.service;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.database.sqlite.SQLiteDatabase;
import android.os.Build;
import android.preference.PreferenceManager;
import android.support.annotation.NonNull;
import android.util.Log;

import com.sequencing.weather.activity.RTPApplication;
import com.sequencing.weather.database.DatabaseCreater;
import com.sequencing.weather.database.LoggingQueries;
import com.sequencing.weather.database.SQLiteAccessData;
import com.sequencing.weather.helper.AccountHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.logging.EventEntity;
import com.sequencing.weather.logging.events.Interaction;
import com.sequencing.weather.logging.events.Request;
import com.sequencing.weather.logging.events.Usage;
import com.sequencing.weather.logging.listeners.UsageEventListener;
import com.sequencing.weather.requests.RestLoggingInterface;

import org.androidannotations.annotations.Background;
import org.androidannotations.annotations.EReceiver;
import org.androidannotations.annotations.UiThread;
import org.androidannotations.rest.spring.annotations.RestService;
import org.greenrobot.eventbus.EventBus;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.prefs.Preferences;

import javax.inject.Inject;

import static java.util.concurrent.TimeUnit.MILLISECONDS;
import static java.util.concurrent.TimeUnit.MINUTES;

/**
 * Created by omazurova on 5/18/2017.
 */

@EReceiver
public class SendLoggingReceiver extends BroadcastReceiver {

    private static int EXTRA_BROADCAST_CODE = 222;

    @RestService
    RestLoggingInterface restInterface;

    @Inject
    UsageEventListener usageEventListener;

    @Inject
    SQLiteAccessData sqLiteAccessData;

    private Context context;
    private SharedPreferences settings;

    @Override
    public void onReceive(Context context, Intent intent) {
        this.context = context;
        this.settings = PreferenceManager.getDefaultSharedPreferences(context);
        if(isTimeRefreshExpired(480)){
            RTPApplication application = RTPApplication.create(context);
            application.getDaggerComponent().inject(this);
            if(!usageEventListener.isRegistered()){
                EventBus.getDefault().register(usageEventListener);
                usageEventListener.setIsUsageEventListenerRegistered(true);
            }
            sendLoggingData();
        }
    }

    public static void setAlarm(Context context) {
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        Intent i = new Intent(context, SendLoggingReceiver_.class);
        PendingIntent pi = PendingIntent.getBroadcast(context, EXTRA_BROADCAST_CODE, i, 0);
        am.setRepeating(AlarmManager.RTC_WAKEUP, AlarmManager.INTERVAL_HALF_DAY, AlarmManager.INTERVAL_DAY, pi);
    }

    public static void cancelAlarm(Context context) {
        Intent intent = new Intent(context, SendLoggingReceiver_.class);
        PendingIntent sender = PendingIntent.getBroadcast(context, EXTRA_BROADCAST_CODE, intent, 0);
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (sender != null) {
            alarmManager.cancel(sender);
            sender.cancel();
        }
    }

    public static boolean checkAlarmIsSet(Context context) {
        Intent intent = new Intent(context, SendLoggingReceiver_.class);
        return PendingIntent.getBroadcast(context, EXTRA_BROADCAST_CODE, intent, PendingIntent.FLAG_NO_CREATE) != null;
    }

    @Background
    protected void sendLoggingData() {
        EventEntity eventEntity = buildJsonEvents();
        try{
            restInterface.sendEvents(eventEntity);
            updateTimeSendReport();
            cleanDB();
        } catch (Exception e){
            Log.d("Send logging", e.getMessage());

        }
        EventBus.getDefault().unregister(usageEventListener);
        usageEventListener.setIsUsageEventListenerRegistered(false);
    }

    @UiThread
    protected void updateTimeSendReport() {
        SharedPreferences.Editor editor = settings.edit();
        Date currentDate = new Date();
        editor.putLong("lastTimeSendReport", currentDate.getTime()).commit();
    }

    private void cleanDB(){
        SQLiteDatabase database = sqLiteAccessData.getDatabase();
        database.delete(DatabaseCreater.TABLE_USAGE, null, null);
        database.delete(DatabaseCreater.TABLE_EVENT, null, null);
        database.delete(DatabaseCreater.TABLE_INTERACTION, null, null);
        database.delete(DatabaseCreater.TABLE_REQUEST, null, null);

        Usage usage = new Usage();
        usage.start = System.currentTimeMillis();
        EventBus.getDefault().post(usage);
    }

    private int getAvgNumber(List<Request> requests) {
        int i = 0;
        for (Request request : requests) {
            i = i + request.requestTime;
        }
        return i / requests.size();
    }

    private EventEntity buildJsonEvents() {
        EventEntity eventEntity = new EventEntity();
        eventEntity.user = settings.getString("email", "");
        eventEntity.os = getOSData();
        eventEntity.app = getAppVersion();
        eventEntity.usage = getUsageData();
        return  eventEntity;
    }

    private EventEntity.App getAppVersion() {
        PackageManager manager = context.getPackageManager();
        PackageInfo info = null;
        try {
            info = manager.getPackageInfo(context.getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        String version = info.versionName;
        EventEntity.App app = new EventEntity.App();
        app.ver = version;
        return app;
    }

    private EventEntity.OS getOSData() {
        EventEntity.OS os = new EventEntity.OS();
        os.name = "Android";
        os.ver = "Android SDK: " + Build.VERSION.SDK_INT + "(" + Build.VERSION.RELEASE + ")";
        os.arch = System.getProperty("os.arch");
        return os;
    }

    private EventEntity.Usage getUsageData() {
        SQLiteAccessData sqLiteAccessData = new SQLiteAccessData(context);
        LoggingQueries loggingQueries = new LoggingQueries(sqLiteAccessData);

        EventEntity.Usage usageLogging = new EventEntity.Usage();

        //usage
        Usage usage = loggingQueries.getUsage();
        usageLogging.start = usage.start;
        usageLogging.end = usage.end;

        //events
        usageLogging.events = loggingQueries.getEvents();

        //background wu
        EventEntity.Services services = new EventEntity.Services();
        //wu
        List<Request> backgroundDataWU = loggingQueries.getBackgroundData(Request.REQUEST_SERVICE_WU);

        if (backgroundDataWU.size() > 0) {
            EventEntity.Stats statsWU = getStats(loggingQueries, backgroundDataWU);
            services.wu = statsWU;
        }

        //appchains
        List<Request> backgroundDataAppchains = loggingQueries.getBackgroundData(Request.REQUEST_SERVICE_APPCHAINS);
        if (backgroundDataAppchains.size() > 0) {
            EventEntity.Stats statsAppchains = getStats(loggingQueries, backgroundDataAppchains);
            services.appchains = statsAppchains;
        }

        usageLogging.background = services;

        //interactions
        List<Interaction> interactions = loggingQueries.getInteractions();
        List<EventEntity.Interactions> interactionsLogging = new ArrayList<>();
        List<Request> foregrAppchainsRequests;
        List<Request> foregrWURequests;
        for (Interaction interaction : interactions) {
            EventEntity.Services interactionServices = new EventEntity.Services();
            EventEntity.Interactions interactionLog = new EventEntity.Interactions();
            interactionLog.location = interaction.lat + "," + interaction.lng;
            interactionLog.place = interaction.place;
            interactionLog.ts = interaction.ts;
            interactionLog.duration = interaction.duration;
            interactionLog.media = interaction.media;

            foregrWURequests = loggingQueries.getRequestsByInteractionTimestamp(interaction.ts, Request.REQUEST_SERVICE_WU);
            if(foregrWURequests.size() > 0){
                EventEntity.Stats statsForegWU = getStats(loggingQueries, foregrWURequests);
                interactionServices.wu = statsForegWU;
            }

            foregrAppchainsRequests = loggingQueries.getRequestsByInteractionTimestamp(interaction.ts, Request.REQUEST_SERVICE_APPCHAINS);
            if(foregrAppchainsRequests.size() > 0) {
                EventEntity.Stats statsForegAppChains = getStats(loggingQueries, foregrAppchainsRequests);
                interactionServices.appchains = statsForegAppChains;
            }
            interactionLog.services = interactionServices;
            interactionsLogging.add(interactionLog);
        }

        usageLogging.interactions = interactionsLogging;
        return usageLogging;
    }

    @NonNull
    private EventEntity.Stats getStats(LoggingQueries loggingQueries, List<Request> requests) {
        EventEntity.Stats stats = new EventEntity.Stats();
        stats.h = requests.get(0).requestTime;
        stats.l = requests.get(requests.size() - 1).requestTime;
        stats.n = requests.size();
        stats.avg = getAvgNumber(requests);
        List<EventEntity.Failures> failuresWU = new ArrayList<>();
        for (Request request : requests) {
            if (request.failureTimestamp != 0) {
                EventEntity.Failures failure = new EventEntity.Failures();
                failure.ts = request.failureTimestamp;
                failure.reason = request.failureReason;
                failuresWU.add(failure);
            }
        }
        stats.failures = failuresWU;
        return stats;
    }

    public boolean isTimeRefreshExpired(int intervalMinutes) {
        long maxInterval = MILLISECONDS.convert(intervalMinutes, MINUTES);
        long lastTimeRefresh = settings.getLong("lastTimeSendReport", 0);
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
}
