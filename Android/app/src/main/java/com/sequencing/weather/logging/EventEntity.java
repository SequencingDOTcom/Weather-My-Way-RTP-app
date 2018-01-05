package com.sequencing.weather.logging;

import java.util.List;

/**
 * Created by omazurova on 5/3/2017.
 */

public class EventEntity {

    public String user;
    public OS os;
    public App app;
    public Usage usage;

    public static class OS {
        public String name;
        public String ver;
        public String arch;
    }

    public static class App {
        public String ver;
    }

    public static class Usage {
        public long start;
        public long end;
        public List<Event> events;
        public Services background;
        public List<Interactions> interactions;
    }

    public static class Event {
        public long ts;
        public int type;
    }

//    public class Background {
//        public Stats wu;
//        public Stats appchains;
//    }

    public static class Stats {
        public int l;
        public int h;
        public int avg;
        public int n;
        public List<Failures> failures;
    }

    public static class Failures {
        public long ts;
        public String reason;
    }

    public static class Interactions {
        public String location;
        public String place;
        public long ts;
        public long duration;
        public int media;
        public Services services;
    }

    public static class Services {
        public Stats wu;
        public Stats appchains;
    }
}
