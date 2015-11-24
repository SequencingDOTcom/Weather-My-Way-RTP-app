//These functions control the about windows appearance, expansion and disappearance animation based on click events.
$(function () {
    $("#aboutButton").click(function ()
    {
        $("#tabContainer").fadeIn();
        $("#aboutButton").fadeOut();
        $("#aboutWindow").fadeIn();
    });
});

$(function () {
    $("#aboutButtonTwo").click(function () {
        $("#tabContainer").fadeIn();
        $("#aboutButton").fadeOut();
        $("#aboutWindow").fadeIn();
        $("#settingsWindow").slideToggle();
    });
});

$(function () {
    $("#bgVideo").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#fileInstruction").slideUp();
    });
});

$(function () {
    $("#titleText").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        
    });
});

$(function () {
    $("#loginContainer").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
    });
});

$(function () {
    $("#regBox").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
    });
});

$(function () {
    $("#close").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
    });
});

$(function () {
    $("#closeTwo").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
    });
});

$(function () {
    $("#locInstruction").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
    });
});

$(function () {
    $("#location").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
    });
});

$(function () {
    $("#loginbox").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#fileInstruction").slideUp();
    });
});

$(function () {
    $("#preloader").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
    });
});

$(function () {
    $("#now").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#shareWindow").slideUp();
    });
});
$(function () {
    $("#tempNow").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#shareWindow").slideUp();
    });
});
$(function () {
    $("#stats").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#shareWindow").slideUp();
    });
});
$(function () {
    $("#tip").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#shareWindow").slideUp();
    });
});
$(function () {
    $("#forecastDetails").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#shareWindow").slideUp();
    });
});
$(function () {
    $("#Forecast").click(function () {
        $("#tabContainer").fadeOut();
        $("#aboutWindow").fadeOut();
        $("#aboutButton").fadeIn();
        $("#settingsWindow").slideUp();
        $("#shareWindow").slideUp();
    });
});
// these control the page turn in the about window
$(function()//turns to the more information page
{
	$("#more").click(function()
	{
		$("#aboutPara").fadeOut();
		$("#more").fadeOut();
		$("#logoContainer").fadeOut();

		$("#aboutPara").animate({left:"95%%"});
		$("#more").animate({left:"66%"});
		$("#aboutPara2").animate({right:"5%"});
		$("#less").animate({right:"33%"});
		
		
		$("#aboutPara2").fadeIn();
		$("#logoTwoContainer").fadeIn();
		
		
	});
});

$(function()//turns back to the main about page
{
	$("#back").click(function()
	{
		$("#aboutPara2").fadeOut();
		$("#logoTwoContainer").fadeOut();
		
		$("#aboutPara2").animate({right:"95%"});
		$("#less").animate({right:"66%"});
		$("#aboutPara").animate({left:"5%"});
		$("#more").animate({left:"33%"});
		
		
		
		$("#aboutPara").fadeIn();
		$("#logoContainer").fadeIn();
		$("#more").fadeIn();
		
		
	});
});

//the share window controller
$(function ()
{
    $("#share").click(function () {
        $("#shareWindow").slideToggle();
    });
});

//the settings drop down
$(function () {
    $("#settingsButton").click(function () {
        $("#settingsWindow").slideToggle();
    });
});

//file selctor instructions
$(function () {
    $("#question").click(function () {
        $("#fileInstruction").slideToggle();
    });
});



//location detection
$(document).ready(function () {
    $("#discoverButton").click(function (parameters) {
        navigator.geolocation.getCurrentPosition(function (position) {
            var lat = position.coords.latitude;
            var lng = position.coords.longitude;
            codeLatLng(lat, lng);
        });

    });
});
function codeLatLng(lat, lng) {
    var geocoder = new google.maps.Geocoder();
    var latlng = new google.maps.LatLng(lat, lng);
    geocoder.geocode({ 'latLng': latlng }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            if (results[1]) {
                //formatted address
                //find country name
                for (var i = 0; i < results[0].address_components.length; i++) {
                    for (var b = 0; b < results[0].address_components[i].types.length; b++) {
                        //there are different types that might hold a city admin_area_lvl_1 usually does in come cases looking for sublocality type will be more appropriate
                        if (results[0].address_components[i].types[b] == "locality") {
                            //this is the object you are looking for
                            city = results[0].address_components[i];
                            break;
                        }
                    }
                }
                if (city) {
                    $("#city").val(city.short_name);
                    $("#currentWeather").text("current weather: @Model.Weather");

                    return;
                }
            }
        }
        $("#city").val("undetermined");


    });
};

//dynamic text sizing
$(document).ready(function () {
    var $body = $('body'); //Cache this for performance

    var setBodyScale = function () {
        var scaleSource = $body.width(),
            scaleFactor = 0.35,
            maxScale = 150,
            minScale = 30; //Tweak these values to taste

        var fontSize = scaleSource * scaleFactor; //Multiply the width of the body by the scaling factor:

        if (fontSize > maxScale) fontSize = maxScale;
        if (fontSize < minScale) fontSize = minScale; //Enforce the minimum and maximums

        $('body').css('font-size', fontSize + '%');
    }

    $(window).resize(function () {
        setBodyScale();
    });

    //Fire it when the page first loads:
    setBodyScale();
});


//mobile device detection
var html5video = document.createElement('video').canPlayType;

/*
if (!html5video)
{
    $(function ()
    {
        $("#bgVideo").css({ "display": "none" });
        $("#currentVid").css({ "display": "none" });
    
    });
}
*/
function getMobileOperatingSystem() {
    var userAgent = navigator.userAgent || navigator.vendor || window.opera;

    if (userAgent.match(/iPad/i) || userAgent.match(/iPhone/i) || userAgent.match(/iPod/i))
    {
        $(function () {
            $("#bgVideo").css({ "display": "none" });
            $("#currentVid").css({ "display": "none" });
        });
    }
  
}

