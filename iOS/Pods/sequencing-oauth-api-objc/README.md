# CocoaPods plugin for quickly adding Sequencing.com's OAuth2 to iOS apps coded in Objective-C

=========================================
This repo contains CocoaPods plugin code for implementing Sequencing.com's OAuth2 authentication for your Objective-C iOS app so that your app can securely access [Sequencing.com's](https://sequencing.com/) API and app chains.

* oAuth flow is explained [here](https://github.com/SequencingDOTcom/OAuth2-code-with-demo)
* Example that uses this Pod is located [here](https://github.com/SequencingDOTcom/OAuth2-code-with-demo/tree/master/objective-c)

Contents
=========================================
* Authentication flow
* CocoaPod integration
* Resources
* Maintainers
* Contribute

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


CocoaPod integration
======================================

You need to follow instruction below if you want to install and use OAuth logic and file selector logic in your existed or new project.

* **Create a new project in Xcode**

* **Install pod**
	* see [CocoaPods guides](https://guides.cocoapods.org/using/using-cocoapods.html)
	* create Podfile in your project directory: ```$ pod init```
    * specify "sequencing-oauth-api-objc" pod parameters in Podfile:
    
    	```pod 'sequencing-oauth-api-objc', '~> 2.0.4’```
    	
	* install the dependency in your project: ```$ pod install```
	* always open the Xcode workspace instead of the project file: ```$ open *.xcworkspace```

* **Add Application Transport Security setting**
	* open project settings > Info tab
	* add ```App Transport Security Settings``` row parameter (as Dictionary)
	* add subrow to App Transport Security Settings parameter as ```Exception Domains``` dictionary parameter
	* add subrow to Exception Domains parameter with ```sequencing.com``` string value
	* add subrow to App Transport Security Settings parameter with ```Allow Arbitrary Loads``` boolean value
	* set ```Allow Arbitrary Loads``` boolean value as ```YES```
	
	![sample files](https://github.com/SequencingDOTcom/CocoaPod-iOS-OAuth-ObjectiveC/blob/master/Screenshots/authTransportSecuritySetting.png)
	
	
* **Register app parameters and delegate**

	* add imports
		```
		#import "SQOAuth.h"
		#import "SQToken.h"
		#import "SQAuthorizationProtocol.h"
		```
		
	* subscribe your class for Authorization protocol
		```
		<SQAuthorizationProtocol>
		```
		
	* have access to SQOAuth via ```shared instance``` method
		```
		[SQOAuth sharedInstance]
		```
		
	* register your app parameters and delegate
		```
		- (void)registerApplicationParametersCliendID:(NSString *)client_id
                                 clientSecret:(NSString *)client_secret
                                  redirectUri:(NSString *)redirect_uri
                                        scope:(NSString *)scope
                                     delegate:(UIViewController<SQAuthorizationProtocol> *)delegate;                                     
		``` 
		
		where:
		```
		client_id - your app CLIENT_ID
		client_secret - your app CLIENT_SECRET
		redirect_uri - your app REDIRECT_URI
		scope - your app SCOPE
		delegate - UIViewController instance that conform to "SQAuthorizationProtocol" protocol
		```


* **Use authorization method**		
				
	* implement methods from SQAuthorizationProtocol
		```
		- (void)userIsSuccessfullyAuthorized:(SQToken *)token

		- (void)userIsNotAuthorized
			
		- (void)userDidCancelAuthorization
		```
		
	* you can authorize your user via ```authorizeUser``` method
		```
		[[SQOAuth sharedInstance] authorizeUser];
		```
		
	* in method ```userIsSuccessfullyAuthorized``` you'll receive SQToken object, that contains following 5 properties with clear titles for usage:
		```	
		NSString *accessToken
		NSDate   *expirationDate
		NSString *tokenType
		NSString *scope
		NSString *refreshToken
		```
		
		
* **Access to up-to-date token**
		
	* to receive up-to-date token use ```token:``` method from SQOAuth API (it returns the updated token): 
		```
		[[SQOAuth sharedInstance] token:^(SQToken *token) {}];
		```

    		
* **Register new account / Reset password methods**

	* just call ```callRegisterResetAccountFlow``` method - it will open dialog popup
		```
		[[SQOAuth sharedInstance] callRegisterResetAccountFlow];		
		```
				
		


Resources
======================================
* [App chains](https://sequencing.com/app-chains)
* [File selector code](https://github.com/SequencingDOTcom/File-Selector-code)
* [Developer center](https://sequencing.com/developer-center)
* [Developer documentation](https://sequencing.com/developer-documentation/)

Maintainers
======================================
This repo is actively maintained by [Sequencing.com](https://sequencing.com/). Email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.

Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please send us a pull request. If the changes contribute positively, we'll let it ride.
