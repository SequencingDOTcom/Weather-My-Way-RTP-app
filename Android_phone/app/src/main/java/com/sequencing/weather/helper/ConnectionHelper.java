package com.sequencing.weather.helper;

import android.content.Context;
import android.net.ConnectivityManager;

public class ConnectionHelper {

    public static boolean isConnectionAvailable(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        return (cm.getActiveNetworkInfo() != null);
    }
}
