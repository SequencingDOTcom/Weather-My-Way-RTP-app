package com.sequencing.weather.entity;


import com.google.gson.annotations.SerializedName;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

public class WeatherEntity implements Serializable{

    @SerializedName("response")
    private Response response;

    @SerializedName("current_observation")
    private CurrentObservation currentObservation;

    @SerializedName("forecast")
    private Forecast forecast;

    @SerializedName("moon_phase")
    private MoonPhase moonPhase;

    @SerializedName("sun_phase")
    private SunPhase sunPhase;

    @SerializedName("alerts")
    private List<Alert> alerts;


    @SerializedName("query_zone")
    private String queryZone;


    public Response getResponse() {
        return response;
    }

    public void setResponse(Response response) {
        this.response = response;
    }

    public CurrentObservation getCurrentObservation() {
        return currentObservation;
    }

    public void setCurrentObservation(CurrentObservation currentObservation) {
        this.currentObservation = currentObservation;
    }

    public Forecast getForecast() {
        return forecast;
    }

    public void setForecast(Forecast forecast) {
        this.forecast = forecast;
    }

    public MoonPhase getMoonPhase() {
        return moonPhase;
    }

    public void setMoonPhase(MoonPhase moonPhase) {
        this.moonPhase = moonPhase;
    }

    public SunPhase getSunPhase() {
        return sunPhase;
    }

    public void setSunPhase(SunPhase sunPhase) {
        this.sunPhase = sunPhase;
    }

    public String getQueryZone() {
        return queryZone;
    }

    public void setQueryZone(String queryZone) {
        this.queryZone = queryZone;
    }

    public List<Alert> getAlerts() {
        return alerts;
    }

    public void setAlerts(List<Alert> alerts) {
        this.alerts = alerts;
    }

    public class Response implements Serializable{
        private String version;
        private String termsofService;
        private Map<String, String> features;

        public String getVersion() {
            return version;
        }

        public void setVersion(String version) {
            this.version = version;
        }

        public String getTermsofService() {
            return termsofService;
        }

        public void setTermsofService(String termsofService) {
            this.termsofService = termsofService;
        }

        public Map<String, String> getFeatures() {
            return features;
        }

        public void setFeatures(Map<String, String> features) {
            this.features = features;
        }
    }

    public class CurrentObservation implements Serializable {

        private Map<String, String> image;

        @SerializedName("display_location")
        private Map<String, String> displayLocation;

        @SerializedName("observation_location")
        private Map<String, String> observationLocation;

        @SerializedName("station_id")
        private String stationId;

        @SerializedName("observation_time")
        private String observationTime;

        @SerializedName("observation_time_rfc822")
        private String observationTimeRfc822;

        @SerializedName("observation_epoch")
        private String observationEpoch;

        @SerializedName("local_time_rfc822")
        private String localTimeRfc822;

        @SerializedName("local_epoch")
        private String localEpoch;

        @SerializedName("local_tz_short")
        private String localTzShort;

        @SerializedName("local_tz_long")
        private String localTzLong;

        @SerializedName("local_tz_offset")
        private String localTzOffset;

        @SerializedName("weather")
        private String weather;

        @SerializedName("temperature_string")
        private String temperatureString;

        @SerializedName("temp_f")
        private String tempF;

        @SerializedName("temp_c")
        private String tempC;

        @SerializedName("relative_humidity")
        private String relativeHumidity;

        @SerializedName("wind_string")
        private String windString;

        @SerializedName("wind_dir")
        private String windDir;

        @SerializedName("wind_degrees")
        private String windDegrees;

        @SerializedName("wind_mph")
        private String windMph;

        @SerializedName("wind_gust_mph")
        private String windGustMph;

        @SerializedName("wind_kph")
        private String windKph;

        @SerializedName("wind_gust_kph")
        private String windGustKph;

        @SerializedName("pressure_mb")
        private String pressureMb;

