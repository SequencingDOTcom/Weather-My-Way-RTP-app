package com.sequencing.weather.preference;

import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.preference.DialogPreference;
import android.util.AttributeSet;
import android.view.View;

import com.sequencing.weather.helper.TimeHelper;
import com.sequencing.weather.time.RadialPickerLayout;
import com.sequencing.weather.time.TimePickerDialog;

public class TimePreference extends DialogPreference implements TimePickerDialog.OnTimeSetListener {
    private int hour=0;
    private int minute=0;
    private String displayTime;
    private RadialPickerLayout radialPickerLayout;
    private TimePickerDialog timepickerdialog;

    public TimePreference(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected View onCreateDialogView() {
        return null;
    }

    @Override
    protected void onClick() {
        timepickerdialog = TimePickerDialog.newInstance(this, hour, minute, false);
        final Activity activity = (Activity) getContext();
        timepickerdialog.show(activity.getFragmentManager(), "TimePickerDialog");
    }

    @Override
    protected void onBindDialogView(View v) {
        super.onBindDialogView(v);
    }

    @Override
    protected void onDialogClosed(boolean positiveResult) {
        super.onDialogClosed(positiveResult);

        if (positiveResult) {

            String minuteStr = minute < 10 ? "0" + minute : String.valueOf(minute);
            String hourStr = hour != 0 ? String.valueOf(hour) : "00";

            String time = hourStr + ":" + minuteStr;

            displayTime = TimeHelper.transform24ClockFormatTo12(time);

            if (callChangeListener(displayTime)) {
                persistString(displayTime);
            }
        }
    }

    @Override
    protected Object onGetDefaultValue(TypedArray a, int index) {
        return(a.getString(index));
    }

    @Override
    protected void onSetInitialValue(boolean restoreValue, Object defaultValue) {
        String time;

        if (restoreValue) {
            if (defaultValue == null) {
                time = getPersistedString("00:00");
            }
            else {
                time = getPersistedString(defaultValue.toString());
            }
        }
        else {
            time = defaultValue.toString();
        }

        String hoursAndMinutes = time.split(" ")[0];
        if(!hoursAndMinutes.contains(":")) {
            time = hoursAndMinutes + ":00" + " " + time.split(" ")[1];
        }

        hour = Integer.parseInt( time.split(":")[0] );
        minute = Integer.parseInt( time.split(":")[1].split(" ")[0]);

        displayTime = TimeHelper.transform24ClockFormatTo12(hour + ":" + minute);
    }

    @Override
    public void onTimeSet(RadialPickerLayout view, int hourOfDay, int minute) {
        this.radialPickerLayout = view;
        this.hour = hourOfDay;
        this.minute = minute;
        onDialogClosed(true);
    }
}