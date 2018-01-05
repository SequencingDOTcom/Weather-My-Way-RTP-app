package com.sequencing.weather.requests;


import com.sequencing.weather.logging.EventEntity;
import com.sequencing.weather.requests.model.RegistrationEntity;
import com.sequencing.weather.requests.model.ResetEntity;

import org.androidannotations.rest.spring.annotations.Body;
import org.androidannotations.rest.spring.annotations.Post;
import org.androidannotations.rest.spring.annotations.Rest;
import org.springframework.http.converter.json.GsonHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;

/**
 * Created by omazurova on 12/28/2016.
 */

@Rest(rootUrl = "https://sequencing.com/indexApi.php?q=sequencing/public/webservice/user", converters = GsonHttpMessageConverter.class)
public interface RestLoggingInterface {

    @Post("/seq_register.json")
    RegistrationEntity registerAccount(@Body RegistrationBody registrationBody);

    @Post("/seq_new_pass.json")
    ResetEntity resetPassword(@Body RegistrationBody registrationBody);

    @Post("https://logbase.sequencing.com/logging/event/wmw")
    void sendEvents(@Body EventEntity eventEntity);

}
