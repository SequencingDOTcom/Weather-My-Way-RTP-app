package com.sequencing.weather.helper;


import android.net.Uri;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.sequencing.weather.entity.LocationEntity;
import com.sequencing.weather.entity.WeatherEntity;
import com.sequencing.weather.exceptions.WUndergroundException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WeatherHelper {

    private static final String API_KEY = "API_KEY"; // here is your WeatherUnderground api key
    private static final String BASE_WEATHER_URL = "https://api.wunderground.com/api/" + API_KEY
            + "/forecast10day/conditions/alerts/astronomy%s";
    private static final String BASE_CITY_URL = "https://autocomplete.wunderground.com/aq?query=";
    private static final String GEO_LOOKUP_URL = "https://api.wunderground.com/api/" + API_KEY + "/geolookup/q/%s,%s.json";

    public static WeatherEntity getCurrentWeather(String cityId) throws WUndergroundException {
        String url = String.format(BASE_WEATHER_URL,  cityId + ".json");
        String serverResponse = HttpHelper.doGet(url, null);

        checkWeatherUndergroundResponse(serverResponse);

        WeatherEntity weatherEntity = JsonHelper.convertToJavaObject(serverResponse, WeatherEntity.class);

        if(weatherEntity== null || weatherEntity.getCurrentObservation() == null)
            return null;

        return  weatherEntity;
    }

    public static List<LocationEntity.City> getCities(String cityName)  {
        String url = BASE_CITY_URL + Uri.encode(cityName);
        String serverResponse = HttpHelper.doGet(url, null);

        try {
            checkWeatherUndergroundResponse(serverResponse);
        } catch (WUndergroundException e) {
            return new ArrayList<LocationEntity.City>();
        }

        List<LocationEntity.City> cities = JsonHelper.convertToJavaObject(serverResponse, LocationEntity.class).getCities();

        return cities;
    }

    public static Map<String, String> getCityIdByGeoData(double latitude, double longitude) throws WUndergroundException {
        String cityId = null;
        String url = String.format(GEO_LOOKUP_URL, latitude, longitude);
        String serverResponse = HttpHelper.doGet(url, null);

        checkWeatherUndergroundResponse(serverResponse);

        Gson gson = new Gson();
        JsonObject jsonObject = gson.fromJson(serverResponse, JsonObject.class);
        JsonObject locationObject = jsonObject.getAsJsonObject("location");

        if(locationObject == null)
            throw new WUndergroundException("Unable to get city id by geo data");

        cityId = locationObject.get("l").getAsString();
        String cityName = locationObject.get("city").getAsString() + ", " +locationObject.get("country_name").getAsString();


        Map<String, String> cityCodeAndName = new HashMap<String, String>(2);
        cityCodeAndName.put("code", cityId);
        cityCodeAndName.put("name", cityName);

        return cityCodeAndName;
    }

    private static void checkWeatherUndergroundResponse(String response) throws WUndergroundException {
        Gson gson = new Gson();
        JsonObject mainObject = gson.fromJson(response, JsonObject.class);
        if(mainObject == null)
            throw new WUndergroundException("Unable to get response from wunderground.com");

        JsonObject responseObject= mainObject.getAsJsonObject("response");

        if(responseObject != null && responseObject.get("error") != null) {
            throw new WUndergroundException("Unable to get response from wunderground.com");
        }
    }

    public static boolean isDay(WeatherEntity weatherEntity){
        try {
            String []tmpArr = weatherEntity.getCurrentObservation().getLocalTimeRfc822().split(":")[0].split(" ");
            int currentHour = Integer.parseInt(tmpArr[tmpArr.length - 1]);

            int sunriseHour = Integer.parseInt(weatherEntity.getSunPhase().getSunrise().get("hour"));
            int sunsetHour = Integer.parseInt(weatherEntity.getSunPhase().getSunset().get("hour"));

            return currentHour < sunsetHour && currentHour >= sunriseHour;
        } catch (Exception e) {
            return true;
        }
    }
}
