import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout"];

  connect() {
    console.log("Hello from Search Bar Controller");

    let availableDates = [];
    if (this.element.dataset.available) {
      availableDates = JSON.parse(this.element.dataset.available);
    }

    const checkinOptions = {
      minDate: new Date(),
      enable: availableDates,
      onChange: (selectedDates, dateStr, instance) => {
        const selectedDate = new Date(dateStr);
        const checkoutDate = new Date(selectedDate);
        checkoutDate.setDate(checkoutDate.getDate() + 1);
        this.checkoutPicker.set("minDate", checkoutDate);
        this.checkoutPicker.jumpToDate(checkoutDate);
      },
    };
    this.checkinPicker = initFlatpickr(this.checkinTarget, checkinOptions);

    const checkoutDate = new Date();
    checkoutDate.setDate(checkoutDate.getDate() + 1);

    const checkoutOptions = {
      minDate: checkoutDate,
      enable: availableDates,
    };
    this.checkoutPicker = initFlatpickr(this.checkoutTarget, checkoutOptions);
  }
}
