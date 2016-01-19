function vidRandom()
{
    var random = Math.floor((Math.random() * 5) + 1);
	
	if(random == 1)
	{
		$("#currentVid").attr("src", "/assets/videos/shutterstock_v10572149.mp4");
		

		$("#bgVideo").attr("poster", "/assets/img/posters/10572149_poster.jpg");
		$("#content").css({ "background-image": "url(/assets/img/posters/10572149_poster.jpg)" });
	}
	if(random == 2)
	{
		$("#currentVid").attr("src", "/assets/videos/shutterstock_v4406759.mp4");
		

		$("#bgVideo").attr("poster", "/assets/img/posters/4406759_poster.jpg");
		$("#content").css({ "background-image": "url(/assets/img/posters/4406759_poster.jpg)" });
	}
	if(random == 3)
	{
		$("#currentVid").attr("src", "/assets/videos/shutterstock_v6698111.mp4");
		

		$("#bgVideo").attr("poster", "/assets/img/posters/6698111_poster.jpg");
		$("#content").css({ "background-image": "url(/assets/img/posters/6698111_poster.jpg)" });
	}
	if(random == 4)
	{
		$("#currentVid").attr("src", "/assets/videos/shutterstock_v163903.mp4");
		

		$("#bgVideo").attr("poster", "/assets/img/posters/163903_poster.jpg");
		$("#content").css({ "background-image": "url(/assets/img/posters/163903_poster.jpg)" });
	}
	if (random == 5) {
	    $("#currentVid").attr("src", "/assets/videos/shutterstock_v4584485.mp4");


	    $("#bgVideo").attr("poster", "/assets/img/posters/4584485_poster.jpg");
	    $("#content").css({ "background-image": "url(/assets/img/posters/4584485_poster.jpg)" });
	}
}