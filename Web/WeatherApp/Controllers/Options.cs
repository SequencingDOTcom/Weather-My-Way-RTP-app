using System;
using System.Configuration;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Options from web.config
    /// </summary>
    public static class Options
    {
        //OAuth related options
        public static string OAuthRedirectUrl { get { return ConfigurationManager.AppSettings["OAuthRedirectUrl"]; } }
        public static string OAuthAppId { get { return ConfigurationManager.AppSettings["OAuthAppId"]; } }
        public static string OAuthSecret { get { return ConfigurationManager.AppSettings["OAuthSecret"]; } }
        public static string OAuthUrl { get { return ConfigurationManager.AppSettings["OAuthUrl"]; } }

        //Backend url
        public static string ApiUrl { get { return ConfigurationManager.AppSettings["ApiUrl"]; } }
        //Mandrill api key
        public static string MandrillApi { get { return ConfigurationManager.AppSettings["MandrillApi"]; } }
        //Check delay for user notifications sender processor
        public static int EmailCheckDelay { get { return int.Parse(ConfigurationManager.AppSettings["EmailCheckDelay"]); } }

        //Twilio options
        public static string TwilioAccountSid { get { return ConfigurationManager.AppSettings["TwilioAccountSid"]; } }
        public static string TwilioAuthToken { get { return ConfigurationManager.AppSettings["TwilioAuthToken"]; } }
        public static string FromPhone { get { return ConfigurationManager.AppSettings["FromPhone"]; } }
        public static string FromPhone2 { get { return ConfigurationManager.AppSettings["FromPhone2"]; } }

        //WU key
        public static string WUKey { get { return ConfigurationManager.AppSettings["WUKey"]; } }

        //Personalized recommendations file path
        public static string RecommendationsPath { get { return ConfigurationManager.AppSettings["RecommendationsPath"]; } }


        
        public static string FrontendUrl { get { return ConfigurationManager.AppSettings["FrontendUrl"]; } }
        public static string BaseSiteUrl { get { return ConfigurationManager.AppSettings["BaseSiteUrl"]; } }

        //Certificates for push notification
        public static string ApnsCertificateFileMobile { get { return ConfigurationManager.AppSettings["ApnsCertificateFileMobile"]; } }
        public static string ApnsCertificatePasswordMobile { get { return ConfigurationManager.AppSettings["ApnsCertificatePasswordMobile"]; } }
        public static string ApnsCertificateFileTablet { get { return ConfigurationManager.AppSettings["ApnsCertificateFileTablet"]; } }
        public static string ApnsCertificatePasswordTablet { get { return ConfigurationManager.AppSettings["ApnsCertificatePasswordTablet"]; } }
        public static string GCMSenderIdMobile { get { return ConfigurationManager.AppSettings["GCMSenderIdMobile"]; } }
        public static string DeviceAuthTokenMobile { get { return ConfigurationManager.AppSettings["DeviceAuthTokenMobile"]; } }
        public static string GCMSenderIdTablet { get { return ConfigurationManager.AppSettings["GCMSenderIdTablet"]; } }
        public static string DeviceAuthTokenTablet { get { return ConfigurationManager.AppSettings["DeviceAuthTokenTablet"]; } }
        public static string NotificationMessage { get { return ConfigurationManager.AppSettings["NotificationMessage"]; } }
        public static Int64 APNSFeedbackServiceRunDelay { get { return Int64.Parse(ConfigurationManager.AppSettings["APNSFeedbackServiceRunDelay"]); } }


        public static int ApplicationName { get { return Int32.Parse(ConfigurationManager.AppSettings["ApplicationName"]); } }


        public static int STOutputMaxSize { get { return Int32.Parse(ConfigurationManager.AppSettings["STOutputMaxSize"]); } }
        public static string STParameter1Name { get { return ConfigurationManager.AppSettings["STParameter1Name"]; } }
        public static string STParameter2Name { get { return ConfigurationManager.AppSettings["STParameter2Name"]; } }
        public static string STParameter3Name { get { return ConfigurationManager.AppSettings["STParameter3Name"]; } }
        public static string STParameter4Name { get { return ConfigurationManager.AppSettings["STParameter4Name"]; } }
        public static string STParameter5Name { get { return ConfigurationManager.AppSettings["STParameter5Name"]; } }
        public static string STParameter6Name { get { return ConfigurationManager.AppSettings["STParameter6Name"]; } }
        public static string STOutputName { get { return ConfigurationManager.AppSettings["STOutputName"]; } }
        public static string StorageProcedureName { get { return ConfigurationManager.AppSettings["StorageProcedureName"]; } }
        public static string ForecastManagerLogin { get { return ConfigurationManager.AppSettings["ForecastManagerLogin"]; } }
        public static string ForecastManagerPassword { get { return ConfigurationManager.AppSettings["ForecastManagerPassword"]; } }
}
}