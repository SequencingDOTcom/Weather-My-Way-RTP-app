package com.sequencing.weather.entity;

/**
 * Created by maksim on 16.09.16.
 */
public class ForecastRequestEntity {

    private String melanomaRisk;
    private boolean vitaminD;
    private String language;
    private String authToken;
    private DateForecastEntity[] forecastRequest;

    public static class DateForecastEntity {
        String date;
        String weather;
        String alertCode;

        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getAlertCode() {
            return alertCode;
        }

        public void setAlertCode(String alertCode) {
            this.alertCode = alertCode;
        }

        public String getWeather() {
            return weather;
        }

        public void setWeather(String weather) {
            this.weather = weather;
        }
    }

    public boolean isVitaminD() {
        return vitaminD;
    }

    public void setVitaminD(boolean vitaminD) {
        this.vitaminD = vitaminD;
    }

    public String getMelanomaRisk() {
        return melanomaRisk;
    }

    public void setMelanomaRisk(String melanomaRisk) {
        this.melanomaRisk = melanomaRisk;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getAuthToken() {
        return authToken;
    }

    public void setAuthToken(String authToken) {
        this.authToken = authToken;
    }

    public DateForecastEntity[] getForecastRequest() {
        return forecastRequest;
    }

    public void setForecastRequest(DateForecastEntity[] forecastRequest) {
        this.forecastRequest = forecastRequest;
    }

    public void setForecastRequest(DateForecastEntity forecastRequest) {
        this.forecastRequest = new DateForecastEntity []{forecastRequest};
    }
}
