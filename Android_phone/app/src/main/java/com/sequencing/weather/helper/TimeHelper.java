package com.sequencing.weather.helper;

public class TimeHelper {

    public static String transform24ClockFormatTo12(String clockFormat24) {
        if (clockFormat24 == null)
            return null;
        int hours = Integer.parseInt(clockFormat24.split(":")[0]);
        if (hours >= 12)
            clockFormat24 = String.format("%d:%s PM", hours - 12, clockFormat24.split(":")[1]);
        else
            clockFormat24 = String.format("%d:%s AM", hours, clockFormat24.split(":")[1]);

        return clockFormat24;
    }

    public static String transform12ClockFormatTo24(String clockFormat12) {
        if (clockFormat12 == null)
            return null;

        String hoursAndMinutes = clockFormat12.split(" ")[0];
        if(!hoursAndMinutes.contains(":")) {
            hoursAndMinutes = hoursAndMinutes + ":00";
        }

        if (clockFormat12.contains("PM"))
            clockFormat12 = String.format("%s:%s", Integer.parseInt(hoursAndMinutes.split(":")[0]) + 12, hoursAndMinutes.split(":")[1]);
        else
            clockFormat12 = String.format("%s:%s", hoursAndMinutes.split(":")[0], hoursAndMinutes.split(":")[1]);

        return clockFormat12;
    }
}
