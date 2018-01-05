package com.sequencing.weather.dagger;

import android.content.Context;

import com.sequencing.weather.database.LoggingQueries;
import com.sequencing.weather.database.SQLiteAccessData;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;

/**
 * Created by omazurova on 5/16/2017.
 */

@Module
public class DatabaseModule {

    private Context context;
    private SQLiteAccessData sqLiteAccessData;

    public DatabaseModule(Context context){
        this.context = context;
    }

    @Provides
    @Singleton
    SQLiteAccessData sqLiteAccessData(){
        sqLiteAccessData = new SQLiteAccessData(context);
        return sqLiteAccessData;
    }

    @Provides
    @Singleton
    LoggingQueries loggingQueries(SQLiteAccessData sqLiteAccessData){
        return new LoggingQueries(sqLiteAccessData);
    }
}
