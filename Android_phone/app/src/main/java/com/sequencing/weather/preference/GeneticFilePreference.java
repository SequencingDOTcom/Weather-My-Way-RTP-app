package com.sequencing.weather.preference;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.TypedArray;
import android.os.StrictMode;
import android.preference.DialogPreference;
import android.preference.PreferenceManager;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;

import com.sequencing.fileselector.FileEntity;
import com.sequencing.fileselector.core.ISQFileCallback;
import com.sequencing.fileselector.core.SQUIFileSelectHandler;
import com.sequencing.oauth.core.SequencingOAuth2Client;
import com.sequencing.weather.helper.HttpHelper;
import com.sequencing.weather.helper.InstancesContainer;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class GeneticFilePreference extends DialogPreference {
    private String filename;
    private static SQUIFileSelectHandler fileSelectHandler;
    private static Context context;

    private static final String TAG = "GeneticFilePreference";

    public GeneticFilePreference(Context ctxt, AttributeSet attrs) {
        super(ctxt, attrs);
    }

    @Override
    protected View onCreateDialogView() {
        return null;
    }

    @Override
    protected void onClick() {
        runFileSelector(getContext(), true);
    }

    public static void runFileSelector(Context context, boolean showRotatingCube){
        GeneticFilePreference.context = context;
        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);

        fileSelectHandler = new SQUIFileSelectHandler(context);

        SequencingOAuth2Client oAuth2Client = InstancesContainer.getoAuth2Client();

        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        fileSelectHandler.selectFile(oAuth2Client, weatherISQFileCallback, showRotatingCube, settings.getString("genetic_file_id", null));
    }

    public static ISQFileCallback weatherISQFileCallback = new ISQFileCallback() {
        @Override
        public void onFileSelected(FileEntity entity, Activity activity) {
            Log.i(TAG, "File has been selected");

            String filename = getGeneticFileName(entity);

            SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(context);
            SharedPreferences.Editor editor = settings.edit();
            editor.putString("genetic_data_file", filename);
            editor.putString("genetic_file_id", entity.getId());
            editor.putBoolean("should_refresh_genetically", true);
            editor.putBoolean("should_refresh", true);
            editor.commit();

            sendFileIdToServer(entity.getId(), filename, InstancesContainer.getoAuth2Client().getToken().getAccessToken());

            activity.finish();
        }
    };

    private static void sendFileIdToServer(final String selectedId, final String selectedName, final String token) {
        Runnable run = new Runnable() {
            @Override
            public void run() {
                Map<String, String> params = new HashMap<>(11);
                params.put("selectedId", selectedId);
                params.put("selectedName", selectedName);
                params.put("token", token);

                String url = "https://weathermyway.rocks//ExternalSettings/SaveFile";
                String response = HttpHelper.doPost(url, null, params);
            }
        };
        ExecutorService service = Executors.newSingleThreadExecutor();
        service.submit(run);

        Log.i(TAG, "File id has been sent to server");
    }

    private static String getGeneticFileName(FileEntity entity) {

        if (entity.getName().equals("Sample genome"))
            return entity.getFriendlyDesc1() + " - " + entity.getFriendlyDesc2();
        else
            return entity.getName();
    }

    @Override
    protected void onBindDialogView(View v) {
        super.onBindDialogView(v);
    }

    @Override
    protected void onDialogClosed(boolean positiveResult) {
        super.onDialogClosed(positiveResult);

        if (positiveResult) {
            if (callChangeListener(filename)) {
                persistString(filename);
            }
        }
    }

    @Override
    protected Object onGetDefaultValue(TypedArray a, int index) {
        return (a.getString(index));
    }

    @Override
    protected void onSetInitialValue(boolean restoreValue, Object defaultValue) {
        if (restoreValue) {
            if (defaultValue == null) {
                filename = getPersistedString("N/A");
            } else {
                filename = getPersistedString(defaultValue.toString());
            }
        } else {
            filename = defaultValue.toString();
        }
    }
}

