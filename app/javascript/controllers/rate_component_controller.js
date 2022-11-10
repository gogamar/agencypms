import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout"];

  connect() {
    flatpickr();
    console.log("Rate component controller connected again!");
    const unavailableDates = JSON.parse(this.element.dataset.unavailable);

    const checkinPicker = this.checkinTarget.flatpickr({
      disable: unavailableDates,
      minDate: "today",
      onChange: function (selectedDates, dateStr, instance) {
        checkoutPicker.set("minDate", dateStr);
      },
    });

    const checkoutPicker = this.checkoutTarget.flatpickr({
      disable: unavailableDates,
      minDate: "today",
      onChange: function (selectedDates, dateStr, instance) {
        checkinPicker.set("maxDate", dateStr);
      },
    });
  }
}
