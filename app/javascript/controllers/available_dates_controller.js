import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["start", "end"];

  connect() {
    console.log("Available dates controller connected");
    const availableDates = JSON.parse(this.element.dataset.available);
    console.log(availableDates);
    const minStart = this.element.dataset.minAdvance
      ? new Date(
          new Date().setDate(
            new Date().getDate() + parseInt(this.element.dataset.minAdvance)
          )
        )
      : new Date();

    const minStay = parseInt(this.element.dataset.minStay);

    const startOptions = {
      minDate: minStart,
      enable: availableDates,
      onChange: (selectedDates, dateStr, instance) => {
        this.endPicker.set("minDate", selectedDates[0].fp_incr(minStay));
      },
    };
    this.startPicker = initFlatpickr(this.startTarget, startOptions);

    const endOptions = {
      minDate: minStart.fp_incr(minStay),
      enable: availableDates,
      onChange: (selectedDates, dateStr, instance) => {
        this.startPicker.set("maxDate", selectedDates[0]);
      },
    };
    this.endPicker = initFlatpickr(this.endTarget, endOptions);
  }

  getRateAttributes(event) {
    const selectedDate = event.target.value;

    fetch(`/get_rate_attributes?selected_date=${selectedDate}`)
      .then((response) => response.json())
      .then((data) => {
        const minStay = data.min_stay;
        console.log(`min_stay: ${minStay}`);
        const newEndDate = new Date(this.startPicker.selectedDates[0]);
        newEndDate.setDate(startDate.getDate() + parseInt(minStay));
        this.endPicker.setDate(newEndDate, true, "d/m/Y");
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}