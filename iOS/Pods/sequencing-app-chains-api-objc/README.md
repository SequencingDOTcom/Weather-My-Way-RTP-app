# CocoaPod-iOS-App-Chains-ObjectiveC
App Chains are the easy way to code Real Time Personalization (RTP) into your app. 
Easily add an App-Chains functionality using this CocoaPod plugin for ObjectiveC iOS apps


Contents
=========================================
* Introduction
* Example (of an app using RTP)
* CocoaPod integration
* Configuration
* Troubleshooting
* Resources
* Maintainers
* Contribute


Introduction
=========================================
Search and find app chains -> https://sequencing.com/app-chains/

An app chain is an integration of an API call and an analysis of an app user's genes. Each app chain provides information about a specific trait, condition, disease, supplement or medication. App chains are used to provide genetically tailored content to app users so that the user experience is instantly personalized at the genetic level. This is called [Real Time Personalization (RTP)](https://sequencing.com/developer-documentation/what-is-real-time-personalization-rtp).

Each app chain consists of:

1. **API call**
 * API call that triggers an app hosted by Sequencing.com to perform genetic analysis on your app user's genes
2. **API response**
 * the straightforward, easy-to-use results are sent to your app as the API response
3. **Personalzation**
 * your app uses this information, which is obtained directly from your app user's genes in real-time, to create a truly personalized user experience

Each app chain is composed of 

* an **API request** to Sequencing.com
 * this request is secured using oAuth2
* analysis of the app user's genes
 * each app chain analyzes a specific trait or condition
 * there are thousands of app chains to choose from
 * all analysis occurs in real-time at Sequencing.com
* an **API response** to your app
 * the information provided by the response allows your app to tailor itself to the app user based on the user's genes.
 * the documentation for each app chain provides a list of all possible API responses. The response for most app chains are simply 'Yes' or 'No'.

Example

* App Chain: It is very important for this person's health to apply sunscreen with SPF +30 whenever it is sunny or even partly sunny.
* Possible responses: Yes, No, Insufficient Data, Error

While there are already app chains to personalize most apps, if you need something but don't see an app chain for it, tell us! (ie email us: gittaca@sequencing.com).

