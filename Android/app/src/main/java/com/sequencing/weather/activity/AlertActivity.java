package com.sequencing.weather.activity;

import android.content.res.Configuration;
import android.media.MediaPlayer;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;

public class AlertActivity extends AppCompatActivity {

    private TextView tvAlert;
    private CVideoView videoView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_alert);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            setSupportActionBar(toolbar);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setDisplayShowTitleEnabled(false);
        }

        TextView tvToolbarTitle = (TextView) toolbar.findViewById(R.id.tvToolbarTitle);

        tvAlert = (TextView) findViewById(R.id.tvAlert);
        tvAlert.setText(getIntent().getStringExtra("alertText"));
        tvAlert.setTypeface(FontHelper.getTypeface(this));

        videoView = (CVideoView) findViewById(R.id.video_view);
        init();
    }

    @Override
    protected void onResume() {
        super.onResume();
        playVideo();
    }

    @Override
    public void onStop() {
        super.onStop();
        stopVideo();
    }

    private void stopVideo() {
        videoView.stopPlayback();
        videoView.setVisibility(View.GONE);
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
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}
