package com.sequencing.weather.helper;

import java.util.Arrays;
import java.util.Comparator;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

public class TimezoneHelper{

    public static String[] getTimezonesAsArray () {
        String[] ids = TimeZone.getAvailableIDs();
        String[] timezones = new String [ids.length];

        for (int i = 0; i < ids.length; i++)
            timezones[i] = getTimezoneById(TimeZone.getTimeZone(ids[i]));

        Arrays.sort(timezones, new TimeZoneComparator());
        return  timezones;
    }

    public static String getTimezoneById(TimeZone tz) {
        long hours = TimeUnit.MILLISECONDS.toHours(tz.getRawOffset());
        long minutes = TimeUnit.MILLISECONDS.toMinutes(tz.getRawOffset())
                - TimeUnit.HOURS.toMinutes(hours);
        // avoid -4:-30 issue
        minutes = Math.abs(minutes);

        String display = tz.getDisplayName(true, TimeZone.SHORT);

        String result = String.format("(%s) %s", display, tz.getID());

        if(result.split(" ")[0].length() < 7) {
            if (hours >= 0) {
                result = String.format("(GMT+%d:%02d) %s", hours, minutes, tz.getID());
            } else {
                result = String.format("(GMT%d:%02d) %s", hours, minutes, tz.getID());
            }
        }

        return result;
    }

    private static class TimeZoneComparator implements Comparator<String> {

        @Override
        public int compare(String lhs, String rhs) {
            int lh;
            int rh;
            if(lhs.split(":")[0].substring(4).startsWith("+")){
                lh = Integer.parseInt(lhs.split(":")[0].substring(5));
            } else {
                lh = Integer.parseInt(lhs.split(":")[0].substring(4));
            }
            if(rhs.split(":")[0].substring(4).startsWith("+")){
                rh = Integer.parseInt(rhs.split(":")[0].substring(5));
            } else {
                rh = Integer.parseInt(rhs.split(":")[0].substring(4));
            }
            return Integer.compare(lh, rh);
        }
    }

}