        @SerializedName("pressure_in")
        private String pressureIn;

        @SerializedName("pressure_trend")
        private String pressureTrend;

        @SerializedName("dewpoint_string")
        private String dewpointString;

        @SerializedName("dewpoint_f")
        private String dewpointF;

        @SerializedName("dewpoint_c")
        private String dewpointC;

        @SerializedName("heat_index_string")
        private String heatIndexString;

        @SerializedName("heat_index_f")
        private String heatIndexF;

        @SerializedName("heat_index_c")
        private String heatIndexC;

        @SerializedName("windchill_string")
        private String windchillString;

        @SerializedName("windchill_f")
        private String windchillF;

        @SerializedName("windchill_c")
        private String windchillC;

        @SerializedName("feelslike_string")
        private String feelslikeString;

        @SerializedName("feelslike_f")
        private String feelslikeF;

        @SerializedName("feelslike_c")
        private String feelslikeC;

        @SerializedName("visibility_mi")
        private String visibilityMi;

        @SerializedName("visibility_km")
        private String visibilityKm;

        @SerializedName("solarradiation")
        private String solarradiation;

        @SerializedName("UV")
        private String Uv;

        @SerializedName("precip_1hr_string")
        private String precip1hrString;

        @SerializedName("precip_1hr_in")
        private String precip1hrIn;

        @SerializedName("precip_1hr_metric")
        private String precip1hrMetric;

        @SerializedName("precip_today_string")
        private String precipTodayString;

        @SerializedName("precip_today_in")
        private String precipTodayIn;

        @SerializedName("precip_today_metric")
        private String precipTodayMetric;

        @SerializedName("icon")
        private String icon;

        @SerializedName("icon_url")
        private String iconUrl;

        @SerializedName("forecast_url")
        private String forecastUrl;

        @SerializedName("history_url")
        private String historyUrl;

        @SerializedName("ob_url")
        private String obUrl;

        @SerializedName("nowcast")
        private String nowcast;

        public Map<String, String> getImage() {
            return image;
        }

        public void setImage(Map<String, String> image) {
            this.image = image;
        }

        public Map<String, String> getDisplayLocation() {
            return displayLocation;
        }

        public void setDisplayLocation(Map<String, String> displayLocation) {
            this.displayLocation = displayLocation;
        }

        public Map<String, String> getObservationLocation() {
            return observationLocation;
        }

        public void setObservationLocation(Map<String, String> observationLocation) {
            this.observationLocation = observationLocation;
        }

        public String getStationId() {
            return stationId;
        }

        public void setStationId(String stationId) {
            this.stationId = stationId;
        }

        public String getObservationTime() {
            return observationTime;
        }

        public void setObservationTime(String observationTime) {
            this.observationTime = observationTime;
        }

        public String getObservationTimeRfc822() {
            return observationTimeRfc822;
        }

        public void setObservationTimeRfc822(String observationTimeRfc822) {
            this.observationTimeRfc822 = observationTimeRfc822;
        }

        public String getObservationEpoch() {
            return observationEpoch;
        }

        public void setObservationEpoch(String observationEpoch) {
            this.observationEpoch = observationEpoch;
        }

        public String getLocalTimeRfc822() {
            return localTimeRfc822;
        }

        public void setLocalTimeRfc822(String localTimeRfc822) {
            this.localTimeRfc822 = localTimeRfc822;
        }

        public String getLocalEpoch() {
            return localEpoch;
        }

        public void setLocalEpoch(String localEpoch) {
            this.localEpoch = localEpoch;
        }

        public String getLocalTzShort() {
            return localTzShort;
        }

        public void setLocalTzShort(String localTzShort) {
            this.localTzShort = localTzShort;
        }

        public String getLocalTzLong() {
            return localTzLong;
        }

        public void setLocalTzLong(String localTzLong) {
            this.localTzLong = localTzLong;
        }

