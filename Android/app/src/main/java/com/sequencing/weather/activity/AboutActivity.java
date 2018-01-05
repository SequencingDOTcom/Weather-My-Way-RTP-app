package com.sequencing.weather.activity;

import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Typeface;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.sequencing.video.customview.CVideoView;
import com.sequencing.video.helper.AppUIHelper;
import com.sequencing.weather.R;
import com.sequencing.weather.helper.FontHelper;
import com.sequencing.weather.helper.VideoGeneratorHelper;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.Click;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;

@EActivity(R.layout.activity_about)
public class AboutActivity extends AppCompatActivity {

    @ViewById(R.id.clAboutActivity)
    CoordinatorLayout clAboutActivity;

    @ViewById(R.id.toolbar)
    Toolbar toolbar;

    @ViewById(R.id.toolbar_title)
    TextView toolbarTitle;

    @ViewById(R.id.llAbout)
    LinearLayout llAbout;

    @ViewById(R.id.tvAbout)
    TextView tvAbout;

    @ViewById(R.id.rlContentMore)
    RelativeLayout rlContentMore;

    @ViewById(R.id.tvAboutMore)
    TextView tvAboutMore;

    @ViewById(R.id.tvAboutMorePoweredBy)
    TextView tvAboutMorePoweredBy;

    @ViewById(R.id.ivLogoWithText)
    ImageView ivLogoWithText;

    @ViewById(R.id.ivGithub)
    ImageView ivGithub;

    @ViewById(R.id.video_view)
    CVideoView videoView;

    private Typeface typeface;
    private boolean isTablet;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        isTablet = getResources().getBoolean(R.bool.is_tablet);
    }

    @AfterViews
    protected void setViews() {
        setSupportActionBar(toolbar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setDisplayShowTitleEnabled(false);
        init();
        playVideo();
        typeface = FontHelper.getTypeface(this);
        FontHelper.overrideFonts(clAboutActivity, typeface);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (!isTablet) {
            rlContentMore.setVisibility(View.GONE);
        } else {
            rlContentMore.setVisibility(View.VISIBLE);
        }
        playVideo();
    }

    @Override
    public void onPause() {
        super.onPause();
//        stopVideo();
    }

    @Override
    public void onStop() {
        super.onStop();
        stopVideo();
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

    @Click(R.id.ivLogoWithText)
    protected void onLogoClick() {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://sequencing.com/"));
        startActivity(browserIntent);
    }

    @Click(R.id.ivGithub)
    protected void onLogoGithub() {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("https://github.com/SequencingDOTcom/Weather-My-Way-RTP-app"));
        startActivity(browserIntent);
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
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!isTablet) {
            getMenuInflater().inflate(R.menu.menu_about, menu);
            if (rlContentMore.getVisibility() == View.VISIBLE) {
                rlContentMore.setVisibility(View.GONE);
                llAbout.setVisibility(View.VISIBLE);
                MenuItem menuItem = menu.findItem(R.id.action_more);
                menuItem.setVisible(true);
            }
        }
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_more) {
            rlContentMore.setVisibility(View.VISIBLE);
            llAbout.setVisibility(View.GONE);
            item.setVisible(false);
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        if (isTablet) {
            super.onBackPressed();
        } else if (!isTablet && rlContentMore.getVisibility() == View.VISIBLE) {
            invalidateOptionsMenu();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}
