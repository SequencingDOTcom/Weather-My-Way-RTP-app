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
    }
}