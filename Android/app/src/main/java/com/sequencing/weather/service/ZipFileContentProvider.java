package com.sequencing.weather.service;

import com.android.vending.expansion.zipfile.APEZProvider;

public class ZipFileContentProvider extends APEZProvider {

    @Override
    public String getAuthority() {
        return "com.sequencing.weather.service.provider.ZipFileContentProvider";
    }
}