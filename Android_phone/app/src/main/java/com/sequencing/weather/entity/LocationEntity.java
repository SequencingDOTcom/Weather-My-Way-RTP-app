package com.sequencing.weather.entity;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class LocationEntity {

    @SerializedName("RESULTS")
    private List<City> cities;

    public List<City> getCities() {
        return cities;
    }

    public void setCities(List<City> cities) {
        this.cities = cities;
    }

    public static class City {

        private String name;
        private String type;
        private String c;
        private String zmw;
        private String tz;
        private String tzs;
        private String l;
        private String ll;
        private double lat;
        private double lon;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getC() {
            return c;
        }

        public void setC(String c) {
            this.c = c;
        }

        public String getZmw() {
            return zmw;
        }

        public void setZmw(String zmw) {
            this.zmw = zmw;
        }

        public String getTz() {
            return tz;
        }

        public void setTz(String tz) {
            this.tz = tz;
        }

        public String getTzs() {
            return tzs;
        }

        public void setTzs(String tzs) {
            this.tzs = tzs;
        }

        public String getL() {
            return l;
        }

        public void setL(String l) {
            this.l = l;
        }

        public String getLl() {
            return ll;
        }

        public void setLl(String ll) {
            this.ll = ll;
        }

        public double getLat() {
            return lat;
        }

        public void setLat(double lat) {
            this.lat = lat;
        }

        public double getLon() {
            return lon;
        }

        public void setLon(double lon) {
            this.lon = lon;
        }

        @Override
        public String toString() {
            return "Results{" +
                    "name='" + name + '\'' +
                    ", type='" + type + '\'' +
                    ", c='" + c + '\'' +
                    ", zmw='" + zmw + '\'' +
                    ", tz='" + tz + '\'' +
                    ", tzs='" + tzs + '\'' +
                    ", l='" + l + '\'' +
                    ", ll='" + ll + '\'' +
                    ", lat='" + lat + '\'' +
                    ", lon='" + lon + '\'' +
                    '}';
        }
    }
}
