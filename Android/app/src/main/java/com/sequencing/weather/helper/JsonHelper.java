package com.sequencing.weather.helper;


import com.google.gson.Gson;

/**
 * Helper for common JSON data manipulations routines
 */
public class JsonHelper {

    /**
	 * Convert json to java object
	 */
    public static <T> T convertToJavaObject(String json, Class<T> classOf){
    	Gson gson = new Gson();
    	T object =  gson.fromJson(json, classOf);
    	return object;
    }
    
    /**
	 * Convert java object to json format
	 */
    public static <T> String convertToJson(T object){
    	return new Gson().toJson(object);
    }
}
