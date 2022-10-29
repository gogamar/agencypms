import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout"];

  connect() {
    console.log("Rate component controller connected!");
    const unvailableDates = JSON.parse(this.element.dataset.unavailable);

    const checkinPicker = this.checkinTarget.flatpickr({
      defaultDate: this.element.dataset.defaultCheckinDate,
      disable: unvailableDates,
      minDate: "today",
      disableMobile: true,
      // dateFormat: "m-d-Y",
      onChange: function (selectedDates, dateStr, instance) {
        checkoutPicker.set("minDate", dateStr);
      },
    });

    const checkoutPicker = this.checkoutTarget.flatpickr({
      defaultDate: this.element.dataset.defaultCheckoutDate,
      disable: unvailableDates,
      minDate: "today",
      disableMobile: true,
      // dateFormat: "m-d-Y",
      onChange: function (selectedDates, dateStr, instance) {
        checkinPicker.set("maxDate", dateStr);
      },
    });
  }
}