        public String getLocalTzOffset() {
            return localTzOffset;
        }

        public void setLocalTzOffset(String localTzOffset) {
            this.localTzOffset = localTzOffset;
        }

        public String getWeather() {
            return weather;
        }

        public void setWeather(String weather) {
            this.weather = weather;
        }

        public String getTemperatureString() {
            return temperatureString;
        }

        public void setTemperatureString(String temperatureString) {
            this.temperatureString = temperatureString;
        }

        public String getTempF() {
            return tempF;
        }

        public void setTempF(String tempF) {
            this.tempF = tempF;
        }

        public String getTempC() {
            return tempC;
        }

        public void setTempC(String tempC) {
            this.tempC = tempC;
        }

        public String getRelativeHumidity() {
            return relativeHumidity;
        }

        public void setRelativeHumidity(String relativeHumidity) {
            this.relativeHumidity = relativeHumidity;
        }

        public String getWindString() {
            return windString;
        }

        public void setWindString(String windString) {
            this.windString = windString;
        }

        public String getWindDir() {
            return windDir;
        }

        public void setWindDir(String windDir) {
            this.windDir = windDir;
        }

        public String getWindDegrees() {
            return windDegrees;
        }

        public void setWindDegrees(String windDegrees) {
            this.windDegrees = windDegrees;
        }

        public String getWindMph() {
            return windMph;
        }

        public void setWindMph(String windMph) {
            this.windMph = windMph;
        }

        public String getWindGustMph() {
            return windGustMph;
        }

        public void setWindGustMph(String windGustMph) {
            this.windGustMph = windGustMph;
        }

        public String getWindKph() {
            return windKph;
        }

        public void setWindKph(String windKph) {
            this.windKph = windKph;
        }

        public String getWindGustKph() {
            return windGustKph;
        }

        public void setWindGustKph(String windGustKph) {
            this.windGustKph = windGustKph;
        }

        public String getPressureMb() {
            return pressureMb;
        }

        public void setPressureMb(String pressureMb) {
            this.pressureMb = pressureMb;
        }

        public String getPressureIn() {
            return pressureIn;
        }

        public void setPressureIn(String pressureIn) {
            this.pressureIn = pressureIn;
        }

        public String getPressureTrend() {
            return pressureTrend;
        }

        public void setPressureTrend(String pressureTrend) {
            this.pressureTrend = pressureTrend;
        }

        public String getDewpointString() {
            return dewpointString;
        }

        public void setDewpointString(String dewpointString) {
            this.dewpointString = dewpointString;
        }

        public String getDewpointF() {
            return dewpointF;
        }

        public void setDewpointF(String dewpointF) {
            this.dewpointF = dewpointF;
        }

        public String getDewpointC() {
            return dewpointC;
        }

        public void setDewpointC(String dewpointC) {
            this.dewpointC = dewpointC;
        }

        public String getHeatIndexString() {
            return heatIndexString;
        }

        public void setHeatIndexString(String heatIndexString) {
            this.heatIndexString = heatIndexString;
        }

        public String getHeatIndexF() {
            return heatIndexF;
        }

        public void setHeatIndexF(String heatIndexF) {
            this.heatIndexF = heatIndexF;
        }

        public String getHeatIndexC() {
            return heatIndexC;
        }

        public void setHeatIndexC(String heatIndexC) {
            this.heatIndexC = heatIndexC;
        }

        public String getWindchillString() {
            return windchillString;
        }

        public void setWindchillString(String windchillString) {
            this.windchillString = windchillString;
        }

        public String getWindchillF() {
            return windchillF;
        }

        public void setWindchillF(String windchillF) {
            this.windchillF = windchillF;
        }

        public String getWindchillC() {
            return windchillC;
        }

        public void setWindchillC(String windchillC) {
            this.windchillC = windchillC;
        }

        public String getFeelslikeString() {
            return feelslikeString;
        }

