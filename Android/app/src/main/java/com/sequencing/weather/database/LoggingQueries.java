package com.sequencing.weather.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.provider.BaseColumns;

import com.sequencing.weather.logging.EventEntity;
import com.sequencing.weather.logging.events.Interaction;
import com.sequencing.weather.logging.events.Request;
import com.sequencing.weather.logging.events.Usage;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by omazurova on 5/10/2017.
 */

public class LoggingQueries {

    private Context context;
    SQLiteAccessData sqLiteAccessData;

    public LoggingQueries(SQLiteAccessData sqLiteAccessData) {
        this.sqLiteAccessData = sqLiteAccessData;
    }

    public void startUsage(long startTimestamp) {
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        db.beginTransaction();
        ContentValues contentValues = new ContentValues();
        contentValues.put(DatabaseCreater.TABLE_USAGE_START, startTimestamp);
        try {
            db.insert(DatabaseCreater.TABLE_USAGE, null, contentValues);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public void addEvent(long timestamp, int type) {
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        db.beginTransaction();
        ContentValues contentValues = new ContentValues();
        contentValues.put(DatabaseCreater.TABLE_EVENT_TS, timestamp);
        contentValues.put(DatabaseCreater.TABLE_EVENT_TYPE, type);
        try {
            db.insert(DatabaseCreater.TABLE_EVENT, null, contentValues);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public long addInteraction(Interaction interaction) {
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        db.beginTransaction();
        ContentValues contentValues = new ContentValues();
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_LAT, interaction.lat);
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_LON, interaction.lng);
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_PLACE, interaction.place);
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_TIMESTAMP, interaction.ts);
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_DURATION, interaction.duration);
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_MEDIA, interaction.media);

        long idInteraction;
        try {
            idInteraction = db.insert(DatabaseCreater.TABLE_INTERACTION, null, contentValues);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }

        return idInteraction;
    }

    public void updateInteractionDuration(long idInteraction, long duration) {
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        db.beginTransaction();
        ContentValues contentValues = new ContentValues();
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_DURATION, duration);
        try {
            db.update(DatabaseCreater.TABLE_INTERACTION, contentValues,
                    BaseColumns._ID + " = ?",
                    new String[]{idInteraction + ""});
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public void updateInteractionDurationByTimestamp(long timestamp, long duration) {
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        db.beginTransaction();
        ContentValues contentValues = new ContentValues();
        contentValues.put(DatabaseCreater.TABLE_INTERACTION_DURATION, duration);
        try {
            db.update(DatabaseCreater.TABLE_INTERACTION, contentValues,
                    DatabaseCreater.TABLE_INTERACTION_TIMESTAMP + " = ?",
                    new String[]{timestamp + ""});
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public void addRequest(Request request, long interactionTimeStamp) {
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        db.beginTransaction();
        ContentValues contentValues = new ContentValues();
        contentValues.put(DatabaseCreater.TABLE_REQUEST_TIME, request.requestTime);
        contentValues.put(DatabaseCreater.TABLE_REQUEST_OF_SERVICE, request.requestService);
        contentValues.put(DatabaseCreater.TABLE_REQUEST_BACKGROUND, request.requestBackground);
        contentValues.put(DatabaseCreater.TABLE_REQUEST_FAILURE_TS, request.failureTimestamp);
        contentValues.put(DatabaseCreater.TABLE_REQUEST_FAILURE_REASON, request.failureReason);
        if (interactionTimeStamp != 0) {
            contentValues.put(DatabaseCreater.TABLE_REQUEST_INTERACTION_TIMESTAMP, interactionTimeStamp);
        }
        try {
            db.insert(DatabaseCreater.TABLE_REQUEST, null, contentValues);
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public Usage getUsage(){
        Usage usage = new Usage();
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM " + DatabaseCreater.TABLE_USAGE, null);
        while (cursor.moveToNext()){
            usage.start = cursor.getLong(cursor.getColumnIndex(DatabaseCreater.TABLE_USAGE_START));
            usage.end = cursor.getLong(cursor.getColumnIndex(DatabaseCreater.TABLE_USAGE_END));
        }
        if (cursor != null){
            cursor.close();
        }
        return usage;
    }

    public List<EventEntity.Event> getEvents(){
        List<EventEntity.Event> events = new ArrayList<>();
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM " + DatabaseCreater.TABLE_EVENT, null);
        while (cursor.moveToNext()){
            EventEntity.Event event = new EventEntity.Event();
            event.ts = cursor.getLong(cursor.getColumnIndex(DatabaseCreater.TABLE_EVENT_TS));
            event.type = cursor.getInt(cursor.getColumnIndex(DatabaseCreater.TABLE_EVENT_TYPE));
            events.add(event);
        }
        if (cursor != null){
            cursor.close();
        }
        return events;
    }

    public List<Request> getBackgroundData(int serviceType){
        List<Request> requests = new ArrayList<>();
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM " + DatabaseCreater.TABLE_REQUEST + " WHERE " + DatabaseCreater.TABLE_REQUEST_OF_SERVICE +
                "=" + serviceType + " AND " + DatabaseCreater.TABLE_REQUEST_BACKGROUND + " = 1 " +
                " ORDER BY " + DatabaseCreater.TABLE_REQUEST_TIME + " DESC", null);
        while (cursor.moveToNext()){
            Request request = new Request();
            request.requestTime = cursor.getInt(cursor.getColumnIndex(DatabaseCreater.TABLE_REQUEST_TIME));
            request.failureTimestamp = cursor.getLong(cursor.getColumnIndex(DatabaseCreater.TABLE_REQUEST_FAILURE_TS));
            request.failureReason = cursor.getString(cursor.getColumnIndex(DatabaseCreater.TABLE_REQUEST_FAILURE_REASON));
            requests.add(request);
        }
        if (cursor != null){
            cursor.close();
        }
        return requests;
    }

    public List<Interaction> getInteractions(){
        List<Interaction> interactions = new ArrayList<>();
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM " + DatabaseCreater.TABLE_INTERACTION, null);
        while (cursor.moveToNext()){
            Interaction interaction = new Interaction();
            interaction.id = cursor.getLong(cursor.getColumnIndex(BaseColumns._ID));
            interaction.lat = cursor.getFloat(cursor.getColumnIndex(DatabaseCreater.TABLE_INTERACTION_LAT));
            interaction.lng = cursor.getFloat(cursor.getColumnIndex(DatabaseCreater.TABLE_INTERACTION_LON));
            interaction.duration = cursor.getLong(cursor.getColumnIndex(DatabaseCreater.TABLE_INTERACTION_DURATION));
            interaction.media = cursor.getInt(cursor.getColumnIndex(DatabaseCreater.TABLE_INTERACTION_MEDIA));
            interaction.place = cursor.getString(cursor.getColumnIndex(DatabaseCreater.TABLE_INTERACTION_PLACE));
            interaction.ts = cursor.getLong(cursor.getColumnIndex(DatabaseCreater.TABLE_INTERACTION_TIMESTAMP));

            interactions.add(interaction);
        }
        if (cursor != null){
            cursor.close();
        }
        return interactions;
    }

    public List<Request> getRequestsByInteractionTimestamp(long idInteraction, int serviceType){
        List<Request> requests = new ArrayList<>();
        SQLiteDatabase db = sqLiteAccessData.getDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM " + DatabaseCreater.TABLE_REQUEST +
                " WHERE " + DatabaseCreater.TABLE_REQUEST_INTERACTION_TIMESTAMP + "=" + idInteraction +
                " AND " + DatabaseCreater.TABLE_REQUEST_OF_SERVICE + "=" + serviceType, null);
        while (cursor.moveToNext()){
            Request request = new Request();
            request.requestTime = cursor.getInt(cursor.getColumnIndex(DatabaseCreater.TABLE_REQUEST_TIME));
            request.failureTimestamp = cursor.getLong(cursor.getColumnIndex(DatabaseCreater.TABLE_REQUEST_FAILURE_TS));
            request.failureReason = cursor.getString(cursor.getColumnIndex(DatabaseCreater.TABLE_REQUEST_FAILURE_REASON));
            requests.add(request);
        }
        if (cursor != null){
            cursor.close();
        }
        return requests;
    }
}
