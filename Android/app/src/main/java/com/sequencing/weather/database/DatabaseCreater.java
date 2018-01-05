package com.sequencing.weather.database;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;
import android.util.Log;

/**
 * Created by omazurova on 5/5/2017.
 */

public class DatabaseCreater extends SQLiteOpenHelper{

    private static String LOG_TAG = DatabaseCreater.class.getSimpleName();
    private static final String DATABASE_NAME = "WeatherRTPLoggingDB";
    private static final int DATABASE_VERSION = 3;
    private final Context context;

    ////ALL TABLES IN DATABASE////
    public static String TABLE_USAGE = "TableUsage";
    public static String TABLE_EVENT = "TableEvent";
    public static String TABLE_INTERACTION = "TableInteraction";
    public static String TABLE_REQUEST = "TableRequest";

    ///columns in TableUsage///
    public static final String TABLE_USAGE_ID= "usageId";
    public static final String TABLE_USAGE_START = "usageStart";
    public static final String TABLE_USAGE_END = "usageEnd";

    ///columns in TableInteractions///
    public static final String TABLE_INTERACTION_ID = "interactionId";
    public static final String TABLE_INTERACTION_LAT = "interactionLat";
    public static final String TABLE_INTERACTION_LON = "interactionLon";
    public static final String TABLE_INTERACTION_PLACE = "interactionPlace";
    public static final String TABLE_INTERACTION_TIMESTAMP = "interactionTimestamp";
    public static final String TABLE_INTERACTION_DURATION = "interactionDuration";
    public static final String TABLE_INTERACTION_MEDIA = "interactionMedia";

    ///columns in TableEvents///
    public static final String TABLE_EVENT_ID = "eventId";
    public static final String TABLE_EVENT_TS = "eventTS";
    public static final String TABLE_EVENT_TYPE = "eventType";

    ///columns in TableRequest///
    public static final String TABLE_REQUEST_ID = "requestId";
    public static final String TABLE_REQUEST_TIME = "requestTimeStamp";
    public static final String TABLE_REQUEST_OF_SERVICE = "requestService";//0 for wu, 1 for appchains
    public static final String TABLE_REQUEST_BACKGROUND = "requestBackground";//1 for background, 0 for interactions
    public static final String TABLE_REQUEST_FAILURE_TS= "requestFailureTS";
    public static final String TABLE_REQUEST_FAILURE_REASON = "requestFailureReason";
    public static final String TABLE_REQUEST_INTERACTION_TIMESTAMP = "requestInteractionId";

    public static final String CREATE_TABLE_USAGE =
            "create table " + TABLE_USAGE +
                    " (" + BaseColumns._ID + " integer primary key autoincrement, " +
                    TABLE_USAGE_START + " integer, " +
                    TABLE_USAGE_END + " integer);";

    public static final String CREATE_TABLE_INTERACTIONS =
            "create table " + TABLE_INTERACTION +
                    " (" + BaseColumns._ID + " integer primary key autoincrement, " +
                    TABLE_INTERACTION_LAT + " real, " +
                    TABLE_INTERACTION_LON + " real," +
                    TABLE_INTERACTION_PLACE + " text," +
                    TABLE_INTERACTION_TIMESTAMP + " integer," +
                    TABLE_INTERACTION_DURATION + " integer," +
                    TABLE_INTERACTION_MEDIA + " integer);";

    public static final String CREATE_TABLE_REQUEST =
            "create table " + TABLE_REQUEST +
                    " (" + BaseColumns._ID + " integer primary key autoincrement, " +
                    TABLE_REQUEST_TIME + " integer, " +
                    TABLE_REQUEST_OF_SERVICE + " integer," +
                    TABLE_REQUEST_BACKGROUND + " integer,"+
                    TABLE_REQUEST_FAILURE_TS + " integer," +
                    TABLE_REQUEST_FAILURE_REASON + " text," +
                    TABLE_REQUEST_INTERACTION_TIMESTAMP + " integer, " +
                    " foreign key (" + TABLE_REQUEST_INTERACTION_TIMESTAMP + ") references " + TABLE_INTERACTION +  "(" + TABLE_INTERACTION_TIMESTAMP + "));";

    public static final String CREATE_TABLE_EVENTS =
            "create table " + TABLE_EVENT +
                    " (" + BaseColumns._ID + " integer primary key autoincrement, " +
                    TABLE_EVENT_TS + " integer, " +
                    TABLE_EVENT_TYPE + " integer);";

    public DatabaseCreater(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
        this.context = context;
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.beginTransaction();
        try {
            db.execSQL(CREATE_TABLE_USAGE);
            db.execSQL(CREATE_TABLE_EVENTS);
            db.execSQL(CREATE_TABLE_INTERACTIONS);
            db.execSQL(CREATE_TABLE_REQUEST);
            db.setTransactionSuccessful();
        } catch (SQLiteException e){
            Log.d(LOG_TAG, "Can't create database", e);
        } finally {
            db.endTransaction();
        }
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int i, int i1) {
        db.beginTransaction();
        try{
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_USAGE);
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_EVENT);
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_INTERACTION);
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_REQUEST);
            db.setTransactionSuccessful();
        } catch (SQLiteException e){
            Log.d(LOG_TAG, "Can't drop database", e);
        } finally {
            db.endTransaction();
        }
        onCreate(db);
    }
}