        public void setFeelslikeString(String feelslikeString) {
            this.feelslikeString = feelslikeString;
        }

        public String getFeelslikeF() {
            return feelslikeF;
        }

        public void setFeelslikeF(String feelslikeF) {
            this.feelslikeF = feelslikeF;
        }

        public String getFeelslikeC() {
            return feelslikeC;
        }

        public void setFeelslikeC(String feelslikeC) {
            this.feelslikeC = feelslikeC;
        }

        public String getVisibilityMi() {
            return visibilityMi;
        }

        public void setVisibilityMi(String visibilityMi) {
            this.visibilityMi = visibilityMi;
        }

        public String getVisibilityKm() {
            return visibilityKm;
        }

        public void setVisibilityKm(String visibilityKm) {
            this.visibilityKm = visibilityKm;
        }

        public String getSolarradiation() {
            return solarradiation;
        }

        public void setSolarradiation(String solarradiation) {
            this.solarradiation = solarradiation;
        }

        public String getUv() {
            return Uv;
        }

        public void setUv(String uv) {
            Uv = uv;
        }

        public String getPrecip1hrString() {
            return precip1hrString;
        }

        public void setPrecip1hrString(String precip1hrString) {
            this.precip1hrString = precip1hrString;
        }

        public String getPrecip1hrIn() {
            return precip1hrIn;
        }

        public void setPrecip1hrIn(String precip1hrIn) {
            this.precip1hrIn = precip1hrIn;
        }

        public String getPrecip1hrMetric() {
            return precip1hrMetric;
        }

        public void setPrecip1hrMetric(String precip1hrMetric) {
            this.precip1hrMetric = precip1hrMetric;
        }

        public String getPrecipTodayString() {
            return precipTodayString;
        }

        public void setPrecipTodayString(String precipTodayString) {
            this.precipTodayString = precipTodayString;
        }

        public String getPrecipTodayIn() {
            return precipTodayIn;
        }

        public void setPrecipTodayIn(String precipTodayIn) {
            this.precipTodayIn = precipTodayIn;
        }

        public String getPrecipTodayMetric() {
            return precipTodayMetric;
        }

        public void setPrecipTodayMetric(String precipTodayMetric) {
            this.precipTodayMetric = precipTodayMetric;
        }

        public String getIcon() {
            return icon;
        }

        public void setIcon(String icon) {
            this.icon = icon;
        }

        public String getIconUrl() {
            return iconUrl;
        }

        public void setIconUrl(String iconUrl) {
            this.iconUrl = iconUrl;
        }

        public String getForecastUrl() {
            return forecastUrl;
        }

        public void setForecastUrl(String forecastUrl) {
            this.forecastUrl = forecastUrl;
        }

        public String getHistoryUrl() {
            return historyUrl;
        }

        public void setHistoryUrl(String historyUrl) {
            this.historyUrl = historyUrl;
        }

        public String getObUrl() {
            return obUrl;
        }

        public void setObUrl(String obUrl) {
            this.obUrl = obUrl;
        }

        public String getNowcast() {
            return nowcast;
        }

        public void setNowcast(String nowcast) {
            this.nowcast = nowcast;
        }
    }

    public class Forecast implements Serializable{

        @SerializedName("txt_forecast")
        private TxtForecast txtForecast;

        @SerializedName("simpleforecast")
        private SimpleForecast simpleForecast;

        public class TxtForecast implements Serializable {

            private String date;

            private List<Map<String, String>> forecastday;

            public String getDate() {
                return date;
            }

            public void setDate(String date) {
                this.date = date;
            }

            public List<Map<String, String>> getForecastday() {
                return forecastday;
            }

            public void setForecastday(List<Map<String, String>> forecastday) {
                this.forecastday = forecastday;
            }
        }

        public class SimpleForecast  implements Serializable{

            @SerializedName("forecastday")
            private List<ForecastDay> forecastDays;

