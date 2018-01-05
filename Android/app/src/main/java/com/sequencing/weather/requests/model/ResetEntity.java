package com.sequencing.weather.requests.model;

import com.google.gson.annotations.SerializedName;

/**
 * Created by omazurova on 12/29/2016.
 */

public class ResetEntity {

    @SerializedName("status")
    public String status;

    @SerializedName("errorCode")
    public String errorCode;

    @SerializedName("errorMessage")
    public String errorMessage;
}
