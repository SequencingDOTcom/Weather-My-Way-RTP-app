Weather My Way +RTP app - Web version
=========================================
The [Weather My Way +RTP](https://weathermyway.rocks/) is the first weather app in the world to utilize Sequencing.com's [Sequencing.com's](https://sequencing.com/) [Real Time Personalization (RTP)](https://sequencing.com/developer-documentation/what-is-real-time-personalization-rtp/) technology. This code is open source and free to use, share, build upon and improve!

Weather My Way +RTP web app: https://weathermyway.rocks

This repository is for the .NET version of the Weather My Way +RTP app.

* Introduction
* Project
* Requirements
* Installation
* Configuration
* Troubleshooting
* Maintainers
* Contribute

Introduction
=========================================
The [Weather My Way +RTP app](https://weathermyway.rocks/) is the first weather app in the world to utilize Sequencing.com's Real Time Personalization (RTP) technology.

This codebase is a C# .NET implementation that shows how to combine real-time weather data with an users genetic data and is also intended to show how to work with Sequencing.com's open API. The APIs are implemented as REST API and can be used with any coding language that supports JSON.

The overall information flow of this app is that an end-user validates using their sequencing.com login and if successfully the app asks for geographic location which can be any location on the planet. After which the user should select a genetic file for analysis. The backend APIs will then process the user’s genes and combine it with real-time weather data. Finally, the user will be presented with personalized recommendations that takes into account the current weather and the user’s genes - all occurring in real-time.

[Register for a free account](https://sequencing.com/user/register/) to learn more about Real-Time Personalization technology and gain full access to this technology. Development using RTP is free.

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

Maintainers
======================================
The codebase is actively maintained by [Sequencing.com](https://sequencing.com/). Please email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.

Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please submit a pull request. If the changes contribute positively, we'll let it ride.
