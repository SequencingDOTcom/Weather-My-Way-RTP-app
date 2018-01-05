package com.sequencing.video.helper;

import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.Transformation;

public class AppUIHelper extends AnimationUtils {
    /**
     * Animated resizing layout with specified actions after finish
     */
    public static void resizeLayout(final View v, final int height, final int width, int duration, Animation.AnimationListener listener) {
        final int currentHeight = v.getHeight();
        final int currentWidth = v.getWidth();
        final int diffH = height - currentHeight;
        final int diffW = width - currentWidth;

        Animation a = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                if (height != -1) {
                    v.getLayoutParams().height = currentHeight + (int) (diffH * interpolatedTime);
                }
                if (width != -1) {
                    v.getLayoutParams().width = currentWidth + (int) (diffW * interpolatedTime);
                }
                v.requestLayout();
            }

            @Override
            public boolean willChangeBounds() {
                return true;
            }
        };

        a.setDuration(duration);
        a.setAnimationListener(listener);
        v.startAnimation(a);
    }
}
