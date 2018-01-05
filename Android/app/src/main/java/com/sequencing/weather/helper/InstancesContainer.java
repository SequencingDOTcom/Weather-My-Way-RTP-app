package com.sequencing.weather.helper;

import com.sequencing.oauth.core.SequencingOAuth2Client;

public class InstancesContainer {

    private static SequencingOAuth2Client oAuth2Client;

    public static SequencingOAuth2Client getoAuth2Client() {
        return oAuth2Client;
    }

    public static void setoAuth2Client(SequencingOAuth2Client oAuth2Client) {
        InstancesContainer.oAuth2Client = oAuth2Client;
    }
}
