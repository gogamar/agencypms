import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["start", "end"];

  connect() {
    flatpickr();
    console.log("Tasks controller connected");
    const unavailableTimes = JSON.parse(this.element.dataset.unavailable);

    const startPicker = this.startTarget.flatpickr({
      allowInput: true,
      enableTime: true,
      dateFormat: "Y-m-d H:i",
      minDate: "today",
      disable: unavailableTimes,
      onChange: function (selectedTimes, dateStr, instance) {
        endPicker.set("minDate", new Date(selectedTimes).fp_incr(1));
      },
    });

    const endPicker = this.endTarget.flatpickr({
      allowInput: true,
      enableTime: true,
      dateFormat: "Y-m-d H:i",
      minDate: "today",
      disable: unavailableTimes,
      onChange: function (selectedTimes, dateStr, instance) {
        startPicker.set("maxDate", dateStr);
      },
    });
  }
}
