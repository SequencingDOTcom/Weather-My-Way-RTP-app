Weather My Way +RTP app - Web version
=========================================
The [Weather My Way +RTP](https://weathermyway.rocks/) is the first weather app in the world to utilize Sequencing.com's [Sequencing.com's](https://sequencing.com/) [Real Time Personalization (RTP)](https://sequencing.com/developer-documentation/what-is-real-time-personalization-rtp/) technology.

The app provides the app user with genetically tailored forecasts that help the app user optimize his or her health and wellness. 

The genetically tailored forecasts are personalized to the user's genes (using Sequencing.com's API) and the weather (using Weather Underground's API) in real-time.

Contents
=========================================
* Editions
* Introduction
* Information flow
* Project
* Requirements
* Installation
* Configuration
* Troubleshooting
* App chains
* Maintainers
* Contribute

Editions
=========================================
Weather My Way +RTP 
* Repo = this repo
* App = https://weathermyway.rocks

Weather My Child's Way +RTP
* Repo = https://github.com/SequencingDOTcom/Weather-My-Childs-Way-app
* App = https://weathermychildsway.rocks

Introduction
=========================================
The [Weather My Way +RTP app](https://weathermyway.rocks/) codebase is a C# .NET implementation that shows how to combine real-time weather data with the genetic data from the child of the app user.

[Register for a free account](https://sequencing.com/user/register/) to learn more about Real-Time Personalization technology and gain full access to this technology. Development using RTP is free.

Information flow
========================================
1. App-user validates using Sign in with Sequencing.com. OAuth2 code is open source and available here: https://github.com/SequencingDOTcom/oAuth2-code-and-demo
2. If successful, app either auto-detects geographic location or user can manually input location. The app works for most locations throughout the world. 
3. Next, user selects a genetic file for analysis. Sample files are also provided. File selector code is open source and available here: https://github.com/SequencingDOTcom/File-Selector
4. The app will then be personalized to the app user's genes by combining an analysis of the app user's genes with an analysis of the current weather forecast.

* Two [App Chains](https://sequencing.com/app-chains/) that use Sequencing.com's API are utilized for this app: 
 * [Chain9](https://sequencing.com/skin-cancer-risk-melanoma) (Skin cancer risk)
 * [Chain88](https://sequencing.com/optimizing-vitamin-d-levels-very-important-health) (Vitamin D supplements likely to protect health)
* Forecast screen contains both the weather forecast and the user's genetically tailored forecast, which is personalized insight to help the user optimize their health and wellness.
* All analysis occurs in real-time.

Project
========================================
This codebase is supplied as a C# Visual Studio project with MVC as the coding pattern. The code included mainly three components

* Models: Implemented as C# class objects.
* Controllers: Implemented as C# class objects.
* Views: Implemented as HTML pages with basic templating and styling.

Requirements
======================================
The main requirement is installed Visual Studio or the free Visual Web Matrix that can be obtained from the following links

* Visual Web Matrix: http://www.microsoft.com/web/webmatrix/
* Visual Studio: http://www.visualstudio.com

We have included all the supporting binaries to execute the code. The following external binaries are used, if you require them separately.

* JSON .NET: https://json.codeplex.com/
* REST Sharp: http://restsharp.org/

Installation
======================================
The app is developed as a web application and so no installation as such is required. Simply clone this repository on your workstation/ computer and open the project in Visual Studio/ Visual Web Matrix. Then click the play button and you should be on your way. Then follow the screen instructions.

Configuration
======================================
There are no strict configurations that have to be performed. However, there are some settings while using the app.

It is possible to use the app in an anonymous mode in which case the app will work with real-time weather data and will not include any personalized data. Only if the use logs in using their account then the genetic data is visible and personalized recommendations are generated.

Troubleshooting
======================================
The app should work straight away without any issue. 

Other tips

* To experience the app, [register for a free account](https://sequencing.com/user/register/) and use your account credentials when running the demo. You may then access all developer tools and information directly from the [Developer Center](https://sequencing.com/developer-center/).
* [Developer Documentation](https://sequencing.com/developer-documentation/) is also available.
* Confirm all the dependency dlls loaded correctly.
* Confirm you are connected to the internet since the API calls will be made to our server and the weather data servers as well.
* Confirm you have the latest version of the code from this repository.
* Search through available App Chains here: https://sequencing.com/app-chains/

App chains
======================================
Search and find app chains -> https://sequencing.com/app-chains/

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

Maintainers
======================================
The codebase is actively maintained by [Sequencing.com](https://sequencing.com/). Please email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.

Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please submit a pull request. If the changes contribute positively, we'll let it ride.
