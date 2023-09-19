import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";
import { start } from "@popperjs/core";

export default class extends Controller {
  static targets = ["start", "end"];

  connect() {
    flatpickr();
    const unavailableDates = JSON.parse(this.element.dataset.unavailable);
    const defaultStart = this.element.dataset.defaultstart
      ? this.element.dataset.defaultstart
      : null;
    const defaultEnd = this.element.dataset.defaultend
      ? this.element.dataset.defaultend
      : null;

    let start = defaultStart ? new Date(defaultStart) : null;
    let end = defaultEnd ? new Date(defaultEnd) : null;

    const startPicker = this.startTarget.flatpickr({
      allowInput: true,
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      defaultDate: start,
      disable: unavailableDates,
      onChange: function (selectedDates, dateStr, instance) {
        checkoutPicker.set("minDate", new Date(selectedDates).fp_incr(1));
      },
    });

    const endPicker = this.endTarget.flatpickr({
      allowInput: true,
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      defaultDate: end || start.setDate(start.getDate() + 7),
      disable: unavailableDates,
      onChange: function (selectedDates, dateStr, instance) {
        startPicker.set("maxDate", dateStr);
      },
    });
  }
}