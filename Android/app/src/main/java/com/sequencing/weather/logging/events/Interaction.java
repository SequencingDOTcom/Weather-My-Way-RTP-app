package com.sequencing.weather.logging.events;

/**
 * Created by omazurova on 5/10/2017.
 */

public class Interaction {

    public long id;
    public double lat;
    public double lng;
    public String place;
    public long ts;
    public long duration;
    public int media;

    public long requestTime;
    public long failureTimestamp;
    public String failureReason;
}
