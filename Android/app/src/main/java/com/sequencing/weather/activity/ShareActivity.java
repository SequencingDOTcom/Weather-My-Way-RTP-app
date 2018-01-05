package com.sequencing.weather.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.support.v4.app.ShareCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.FacebookSdk;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.ShareButton;
import com.google.android.gms.plus.PlusShare;
import com.linkedin.platform.APIHelper;
import com.linkedin.platform.LISessionManager;
import com.linkedin.platform.errors.LIApiError;
import com.linkedin.platform.errors.LIAuthError;
import com.linkedin.platform.listeners.ApiListener;
import com.linkedin.platform.listeners.ApiResponse;
import com.linkedin.platform.listeners.AuthListener;
import com.linkedin.platform.utils.Scope;
import com.pinterest.android.pdk.PDKBoard;
import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.tweetcomposer.TweetComposer;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import io.fabric.sdk.android.Fabric;

import com.pinterest.android.pdk.PDKCallback;
import com.pinterest.android.pdk.PDKClient;
import com.pinterest.android.pdk.PDKException;
import com.pinterest.android.pdk.PDKResponse;

public class ShareActivity extends AppCompatActivity implements View.OnClickListener {

    private static final int REQ_SELECT_PHOTO = 1;
    private static final int REQ_START_SHARE = 2;

    private ImageButton btnFacebook;
    private ImageButton btnTwitter;
    private ImageButton btnLinkedIn;
    private ImageButton btnGoogle;
    private ImageButton btnReddit;
    private ImageButton btnPinterest;
    private ShareButton btnShareFacebook;

    private Activity thisActivity;
    private SharedPreferences settings;

    private CVideoView videoView;

