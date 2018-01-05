package com.sequencing.weather.helper;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.preference.PreferenceManager;
import android.support.v4.content.ContextCompat;

import com.android.vending.expansion.zipfile.APEZProvider;
import com.sequencing.weather.R;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

public class VideoGeneratorHelper {
    private static final String CONTENT_URI = "content://com.sequencing.weather.service.provider.ZipFileContentProvider/movies/";

    private static final String SHUTTERSTOCK_V120847 = "shutterstock_v120847.mp4";
    private static final String SHUTTERSTOCK_V163903 = "shutterstock_v163903.mp4";
    private static final String SHUTTERSTOCK_V225991 = "shutterstock_v225991.mp4";
    private static final String SHUTTERSTOCK_V728440 = "shutterstock_v728440.mp4";
    private static final String SHUTTERSTOCK_V800269 = "shutterstock_v800269.mp4";
    private static final String SHUTTERSTOCK_V861337 = "shutterstock_v861337.mp4";
    private static final String SHUTTERSTOCK_V885172 = "shutterstock_v885172.mp4";
    private static final String SHUTTERSTOCK_V1126162 = "shutterstock_v1126162.mp4";
    private static final String SHUTTERSTOCK_V1389124 = "shutterstock_v1389124.mp4";
    private static final String SHUTTERSTOCK_V1538677 = "shutterstock_v1538677.mp4";
    private static final String SHUTTERSTOCK_V1775912 = "shutterstock_v1775912.mp4";
    private static final String SHUTTERSTOCK_V1936054 = "shutterstock_v1936054.mp4";
    private static final String SHUTTERSTOCK_V2051507 = "shutterstock_v2051507.mp4";
    private static final String SHUTTERSTOCK_V2302283 = "shutterstock_v2302283.mp4";
    private static final String SHUTTERSTOCK_V2580011 = "shutterstock_v2580011.mp4";
    private static final String SHUTTERSTOCK_V2629166 = "shutterstock_v2629166.mp4";
    private static final String SHUTTERSTOCK_V2718020 = "shutterstock_v2718020.mp4";
    private static final String SHUTTERSTOCK_V2831005 = "shutterstock_v2831005.mp4";
    private static final String SHUTTERSTOCK_V2864458 = "shutterstock_v2864458.mp4";
    private static final String SHUTTERSTOCK_V3036661 = "shutterstock_v3036661.mp4";
    private static final String SHUTTERSTOCK_V3112114 = "shutterstock_v3112114.mp4";
    private static final String SHUTTERSTOCK_V3149698 = "shutterstock_v3149698.mp4";
    private static final String SHUTTERSTOCK_V3168328 = "shutterstock_v3168328.mp4";
    private static final String SHUTTERSTOCK_V3579536 = "shutterstock_v3579536.mp4";
    private static final String SHUTTERSTOCK_V3652088 = "shutterstock_v3652088.mp4";
    private static final String SHUTTERSTOCK_V3671960 = "shutterstock_v3671960.mp4";
    private static final String SHUTTERSTOCK_V3753200 = "shutterstock_v3753200.mp4";
    private static final String SHUTTERSTOCK_V4189258 = "shutterstock_v4189258.mp4";
    private static final String SHUTTERSTOCK_V4314167 = "shutterstock_v4314167.mp4";
    private static final String SHUTTERSTOCK_V4443185 = "shutterstock_v4443185.mp4";
    private static final String SHUTTERSTOCK_V4491596 = "shutterstock_v4491596.mp4";
    private static final String SHUTTERSTOCK_V4584485 = "shutterstock_v4584485.mp4";
    private static final String SHUTTERSTOCK_V4627466 = "shutterstock_v4627466.mp4";
    private static final String SHUTTERSTOCK_V5236070 = "shutterstock_v5236070.mp4";
    private static final String SHUTTERSTOCK_V5468858 = "shutterstock_v5468858.mp4";
    private static final String SHUTTERSTOCK_V5649644 = "shutterstock_v5649644.mp4";
    private static final String SHUTTERSTOCK_V5793242 = "shutterstock_v5793242.mp4";
    private static final String SHUTTERSTOCK_V6698111 = "shutterstock_v6698111.mp4";
    private static final String SHUTTERSTOCK_V6820675 = "shutterstock_v6820675.mp4";
    private static final String SHUTTERSTOCK_V7188568 = "shutterstock_v7188568.mp4";
    private static final String SHUTTERSTOCK_V7419178 = "shutterstock_v7419178.mp4";
    private static final String SHUTTERSTOCK_V8037967 = "shutterstock_v8037967.mp4";
    private static final String SHUTTERSTOCK_V8257699 = "shutterstock_v8257699.mp4";
    private static final String SHUTTERSTOCK_V10572149 = "shutterstock_v10572149.mp4";
    private static final String SHUTTERSTOCK_V11588486 = "shutterstock_v11588486.mp4";
    private static final String SHUTTERSTOCK_V11612783 = "shutterstock_v11612783.mp4";

