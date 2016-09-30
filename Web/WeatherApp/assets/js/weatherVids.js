function vidSelect(weatherType, dayNight)
{
	if(dayNight == "day")//for day time
	{
		if(weatherType == "Heavy Low Drifting Sand" || weatherType == "Sand" ||weatherType == "LowDriftingSand" ||weatherType == "BlowingSand" ||weatherType == "Light Sand" || weatherType == "Light Low Drifting Sand" ||weatherType == "Light Blowing Sand")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2580011.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2580011_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2580011_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2580011_poster.jpg)" });
		}
		if(weatherType == "Light Drizzle" || weatherType == "Light Rain Showers")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4627466.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4627466_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4627466_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4627466_poster.jpg)" });
		}
		if(weatherType == "Partly Cloudy" || weatherType == "Scattered Clouds")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v10572149.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/10572149_poster.jpg");
			$("#content").css( "background-image", "/assets/img/posters/10572149_poster.jpg" );
			$("#dashboard").css( "background-image", "/assets/img/posters/10572149_poster.jpg" );
		}
		if(weatherType == "Heavy Widespread Dust" || weatherType == "Heavy Blowing Widespread Dust" || weatherType == "WidespreadDust")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1126162.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1126162_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1126162_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1126162_poster.jpg)" });
		}
		if(weatherType == "Heavy Haze" || weatherType == "Haze" || weatherType == "RainMist" || weatherType == "Light Haze" || weatherType == "Hazy")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v11588486.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/11588486_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/11588486_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/11588486_poster.jpg)" });
		}
		if(weatherType == "Heavy Thunderstorms and Snow" || weatherType == "ThunderstormsandSnow" || weatherType == "Light Thunderstorms and Snow")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v11612783.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/11612783_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/11612783_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/11612783_poster.jpg)" });
		}
		if(weatherType == "Heavy Freezing Drizzle" || weatherType == "FreezingRain" || weatherType == "Light Freezing Rain")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v120847.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/120847_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/120847_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/120847_poster.jpg)" });
		}
		if(weatherType == "Light Mist")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1389124.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1389124_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1389124_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1389124_poster.jpg)" });
		}
		if(weatherType == "Heavy Thunderstorm" || weatherType == "Thunderstorm" || weatherType == "ThunderstormsandRain")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1538677.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1538677_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1538677_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1538677_poster.jpg)" });
		}
		if(weatherType == "Squalls")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v163903.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/163903_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/163903_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/163903_poster.jpg)" });
		}
		if(weatherType == "Light Thunderstorm" || weatherType == "Light Thunderstorms and Rain" || weatherType == "Heavy Thunderstorms and Rain" || weatherType == "Thunderstorm")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2051507.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2051507_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2051507_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2051507_poster.jpg)" });
		}
		if(weatherType == "Heavy Drizzle" || weatherType == "Heavy Rain" || weatherType == "Heavy Rain Mist" || weatherType == "Rain" || weatherType == "RainShowers" || weatherType == "Unknown Precipitation" || weatherType == "Chance of Showers" || weatherType == "Showers")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v225991.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/225991_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/225991_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/225991_poster.jpg)" });
		}
		if(weatherType == "Heavy Rain Showers" || weatherType == "Chance of Rain")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2302283.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2302283_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2302283_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2302283_poster.jpg)" });
		}
		if(weatherType == "Heavy Blowing Sand")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2580011.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2580011_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2580011_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2580011_poster.jpg)" });
		}
		if(weatherType == "Heavy Ice Crystals" || weatherType == "Heavy Ice Pellets" || weatherType == "Heavy Hail" || weatherType == "Heavy Ice Pellet Showers" || weatherType == "Heavy Hail Showers" || weatherType == "Heavy Small Hail Showers" || weatherType == "Heavy Thunderstorms and Ice Pellets" || weatherType == "Heavy Thunderstorms with Hail" || weatherType == "Heavy Thunderstorms with Small Hail" || weatherType == "Hail" || weatherType == "IcePelletShowers" || weatherType == "HailShowers" || weatherType == "SmallHailShowers" || weatherType == "ThunderstormsandIcePellets" || weatherType == "ThunderstormswithHail" || weatherType == "ThunderstormswithSmallHail" || weatherType == "Light Hail Showers" || weatherType == "Light Small Hail Showers")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2629166.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2629166_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2629166_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2629166_poster.jpg)" });
		}
		if(weatherType == "Heavy Smoke" || weatherType == "Heavy Freezing Fog" || weatherType == "Smoke" || weatherType == "FreezingFog" || weatherType == "Light Smoke")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2718020.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2718020_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2718020_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2718020_poster.jpg)" });
		}
		if(weatherType == "Very Cold" || weatherType == "IceCrystals" || weatherType == "IcePellets" || weatherType == "Light Ice Crystals" || weatherType == "Light Ice Pellet Showers" || weatherType == "Light Thunderstorms and Ice Pellets" || weatherType == "Light Thunderstorms with Hail" || weatherType == "Light Thunderstorms with Small Hail")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3036661.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3036661_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3036661_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3036661_poster.jpg)" });
		}
		if(weatherType == "Patches of Fog" || weatherType == "Shallow Fog" || weatherType == "Partial Fog")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3112114.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3112114_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3112114_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3112114_poster.jpg)" });
		}
		if(weatherType == "Drizzle" || weatherType == "Light Rain" || weatherType == "Light Rain Mist") 
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3168328.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3168328_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3168328_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3168328_poster.jpg)" });
		}
		if(weatherType == "Heavy Spray" || weatherType == "Spray" || weatherType == "Light Spray")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3652088.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3652088_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3652088_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3652088_poster.jpg)" });
		}
		if(weatherType == "Mostly Cloudy")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3671960.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3671960_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3671960_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3671960_poster.jpg)" });
		}
		if(weatherType == "Heavy Freezing Rain" || weatherType == "Snow Showers")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3753200.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3753200_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3753200_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3753200_poster.jpg)" });
		}
		if(weatherType == "Heavy Dust Whirls" || weatherType == "Heavy Low Drifting Widespread Dust" || weatherType == "DustWhirls" || weatherType == "LowDriftingWidespreadDust" || weatherType == "BlowingWidespreadDust" || weatherType == "Light Widespread Dust" || weatherType == "Light Dust Whirls" || weatherType == "Light Low Drifting Widespread Dust" || weatherType == "Light Blowing Widespread Dust")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4189258.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4189258_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4189258_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4189258_poster.jpg)" });
		}
		if(weatherType == "FreezingDrizzle" || weatherType == "Light Snow" || weatherType == "Light Snow Grains" || weatherType == "" || weatherType == "Light Blowing Snow" || weatherType == "Light Snow Showers" || weatherType == "Light Snow Blowing Snow Mist" || weatherType == "Light Freezing Drizzle" || weatherType == "Light Freezing Fog")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4314167.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4314167_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4314167_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4314167_poster.jpg)" });
		}
		if(weatherType == "Mist" || weatherType == "Fog" || weatherType == "FogPatches" || weatherType == "Light Fog" || weatherType == "Light Fog Patches")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4443185.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4443185_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4443185_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4443185_poster.jpg)" });
		}
		if(weatherType == "Unknown" || weatherType == "OMITTED")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4584485.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4584485_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
		}
		if (weatherType == "Very Hot") {
		    $("#currentVid").attr("src", "/assets/videos/shutterstock_v4491596.mp4");
		    

		    $("#bgVideo").attr("poster", "/assets/img/posters/4491596_poster.jpg");
		    $("#content").css({ "background-image": "url(/assets/img/posters/4491596_poster.jpg)" });
		    $("#dashboard").css({ "background-image": "url(/assets/img/posters/4491596_poster.jpg)" });
		}
		if (weatherType == "Heavy Snow" || weatherType == "Heavy Snow Grains" || weatherType == "Heavy Snow Showers" || weatherType == "Heavy Snow Blowing Snow Mist" || weatherType == "Snow" || weatherType == "SnowGrains" || weatherType == "Chance of Snow Showers" || weatherType == "Chance of Snow")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5236070.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5236070_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5236070_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5236070_poster.jpg)" });
		}
		if (weatherType == "Heavy Low Drifting Snow" || weatherType == "Heavy Blowing Snow" || weatherType == "LowDriftingSnow" || weatherType == "BlowingSnow" || weatherType == "Blowing Snow" || weatherType == "Blizzard")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5468858.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5468858_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5468858_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5468858_poster.jpg)" });
		}
		if(weatherType == "Heavy Mist" || weatherType == "Heavy Fog" || weatherType == "Heavy Fog Patches")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5793242.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5793242_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5793242_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5793242_poster.jpg)" });
		}
		if(weatherType == "SnowShowers" || weatherType == "SnowBlowingSnowMist" || weatherType == "Light Low Drifting Snow" || weatherType == "Flurries")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v6698111.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/6698111_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/6698111_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/6698111_poster.jpg)" });
		}
		if(weatherType == "Funnel Cloud")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v7188568.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/7188567_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/7188567_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/7188568_poster.jpg)" });
		}
		if(weatherType == "Light Ice Pellets" || weatherType == "Light Hail" || weatherType == "Small Hail")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v728440.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/728440_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/728440_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/728440_poster.jpg)" });
		}
		if(weatherType == "Heavy Volcanic Ash" || weatherType == "VolcanicAsh" || weatherType == "Light Volcanic Ash")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v8037967.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/8037967_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/8037967_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/8037967_poster.jpg)" });
		}
		if(weatherType == "Clear")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v8257699.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/8257699_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/8257699_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/8257699_poster.jpg)" });
		}
		if(weatherType == "Heavy Sand" || weatherType == "Heavy Sandstorm" || weatherType == "Sandstorm" || weatherType == "Light Sandstorm")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v861337.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/861337_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/861337_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/861337_poster.jpg)" });
		}
		if(weatherType == "Overcast" || weatherType == "Cloudy")
		{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v885172.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/885172_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/885172_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/885172_poster.jpg)" });
		}
		if(weatherType == "Chance of a Thunderstorm")
		{
		    $("#currentVid").attr("src", "/assets/videos/shutterstock_v800269.mp4");
		    

		    $("#bgVideo").attr("poster", "/assets/img/posters/800269_poster.jpg");
		    $("#content").css({ "background-image": "url(/assets/img/posters/800269_poster.jpg)" });
		    $("#dashboard").css({ "background-image": "url(/assets/img/posters/800269_poster.jpg)" });
		}
		if(weatherType == "Chance of Ice Pellets" || weatherType == "Ice Pellets")
		{
		    $("#currentVid").attr("src", "/assets/videos/shutterstock_v2629166.mp4");
		    

		    $("#bgVideo").attr("poster", "/assets/img/posters/2629166_poster.jpg");
		    $("#content").css({ "background-image": "url(/assets/img/posters/2629166_poster.jpg)" });
		    $("#dashboard").css({ "background-image": "url(/assets/img/posters/2629166_poster.jpg)" });
		}
	}
	if(dayNight == "night" )//for night time
	{
		if(weatherType == "Unknown" || weatherType == "Clear")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v1775912.mp4");
					
                    
					$("#bgVideo").attr("poster", "/assets/img/posters/1775912_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/1775912_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/1775912_poster.jpg)" });
				}
		if(weatherType == "Heavy Blowing Sand" || weatherType == "Heavy Low Drifting Sand" || weatherType == "Sand" || weatherType == "LowDriftingSand" || weatherType == "BlowingSand" || weatherType == "Light Sand" || weatherType == "Light Low Drifting Sand" || weatherType == "Light Blowing Sand")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v2580011.mp4");
					
                    
					$("#bgVideo").attr("poster", "/assets/img/posters/2580011_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/2580011_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/2580011_poster.jpg)" });
				}
		if(weatherType == "Heavy Widespread Dust" || weatherType == "Heavy Blowing Widespread Dust" || weatherType == "WidespreadDust")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v1126162.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/1126162_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/1126162_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/1126162_poster.jpg)" });
				}
		if(weatherType == "Heavy Haze" || weatherType == "Haze" || weatherType == "Light Haze" || weatherType == "Hazy")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v11588486.mp4");
					
                    
					$("#bgVideo").attr("poster", "/assets/img/posters/11588486_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/11588486_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/11588486_poster.jpg)" });
				}
		if(weatherType == "Light Mist" || weatherType == "Patches of Fog" || weatherType == "Shallow Fog" || weatherType == "Partial Fog" || weatherType == "Light Freezing Fog" || weatherType == "Fog" || weatherType == "FogPatches" || weatherType == "Light Fog" || weatherType == "Light Fog Patches" || weatherType == "Heavy Fog Patches" || weatherType == "Foggy")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v1389124.mp4");
					
                    
					$("#bgVideo").attr("poster", "/assets/img/posters/1389124_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/1389124_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/1389124_poster.jpg)" });
				}
		if(weatherType == "ThunderstormsandRain" || weatherType == "Squalls" || weatherType == "Light Thunderstorms and Rain" || weatherType == "Heavy Thunderstorms and Rain")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v163903.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/163903_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/163903_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/163903_poster.jpg)" });
				}
		if(weatherType == "Overcast")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v1936054.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/1936054_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/1936054_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/1936054_poster.jpg)" });
				}
	
		if(weatherType == "Chance of Ice Pellets" || weatherType == "Ice Pellets" || weatherType == "Heavy Ice Pellet Showers" || weatherType == "Heavy Hail Showers" || weatherType == "Heavy Small Hail Showers" || weatherType == "Heavy Thunderstorms and Ice Pellets" || weatherType == "Heavy Thunderstorms with Hail" || weatherType == "Heavy Thunderstorms with Small Hail" || weatherType == "Hail" || weatherType == "IcePelletShowers" || weatherType == "ThunderstormsandIcePellets" || weatherType == "ThunderstormswithHail" || weatherType == "ThunderstormswithSmallHail")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v2629166.mp4");
					


					$("#bgVideo").attr("poster", "/assets/img/posters/2629166_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/2629166_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/2629166_poster.jpg)" });
				}
		if(weatherType == "Heavy Smoke" || weatherType == "Smoke" || weatherType == "Light Smoke")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v2718020.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/2718020_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/2718020_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/2718020_poster.jpg)" });
				}
		if(weatherType == "Partly Cloudy")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v2831005.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/2831005_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/2831005_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/2831005_poster.jpg)" });
		        }
		if (weatherType == "Very Hot")
		{
		    $("#currentVid").attr("src", "/assets/videos/shutterstock_v2864458.mp4");
		    

		    $("#bgVideo").attr("poster", "/assets/img/posters/2864458_poster.jpg");
		    $("#content").css({ "background-image": "url(/assets/img/posters/2864458_poster.jpg)" });
		    $("#dashboard").css({ "background-image": "url(/assets/img/posters/2864458_poster.jpg)" });
		}
		if(weatherType == "Heavy Freezing Drizzle" || weatherType == "FreezingRain" || weatherType == "Light Freezing Rain" || weatherType == "IceCrystals" || weatherType == "IcePellets" || weatherType == "Light Ice Crystals" || weatherType == "Light Ice Pellet Showers" || weatherType == "Light Thunderstorms and Ice Pellets" || weatherType == "Light Thunderstorms with Hail" || weatherType == "Light Thunderstorms with Small Hail" || weatherType == "Heavy Freezing Rain" || weatherType == "FreezingDrizzle" || weatherType == "Light Freezing Drizzle")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v3036661.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/3036661_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/3036661_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/3036661_poster.jpg)" });
				}
		if(weatherType == "Very Cold" || weatherType == "HailShowers" || weatherType == "SmallHailShowers" || weatherType == "Light Hail Showers" || weatherType == "Light Small Hail Showers" || weatherType == "Heavy Freezing Fog" || weatherType == "FreezingFog")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v3149698.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/3149698_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/3149698_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/3149698_poster.jpg)" });
				}
		if(weatherType == "RainMist" || weatherType == "Light Rain Mist")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v3168328.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/3168328_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/3168328_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/3168328_poster.jpg)" });
				}
		if(weatherType == "Chance of Showers" || weatherType == "Heavy Rain" || weatherType == "Heavy Rain Mist" || weatherType == "Heavy Rain Showers" || weatherType == "RainShowers")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v3579536.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/3579536_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/3579536_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/3579536_poster.jpg)" });
				}
		if(weatherType == "Heavy Spray" || weatherType == "Spray" || weatherType == "Light Spray")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v3652088.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/3652088_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/3652088_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/3652088_poster.jpg)" });
				}
		if(weatherType == "Heavy Drizzle")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v5649644.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/5649644_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/5649644_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/5649644_poster.jpg)" });
				}
		if(weatherType == "Heavy Dust Whirls" || weatherType == "Heavy Low Drifting Widespread Dust" || weatherType == "DustWhirls" || weatherType == "LowDriftingWidespreadDust" || weatherType == "BlowingWidespreadDust" || weatherType == "Light Widespread Dust" || weatherType == "Light Dust Whirls" || weatherType == "Light Low Drifting Widespread Dust" || weatherType == "Light Blowing Widespread Dust" || weatherType == "Light Low Drifting Snow")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v4189258.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/4189258_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/4189258_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/4189258_poster.jpg)" });
				}
		if(weatherType == "Mist" || weatherType == "Foggy")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v4443185.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/4443185_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/4443185_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/4443185_poster.jpg)" });
				}
		if(weatherType == "Blizzard" || weatherType == "Light Snow" || weatherType == "Light Snow Grains" || weatherType == "Light Snow Showers" || weatherType == "Light Snow Blowing Snow Mist" || weatherType == "BlowingSnow") 
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v5468858.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/5468858_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/5468858_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/5468858_poster.jpg)" });
				}
		if (weatherType == "Showers" || weatherType == "Chance of Rain" || weatherType == "Rain" || weatherType == "Light Drizzle" || weatherType == "Light Rain Showers" || weatherType == "Unknown Precipitation" || weatherType == "Drizzle" || weatherType == "Light Rain" || weatherType == "")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v5649644.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/5649644_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/5649644_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/5649644_poster.jpg)" });
				}		
		if(weatherType == "Heavy Mist" || weatherType == "Heavy Fog")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v5793242.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/5793242_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/5793242_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/5793242_poster.jpg)" });
				}
		if(weatherType == "Light Blowing Snow" || weatherType == "Snow" || weatherType == "SnowGrains")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v6698111.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/6698111_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/6698111_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/6698111_poster.jpg)" });
				}
		if(weatherType == "Scattered Clouds" || weatherType == "Mostly Cloudy" || weatherType == "Cloudy")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v6820675.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/6820675_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/6820675_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/6820675_poster.jpg)" });
				}
		if(weatherType == "Funnel Cloud")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v7188568.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/7188568_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/7188568_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/7188568_poster.jpg)" });
				}
		if(weatherType == "Heavy Ice Crystals" || weatherType == "Heavy Ice Pellets" || weatherType == "Heavy Hail" || weatherType == "Light Ice Pellets" || weatherType == "Light Hail" || weatherType == "Small Hail")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v728440.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/728440_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/728440_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/728440_poster.jpg)" });
				}
		if(weatherType == "Blowing Snow" || weatherType == "Heavy Thunderstorms and Snow" || weatherType == "ThunderstormsandSnow" || weatherType == "Light Thunderstorms and Snow" || weatherType == "Heavy Snow" || weatherType == "Heavy Snow Grains" || weatherType == "Heavy Snow Showers" || weatherType == "Heavy Snow Blowing Snow Mist" || weatherType == "Heavy Low Drifting Snow" || weatherType == "Heavy Blowing Snow" || weatherType == "LowDriftingSnow" || weatherType == "SnowShowers" || weatherType == "SnowBlowingSnowMist" || weatherType == "Flurries" || weatherType == "Chance of Snow Showers" || weatherType == "Snow Showers" || weatherType == "Chance of Snow" || weatherType =="Snow")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v7419178.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/7419178_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/7419178_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/7419178_poster.jpg)" });
				}
		if(weatherType == "Chance of a Thunderstorm" || weatherType == "Heavy Thunderstorm" || weatherType == "Thunderstorm" || weatherType == "Light Thunderstorm")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v800269.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/800269_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/800269_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/800269_poster.jpg)" });
				}
		if(weatherType == "Heavy Volcanic Ash" || weatherType == "VolcanicAsh" || weatherType == "Light Volcanic Ash")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v8037967.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/8037967_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/8037967_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/8037967_poster.jpg)" });
				}
		if(weatherType == "Heavy Sand" || weatherType == "Heavy Sandstorm " || weatherType == "Sandstorm" || weatherType == "Light Sandstorm")
				{
					$("#currentVid").attr("src", "/assets/videos/shutterstock_v861337.mp4");
					

					$("#bgVideo").attr("poster", "/assets/img/posters/861337_poster.jpg");
					$("#content").css({ "background-image": "url(/assets/img/posters/861337_poster.jpg)" });
					$("#dashboard").css({ "background-image": "url(/assets/img/posters/861337_poster.jpg)" });
		}
		if(weatherType == "Thunderstorm")
		{
		    $("#currentVid").attr("src", "/assets/videos/shutterstock_v2051507.mp4");
		    

		    $("#bgVideo").attr("poster", "/assets/img/posters/2051507_poster.jpg");
		    $("#content").css({ "background-image": "url(/assets/img/posters/2051507_poster.jpg)" });
		    $("#dashboard").css({ "background-image": "url(/assets/img/posters/2051507_poster.jpg)" });
		}
		if(weatherType == "OMITTED")
		{
		    $("#currentVid").attr("src", "/assets/videos/shutterstock_v4584485.mp4");
		    

		    $("#bgVideo").attr("poster", "/assets/img/posters/4584485_poster.jpg");
		    $("#content").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
		    $("#dashboard").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
		}
	}
}



