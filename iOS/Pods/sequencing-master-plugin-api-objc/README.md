# Master CocoaPod Plugin for adding Sequencing.com's Real-Time Personalization technology to iOS apps coded in Objective-C
This Master CocoaPod Plugin can be used to quickly add [Real-Time Personalization](https://sequencing.com/developer-documentation/what-is-real-time-personalization-rtp) to your app. This Master Plugin contains a customizable, end-to-end plug-n-play solution that quickly adds all necessary code (OAuth2, File Selector and App Chain coding) to your app.

Once this Master Plugin is added to your app all you'll need to do is:

1. add your [OAuth2 secret](https://sequencing.com/developer-center/new-app-oauth-secret)
2. add one or more [App Chain numbers](https://sequencing.com/app-chains/)
3. configure your app based on each [app chain's possible responses](https://sequencing.com/app-chains/)

To code Real-Time Personalization technology into apps, developers may [register for a free account](https://sequencing.com/user/register/) at Sequencing.com. App development with RTP is always free.

**The Master Plugin is also available in the following languages:**
* Objective-C (CocoaPod plugin) <-- this repo
* [Swift (CocoaPod plugin)](https://github.com/SequencingDOTcom/CocoaPods-iOS-Master-Plugin-Swift)
* [Android (Maven plugin)](https://github.com/SequencingDOTcom/Maven-Android-Master-Plugin-Java)
* [Java (Maven plugin)](https://github.com/SequencingDOTcom/Maven-Android-Master-Plugin-Java)
* [C#/.NET (Nuget for Visual Studio)](https://sequencing.com/developer-documentation/nuget-visual-studio)

**Master Plugin - Plug-n-Play Samples** (This code can be used as an out-of-the-box solution to quickly add Real-Time Personalization technology into your app):
* [Objective-C (CocoaPod) Plug-n-Play Sample](https://github.com/SequencingDOTcom/iOS-Objective-C-Master-Plugin-Plug-n-Play-Sample)
* [Swift (CocoaPod) Plug-n-Play Sample](https://github.com/SequencingDOTcom/iOS-Swift-Master-Plugin-Plug-n-Play-Sample)
* [Android (Maven) Plug-n-Play Sample](https://github.com/SequencingDOTcom/Android-Master-Plugin-Plug-N-Play-Sample)


Contents
=========================================
* Implementation
* Master CocoaPod Plugin install
* Authentication flow
* OAuth CocoaPod Plugin integration
* File Selector CocoaPod Plugin integration
* AppChains CocoaPod Plugin integration
* Resources
* Maintainers
* Contribute


Implementation
======================================
To implement this Master Plugin for your app:

1) [Register](https://sequencing.com/user/register/) for a free account

2) Add this Master Plugin to your app

3) [Generate an OAuth2 secret](https://sequencing.com/api-secret-generator) and insert the secret into the plugin

4) Add one or more [App Chain numbers](https://sequencing.com/app-chains/). The App Chain will provide genetic-based information you can use to personalize your app.

5) Configure your app based on each [app chain's possible responses](https://sequencing.com/app-chains/)


Master CocoaPod Plugin install
======================================
* see [CocoaPods guides](https://guides.cocoapods.org/using/using-cocoapods.html)
* create Podfile in your project directory: ```$ pod init```
* specify "sequencing-master-plugin-api-objc" pod parameters in Podfile: 

	```pod 'sequencing-master-plugin-api-objc', '~> 1.4.1'```

* install the dependency in your project: ```$ pod install```
* always open the Xcode workspace instead of the project file: ```$ open *.xcworkspace```
* as a result you'll have 3 CocoaPod plugins installed: OAuth, Files Selector and AppChains


Authentication flow
======================================
Sequencing.com uses standard OAuth approach which enables applications to obtain limited access to user accounts on an HTTP service from 3rd party applications without exposing the user's password. OAuth acts as an intermediary on behalf of the end user, providing the service with an access token that authorizes specific account information to be shared.

![Authentication sequence diagram]
(https://github.com/SequencingDOTcom/oAuth2-code-and-demo/blob/master/screenshots/oauth_activity.png)


## Steps

### Step 1: Authorization Code Link

First, the user is given an webpage opened by following authorization code link:

```
https://sequencing.com/oauth2/authorize?redirect_uri=REDIRECT_URL&response_type=code&state=STATE&client_id=CLIENT_ID&scope=SCOPES
```

Here is an explanation of the link components:
* ```https://sequencing.com/oauth2/authorize``` - the API authorization endpoint
* ```redirect_uri=REDIRECT_URL``` - where the service redirects the user-agent after an authorization code is granted
* ```response_type=code``` - specifies that your application is requesting an authorization code grant
* ```state=STATE``` - holds the random verification code that will be compared with the same code within the server answer in order to verify if response was being spoofed
* ```client_id=CLIENT_ID``` - the application's client ID (how the API identifies the application)
* ```scope=CODES``` specifies the level of access that the application is requesting

![login dialog](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/blob/master/screenshots/oauth_auth.png)


### Step 2: User Authorizes Application

User must first log in to the service, to authenticate their identity (unless they are already logged in). Then they will be prompted by the service to authorize or deny the application access to their account. Here is an example authorize application prompt

![grant dialog](https://github.com/SequencingDOTcom/oAuth2-code-and-demo/blob/master/screenshots/oauth_grant.png)


### Step 3: Application Receives Authorization Code

When user clicks "Authorize Application", the service will open the redirect_URI url address, which was specified during the authorization request. In iOS application following ```redirect_uri``` was used:

```
authapp://Default/Authcallback
```

As soon as your application detects that redirect_uri page was opened then it should analyse the server response with the state verification code. If the state verification code matches the one was sent in authorization request then it means that the server response is valid.
Now we can get the authorization code form the server response.


### Step 4: Application Requests Access Token

The application requests an access token from the API, by passing the authorization code (got from server response above) along with authentication details, including the client secret, to the API token endpoint. Here is an example POST request to Sequencing.com token endpoint:

```
https://sequencing.com/oauth2/token
```

Following POST parameters have to be sent

* grant_type='authorization_code'
* code=AUTHORIZATION_CODE (where AUTHORIZATION_CODE is a code acquired in a "code" parameter in the result of redirect from sequencing.com)
* redirect_uri=REDIRECT_URL (where REDIRECT_URL is the same URL as the one used in step 1)


### Step 5: Application Receives Access Token

If the authorization is valid, the API will send a JSON response containing the token object to the application. Token object contains accessToken, its expirationDate, tokenType, scope and refreshToken.



OAuth CocoaPod Plugin integration
======================================

[See OAuth CocoaPod Plugin documentation (ObjC)](https://github.com/SequencingDOTcom/CocoaPod-iOS-OAuth-ObjectiveC)



File Selector CocoaPod Plugin integration
======================================

[See File Selector CocoaPod Plugin documentation (ObjC)](https://github.com/SequencingDOTcom/CocoaPod-iOS-File-Selector-ObjectiveC)



AppChains CocoaPod Plugin integration
======================================

[See AppChains CocoaPod Plugin documentation (ObjC)](https://github.com/SequencingDOTcom/CocoaPod-iOS-App-Chains-ObjectiveC)



Resources
======================================
* [App chains](https://sequencing.com/app-chains)
* [File selector code](https://github.com/SequencingDOTcom/File-Selector-code)
* [Generate OAuth2 secret](https://sequencing.com/developer-center/new-app-oauth-secret)
* [Developer Center](https://sequencing.com/developer-center)
* [Developer Documentation](https://sequencing.com/developer-documentation/)


Maintainers
======================================
This repo is actively maintained by [Sequencing.com](https://sequencing.com/). Email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.


Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please send us a pull request. If the changes contribute positively, we'll let it ride.