    private static Map<String, String> WEATHER_CONDITION_DAY = new HashMap<String, String>() {
        {
            put("sand", SHUTTERSTOCK_V2580011);
            put("lowdriftingsand", SHUTTERSTOCK_V2580011);
            put("low drifting sand", SHUTTERSTOCK_V2580011);
            put("blowingsand", SHUTTERSTOCK_V2580011);
            put("blowing sand", SHUTTERSTOCK_V2580011);
            put("light sand", SHUTTERSTOCK_V2580011);
            put("light low drifting sand", SHUTTERSTOCK_V2580011);
            put("light blowing sand", SHUTTERSTOCK_V2580011);
            put("heavy blowing sand", SHUTTERSTOCK_V2580011);

            put("light drizzle", SHUTTERSTOCK_V4627466);
            put("light rain showers", SHUTTERSTOCK_V4627466);

            put("partly cloudy", SHUTTERSTOCK_V10572149);
            put("scattered clouds", SHUTTERSTOCK_V10572149);

            put("heavy widespread dust", SHUTTERSTOCK_V1126162);
            put("heavy blowing widespread dust", SHUTTERSTOCK_V1126162);
            put("widespreaddust", SHUTTERSTOCK_V1126162);
            put("widespread dust", SHUTTERSTOCK_V1126162);

            put("heavy haze", SHUTTERSTOCK_V11588486);
            put("haze", SHUTTERSTOCK_V11588486);
            put("rainmist", SHUTTERSTOCK_V11588486);
            put("rain mist", SHUTTERSTOCK_V11588486);
            put("light haze", SHUTTERSTOCK_V11588486);
            put("hazy", SHUTTERSTOCK_V11588486);

            put("heavy thunderstorms and snow", SHUTTERSTOCK_V11612783);
            put("thunderstormsandsnow", SHUTTERSTOCK_V11612783);
            put("thunderstorms and snow", SHUTTERSTOCK_V11612783);
            put("light thunderstorms and snow", SHUTTERSTOCK_V11612783);

            put("heavy freezing drizzle", SHUTTERSTOCK_V120847);
            put("freezingrain", SHUTTERSTOCK_V120847);
            put("freezing rain", SHUTTERSTOCK_V120847);
            put("light freezing rain", SHUTTERSTOCK_V120847);

            put("light mist", SHUTTERSTOCK_V1389124);

            put("heavy thunderstorm", SHUTTERSTOCK_V1538677);
            put("thunderstormsandrain", SHUTTERSTOCK_V1538677);
            put("thunderstorms and rain", SHUTTERSTOCK_V1538677);

            put("squalls", SHUTTERSTOCK_V163903);

            put("light thunderstorm", SHUTTERSTOCK_V2051507);
            put("light thunderstorms and rain", SHUTTERSTOCK_V2051507);
            put("heavy thunderstorms and rain", SHUTTERSTOCK_V2051507);
            put("thunderstorm", SHUTTERSTOCK_V2051507);

            put("heavy drizzle", SHUTTERSTOCK_V225991);
            put("heavy rain", SHUTTERSTOCK_V225991);
            put("heavy rain mist", SHUTTERSTOCK_V225991);
            put("rain", SHUTTERSTOCK_V225991);
            put("rainshowers", SHUTTERSTOCK_V225991);
            put("rain showers", SHUTTERSTOCK_V225991);
            put("unknown precipitation", SHUTTERSTOCK_V225991);
            put("chance of showers", SHUTTERSTOCK_V225991);
            put("showers", SHUTTERSTOCK_V225991);

            put("heavy rain showers", SHUTTERSTOCK_V2302283);
            put("chance of rain", SHUTTERSTOCK_V2302283);

            put("heavy ice crystals", SHUTTERSTOCK_V2629166);
            put("heavy ice pellets", SHUTTERSTOCK_V2629166);
            put("heavy hail", SHUTTERSTOCK_V2629166);
            put("heavy ice pellet showers", SHUTTERSTOCK_V2629166);
            put("heavy hail showers", SHUTTERSTOCK_V2629166);
            put("heavy small hail showers", SHUTTERSTOCK_V2629166);
            put("heavy thunderstorms and ice pellets", SHUTTERSTOCK_V2629166);
            put("heavy thunderstorms with hail", SHUTTERSTOCK_V2629166);
            put("heavy thunderstorms with small hail", SHUTTERSTOCK_V2629166);
            put("hail", SHUTTERSTOCK_V2629166);
            put("icepelletshowers", SHUTTERSTOCK_V2629166);
            put("ice pellet showers", SHUTTERSTOCK_V2629166);
            put("hailshowers", SHUTTERSTOCK_V2629166);
            put("hail showers", SHUTTERSTOCK_V2629166);
            put("smallhailshowers", SHUTTERSTOCK_V2629166);
            put("small hail showers", SHUTTERSTOCK_V2629166);
            put("thunderstormsandicepellets", SHUTTERSTOCK_V2629166);
            put("thunderstorm sand ice pellets", SHUTTERSTOCK_V2629166);
            put("thunderstormswithhail", SHUTTERSTOCK_V2629166);
            put("thunderstorms with hail", SHUTTERSTOCK_V2629166);
            put("thunderstormswithsmallhail", SHUTTERSTOCK_V2629166);
            put("thunderstorms with small hail", SHUTTERSTOCK_V2629166);
            put("light hail showers", SHUTTERSTOCK_V2629166);
            put("light small hail showers", SHUTTERSTOCK_V2629166);
            put("chance of ice pellets", SHUTTERSTOCK_V2629166);
            put("ice pellets", SHUTTERSTOCK_V2629166);
            put("icepellets", SHUTTERSTOCK_V2629166);

            put("heavy smoke", SHUTTERSTOCK_V2718020);
            put("heavy freezing fog", SHUTTERSTOCK_V2718020);
            put("smoke", SHUTTERSTOCK_V2718020);
            put("freezingfog", SHUTTERSTOCK_V2718020);
            put("freezing fog", SHUTTERSTOCK_V2718020);
            put("light smoke", SHUTTERSTOCK_V2718020);

            put("very cold", SHUTTERSTOCK_V3036661);
            put("icecrystals", SHUTTERSTOCK_V3036661);
            put("ice crystals", SHUTTERSTOCK_V3036661);
            put("light ice crystals", SHUTTERSTOCK_V3036661);
            put("light ice pellet showers", SHUTTERSTOCK_V3036661);
            put("light thunderstorms and ice pellets", SHUTTERSTOCK_V3036661);
            put("light thunderstorms with hail", SHUTTERSTOCK_V3036661);
            put("light thunderstorms with small hail", SHUTTERSTOCK_V3036661);

            put("patches of fog", SHUTTERSTOCK_V3112114);
            put("shallow fog", SHUTTERSTOCK_V3112114);
            put("partial fog", SHUTTERSTOCK_V3112114);

            put("drizzle", SHUTTERSTOCK_V3168328);
            put("light rain", SHUTTERSTOCK_V3168328);
            put("light rain mist", SHUTTERSTOCK_V3168328);

            put("heavy spray", SHUTTERSTOCK_V3652088);
            put("spray", SHUTTERSTOCK_V3652088);
            put("light spray", SHUTTERSTOCK_V3652088);

            put("mostly cloudy", SHUTTERSTOCK_V3671960);

            put("heavy freezing rain", SHUTTERSTOCK_V3753200);
            put("snow showers", SHUTTERSTOCK_V3753200);

            put("heavy dust whirls", SHUTTERSTOCK_V4189258);
            put("heavy low drifting widespread dust", SHUTTERSTOCK_V4189258);
            put("dustwhirls", SHUTTERSTOCK_V4189258);
            put("dust whirls", SHUTTERSTOCK_V4189258);
            put("lowdriftingwidespreaddust", SHUTTERSTOCK_V4189258);
            put("low drifting widespread dust", SHUTTERSTOCK_V4189258);
            put("blowingwidespreaddust", SHUTTERSTOCK_V4189258);
            put("blowing widespread dust", SHUTTERSTOCK_V4189258);
            put("light widespread dust", SHUTTERSTOCK_V4189258);
            put("light dust whirls", SHUTTERSTOCK_V4189258);
            put("light low drifting widespread dust", SHUTTERSTOCK_V4189258);
            put("light blowing widespread dust", SHUTTERSTOCK_V4189258);

            put("freezingdrizzle", SHUTTERSTOCK_V4314167);
            put("freezing drizzle", SHUTTERSTOCK_V4314167);
            put("light snow", SHUTTERSTOCK_V4314167);
            put("light snow grains", SHUTTERSTOCK_V4314167);
            put("light blowing snow", SHUTTERSTOCK_V4314167);
            put("light snow showers", SHUTTERSTOCK_V4314167);
            put("light snow blowing snow mist", SHUTTERSTOCK_V4314167);
            put("light freezing drizzle", SHUTTERSTOCK_V4314167);
            put("light freezing fog", SHUTTERSTOCK_V4314167);

            put("mist", SHUTTERSTOCK_V4443185);
            put("fog", SHUTTERSTOCK_V4443185);
            put("fogpatches", SHUTTERSTOCK_V4443185);
            put("fog patches", SHUTTERSTOCK_V4443185);
            put("light fog", SHUTTERSTOCK_V4443185);
            put("light fog patches", SHUTTERSTOCK_V4443185);

            put("very hot", SHUTTERSTOCK_V4491596);

            put("heavy snow", SHUTTERSTOCK_V5236070);
            put("heavy snow grains", SHUTTERSTOCK_V5236070);
            put("heavy snow showers", SHUTTERSTOCK_V5236070);
            put("heavy snow blowing snow mist", SHUTTERSTOCK_V5236070);
            put("snow", SHUTTERSTOCK_V5236070);
            put("snowgrains", SHUTTERSTOCK_V5236070);
            put("snow grains", SHUTTERSTOCK_V5236070);
            put("chance of snow showers", SHUTTERSTOCK_V5236070);
            put("chance of snow", SHUTTERSTOCK_V5236070);

            put("heavy low drifting snow", SHUTTERSTOCK_V5468858);
            put("heavy blowing snow", SHUTTERSTOCK_V5468858);
            put("lowdriftingsnow", SHUTTERSTOCK_V5468858);
            put("low drifting snow", SHUTTERSTOCK_V5468858);
            put("blowingsnow", SHUTTERSTOCK_V5468858);
            put("blowing snow", SHUTTERSTOCK_V5468858);
            put("blizzard", SHUTTERSTOCK_V5468858);

            put("heavy mist", SHUTTERSTOCK_V5793242);
            put("heavy fog", SHUTTERSTOCK_V5793242);
            put("heavy fog patches", SHUTTERSTOCK_V5793242);

            put("snowblowingsnowmist", SHUTTERSTOCK_V6698111);
            put("snow blowing snow mist", SHUTTERSTOCK_V6698111);
            put("light low drifting snow", SHUTTERSTOCK_V6698111);
            put("flurries", SHUTTERSTOCK_V6698111);

            put("funnel cloud", SHUTTERSTOCK_V7188568);

            put("light ice pellets", SHUTTERSTOCK_V728440);
            put("light hail", SHUTTERSTOCK_V728440);
            put("small hail", SHUTTERSTOCK_V728440);

            put("heavy volcanic ash", SHUTTERSTOCK_V8037967);
            put("volcanicash", SHUTTERSTOCK_V8037967);
            put("volcanic ash", SHUTTERSTOCK_V8037967);
            put("light volcanic ash", SHUTTERSTOCK_V8037967);

            put("clear", SHUTTERSTOCK_V8257699);

            put("heavy sand", SHUTTERSTOCK_V861337);
            put("heavy sandstorm", SHUTTERSTOCK_V861337);
            put("sandstorm", SHUTTERSTOCK_V861337);
            put("light sandstorm", SHUTTERSTOCK_V861337);

            put("overcast", SHUTTERSTOCK_V885172);
            put("cloudy", SHUTTERSTOCK_V885172);

            put("chance of a thunderstorm", SHUTTERSTOCK_V800269);

            put("unknown", SHUTTERSTOCK_V4584485);
            put("omitted", SHUTTERSTOCK_V4584485);
        }
    };

