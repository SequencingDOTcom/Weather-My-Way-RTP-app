
    $(document).ready(function() {
        $("#btnDiscover").click(function(parameters) {
            navigator.geolocation.getCurrentPosition(function(position) {
                var lat = position.coords.latitude;
                var lng = position.coords.longitude;
                codeLatLng(lat, lng);
            }, function(code) {
                $("#city").val("error evaluating location");
            });

        });
    });

function codeLatLng(lat, lng) {
    var geocoder = new google.maps.Geocoder();
    var latlng = new google.maps.LatLng(lat, lng);
    geocoder.geocode({ 'latLng': latlng }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            var city = null;
            var country = null;
            var state = null;
            if (results[1]) {
                //formatted address
                //find country name
                for (var i = 0; i < results[0].address_components.length; i++) {
                    for (var b = 0; b < results[0].address_components[i].types.length; b++) {
                        //there are different types that might hold a city admin_area_lvl_1 usually does in come cases looking for sublocality type will be more appropriate
                        if (results[0].address_components[i].types[b] == "locality") {
                            if (!city)
                                city = results[0].address_components[i];
                        }
                        if (results[0].address_components[i].types[b] == "country") {
                            if (!country)
                                country = results[0].address_components[i];
                        }
                        if (results[0].address_components[i].types[b] == "administrative_area_level_1") {
                            if (!state)
                                state = results[0].address_components[i];
                        }
                    }
                }
                if (city) {
                    var fin = city.short_name;
                    if (country.short_name == "US")
                        fin += ", " + state.short_name;
                    else
                        fin += ", " + country.short_name;
                    $("#city").val(fin);
                    return;
                }
            }
        }
        $("#city").val("undetermined");
    });
}