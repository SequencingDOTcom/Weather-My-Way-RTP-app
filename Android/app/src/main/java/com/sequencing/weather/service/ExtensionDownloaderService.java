package com.sequencing.weather.service;

import com.google.android.vending.expansion.downloader.impl.DownloaderService;

public class ExtensionDownloaderService extends DownloaderService {
    // You must use the public key belonging to your publisher account
    public static final String BASE64_PUBLIC_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5gSqK20Xdq+tqRfw49aHvNiXRtWcmBUpAhhJ7uMf1sJL2FI3o1k5ScV6v4WwPG31uYB+rVet42HKypZO5bqhHwsg0FuWz/VZhx5ulGE0y1a3iPuDReosdaSc5jRy1cbZF5TQhvs1iL3QB5+A6vYayUBgaosM815pZXRHDroqw6nd5aJTR9Zzriz4X3tGde+izOxyRDUb/c7gtXb37Q/U/Vo3dlgYCzU0nxVkIZsYMMu4Y4ffOkw6oN8RhXZ33qsf39Qe0KQRNd04qWuBU+lvz8VXzeJTCGr4rqYcj/Fkgz2QQ/OWQBYStJW0QNNzVI/ZeE2Oovwan4FXNRphUVCOlwIDAQAB";
    // You should also modify this salt
    public static final byte[] SALT = new byte[] { 1, 42, -5, -1, 46, 98,
            -100, -12, 43, 2, -8, -4, 9, 5, -85, -107, -33, 31, -1, 56
    };

    @Override
    public String getPublicKey() {
        return BASE64_PUBLIC_KEY;
    }

    @Override
    public byte[] getSALT() {
        return SALT;
    }

    @Override
    public String getAlarmReceiverClassName() {
        return SampleAlarmReceiver.class.getName();
    }
}