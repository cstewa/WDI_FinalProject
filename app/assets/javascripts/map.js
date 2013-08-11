$(document).ready(function() {
  var map = L.mapbox.map('map_container', 'examples.map-uci7ul8p', { zoomControl: false })
      .setView([37.7, -122.4183], 12);

  var moveSlide;

  // moves the zoom controls the right side; defaults to 'topleft' if this line is left off.
  new L.Control.Zoom({ position: 'topright' }).addTo(map);

  geolocate();

  function geolocate() {
    if (navigator.geolocation) {
      console.log(navigator.geolocation);
      map.locate();
    };
  };

  map.on('locationfound', function(e) {
      map.fitBounds(e.bounds);

      // var map = L.mapbox.map('map_container', 'examples.map-uci7ul8p', { zoomControl: false })
      //     .setView([37.7, -122.4183], 12);

      map.setView([e.latlng.lat, e.latlng.lng], 12);

      map.markerLayer.setGeoJSON({
          type: "Feature",
          geometry: {
              type: "Point",
              coordinates: [e.latlng.lng, e.latlng.lat]
          },
          // properties: {
          //     'marker-color': '#000',
          //     'marker-symbol': 'star-stroked'
          // }
      });

  });


});


