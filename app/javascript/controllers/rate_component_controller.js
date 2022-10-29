import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout"];

  connect() {
    console.log("Rate component controller connected again!");

    const checkinPicker = this.checkinTarget.flatpickr({
      minDate: "today",
      disableMobile: true,
      // dateFormat: "m-d-Y",
      onChange: function (selectedDates, dateStr, instance) {
        checkoutPicker.set("minDate", dateStr);
      },
    });

    const checkoutPicker = this.checkoutTarget.flatpickr({
      minDate: "today",
      disableMobile: true,
      // dateFormat: "m-d-Y",
      onChange: function (selectedDates, dateStr, instance) {
        checkinPicker.set("maxDate", dateStr);
      },
    });

    // const checkoutPicker = flatpickr(this.checkoutTarget, {
    //   minDate: this.element.dataset.defaultCheckoutDate,
    // });

    // this.checkinTarget.addEventListener("changeDate", (e) => {
    //   const date = new Date(e.target.value);
    //   date.setDate(date.getDate() + 1);
    //   checkoutPicker.setOptions({
    //     minDate: date,
    //   });
    //   // this.updateNightlyTotal();
    // });

    // this.checkoutTarget.addEventListener("changeDate", (e) => {
    //   const date = new Date(e.target.value);
    //   date.setDate(date.getDate() - 1);
    //   checkinPicker.setOptions({
    //     maxDate: date,
    //   });
    //   // this.updateNightlyTotal();
    // });
  }
}