            public List<ForecastDay> getForecastDays() {
                return forecastDays;
            }

            public void setForecastDays(List<ForecastDay> forecastDays) {
                this.forecastDays = forecastDays;
            }

            public class ForecastDay  implements Serializable{

                private Map<String, String> date;

                private int period;

                private Map<String, String> high;

                private Map<String, String> low;

                private String conditions;

                private String icon;

                @SerializedName("icon_url")
                private String iconUrl;

                private String skyicon;

                private String pop;

                @SerializedName("qpf_allday")
                private Map<String, String> qpfAllday;

                @SerializedName("qpf_day")
                private Map<String, String> qpfDay;

                @SerializedName("qpf_night")
                private Map<String, String> qpfNight;

                @SerializedName("snow_allday")
                private Map<String, String> snowAllday;

                @SerializedName("snow_day")
                private Map<String, String> snowDay;

                @SerializedName("snow_night")
                private Map<String, String> snowNight;

                @SerializedName("maxwind")
                private Map<String, String> maxwind;

                @SerializedName("avewind")
                private Map<String, String> avewind;

                private String avehumidity;

                private String maxhumidity;

                private String minhumidity;

                public Map<String, String> getDate() {
                    return date;
                }

                public void setDate(Map<String, String> date) {
                    this.date = date;
                }

                public int getPeriod() {
                    return period;
                }

                public void setPeriod(int period) {
                    this.period = period;
                }

                public Map<String, String> getHigh() {
                    return high;
                }

                public void setHigh(Map<String, String> high) {
                    this.high = high;
                }

                public Map<String, String> getLow() {
                    return low;
                }

                public void setLow(Map<String, String> low) {
                    this.low = low;
                }

                public String getConditions() {
                    return conditions;
                }

                public void setConditions(String conditions) {
                    this.conditions = conditions;
                }

                public String getIcon() {
                    return icon;
                }

                public void setIcon(String icon) {
                    this.icon = icon;
                }

                public String getIconUrl() {
                    return iconUrl;
                }

                public void setIconUrl(String iconUrl) {
                    this.iconUrl = iconUrl;
                }

                public String getSkyicon() {
                    return skyicon;
                }

                public void setSkyicon(String skyicon) {
                    this.skyicon = skyicon;
                }

                public String getPop() {
                    return pop;
                }

                public void setPop(String pop) {
                    this.pop = pop;
                }

                public Map<String, String> getQpfAllday() {
                    return qpfAllday;
                }

                public void setQpfAllday(Map<String, String> qpfAllday) {
                    this.qpfAllday = qpfAllday;
                }

                public Map<String, String> getQpfDay() {
                    return qpfDay;
                }

                public void setQpfDay(Map<String, String> qpfDay) {
                    this.qpfDay = qpfDay;
                }

                public Map<String, String> getQpfNight() {
                    return qpfNight;
                }

                public void setQpfNight(Map<String, String> qpfNight) {
                    this.qpfNight = qpfNight;
                }

                public Map<String, String> getSnowAllday() {
                    return snowAllday;
                }

                public void setSnowAllday(Map<String, String> snowAllday) {
                    this.snowAllday = snowAllday;
                }

                public Map<String, String> getSnowDay() {
                    return snowDay;
                }

                public void setSnowDay(Map<String, String> snowDay) {
                    this.snowDay = snowDay;
                }

                public Map<String, String> getSnowNight() {
                    return snowNight;
                }

                public void setSnowNight(Map<String, String> snowNight) {
                    this.snowNight = snowNight;
                }

                public Map<String, String> getMaxwind() {
                    return maxwind;
                }

                public void setMaxwind(Map<String, String> maxwind) {
                    this.maxwind = maxwind;
                }

                public Map<String, String> getAvewind() {
                    return avewind;
                }

                public void setAvewind(Map<String, String> avewind) {
                    this.avewind = avewind;
                }

