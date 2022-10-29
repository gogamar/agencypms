import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  connect() {
    flatpickr();
    console.log("Flatpickr connected!");
  }
}
