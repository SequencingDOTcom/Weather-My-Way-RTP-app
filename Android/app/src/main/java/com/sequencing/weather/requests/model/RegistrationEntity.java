package com.sequencing.weather.requests.model;

import com.google.gson.annotations.SerializedName;

/**
 * Created by omazurova on 12/28/2016.
 */

public class RegistrationEntity {

    @SerializedName("status")
    public String status;

    @SerializedName("errorCode")
    public String errorCode;

    @SerializedName("errorMessage")
    public ErrorMessage errorRegisterMessage;

    public class ErrorMessage{

        @SerializedName("mail")
        public String errorMail;
    }
}


