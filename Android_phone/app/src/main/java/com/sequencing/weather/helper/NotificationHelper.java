package com.sequencing.weather.helper;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.support.v4.app.NotificationCompat;

import com.sequencing.weather.R;
import com.sequencing.weather.activity.PreStartedActivity;

public class NotificationHelper {

    public static void sendNotification(Context context, String subject ,String message){
        Uri alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        long[] pattern = {500,500,500,500,500};

        NotificationCompat.Builder locationNotification =
                new NotificationCompat.Builder(context)
                        .setSmallIcon(R.drawable.android_icon_weather_my_way)
                        .setContentTitle(subject)
                        .setContentText(message)
                        .setAutoCancel(true)
                        .setSound(alarmSound)
                        .setVibrate(pattern)
                        .setStyle(new NotificationCompat.BigTextStyle()
                                .bigText(message));

        Intent resultIntent = new Intent(context, PreStartedActivity.class);

        PendingIntent resultPendingIntent =
                PendingIntent.getActivity(context, 0, resultIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        locationNotification.setContentIntent(resultPendingIntent);

        NotificationManager mNotificationManager =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        mNotificationManager.notify(001, locationNotification.build());
    }
}
