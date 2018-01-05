package com.sequencing.weather.activity;

import android.Manifest;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.preference.PreferenceManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;

import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.sequencing.weather.R;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

public class LocationMapsActivity extends FragmentActivity implements OnMapReadyCallback, GoogleMap.OnMapClickListener, DialogInterface.OnClickListener {

    private double latitude = 0;
    private double longitude = 0;
    private GoogleMap mMap;
    private Marker marker;
    private String address = "";

    private static final String TAG = "MapsActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_location_maps);
        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
    }


    /**
     * Manipulates the map once available.
     * This callback is triggered when the map is ready to be used.
     * This is where we can add markers or lines, add listeners or move the camera. In this case,
     * we just add a marker near Sydney, Australia.
     * If Google Play services is not installed on the device, the user will be prompted to install
     * it inside the SupportMapFragment. This method will only be triggered once the user has
     * installed Google Play services and returned to the app.
     */
    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mMap.setMapType(GoogleMap.MAP_TYPE_HYBRID);
        mMap.getUiSettings().setMapToolbarEnabled(false);

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        mMap.setMyLocationEnabled(true);
        mMap.setOnMapClickListener(this);
    }

    @Override
    public void onMapClick(LatLng latLng) {
        String selectedCity = null;

        latitude = latLng.latitude;
        longitude = latLng.longitude;

        selectedCity = getCurrentCity(latitude, longitude);

        if( selectedCity == null ) {
            Toast.makeText(this, "Unable to detect a location, try again", Toast.LENGTH_SHORT).show();
            return;
        }

        address = selectedCity;

        //remove previously placed Marker
        if (marker != null) {
            marker.remove();
        }
        //place marker where user just clicked
        marker = mMap.addMarker(new MarkerOptions().position(latLng));

        Dialog mapDialog = createDialog(address);
        mapDialog.show();
    }

    private String getCurrentCity(double latitude, double longitude) {
        Geocoder gcd = new Geocoder(this, Locale.getDefault());
        List<Address> addresses = null;

        try {
            addresses = gcd.getFromLocation(latitude, longitude, 1);
        } catch (IOException e) {
            Log.w(TAG, "Unable to get user current address");
            return null;
        }

        if (addresses.size() == 0 || addresses.get(0).getLocality() == null)
            return null;

        String result = addresses.get(0).getAdminArea() != null ? addresses.get(0).getLocality() + ", " + addresses.get(0).getAdminArea() :
                addresses.get(0).getLocality() + ", " + addresses.get(0).getCountryName();

        return result;
    }

    private Dialog createDialog(String displayAddress) {
        AlertDialog.Builder adb = new AlertDialog.Builder(this);
        adb.setTitle("City selection");
        adb.setMessage("Use "  + displayAddress + " as the location for Weather My Way?");
        adb.setIcon(R.drawable.ic_location_on_black_24dp);
        adb.setPositiveButton("Yes", this);
        adb.setNegativeButton("Cancel", this);
        return adb.create();
    }

    @Override
    public void onClick(DialogInterface dialog, int which) {
        switch (which) {
            case Dialog.BUTTON_POSITIVE:
                LocationActivity locationActivity = new LocationActivity();
                locationActivity.updateLocation(this, address, latitude, longitude, null);
                Toast.makeText(getBaseContext(), "Location has been changed on " + address, Toast.LENGTH_SHORT).show();
                SharedPreferences SP = PreferenceManager.getDefaultSharedPreferences(getBaseContext());
                SP.edit().putBoolean("should_auto_detect", false).commit();
                finish();
                break;

            case Dialog.BUTTON_NEGATIVE:
                break;
        }
    }
}
