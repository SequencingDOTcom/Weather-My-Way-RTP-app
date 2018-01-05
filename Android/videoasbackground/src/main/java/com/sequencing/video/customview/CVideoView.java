package com.sequencing.video.customview;

import android.content.Context;
import android.media.MediaPlayer;
import android.util.AttributeSet;
import android.widget.VideoView;

public class CVideoView extends VideoView {

    public static final int ALIGN_NONE = 1;
    public static final int ALIGN_WIDTH = 2;
    public static final int ALIGN_HEIGHT = 3;

    /**
     * Determine actions which will be executed when dimensions
     * of this view changing
     */
    public interface OnCorrectVideoDimensions {
        void correctDimensions(int width, int height);
    }

    private OnCorrectVideoDimensions correcting;

    /**
     * Determine view alignment according to video size in
     * <code>OnMeasure</code> method
     */
    private int alignment = ALIGN_NONE;

    private int mVideoWidth;
    private int mVideoHeight;
    private int essentialVideoHeight = -1;
    private int essentialVideoWidth = -1;

    public CVideoView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public CVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public CVideoView(Context context) {
        super(context);
    }

    public void setOnCorrectVideoDimensions(OnCorrectVideoDimensions correcting) {
        resetEssentialVideoSize();
        this.correcting = correcting;
    }

    public void resetEssentialVideoSize() {
        essentialVideoWidth = -1;
        essentialVideoHeight = -1;
        invalidate();
        requestLayout();
    }

    /**
     * Set view alignment according to video dimensions
     */
    public void setAlignment(int alignment) {
        this.alignment = alignment;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int width = getDefaultSize(mVideoWidth, widthMeasureSpec);
        int height = getDefaultSize(mVideoHeight, heightMeasureSpec);
        correctVideoContainerDimensions(width, height);
    }

    public void onVideoSizeChanged(MediaPlayer mp) {
        mVideoWidth = mp.getVideoWidth();
        mVideoHeight = mp.getVideoHeight();
        resetEssentialVideoSize();
    }

    public void correctVideoContainerDimensions(int width, int height) {
        if (mVideoWidth > 0 && mVideoHeight > 0) {
            switch (alignment) {
                case ALIGN_HEIGHT:
                    height = width * mVideoHeight / mVideoWidth;
                    break;
                case ALIGN_WIDTH:
                    width = height * mVideoWidth / mVideoHeight;
                    break;
            }

            // Make correcting just when new values are not equal with previous
            if (correcting != null && height != essentialVideoHeight
                    && alignment == ALIGN_HEIGHT) {
                correcting.correctDimensions(width, height);
                essentialVideoHeight = height;
            }
            if (correcting != null && width != essentialVideoWidth
                    && alignment == ALIGN_WIDTH) {
                correcting.correctDimensions(width, height);
                essentialVideoWidth = width;
            }
        }
        setMeasuredDimension(width, height);
    }
}
