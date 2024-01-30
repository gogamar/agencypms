import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["start", "end"];

  connect() {
    const minDate = new Date(this.element.dataset.min);
    const maxDate = new Date(this.element.dataset.max);

    const minStart = minDate || new Date();
    const minEnd = new Date(minStart);
    minEnd.setDate(minEnd.getDate() + 1);
    const maxEnd = maxDate;

    const startOptions = {
      minDate: minStart,
      onChange: (selectedDates, dateStr, instance) => {
        const selectedDate = new Date(dateStr);
        const endDate = new Date(selectedDate);
        endDate.setDate(endDate.getDate() + 1);
        this.endPicker.set("minDate", endDate);
        this.endPicker.jumpToDate(endDate);
      },
    };
    this.startPicker = initFlatpickr(this.startTarget, startOptions);

    const endOptions = {
      minDate: minEnd,
      maxDate: maxEnd,
      onChange: (selectedDates, dateStr, instance) => {
        this.startPicker.set("maxDate", selectedDates[0]);
      },
    };
    this.endPicker = initFlatpickr(this.endTarget, endOptions);
  }
}
