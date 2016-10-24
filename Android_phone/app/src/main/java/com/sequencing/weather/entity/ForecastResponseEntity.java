package com.sequencing.weather.entity;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class ForecastResponseEntity {
    @SerializedName("Status")
    private int status;

    @SerializedName("ResponseTime")
    private int responseTime;

    @SerializedName("Data")
    private List<DaysForecast> data;

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getResponseTime() {
        return responseTime;
    }

    public void setResponseTime(int responseTime) {
        this.responseTime = responseTime;
    }

    public List<DaysForecast> getData() {
        return data;
    }

    public void setData(List<DaysForecast> data) {
        this.data = data;
    }

    public static class DaysForecast {
        String gtForecast;
        String date;

        public String getGtForecast() {
            return gtForecast;
        }

        public void setGtForecast(String gtForecast) {
            this.gtForecast = gtForecast;
        }

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }
    }
}
