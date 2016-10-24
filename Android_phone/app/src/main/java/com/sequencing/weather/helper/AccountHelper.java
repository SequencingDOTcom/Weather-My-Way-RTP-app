package com.sequencing.weather.helper;

import com.sequencing.weather.entity.AccountEntity;

public class AccountHelper {

    public static String getUserEmail(String accessToken)
    {
        return getUserAccountEntity(accessToken).getEmail();
    }

    public static String getUsername(String accessToken)
    {
        return getUserAccountEntity(accessToken).getUsername();
    }

    public static AccountEntity getUserAccountEntity(String accessToken)
    {
        String url = "https://sequencing.com/indexApi.php?q=js/custom_oauth2_server/custom-token-info/" + accessToken;
        String serverResponse = HttpHelper.doGet(url, null);

        AccountEntity account = JsonHelper.convertToJavaObject(serverResponse, AccountEntity.class);

        return account;
    }
}
