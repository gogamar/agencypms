import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout"];

  connect() {
    console.log("Flatpickr controller connected.");
    flatpickr();
    // const today = new Date();
    // const checkinDate = new Date(today.setDate(today.getDate() + 1));

    const checkinPicker = this.checkinTarget.flatpickr({
      allowInput: true,
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      minDate: new Date(),
      onChange: function (selectedDates, dateStr, instance) {
        checkoutPicker.set("minDate", new Date(selectedDates).fp_incr(1));
      },
    });

    const checkoutPicker = this.checkoutTarget.flatpickr({
      allowInput: true,
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      // defaultDate: checkinDate.setDate(checkinDate.getDate() + 7),
      onChange: function (selectedDates, dateStr, instance) {
        checkinPicker.set("maxDate", dateStr);
      },
    });
  }
}
