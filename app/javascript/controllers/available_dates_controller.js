import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["start", "end"];

  connect() {
    const availableDates = JSON.parse(this.element.dataset.available);
    const todayPlusAdvance = this.element.dataset.minAdvance
      ? new Date(
          new Date().setDate(
            new Date().getDate() + parseInt(this.element.dataset.minAdvance)
          )
        )
      : new Date();
    let minStart;

    if (availableDates.length > 0) {
      minStart = availableDates[0]["from"];
    } else {
      minStart = todayPlusAdvance;
    }

    let minStay = 1;
    if (this.element.dataset.minStay) {
      const minStayValue = parseInt(this.element.dataset.minStay);
      if (!isNaN(minStayValue)) {
        minStay = minStayValue;
      }
    }

    const startOptions = {
      minDate: minStart,
      enable: availableDates,
      onChange: (selectedDates, dateStr, instance) => {
        // this.endPicker.set("minDate", selectedDates[0].fp_incr(minStay));
        const selectedDate = selectedDates[0];

        if (selectedDate instanceof Date && !isNaN(minStay)) {
          const newDate = new Date(selectedDate);
          newDate.setDate(newDate.getDate() + minStay);

          this.endPicker.set("minDate", newDate);
        }
      },
    };
    this.startPicker = initFlatpickr(this.startTarget, startOptions);

    const minStartDate = new Date(minStart);
    minStartDate.setDate(minStartDate.getDate() + minStay);

    const endOptions = {
      minDate: minStartDate,
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
        const newEndDate = new Date(this.startPicker.selectedDates[0]);
        newEndDate.setDate(startDate.getDate() + parseInt(minStay));
        this.endPicker.setDate(newEndDate, true, "d/m/Y");
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
}
