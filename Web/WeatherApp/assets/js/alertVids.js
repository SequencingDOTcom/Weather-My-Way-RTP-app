function alertVid(alertType, dayNight)
{
	if (dayNight == "day")
	{

		if( alertType == "FLO" || alertType == "WAT")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1093591.mp4");
			

			$("#bgVideo").attr( "poster", "/assets/img/posters/1093591_poster.jpg" );
			$("#content").css({ "background-image": "url(/assets/img/posters/1093591_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1093591_poster.jpg)" });
			}
		}
		if( alertType == "WRN" || alertType == "SEW")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1538677.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1538677_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1538677_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1538677_poster.jpg)" });
			}
		}

		if( alertType == "HEA" || alertType == "FIR")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2864458.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2864458_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2864458_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2864458_poster.jpg)" });
			}
		}

		if( alertType == "WIN")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3036661.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3036661_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3036661_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3036661_poster.jpg)" });
			}
		}

		if (alertType == "VOL")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3935576.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3935576_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3935576_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3935576_poster.jpg)" });
			}
		}
		
		if( alertType == "SVR" || alertType == "SPE" || alertType == "REC" || alertType == "REP" || alertType == "PUB")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4584485.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4584485_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
			}
		}
		
		if( alertType == "WND")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4636637.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4636637_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4636637_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4636637_poster.jpg)" });
			}
		}

		if (alertType == "TOR" || alertType == "TOW")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5742650.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5742650_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5742650_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5742650_poster.jpg)" });
			}
		}

		if( alertType == "HUR" || alertType == "HWW")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5744606.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5744606_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5744606_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5744606_poster.jpg)" });
			}
		}

		if( alertType == "FOG")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5793242.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5793242_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5793242_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5793242_poster.jpg)" });
			}
		}
	}

	if(dayNight == "night")
	{
		if(alertType == "SVR" || alertType == "SPE")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1775912.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1775912_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1775912_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1775912_poster.jpg)" });
			}
		}
		if(alertType == "FLO" || alertType == "WAT")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1093591.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1093591_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1093591_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1093591_poster.jpg)" });
			}
		}
		if(alertType == "FOG")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1389124.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1389124_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1389124_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1389124_poster.jpg)" });
			}
		}
		if(alertType == "SEW")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v1538677.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/1538677_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/1538677_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/1538677_poster.jpg)" });
			}
		}
		if(alertType == "HEA" || alertType == "FIR")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v2864458.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/2864458_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/2864458_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/2864458_poster.jpg)" });
			}
		}
		if(alertType == "WIN")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3149698.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3149698_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3149698_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3149698_poster.jpg)" });
			}
		}
		if(alertType == "VOL")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v3935576.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/3935576_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/3935576_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/3935576_poster.jpg)" });
			}
		}
		if(alertType == "WND")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4406759.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4406759_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4406759_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4406759_poster.jpg)" });
			}
		}
		if(alertType == "REC" || alertType == "REP" || alertType == "PUB")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v4584485.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/4584485_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
			}
		}
		if(alertType == "TOR" || alertType == "TOW")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5742650.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5742650_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5742650_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5742650_poster.jpg)" });
			}
		}
		if(alertType == "HUR" || alertType == "HWW")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v5744606.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/5744606_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/5744606_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/5744606_poster.jpg)" });
			}
		}
		if(alertType == "WRN")
		{
			{
			$("#currentVid").attr("src", "/assets/videos/shutterstock_v8529928.mp4");
			

			$("#bgVideo").attr("poster", "/assets/img/posters/8529928_poster.jpg");
			$("#content").css({ "background-image": "url(/assets/img/posters/8529928_poster.jpg)" });
			$("#dashboard").css({ "background-image": "url(/assets/img/posters/8527728_poster.jpg)" });
			}
		}
	}
}