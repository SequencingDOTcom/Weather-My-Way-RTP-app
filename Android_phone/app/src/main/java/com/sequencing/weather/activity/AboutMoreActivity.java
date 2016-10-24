package com.sequencing.weather.activity;

import android.content.Intent;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;

public class AboutMoreActivity extends AppCompatActivity {


    private CVideoView videoView;
    private ImageView imLogoWithText;
    private ImageView ivGithub;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_about_more);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            setSupportActionBar(toolbar);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setDisplayShowTitleEnabled(false);
        }

        TextView tvToolbarTitle = (TextView) toolbar.findViewById(R.id.toolbar_title);
        tvToolbarTitle.setTypeface(FontHelper.getTypeface(this));

        videoView = (CVideoView) findViewById(R.id.video_view);

        TextView tvAboutMore = (TextView) findViewById(R.id.tvAboutMore);
        tvAboutMore.setMovementMethod(LinkMovementMethod.getInstance());
        TextView tvAboutMorePoweredBy = (TextView) findViewById(R.id.tvAboutMorePoweredBy);
        tvAboutMore.setTypeface(FontHelper.getTypeface(this));
        tvAboutMorePoweredBy.setTypeface(FontHelper.getTypeface(this));

        imLogoWithText = (ImageView) findViewById(R.id.ivLogoWithText);
        imLogoWithText.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://sequencing.com/"));
                startActivity(browserIntent);
            }
        });
        ivGithub = (ImageView) findViewById(R.id.ivGithub);
        ivGithub.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/SequencingDOTcom/Weather-My-Way-RTP-app"));
                startActivity(browserIntent);
            }
        });
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
        videoView.setVisibility(View.VISIBLE);
        String videoName = VideoGeneratorHelper.getVideo(this);
        videoView.setVideoURI(Uri.parse(videoName));
        videoView.start();
        videoView.setAlignment(CVideoView.ALIGN_WIDTH);
    }

    private void stopVideo() {
        videoView.stopPlayback();
        videoView.setVisibility(View.GONE);
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
