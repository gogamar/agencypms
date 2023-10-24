import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";

export default class extends Controller {
  static values = { apiKey: String };

  static targets = ["address"];

  connect() {
    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: "country,region,place,postcode,locality,neighborhood,address",
    });
    this.geocoder.addTo(this.element);

    this.geocoder.on("result", (event) => this.#setInputValues(event.result));
    this.geocoder.on("clear", () => this.#clearInputValues());
  }

  #setInputValues(result) {
    this.addressTarget.value = result["place_name"];
    document.querySelector('input[name="vrental[latitude]"]').value =
      result["center"][1]; // Latitude is at index 1
    document.querySelector('input[name="vrental[longitude]"]').value =
      result["center"][0]; // Longitude is at index 0
  }

  #clearInputValues() {
    this.addressTarget.value = "";
    document.querySelector('input[name="vrental[latitude]"]').value = "";
    document.querySelector('input[name="vrental[longitude]"]').value = "";
  }

  disconnect() {
    this.geocoder.onRemove();
  }
}
