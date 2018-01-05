package com.sequencing.weather.service;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

import com.google.android.vending.expansion.downloader.DownloaderClientMarshaller;

public class SampleAlarmReceiver extends BroadcastReceiver {
    private final static String TAG = "SampleAlarmReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        try {
            DownloaderClientMarshaller.startDownloadServiceIfRequired(context,
                    intent, ExtensionDownloaderService.class);
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(TAG, "Failed to find needed file name: " + e.getMessage());
            e.printStackTrace();
        }
    }
}