                public String getAvehumidity() {
                    return avehumidity;
                }

                public void setAvehumidity(String avehumidity) {
                    this.avehumidity = avehumidity;
                }

                public String getMaxhumidity() {
                    return maxhumidity;
                }

                public void setMaxhumidity(String maxhumidity) {
                    this.maxhumidity = maxhumidity;
                }

                public String getMinhumidity() {
                    return minhumidity;
                }

                public void setMinhumidity(String minhumidity) {
                    this.minhumidity = minhumidity;
                }
            }
        }

        public TxtForecast getTxtForecast() {
            return txtForecast;
        }

        public void setTxtForecast(TxtForecast txtForecast) {
            this.txtForecast = txtForecast;
        }

        public SimpleForecast getSimpleForecast() {
            return simpleForecast;
        }

        public void setSimpleForecast(SimpleForecast simpleForecast) {
            this.simpleForecast = simpleForecast;
        }
    }

    public class MoonPhase implements Serializable{

        @SerializedName("percentIlluminated")
        private String percentIlluminated;

        @SerializedName("ageOfMoon")
        private String ageOfMoon;

        @SerializedName("phaseofMoon")
        private String phaseofMoon;

        @SerializedName("hemisphere")
        private String hemisphere;

        @SerializedName("current_time")
        private Map<String, String> currentTime;

        @SerializedName("sunrise")
        private Map<String, String> sunrise;

        @SerializedName("sunset")
        private Map<String, String> sunset;

        @SerializedName("moonrise")
        private Map<String, String> moonrise;

        @SerializedName("moonset")
        private Map<String, String> moonset;

        public String getPercentIlluminated() {
            return percentIlluminated;
        }

        public void setPercentIlluminated(String percentIlluminated) {
            this.percentIlluminated = percentIlluminated;
        }

        public String getAgeOfMoon() {
            return ageOfMoon;
        }

        public void setAgeOfMoon(String ageOfMoon) {
            this.ageOfMoon = ageOfMoon;
        }

        public String getPhaseofMoon() {
            return phaseofMoon;
        }

        public void setPhaseofMoon(String phaseofMoon) {
            this.phaseofMoon = phaseofMoon;
        }

        public String getHemisphere() {
            return hemisphere;
        }

        public void setHemisphere(String hemisphere) {
            this.hemisphere = hemisphere;
        }

        public Map<String, String> getCurrentTime() {
            return currentTime;
        }

        public void setCurrentTime(Map<String, String> currentTime) {
            this.currentTime = currentTime;
        }

        public Map<String, String> getSunrise() {
            return sunrise;
        }

        public void setSunrise(Map<String, String> sunrise) {
            this.sunrise = sunrise;
        }

        public Map<String, String> getSunset() {
            return sunset;
        }

        public void setSunset(Map<String, String> sunset) {
            this.sunset = sunset;
        }

        public Map<String, String> getMoonrise() {
            return moonrise;
        }

        public void setMoonrise(Map<String, String> moonrise) {
            this.moonrise = moonrise;
        }

        public Map<String, String> getMoonset() {
            return moonset;
        }

        public void setMoonset(Map<String, String> moonset) {
            this.moonset = moonset;
        }
    }

    public class SunPhase implements Serializable{

        @SerializedName("sunrise")
        private Map<String, String> sunrise;

        @SerializedName("sunset")
        private Map<String, String> sunset;

        public Map<String, String> getSunrise() {
            return sunrise;
        }

        public void setSunrise(Map<String, String> sunrise) {
            this.sunrise = sunrise;
        }

        public Map<String, String> getSunset() {
            return sunset;
        }

        public void setSunset(Map<String, String> sunset) {
            this.sunset = sunset;
        }
    }

    public class Alert implements Serializable {
        @SerializedName("message")
        private String message;

        @SerializedName("description")
        private String description;

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }
    }
}
