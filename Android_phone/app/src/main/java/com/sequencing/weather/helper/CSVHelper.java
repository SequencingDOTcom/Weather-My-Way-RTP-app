package com.sequencing.weather.helper;

import android.content.Context;
import android.util.Log;

import com.sequencing.weather.R;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CSVHelper {
    private static final String TAG = "CSVHelper";
    private static List<String> headres = new ArrayList<>();
    private static Map<String, List<String>> content = new HashMap<>();

    private static void init(Context context) throws IOException {
        InputStream is = context.getAssets().open("recs.csv");
        int size = is.available();
        byte[] buffer = new byte[size];
        is.read(buffer);
        is.close();
        String fileContent = new String(buffer);

        CSVParser parser = CSVParser.parse(fileContent,  CSVFormat.RFC4180);
        for (CSVRecord csvRecord : parser) {
            if(headres.size() == 0) {
                for(int i = 1; i < csvRecord.size(); i++)
                    headres.add(csvRecord.get(i));
                continue;
            }

            List<String> tmpList = new ArrayList<>(csvRecord.size()-1);
            for(int i = 1; i < csvRecord.size(); i++){
                tmpList.add(csvRecord.get(i));
            }
            content.put(csvRecord.get(0), tmpList);
        }
    }

    public static List<String> getHeadres(Context context) {
        if(headres.size() == 0) {
            try {
                init(context);
            } catch (IOException e) {
                Log.w(TAG, "Unable to reade CSV file -> " + e.getMessage(), e);
            }
        }
        return headres;
    }

    public static Map<String, List<String>> getContent(Context context) {
        if(content.size() == 0) {
            try {
                init(context);
            } catch (IOException e) {
                Log.w(TAG, "Unable to reade CSV file -> " + e.getMessage(), e);
            }
        }
        return content;
    }

    public static String getGeneticallyTailoredForecast(Context context, String riskDescription, String hasVitD, String weather) {
        String header = riskDescription + "-" + hasVitD;
        int columnIndex = CSVHelper.getHeadres(context).indexOf(header);

        Map<String ,List<String>> csvContent = CSVHelper.getContent(context);
        List<String> forecastList = csvContent.get(weather);

        if(forecastList == null || forecastList.size() < columnIndex)
            return context.getResources().getString(R.string.error_during_receive_genetically_forecast);

        return forecastList.get(columnIndex);
    }
}
