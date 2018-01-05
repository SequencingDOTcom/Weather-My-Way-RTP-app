package com.sequencing.weather.helper;

/**
 * Created by omazurova on 12/7/2016.
 */

public class ValidationHelper {

    public static boolean isValidEmail(CharSequence target) {
        if (target == null) {
            return false;
        } else {
            return android.util.Patterns.EMAIL_ADDRESS.matcher(target).matches();
        }
    }

    public static boolean isValidMobile(String phone)
    {
        if(android.util.Patterns.PHONE.matcher(phone).matches() && phone.length() > 6 && phone.length() <= 20){
            return true;
        }
        return false;
    }
}
