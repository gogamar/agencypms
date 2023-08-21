import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
  };

  connect() {
    console.log("Map connected.");
    mapboxgl.accessToken = this.apiKeyValue;
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10",
    });

    this.map.addControl(
      new MapboxGeocoder({
        accessToken: mapboxgl.accessToken,
        mapboxgl: mapboxgl,
      })
    );

    this.map.addControl(new mapboxgl.NavigationControl());
    let map_markers = [];

    this.#addSmallMarkersToMap(map_markers);

    this.#fitMapToMarkers();

    this.map.on("zoomend", () => {
      const currentZoomLevel = this.map.getZoom();
      if (currentZoomLevel >= 10) {
        this.#priceMarkers(map_markers);
      } else if (currentZoomLevel < 10) {
        this.#smallMarkers(map_markers);
      }
    });
  }

  // # means it's a private method
  #priceMarkers(map_markers) {
    map_markers.forEach((marker) => {
      marker._element.classList.remove("smallmarker");
      marker._element.classList.add("marker");
    });
  }

  #smallMarkers(map_markers) {
    map_markers.forEach((marker) => {
      marker._element.classList.remove("marker");
      marker._element.classList.add("smallmarker");
    });
  }

  #addSmallMarkersToMap(map_markers) {
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window);
      const customMarker = document.createElement("div");
      customMarker.classList.add("smallmarker");
      customMarker.innerHTML = `<span>${marker.price}</span>`;
      customMarker.style.backgroundImage = `url('${marker.image_url}')`;
      customMarker.style.backgroundSize = "contain";
      customMarker.style.backgroundRepeat = "no-repeat";
      customMarker.style.width = "25px";
      customMarker.style.height = "25px";

      let new_marker = new mapboxgl.Marker(customMarker)
        .setLngLat([marker.lng, marker.lat])
        .setPopup(popup)
        .addTo(this.map);

      map_markers.push(new_marker);
    });
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    this.markersValue.forEach((marker) =>
      bounds.extend([marker.lng, marker.lat])
    );
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 });
  }
}
