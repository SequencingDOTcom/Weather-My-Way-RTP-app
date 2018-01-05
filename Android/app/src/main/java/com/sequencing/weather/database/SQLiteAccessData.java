package com.sequencing.weather.database;

import android.content.Context;

/**
 * Created by omazurova on 5/10/2017.
 */

public class SQLiteAccessData {
    private android.database.sqlite.SQLiteDatabase sqLiteDatabase;
    private DatabaseCreater databaseCreater;

    public SQLiteAccessData(Context context){
        databaseCreater = new DatabaseCreater(context);
        open();
    }

    public android.database.sqlite.SQLiteDatabase getDatabase() {
        sqLiteDatabase = databaseCreater.getWritableDatabase();
        return sqLiteDatabase;
    }

    public void open(){
        sqLiteDatabase = databaseCreater.getWritableDatabase();
    }

    public void closeDB(){
        if(databaseCreater != null) databaseCreater.close();
    }
}