    private static final String TAG = "ShareActivity";
    private String forecast;
    private PDKClient pdkClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);

        FacebookSdk.sdkInitialize(getApplicationContext());

        PDKClient.configureInstance(this, "4835022125880322507");
        PDKClient.getInstance().onConnect(this);

        setContentView(R.layout.activity_share);

        videoView = (CVideoView) findViewById(R.id.video_view);

        thisActivity = this;
        settings = PreferenceManager.getDefaultSharedPreferences(this);
        forecast = settings.getString("genetically_forecast", null);

        TextView tvShare = (TextView) findViewById(R.id.tvShare);
        tvShare.setTypeface(FontHelper.getTypeface(this));

        ShareLinkContent content = new ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(getResources().getString(R.string.share_url)))
                .setContentTitle(getResources().getString(R.string.share_title))
                .setContentDescription(forecast)
                .setImageUrl(Uri.parse(getResources().getString(R.string.share_image_uri)))
                .build();


        btnShareFacebook = new ShareButton(this);
        btnShareFacebook.setShareContent(content);

        btnFacebook = (ImageButton) findViewById(R.id.btnFacebook);
        btnTwitter = (ImageButton) findViewById(R.id.btnTwitter);
        btnLinkedIn = (ImageButton) findViewById(R.id.btnLinkedIn);
        btnGoogle = (ImageButton) findViewById(R.id.btnGoogle);
        btnReddit = (ImageButton) findViewById(R.id.btnReddit);
        btnPinterest = (ImageButton) findViewById(R.id.btnPinterest);
        btnTwitter.setOnClickListener(this);
        btnLinkedIn.setOnClickListener(this);
        btnFacebook.setOnClickListener(this);
        btnGoogle.setOnClickListener(this);
        btnReddit.setOnClickListener(this);
        btnPinterest.setOnClickListener(this);

        TwitterAuthConfig authConfig = new TwitterAuthConfig("pSLyoxsMsrgmsDz80STpCu7Mk", "ZziaiY3d4ALRfEOpauIwMXUYRqKqUfmyx6ZQ9FmufXHEssiSWU");
        Fabric.with(this, new TwitterCore(authConfig), new TweetComposer());
    }

    @Override
    protected void onResume() {
        super.onResume();
        init();
        playVideo();
    }

    @Override
    public void onPause() {
        super.onPause();
//        stopVideo();
    }

    private void init() {
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mp.setLooping(true);
                videoView.setOnCorrectVideoDimensions(getCorrectVideoDimensions());
                mp.setOnVideoSizeChangedListener(new MediaPlayer.OnVideoSizeChangedListener() {
                    public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
                        videoView.onVideoSizeChanged(mp);
                    }
                });
            }
        });
    }

    private void playVideo() {
        int orientation = getResources().getConfiguration().orientation;
        if(orientation == Configuration.ORIENTATION_PORTRAIT){
            videoView.setAlignment(CVideoView.ALIGN_WIDTH);
        } else {
            videoView.setAlignment(CVideoView.ALIGN_NONE);
        }
        videoView.setVisibility(View.VISIBLE);
        String videoName = VideoGeneratorHelper.getVideo(this);
        String videoNameWithoutExtension = videoName.split("\\.")[0];
        int raw_id = getResources().getIdentifier(videoNameWithoutExtension, "raw", getPackageName());
        String path = "android.resource://" + getPackageName() + "/" + raw_id;
        videoView.setVideoURI(Uri.parse(path));
        videoView.start();
    }

    private void stopVideo() {
        videoView.stopPlayback();
        videoView.setVisibility(View.GONE);
    }

    @Override
    public void onStop() {
        super.onStop();
        stopVideo();
    }

    /**
     * Adjust video layout according to video dimensions
     */
    private CVideoView.OnCorrectVideoDimensions getCorrectVideoDimensions() {
        return new CVideoView.OnCorrectVideoDimensions() {
            @Override
            public void correctDimensions(int width, int height) {
                AppUIHelper.resizeLayout(videoView, height, -1, 300, null);
            }
        };
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btnFacebook:
                btnShareFacebook.performClick();
                break;
            case R.id.btnTwitter:
                try {
                    shareViaTwitter();
                } catch (MalformedURLException e) {
                    Log.w(TAG, "Failure to format URL", e);
                }
                break;
            case R.id.btnLinkedIn:
                signinToLinkedin();
                break;
            case R.id.btnGoogle:
                shareViaGoogle();
                break;
            case R.id.btnReddit:
                shareViaReddit();
                break;
            case R.id.btnPinterest:
                shareViaPinterest();
                break;
        }
    }

    private void shareViaTwitter() throws MalformedURLException {
        TweetComposer.Builder builder = new TweetComposer.Builder(this)
                .text(forecast)
                .url(new URL(getResources().getString(R.string.share_url)));
        builder.show();
    }

    private void signinToLinkedin() {
        LISessionManager.getInstance(getApplicationContext()).init(this, buildScope(), new AuthListener() {
            @Override
            public void onAuthSuccess() {
                try {
                    shareViaLinkedin();
                } catch (JSONException e) {
                    Log.w(TAG, "Failure to format JSON", e);
                }
            }

            @Override
            public void onAuthError(LIAuthError error) {
                Log.w(TAG, "Failure to sign in to Linkedin " + error.toString());
                Toast.makeText(getBaseContext(), "Failure to sign in to Linkedin", Toast.LENGTH_SHORT).show();
            }
        }, true);


    }

    private void shareViaLinkedin() throws JSONException {
        String url = "https://api.linkedin.com/v1/people/~/shares";

        JSONObject body = new JSONObject("{" +
                "\"comment\": \"" + forecast + "\"," +
                "\"visibility\": { \"code\": \"anyone\" }," +
                "\"content\": { " +
                "\"title\": \"" + getResources().getString(R.string.share_title) + "\"," +
                "\"submitted-url\": \"" + getResources().getString(R.string.share_url) + "\"," +
                "\"submitted-image-url\": \"" + Uri.parse(getResources().getString(R.string.share_image_uri)) + "\"" +
                "}" +
                "}");

        APIHelper apiHelper = APIHelper.getInstance(getApplicationContext());
        apiHelper.postRequest(this, url, body, new ApiListener() {
            @Override
            public void onApiSuccess(ApiResponse apiResponse) {
                Toast.makeText(getBaseContext(), "You has been successfully shared via Linkedin", Toast.LENGTH_SHORT).show();
                Log.d(TAG, apiResponse.toString());
            }

            @Override
            public void onApiError(LIApiError liApiError) {
                Log.w(TAG, "Failure to share via Linkedin " + liApiError.toString());
                Toast.makeText(getBaseContext(), "Failure to share via Linkedin " + liApiError.getMessage(), Toast.LENGTH_LONG).show();
            }
        });
    }

    private void shareViaGoogle() {
        Intent shareIntent = new PlusShare.Builder(this)
                .setType("text/plain")
                .setText(forecast)
                .setContentUrl(Uri.parse(getResources().getString(R.string.share_url)))
                .getIntent();

        startActivityForResult(shareIntent, 0);
    }

    private void shareViaReddit() {
        String url = "https://www.reddit.com/submit?";
        url += "url=" + getResources().getString(R.string.share_url);
        url += "&title=" + forecast;
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.setData(Uri.parse(url));
        startActivity(i);
    }

    private void shareViaPinterest() {
        List scopes = new ArrayList<String>();
        scopes.add(PDKClient.PDKCLIENT_PERMISSION_READ_PUBLIC);
        scopes.add(PDKClient.PDKCLIENT_PERMISSION_WRITE_PUBLIC);

        pdkClient = PDKClient.getInstance();

        pdkClient.login(this, scopes, new PDKCallback() {
            @Override
            public void onSuccess(PDKResponse response) {
                Log.d(TAG, response.getData().toString());
                final String boardName = "Sequencing";


                pdkClient.createBoard(boardName, getResources().getString(R.string.share_description), new PDKCallback() {
                    @Override
                    public void onSuccess(PDKResponse response) {
                        Log.d(TAG, response.getData().toString());

                        pdkClient.createPin(settings.getString("genetically_forecast", null),
                                response.getBoard().getUid(), getResources().getString(R.string.share_image_uri), getResources().getString(R.string.share_url), pdkCallback);
                    }

                    @Override
                    public void onFailure(PDKException exception) {
                        Log.e(TAG, exception.getDetailMessage());
                        pdkClient.getMyBoards("id,name", new PDKCallback(){
                            public void onSuccess(PDKResponse response) {
                                Log.d(TAG, response.getData().toString());
                                String id = "";
                                for(PDKBoard board: response.getBoardList())
                                    if(board.getName().equals(boardName))
                                        id = board.getUid();

                                pdkClient.createPin(forecast,
                                        id, getResources().getString(R.string.share_image_uri), getResources().getString(R.string.share_url), pdkCallback);
                            }

                            @Override
                            public void onFailure(PDKException exception) {
                                Log.e(TAG, exception.getDetailMessage());
                            }
                        });
                    }
                });
            }

            @Override
            public void onFailure(PDKException exception) {
                Log.e(TAG, exception.getDetailMessage());
            }
        });

    }

    private PDKCallback pdkCallback = new PDKCallback(){
        @Override
        public void onSuccess(PDKResponse response) {
            Log.d(TAG, response.getData().toString());
        }

        @Override
        public void onFailure(PDKException exception) {
            Log.e(TAG, exception.getDetailMessage());
        }
    };

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // Add this line to your existing onActivityResult() method
        LISessionManager.getInstance(getApplicationContext()).onActivityResult(this, requestCode, resultCode, data);

        PDKClient.getInstance().onOauthResponse(requestCode, resultCode, data);
    }

    // Build the list of member permissions our LinkedIn session requires
    private static Scope buildScope() {
        return Scope.build(Scope.R_BASICPROFILE, Scope.W_SHARE);
    }
}
