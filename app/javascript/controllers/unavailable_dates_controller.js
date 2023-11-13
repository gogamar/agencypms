import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["start", "end"];

  connect() {
    const unavailableDates = JSON.parse(this.element.dataset.unavailable);

    const defaultStart = this.startTarget.value
      ? new Date(this.startTarget.value)
      : new Date(this.element.dataset.defaultstart);

    const defaultEnd = this.endTarget.value
      ? new Date(this.endTarget.value)
      : new Date(defaultStart).fp_incr(7);

    const startOptions = {
      defaultDate: defaultStart,
      disable: unavailableDates,
      onChange: (selectedDates, dateStr, instance) => {
        this.endPicker.set("minDate", selectedDates[0].fp_incr(1));
      },
    };
    this.startPicker = initFlatpickr(this.startTarget, startOptions);

    const endOptions = {
      defaultDate: defaultEnd,
      disable: unavailableDates,
      onChange: (selectedDates, dateStr, instance) => {
        this.startPicker.set("maxDate", selectedDates[0]);
      },
    };
    this.endPicker = initFlatpickr(this.endTarget, endOptions);
  }

  updateEnd(event) {
    const nights = parseInt(event.target.value, 10);
    if (!isNaN(nights) && this.startTarget.value) {
      const newEndDate = new Date(this.startTarget.value);
      newEndDate.setDate(newEndDate.getDate() + nights);
      this.endPicker.setDate(newEndDate, true, "d/m/Y");
    }
  }
}
