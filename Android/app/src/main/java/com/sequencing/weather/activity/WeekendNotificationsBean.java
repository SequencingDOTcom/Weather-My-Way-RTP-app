package com.sequencing.weather.activity;

import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.RelativeLayout;

import com.sequencing.weather.R;

import org.androidannotations.annotations.AfterInject;
import org.androidannotations.annotations.EBean;
import org.androidannotations.annotations.RootContext;

import java.util.Arrays;

/**
 * Created by omazurova on 12.12.2016.
 */

@EBean
public class WeekendNotificationsBean {

    @RootContext
    Context context;

    private SharedPreferences settings;
    private CheckBox deviceCB;
    private CheckBox SMSCb;
    private CheckBox cbEmail;
    private CheckBox cbNone;
    NotificationSelectionListener listener;

    public WeekendNotificationsBean(Context context){
        this.context = context;
    }

    public interface NotificationSelectionListener{
        void onNotificationSelected();
    }

    CompoundButton.OnCheckedChangeListener onCheckedChangeListener = new CompoundButton.OnCheckedChangeListener() {
        @Override
        public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
            onCheckboxClicked(compoundButton);
        }
    };

    public void createAlert(){
        listener = (NotificationSelectionListener) context;
        settings = PreferenceManager.getDefaultSharedPreferences(context);
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        RelativeLayout notifDialog = (RelativeLayout) inflater.inflate(R.layout.notifications_preference_spinner, null);

        deviceCB = (CheckBox) notifDialog.findViewById(R.id.cbDevice);
        deviceCB.setOnCheckedChangeListener(onCheckedChangeListener);

        SMSCb = (CheckBox) notifDialog.findViewById(R.id.cbSMS);
        SMSCb.setOnCheckedChangeListener(onCheckedChangeListener);

        cbEmail = (CheckBox) notifDialog.findViewById(R.id.cbEmail);
        cbEmail.setOnCheckedChangeListener(onCheckedChangeListener);

        cbNone = (CheckBox) notifDialog.findViewById(R.id.cbNone);
        cbNone.setOnCheckedChangeListener(onCheckedChangeListener);

        AlertDialog.Builder builder = new AlertDialog.Builder(context, R.style.Theme_AlertStyle);
        builder.setPositiveButton("Done", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                saveResults();
                listener.onNotificationSelected();

            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {

            }
        });
        builder.setTitle("Weekend notifications");
        builder.setView(notifDialog);

        final AlertDialog alertDialog = builder.create();
        alertDialog.show();

        String weekendNotifPref = settings.getString("weekend_notifications", "None");
        setCheckedBoxes(weekendNotifPref);
    }

    public void setCheckedBoxes(String selectedNotification){
        if(selectedNotification.equals("SendSms")){
            SMSCb.setChecked(true);
        } else if(selectedNotification.equals("SendEmail")){
            cbEmail.setChecked(true);
        } else if(selectedNotification.equals("SendBoth")){
            cbEmail.setChecked(true);
            SMSCb.setChecked(true);
        } else if(selectedNotification.equals("None")){
            cbNone.setChecked(true);
        } else if(selectedNotification.equals("Push")){
            deviceCB.setChecked(true);
        } else if(selectedNotification.equals("PushAndEmail")){
            deviceCB.setChecked(true);
            cbEmail.setChecked(true);
        } else if(selectedNotification.equals("PushAndSms")){
            deviceCB.setChecked(true);
            SMSCb.setChecked(true);
        } else if(selectedNotification.equals("All")){
            deviceCB.setChecked(true);
            SMSCb.setChecked(true);
            cbEmail.setChecked(true);
        }
    }

    private void saveResults(){
        if(cbNone.isChecked()){
            updateNotificationInPreference("None");
        } else if(deviceCB.isChecked() && cbEmail.isChecked() && SMSCb.isChecked()){
            //all notifications
            updateNotificationInPreference("All");
        } else if(deviceCB.isChecked() && cbEmail.isChecked()){
            //device, email
            updateNotificationInPreference("PushAndEmail");
        } else if(deviceCB.isChecked() && SMSCb.isChecked()){
            //device, email
            updateNotificationInPreference("PushAndSms");
        } else if(cbEmail.isChecked() && SMSCb.isChecked()){
            //email, sms
            updateNotificationInPreference("SendBoth");
        } else if(deviceCB.isChecked()){
            updateNotificationInPreference("Push");
        } else if(cbEmail.isChecked()){
            updateNotificationInPreference("SendEmail");
        } else if(SMSCb.isChecked()){
            updateNotificationInPreference("SendSms");
        }
    }

    private void updateNotificationInPreference(String value) {
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("weekend_notifications", value);
        editor.commit();
    }

    public void onCheckboxClicked(View view) {
        boolean checked = ((CheckBox) view).isChecked();
        switch (view.getId()) {
            case R.id.cbDevice:
                if (checked) {
                    cbNone.setChecked(false);
                }
                break;
            case R.id.cbSMS:
                if (checked) {
                    cbNone.setChecked(false);
                }
                break;
            case R.id.cbEmail:
                if (checked) {
                    cbNone.setChecked(false);
                }
                break;
            case R.id.cbNone:
                if (checked) {
                    deviceCB.setChecked(false);
                    SMSCb.setChecked(false);
                    cbEmail.setChecked(false);
                } else {
                    if(!deviceCB.isChecked() && !cbEmail.isChecked() && !SMSCb.isChecked()){
                        deviceCB.setChecked(true);
                        SMSCb.setChecked(true);
                        cbEmail.setChecked(true);
                    }
                }
                break;
        }
        checkBoxes();
    }

    private void checkBoxes(){
        if(!deviceCB.isChecked() && !cbEmail.isChecked() && !SMSCb.isChecked()){
            cbNone.setChecked(true);
        }
    }
}
