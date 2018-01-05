package com.sequencing.weather.preference;

import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.preference.DialogPreference;
import android.preference.PreferenceManager;
import android.support.v7.app.AlertDialog;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.sequencing.weather.R;
import com.sequencing.weather.helper.ValidationHelper;

/**
 * Created by omazurova on 12/7/2016.
 */

public class EmailPreference extends DialogPreference {

    private EditText editText;
    private String email;
    private TextView invalidEmailMessage;

    SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getContext());

    public EmailPreference(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    @Override
    protected View onCreateDialogView() {
        return null;
    }

    @Override
    protected void onClick() {
        LayoutInflater inflater = (LayoutInflater) getContext().getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        LinearLayout llDialogLayout = (LinearLayout) inflater.inflate(R.layout.email_layout, null);

        editText = (EditText) llDialogLayout.findViewById(R.id.etEmail);
        invalidEmailMessage = (TextView) llDialogLayout.findViewById(R.id.tvInvalidEmail);

        initEditDialog(llDialogLayout);
        editText.setText(settings.getString("email_address", ""));
        setEditTextListener();
    }

    private void initEditDialog(LinearLayout llDialogLayout) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getContext(), R.style.Theme_AlertStyle);
        builder.setPositiveButton("Done", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                //Do nothing here because we override this button later to change the close behaviour.
                //However, we still need this because on older versions of Android unless we
                //pass a handler the button doesn't get instantiated
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
                onDialogClosed(false);
            }
        });
        builder.setTitle("Please, enter an email:");
        builder.setView(llDialogLayout);
        final AlertDialog dialog = builder.create();
        dialog.setCancelable(false);
        dialog.show();

        dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                email = editText.getText().toString().trim();
                if(!ValidationHelper.isValidEmail(email)){
                    invalidEmailMessage.setVisibility(View.VISIBLE);
                } else {
                    invalidEmailMessage.setVisibility(View.GONE);
                    onDialogClosed(true);
                    dialog.dismiss();
                }
            }
        });
    }

    private void setEditTextListener() {
        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {

            }

            @Override
            public void afterTextChanged(Editable editable) {
                if(!ValidationHelper.isValidEmail(editable.toString().trim())){
                    invalidEmailMessage.setVisibility(View.VISIBLE);
                } else {
                    invalidEmailMessage.setVisibility(View.GONE);
                }
            }
        });
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
