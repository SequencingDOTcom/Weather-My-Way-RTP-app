package com.sequencing.weather.entity;

import com.google.gson.annotations.SerializedName;

public class AccountEntity {

    private String uid;

    private String username;

    private String email;

    private String personas[];

    @SerializedName("app_id")
    private String appId;

    private String scopes[];

    private String expires;

    @SerializedName("token_type")
    private String tokenType;

    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String[] getPersonas() {
        return personas;
    }

    public void setPersonas(String personas[]) {
        this.personas = personas;
    }

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public String[] getScopes() {
        return scopes;
    }

    public void setScopes(String[] scopes) {
        this.scopes = scopes;
    }

    public String getExpires() {
        return expires;
    }

    public void setExpires(String expires) {
        this.expires = expires;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }
}