To code Real Time Personalization (RTP) technology into apps, developers may [register for a free account](https://sequencing.com/user/register/) at Sequencing.com. App development with RTP is always free.


Example
======================================
What types of apps can you personalize with app chains? Any type of app... even a weather app. 
* The open source [Weather My Way +RTP app](https://github.com/SequencingDOTcom/Weather-My-Way-RTP-App/) differentiates itself from all other weather apps because it uses app chains to provide genetically tailored content in real-time to each app user.
* Experience it yourself using one of the fun sample genetic data files. These sample files are provided for free to all apps that use app chains.


CocoaPod integration
======================================
Please follow this guide to install App-Chain module in your existed or new project

* see general CocoaPods instruction: ```https://cocoapods.org > getting started```
			
* create a new project in Xcode
	
* create Podfile in your project directory: 

	```
	$ pod init
	```
		
* specify ```sequencing-app-chains-api-objc``` pod parameters in Podfile: 

	```
	pod 'sequencing-app-chains-api-objc', '~> 1.1.1'
	```		
		
* install the dependency in your project: 

	```
	$ pod install
	```
		
* always open the Xcode workspace instead of the project file: 

	```
	$ open *.xcworkspace
	```


Configuration
======================================
There are no strict configurations that have to be performed.

Just drop the source files for an app chain into your project to add Real-Time Personalization to your app.

Code snippets below contain the following three placeholders. Please make sure to replace each of the placeholders with real values:
* ```<your token>``` 
 * replace with the oAuth2 secret obtained from your [Sequencing.com account](https://sequencing.com/api-secret-generator)
  * The code snippet for enabling Sequencing.com's oAuth2 authentication for your app can be found in the [oAuth2 code and demo repo](https://github.com/SequencingDOTcom/oAuth2-code-and-demo)

* ```<chain id>``` 
 * replace with the App Chain ID obtained from the list of [App Chains](https://sequencing.com/app-chains)

* ```<file id>``` 
 * replace with the file ID selected by the user while using your app
  * The code snippet for enabling Sequencing.com's File Selector for your app can be found in the [File Selector code repo](https://github.com/SequencingDOTcom/File-Selector-code)


### Objective-C

AppChains Objective-C API overview

Method  | Purpose | Arguments | Description
------------- | ------------- | ------------- | -------------
`- (instancetype)initWithToken:(NSString *)token` | Constructor | **token** - security token provided by sequencing.com | 
`- (instancetype)initWithToken:(NSString *)token withHostName:(NSString *)hostName`  | Constructor | **token** - security token provided by sequencing.com <br> **hostName** - API server hostname. api.sequencing.com by default | Constructor used for creating AppChains class instance in case reporting API is needed and where security token is required
`- (void)getReportWithApplicationMethodName:(NSString *)applicationMethodName withDatasourceId:(NSString *)datasourceId withSuccessBlock:(void (^)(Report *result))success withFailureBlock:(void (^)(NSError *error))failure;`   | Reporting API | **applicationMethodName** - name of data processing routine<br><br>**datasourceId** - input data identifier<br><br>**success** - callback executed on success operation, results with `Report` object<br><br>**failure** - callback executed on operation failure
`- (void)getBatchReportWithApplicationMethodName:(NSArray *)appChainsParams withSuccessBlock:(ReportsArray)success withFailureBlock:(void (^)(NSError *error))failure;`   | Reporting API with batch request | **appChainsParams** - array of params for batch request.<br>Each param should be an array with items:<br>first object - `applicationMethodName`<br>last object - `datasourceId`<br><br>**success** - callback executed on success operation, results with array of dictionaries.<br>Each dictionary has following keys and objects:<br>`appChainID` - appChain ID string<br>`report` - Report object<br><br>**failure** - callback executed on operation failure

Adding code to the project:
* import AppChains: ```#import "AppChains.h"```


After that you can start utilizing Reporting API for single chain request:

```
AppChains *appChains = [[AppChains alloc] initWithToken:yourAccessToken withHostName:@"api.sequencing.com"];
    
[appChains getReportWithApplicationMethodName:@"<chain id>"
		withDatasourceId:@"<file id>"
		withSuccessBlock:^(Report *result) {
			NSArray *arr = [result getResults];
			for (Result *obj in arr) {
				ResultValue *frv = [obj getValue];
				if ([frv getType] == kResultTypeFile)
					[(FileResultValue *)frv saveToLocation:@"/tmp/"];
            }
        }
        withFailureBlock:^(NSError *error) {
        	NSLog(@"Error occured: %@", [error description]);
        }];                                 
```


Example of using batch request API for several chains:

```
AppChains *appChains = [[AppChains alloc] initWithToken:yourAccessToken withHostName:@"api.sequencing.com"];
    
// parameters array for batch request as example
NSArray *appChainsForRequest = @[@[@"Chain88", fileID], @[@"Chain9",  fileID]];
    
[appChains getBatchReportWithApplicationMethodName:appChainsForRequest
		withSuccessBlock:^(NSArray *reportResultsArray) {
			
			// @reportResultsArray - result of reports for batch request, it's an array of dictionaries
			// each dictionary has following keys: "appChainID": appChainID string, "report": *Report object
			
			for (NSDictionary *appChainReportDict in reportResultsArray) {
				
				Report *result = [appChainReportDict objectForKey:@"report"];
				NSString *appChainID = [appChainReportDict objectForKey:@"appChainID"];
				NSString *appChainValue = [NSString stringWithFormat:@""];
				
				if ([appChainID isEqualToString:@"Chain88"])
					appChainValue = [self parseAndHandleReportForChain88:result]; // your own method to parse report object
				
				else if ([appChainID isEqualToString:@"Chain9"])
					appChainValue = [self parseAndHandleForChain9:result]; // your own method to parse report object
			}
		}
		withFailureBlock:^(NSError *error) {
			NSLog(@"batch request error: %@", error);
		}];
```



Troubleshooting
======================================
Each app chain code should work straight out-of-the-box without any configuration requirements or issues. 

Other tips

* Ensure that the following three placeholders have been substituted with real values:

1. ```<your token>```
  * replace with the oAuth2 secret obtained from your [Sequencing.com account](https://sequencing.com/api-secret-generator)
   * The code snippet for enabling Sequencing.com's oAuth2 authentication for your app can be found in the [oAuth2 code and demo repo](https://github.com/SequencingDOTcom/oAuth2-code-and-demo)
2. ```<chain id>```
  * replace with the App Chain ID obtained from the list of [App Chains](https://sequencing.com/app-chains)
3. ```<file id>```
  * replace with the file ID selected by the user while using your app. 
   * The code snippet for enabling Sequencing.com's File Selector for your app can be found in the [File Selector code repo](https://github.com/SequencingDOTcom/File-Selector-code)
   
* [Developer Documentation](https://sequencing.com/developer-documentation/)

* [oAuth2 guide](https://sequencing.com/developer-documentation/oauth2-guide/)

* Review the [Weather My Way +RTP app](https://github.com/SequencingDOTcom/Weather-My-Way-RTP-App/), which is an open-source weather app that uses Real-Time Personalization to provide genetically tailored content

* Confirm you have the latest version of the code from this repository.


Resources
======================================
* [App chains](https://sequencing.com/app-chains)
* [File selector code](https://github.com/SequencingDOTcom/File-Selector-code)
* [Developer center](https://sequencing.com/developer-center)
* [Developer Documentation](https://sequencing.com/developer-documentation/)

Maintainers
======================================
This repo is actively maintained by [Sequencing.com](https://sequencing.com/). Email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.

Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please send us a pull request. If the changes contribute positively, we'll let it ride.
