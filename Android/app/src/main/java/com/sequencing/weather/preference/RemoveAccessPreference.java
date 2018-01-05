package com.sequencing.weather.preference;

import android.content.Context;
import android.content.res.TypedArray;
import android.preference.DialogPreference;
import android.util.AttributeSet;
import android.view.View;

import com.sequencing.weather.activity.MainActivity;

public class RemoveAccessPreference extends DialogPreference {
    private static final String TAG = "RemoveAccessPreference";
    private String email;

    public RemoveAccessPreference(Context ctxt, AttributeSet attrs) {
        super(ctxt, attrs);
    }

    @Override
    protected View onCreateDialogView() {
        return null;
    }

    @Override
    protected void onClick() {
        MainActivity.signOut(getContext());
    }

    @Override
    protected void onBindDialogView(View v) {
        super.onBindDialogView(v);
    }

    @Override
    protected void onDialogClosed(boolean positiveResult) {
        super.onDialogClosed(positiveResult);

        if (positiveResult) {
            if (callChangeListener(email)) {
                persistString(email);
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
                email = getPersistedString("");
            } else {
                email = getPersistedString(defaultValue.toString());
            }
        } else {
            email = defaultValue.toString();
        }
    }
}

