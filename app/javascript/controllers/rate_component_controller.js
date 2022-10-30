import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout"];

  connect() {
    console.log("Rate component controller connected default date activated!");
    const unvailableDates = JSON.parse(this.element.dataset.unavailable);

    const checkinPicker = this.checkinTarget.flatpickr({
      altInput: true,
      altFormat: "D, d/m/y",
      // defaultDate: this.element.dataset.defaultCheckinDate,
      disable: unvailableDates,
      minDate: "today",
      disableMobile: true,
      onChange: function (selectedDates, dateStr, instance) {
        checkoutPicker.set("minDate", dateStr);
      },
    });

    const checkoutPicker = this.checkoutTarget.flatpickr({
      altInput: true,
      altFormat: "D, d/m/y",
      // defaultDate: this.element.dataset.defaultCheckoutDate, // when activated, on change doesn't change the month on checkout
      disable: unvailableDates,
      minDate: "today",
      disableMobile: true,
      onChange: function (selectedDates, dateStr, instance) {
        checkinPicker.set("maxDate", dateStr);
      },
    });
  }
}