    private static Map<String, String> WEATHER_CONDITION_NIGHT = new HashMap<String, String>() {
        {
            put("heavy low drifting sand", SHUTTERSTOCK_V2580011);
            put("sand", SHUTTERSTOCK_V2580011);
            put("lowdriftingsand", SHUTTERSTOCK_V2580011);
            put("low drifting sand", SHUTTERSTOCK_V2580011);
            put("blowingsand", SHUTTERSTOCK_V2580011);
            put("blowing sand", SHUTTERSTOCK_V2580011);
            put("light sand", SHUTTERSTOCK_V2580011);
            put("light low drifting sand", SHUTTERSTOCK_V2580011);
            put("light blowing sand", SHUTTERSTOCK_V2580011);
            put("heavy blowing sand", SHUTTERSTOCK_V2580011);

            put("heavy widespread dust", SHUTTERSTOCK_V1126162);
            put("heavy blowing widespread dust", SHUTTERSTOCK_V1126162);
            put("widespreaddust", SHUTTERSTOCK_V1126162);
            put("widespread dust", SHUTTERSTOCK_V1126162);

            put("heavy haze", SHUTTERSTOCK_V11588486);
            put("haze", SHUTTERSTOCK_V11588486);
            put("light haze", SHUTTERSTOCK_V11588486);
            put("hazy", SHUTTERSTOCK_V11588486);

            put("light mist", SHUTTERSTOCK_V1389124);
            put("patches of fog", SHUTTERSTOCK_V1389124);
            put("shallow fog", SHUTTERSTOCK_V1389124);
            put("partial fog", SHUTTERSTOCK_V1389124);
            put("light freezing fog", SHUTTERSTOCK_V1389124);
            put("fog", SHUTTERSTOCK_V1389124);
            put("fogpatches", SHUTTERSTOCK_V1389124);
            put("fog patches", SHUTTERSTOCK_V1389124);
            put("light fog", SHUTTERSTOCK_V1389124);
            put("light fog patches", SHUTTERSTOCK_V1389124);
            put("heavy fog patches", SHUTTERSTOCK_V1389124);

            put("thunderstormsandrain", SHUTTERSTOCK_V163903);
            put("thunderstorms and rain", SHUTTERSTOCK_V163903);
            put("squalls", SHUTTERSTOCK_V163903);
            put("light thunderstorms and rain", SHUTTERSTOCK_V163903);
            put("heavy thunderstorms and rain", SHUTTERSTOCK_V163903);

            put("overcast", SHUTTERSTOCK_V1936054);

            put("chance of ice pellets", SHUTTERSTOCK_V2629166);
            put("ice pellets", SHUTTERSTOCK_V2629166);
            put("icepellets", SHUTTERSTOCK_V2629166);
            put("heavy ice pellet showers", SHUTTERSTOCK_V2629166);
            put("heavy hail showers", SHUTTERSTOCK_V2629166);
            put("heavy small hail showers", SHUTTERSTOCK_V2629166);
            put("heavy thunderstorms and ice pellets", SHUTTERSTOCK_V2629166);
            put("heavy thunderstorms with hail", SHUTTERSTOCK_V2629166);
            put("heavy thunderstorms with small hail", SHUTTERSTOCK_V2629166);
            put("hail", SHUTTERSTOCK_V2629166);
            put("icepelletshowers", SHUTTERSTOCK_V2629166);
            put("ice pellet showers", SHUTTERSTOCK_V2629166);
            put("thunderstormsandicepellets", SHUTTERSTOCK_V2629166);
            put("thunderstorm sand ice pellets", SHUTTERSTOCK_V2629166);
            put("thunderstormswithhail", SHUTTERSTOCK_V2629166);
            put("thunderstorms with hail", SHUTTERSTOCK_V2629166);
            put("thunderstormswithsmallhail", SHUTTERSTOCK_V2629166);
            put("thunderstorms with small hail", SHUTTERSTOCK_V2629166);

            put("heavy smoke", SHUTTERSTOCK_V2718020);
            put("smoke", SHUTTERSTOCK_V2718020);
            put("light smoke", SHUTTERSTOCK_V2718020);

            put("partly cloudy", SHUTTERSTOCK_V2831005);

            put("very hot", SHUTTERSTOCK_V2864458);

            put("heavy freezing drizzle", SHUTTERSTOCK_V3036661);
            put("freezingrain", SHUTTERSTOCK_V3036661);
            put("freezing rain", SHUTTERSTOCK_V3036661);
            put("light freezing rain", SHUTTERSTOCK_V3036661);
            put("icecrystals", SHUTTERSTOCK_V3036661);
            put("ice crystals", SHUTTERSTOCK_V3036661);
            put("light ice crystals", SHUTTERSTOCK_V3036661);
            put("light ice pellet showers", SHUTTERSTOCK_V3036661);
            put("light thunderstorms and ice pellets", SHUTTERSTOCK_V3036661);
            put("light thunderstorms with hail", SHUTTERSTOCK_V3036661);
            put("light thunderstorms with small hail", SHUTTERSTOCK_V3036661);
            put("heavy freezing rain", SHUTTERSTOCK_V3036661);
            put("freezingdrizzle", SHUTTERSTOCK_V3036661);
            put("freezing drizzle", SHUTTERSTOCK_V3036661);
            put("light freezing drizzle", SHUTTERSTOCK_V3036661);

            put("very cold", SHUTTERSTOCK_V3149698);
            put("hail showers", SHUTTERSTOCK_V3149698);
            put("hailshowers", SHUTTERSTOCK_V3149698);
            put("small hail showers", SHUTTERSTOCK_V3149698);
            put("light hail showers", SHUTTERSTOCK_V3149698);
            put("light small hail showers", SHUTTERSTOCK_V3149698);
            put("heavy freezing fog", SHUTTERSTOCK_V3149698);
            put("freezingfog", SHUTTERSTOCK_V3149698);
            put("freezing fog", SHUTTERSTOCK_V3149698);

            put("rainmist", SHUTTERSTOCK_V3168328);
            put("rain mist", SHUTTERSTOCK_V3168328);
            put("light rain mist", SHUTTERSTOCK_V3168328);

            put("chance of showers", SHUTTERSTOCK_V3579536);
            put("heavy rain", SHUTTERSTOCK_V3579536);
            put("heavy rain mist", SHUTTERSTOCK_V3579536);
            put("heavy rain showers", SHUTTERSTOCK_V3579536);
            put("rainshowers", SHUTTERSTOCK_V3579536);
            put("rain showers", SHUTTERSTOCK_V3579536);

            put("heavy spray", SHUTTERSTOCK_V3652088);
            put("spray", SHUTTERSTOCK_V3652088);
            put("light spray", SHUTTERSTOCK_V3652088);

            put("heavy dust whirls", SHUTTERSTOCK_V4189258);
            put("heavy low drifting widespread dust", SHUTTERSTOCK_V4189258);
            put("dustwhirls", SHUTTERSTOCK_V4189258);
            put("dust whirls", SHUTTERSTOCK_V4189258);
            put("lowdriftingwidespreaddust", SHUTTERSTOCK_V4189258);
            put("low drifting widespread dust", SHUTTERSTOCK_V4189258);
            put("blowingwidespreaddust", SHUTTERSTOCK_V4189258);
            put("blowing widespread dust", SHUTTERSTOCK_V4189258);
            put("light widespread dust", SHUTTERSTOCK_V4189258);
            put("light dust whirls", SHUTTERSTOCK_V4189258);
            put("light low drifting widespread dust", SHUTTERSTOCK_V4189258);
            put("light blowing widespread dust", SHUTTERSTOCK_V4189258);
            put("light low drifting snow", SHUTTERSTOCK_V4189258);

            put("mist", SHUTTERSTOCK_V4443185);
            put("foggy", SHUTTERSTOCK_V4443185);

            put("blizzard", SHUTTERSTOCK_V5468858);
            put("light snow", SHUTTERSTOCK_V5468858);
            put("light snow grains", SHUTTERSTOCK_V5468858);
            put("light snow showers", SHUTTERSTOCK_V5468858);
            put("light snow blowing snow mist", SHUTTERSTOCK_V5468858);
            put("blowingsnow", SHUTTERSTOCK_V5468858);
            put("blowing snow", SHUTTERSTOCK_V5468858);

            put("showers", SHUTTERSTOCK_V5649644);
            put("chance of rain", SHUTTERSTOCK_V5649644);
            put("rain", SHUTTERSTOCK_V5649644);
            put("light rain", SHUTTERSTOCK_V5649644);
            put("light drizzle", SHUTTERSTOCK_V5649644);
            put("light rain showers", SHUTTERSTOCK_V5649644);
            put("unknown precipitation", SHUTTERSTOCK_V5649644);
            put("drizzle", SHUTTERSTOCK_V5649644);
            put("heavy drizzle", SHUTTERSTOCK_V5649644);

            put("heavy mist", SHUTTERSTOCK_V5793242);
            put("heavy fog", SHUTTERSTOCK_V5793242);

            put("light blowing snow", SHUTTERSTOCK_V6698111);
            put("snow", SHUTTERSTOCK_V6698111);
            put("snowgrains", SHUTTERSTOCK_V6698111);
            put("snow grains", SHUTTERSTOCK_V6698111);

            put("scattered clouds", SHUTTERSTOCK_V6820675);
            put("mostly cloudy", SHUTTERSTOCK_V6820675);
            put("cloudy", SHUTTERSTOCK_V6820675);

            put("funnel cloud", SHUTTERSTOCK_V7188568);

            put("heavy ice crystals", SHUTTERSTOCK_V728440);
            put("heavy ice pellets", SHUTTERSTOCK_V728440);
            put("heavy hail", SHUTTERSTOCK_V728440);
            put("light ice pellets", SHUTTERSTOCK_V728440);
            put("light hail", SHUTTERSTOCK_V728440);
            put("small hail", SHUTTERSTOCK_V728440);

            put("blowingsnow", SHUTTERSTOCK_V7419178);
            put("blowing snow", SHUTTERSTOCK_V7419178);
            put("heavy thunderstorms and snow", SHUTTERSTOCK_V7419178);
            put("thunderstormsandsnow", SHUTTERSTOCK_V7419178);
            put("thunderstorms and snow", SHUTTERSTOCK_V7419178);
            put("light thunderstorms and snow", SHUTTERSTOCK_V7419178);
            put("heavy snow", SHUTTERSTOCK_V7419178);
            put("heavy snow grains", SHUTTERSTOCK_V7419178);
            put("heavy snow showers", SHUTTERSTOCK_V7419178);
            put("heavy snow blowing snow mist", SHUTTERSTOCK_V7419178);
            put("heavy low drifting snow", SHUTTERSTOCK_V7419178);
            put("heavy blowing snow", SHUTTERSTOCK_V7419178);
            put("lowdriftingsnow", SHUTTERSTOCK_V7419178);
            put("snowshowers", SHUTTERSTOCK_V7419178);
            put("snow showers", SHUTTERSTOCK_V7419178);
            put("snowblowingsnowmist", SHUTTERSTOCK_V7419178);
            put("snow blowing snow mist", SHUTTERSTOCK_V7419178);
            put("chance of snow showers", SHUTTERSTOCK_V7419178);
            put("chance of snow", SHUTTERSTOCK_V7419178);
            put("snow", SHUTTERSTOCK_V7419178);
            put("flurries", SHUTTERSTOCK_V7419178);

            put("chance of a thunderstorm", SHUTTERSTOCK_V800269);
            put("heavy thunderstorm", SHUTTERSTOCK_V800269);
            put("thunderstorm", SHUTTERSTOCK_V800269);
            put("light thunderstorm", SHUTTERSTOCK_V800269);

            put("heavy volcanic ash", SHUTTERSTOCK_V8037967);
            put("volcanicash", SHUTTERSTOCK_V8037967);
            put("volcanic ash", SHUTTERSTOCK_V8037967);
            put("light volcanic ash", SHUTTERSTOCK_V8037967);

            put("heavy sand", SHUTTERSTOCK_V861337);
            put("heavy sandstorm", SHUTTERSTOCK_V861337);
            put("sandstorm", SHUTTERSTOCK_V861337);
            put("light sandstorm", SHUTTERSTOCK_V861337);

            put("thunderstorm", SHUTTERSTOCK_V2051507);

            put("clear", SHUTTERSTOCK_V1775912);
            put("unknown", SHUTTERSTOCK_V1775912);
            put("omitted", SHUTTERSTOCK_V1775912);
        }
    };

