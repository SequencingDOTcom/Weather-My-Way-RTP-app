package com.sequencing.weather.activity;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Messenger;
import android.os.StrictMode;
import android.preference.PreferenceManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import com.google.android.vending.expansion.downloader.DownloadProgressInfo;
import com.google.android.vending.expansion.downloader.DownloaderClientMarshaller;
import com.google.android.vending.expansion.downloader.DownloaderServiceMarshaller;
import com.google.android.vending.expansion.downloader.Helpers;
import com.google.android.vending.expansion.downloader.IDownloaderClient;
import com.google.android.vending.expansion.downloader.IDownloaderService;
import com.google.android.vending.expansion.downloader.IStub;
import com.sequencing.oauth.core.DefaultSequencingOAuth2Client;
import com.sequencing.oauth.core.Token;
import com.sequencing.weather.helper.AccountHelper;
import com.sequencing.weather.helper.ConnectionHelper;
import com.sequencing.weather.helper.InstancesContainer;
import com.sequencing.weather.helper.InternalStorage;
import com.sequencing.weather.service.ExtensionDownloaderService;
import com.sequencing.weather.service.RegistrationIntentService;

import java.io.IOException;
import java.util.concurrent.Executors;

public class PreStartedActivity extends AppCompatActivity implements IDownloaderClient {

    private Intent secondActivity;
    private static final String TAG = "PreStartedActivity";
    private IStub mDownloaderClientStub;
    private IDownloaderService mRemoteService;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(com.sequencing.weather.R.layout.activity_prestarted);

        Intent registrationIntent = new Intent(this, RegistrationIntentService.class);
        startService(registrationIntent);

        if(!ConnectionHelper.isConnectionAvailable(this)) {
            Toast.makeText(this, "Check you internet connection and try again", Toast.LENGTH_LONG).show();
            finish();
            return;
        }

        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean("load_app", true).commit();

        boolean expansionFilesDelivered = expansionFilesDelivered();
        if (!expansionFilesDelivered) {
            Toast.makeText(this, "Please wait before Weather +RTP download resources", Toast.LENGTH_LONG).show();

            // Build an Intent to start this activity from the Notification
            Intent notifierIntent = new Intent(this, PreStartedActivity.class);
            notifierIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK |
                    Intent.FLAG_ACTIVITY_CLEAR_TOP);

            PendingIntent pendingIntent = PendingIntent.getActivity(this, 0,
                    notifierIntent, PendingIntent.FLAG_UPDATE_CURRENT);

            // Start the download service (if required)
            int startResult = 0;
            try {
                startResult = DownloaderClientMarshaller.startDownloadServiceIfRequired(this,
                        pendingIntent, ExtensionDownloaderService.class);
            } catch (PackageManager.NameNotFoundException e) {
                Log.e(TAG, "Failed to find name of extension file: " + e.getMessage());
                e.printStackTrace();
            }
            // If download has started, initialize this activity to show
            // download progress
            if (startResult != DownloaderClientMarshaller.NO_DOWNLOAD_REQUIRED) {
                mDownloaderClientStub = DownloaderClientMarshaller.CreateStub(this,
                        ExtensionDownloaderService.class);
                // Inflate layout that shows download progress
//                setContentView(R.layout.downloader_ui);

                return;
            } // If the download wasn't necessary, fall through to start the app
        }

        new SplashAsyncTask().execute();
    }

    @Override
    public void onServiceConnected(Messenger m) {
        mRemoteService = DownloaderServiceMarshaller.CreateProxy(m);
        mRemoteService.onClientUpdated(mDownloaderClientStub.getMessenger());
    }

    @Override
    public void onDownloadStateChanged(int newState) {
        if(newState == IDownloaderClient.STATE_COMPLETED) {
            Toast.makeText(this, "Download is completed", Toast.LENGTH_SHORT).show();
            new SplashAsyncTask().execute();
        }
    }

    @Override
    public void onDownloadProgress(DownloadProgressInfo progress) {

    }

    public class SplashAsyncTask extends AsyncTask<Void, Void, Void> {

        @Override
        protected void onPreExecute() {

        }

        @Override
        protected Void doInBackground(Void... params) {
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);

            DefaultSequencingOAuth2Client oAuth2Client = null;
            try {

                oAuth2Client = (DefaultSequencingOAuth2Client) InternalStorage.readObject(getApplicationContext(), "oAuth2Client");

                if (oAuth2Client != null && oAuth2Client.isAuthorized()) {
                    oAuth2Client.runRefreshTokenExecutor();
                    InstancesContainer.setoAuth2Client(oAuth2Client);
                    InternalStorage.writeObject(getApplicationContext(), "oAuth2Client", oAuth2Client);

                    secondActivity = new Intent(getApplicationContext(), MainActivity.class);
                    secondActivity.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                }
            } catch (IOException e) {
                Log.e(TAG, "Unable to read SequencingOAuth2Client instance from Android internal storage", e);
            } catch (Exception e) {
                Log.e(TAG, e.getMessage(), e);
            }

            if (oAuth2Client == null || !oAuth2Client.isAuthorized()) {
                secondActivity = new Intent(getApplicationContext(), StartActivity.class);
                secondActivity.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                getApplicationContext().startActivity(secondActivity);
            }

            Token token = null;
            if (oAuth2Client != null) {
                token = InstancesContainer.getoAuth2Client().getToken();
                long timeDifference = System.currentTimeMillis() - InstancesContainer.getoAuth2Client().getToken().getLastRefreshDate().getTime();
                while (token.getLastRefreshDate() == null || timeDifference > (token.getLifeTime() * 1000)) {
                    token = InstancesContainer.getoAuth2Client().getToken();
                    timeDifference = System.currentTimeMillis() - InstancesContainer.getoAuth2Client().getToken().getLastRefreshDate().getTime();
                }

            }
            return  null;
        }

        @Override
        protected void onPostExecute(Void v) {
            DefaultSequencingOAuth2Client oAuth2Client = null;
            try {
                oAuth2Client = (DefaultSequencingOAuth2Client) InternalStorage.readObject(getApplicationContext(), "oAuth2Client");
            } catch (IOException e) {
                Log.e(TAG, "Unable to read SequencingOAuth2Client instance from Android internal storage");
            } catch (Exception e) {
                Log.e(TAG, e.getMessage());
            }

            if(oAuth2Client != null) {
                // Set connected account
                Executors.newSingleThreadExecutor().submit(new Runnable() {
                    @Override
                    public void run() {
                        SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
                        settings.edit().putString("email", AccountHelper.getUserEmail(InstancesContainer.getoAuth2Client().getToken().getAccessToken())).commit();
                    }
                });

                StartActivity.refreshSettings(getApplicationContext(), InstancesContainer.getoAuth2Client().getToken());
                getApplicationContext().startActivity(secondActivity);
            }
        }
    }

    boolean expansionFilesDelivered() {
        String fileName = Helpers.getExpansionAPKFileName(this, true, 24);
        if (!Helpers.doesFileExist(this, fileName, 50637096, false)) {  //244255534
            return false;
        }
        return true;
    }

    @Override
    protected void onResume() {
        if (null != mDownloaderClientStub) {
            mDownloaderClientStub.connect(this);
        }
        super.onResume();
    }

    @Override
    protected void onStop() {
        if (null != mDownloaderClientStub) {
            mDownloaderClientStub.disconnect(this);
        }
        super.onStop();
    }
}
