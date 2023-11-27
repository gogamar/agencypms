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
      minStart = availableDates[0];
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
        const selectedDate = new Date(dateStr);
        const checkoutDate = new Date(selectedDate);
        checkoutDate.setDate(checkoutDate.getDate() + 1);
        this.endPicker.set("minDate", checkoutDate);
        this.endPicker.jumpToDate(checkoutDate);
      },
    };
    this.startPicker = initFlatpickr(this.startTarget, startOptions);

    const minStartDate = new Date(minStart);

    minStartDate.setDate(minStartDate.getDate() + minStay);

    const endOptions = {
      minDate: minStartDate,
      enable: availableDates,
    };
    this.endPicker = initFlatpickr(this.endTarget, endOptions);
  }

  async updateRateData(event) {
    const selectedDate = event.target.value;
    const vrentalId = event.target.dataset.vrentalId;
    const path = `/get_rate_data?selected_date=${selectedDate}&vrental_id=${vrentalId}`;

    try {
      const response = await fetch(path, {
        headers: {
          Accept: "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const responseData = await response.json();
      const minStay = responseData.min_stay;
      const newMinEndDate = new Date(this.startPicker.selectedDates[0]);
      newMinEndDate.setDate(newMinEndDate.getDate() + parseInt(minStay));
      this.endPicker.set("minDate", newMinEndDate);
    } catch (error) {
      console.error(error);
    }
  }
}
