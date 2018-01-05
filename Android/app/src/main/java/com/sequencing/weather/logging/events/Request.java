package com.sequencing.weather.logging.events;

/**
 * Created by omazurova on 5/10/2017.
 */

public class Request {
    public static int REQUEST_SERVICE_WU = 0;
    public static int REQUEST_SERVICE_APPCHAINS = 1;

    public int requestTime;
    public int requestService;
    public int requestBackground;
    public long failureTimestamp;
    public String failureReason;

    public long interactionTimestamp;
}