    public static String getVideo(Context context) {
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
        String weather = settings.getString("weather", null);
        boolean isDay = settings.getBoolean("isDay", true);
        if (weather == null)
            return getRandomVideo();
        else if (isDay)
            return WEATHER_CONDITION_DAY.get(weather.toLowerCase());
        else
            return WEATHER_CONDITION_NIGHT.get(weather.toLowerCase());
    }

    public static int getTextColorAgainstVideo(Context context) {
        List<String> lightVideos = new ArrayList<>();
        lightVideos.add(SHUTTERSTOCK_V4627466);
        lightVideos.add(SHUTTERSTOCK_V2302283);
        lightVideos.add(SHUTTERSTOCK_V120847);
        lightVideos.add(SHUTTERSTOCK_V3036661);
        lightVideos.add(SHUTTERSTOCK_V1126162);

        if (lightVideos.contains(getVideo(context)))
            return ContextCompat.getColor(context, R.color.main_layouts_background);
        else
            return ContextCompat.getColor(context, android.R.color.transparent);
    }

    public static int getBackgroundColorTransparent(Context context) {
        List<String> lightVideos = new ArrayList<>();
        lightVideos.add(SHUTTERSTOCK_V3671960);
        lightVideos.add(SHUTTERSTOCK_V885172);
        lightVideos.add(SHUTTERSTOCK_V800269);
        lightVideos.add(SHUTTERSTOCK_V2718020);
        lightVideos.add(SHUTTERSTOCK_V3753200);

        lightVideos.add(SHUTTERSTOCK_V5793242);
        lightVideos.add(SHUTTERSTOCK_V11612783);
        lightVideos.add(SHUTTERSTOCK_V225991);
        lightVideos.add(SHUTTERSTOCK_V2302283);
        lightVideos.add(SHUTTERSTOCK_V2629166);
        lightVideos.add(SHUTTERSTOCK_V3753200);
        lightVideos.add(SHUTTERSTOCK_V4314167);
        lightVideos.add(SHUTTERSTOCK_V4627466);
        lightVideos.add(SHUTTERSTOCK_V10572149);

        if (lightVideos.contains(getVideo(context))){
            return ContextCompat.getColor(context, R.color.main_layouts_background_darker);
        } else {
            return ContextCompat.getColor(context, R.color.main_layouts_background_darker);//main_layouts_background
        }
    }

    private static String getRandomVideo() {
        List<String> list = new ArrayList<>();
        list.add(SHUTTERSTOCK_V2864458);
        list.add(SHUTTERSTOCK_V3579536);
        list.add(SHUTTERSTOCK_V3671960);
        list.add(SHUTTERSTOCK_V4491596);
        list.add(SHUTTERSTOCK_V4584485);
        list.add(SHUTTERSTOCK_V8257699);

        int index = ThreadLocalRandom.current().nextInt(list.size());
        return list.get(index);
    }
}

