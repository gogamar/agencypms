import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = [
    "start",
    "end",
    "restriction",
    "hint",
    "maxStay",
    "priceWeek",
    "priceNight",
  ];

  connect() {
    const unavailableDates = JSON.parse(this.element.dataset.unavailable);

    const defaultStart = this.startTarget.value
      ? new Date(this.startTarget.value)
      : new Date(this.element.dataset.defaultstart);

    const defaultEnd = this.endTarget.value
      ? new Date(this.endTarget.value)
      : new Date(defaultStart).fp_incr(7);

    const startOptions = {
      defaultDate: defaultStart,
      disable: unavailableDates,
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
      defaultDate: defaultEnd,
      minDate: defaultStart.setDate(defaultStart.getDate() + 1),
      disable: unavailableDates,
      onChange: (selectedDates, dateStr, instance) => {
        this.startPicker.set("maxDate", selectedDates[0]);
      },
    };
    this.endPicker = initFlatpickr(this.endTarget, endOptions);
  }

  updateEnd(event) {
    const nights = parseInt(event.target.value, 10);
    if (!isNaN(nights) && this.startTarget.value) {
      const newEndDate = new Date(this.startTarget.value);
      newEndDate.setDate(newEndDate.getDate() + nights);
      this.endPicker.setDate(newEndDate, true, "d/m/Y");
    }
  }

  showGapFillFields() {
    const restrictionValue = this.restrictionTarget.value;
    if (restrictionValue === "gap_fill") {
      this.enableDates();
      this.hintTarget.classList.remove("d-none");
      this.maxStayTarget.classList.remove("d-none");
      if (this.priceWeekTarget) {
        this.priceWeekTarget.classList.add("d-none");
        this.priceWeekTarget.querySelector("input").removeAttribute("required");
        this.priceNightTarget.classList.remove("d-none");
        this.priceNightTarget
          .querySelector("input")
          .setAttribute("required", "required");
      }
    } else {
      this.disableDates();
      this.hintTarget.classList.add("d-none");
      this.maxStayTarget.classList.add("d-none");
      this.maxStayTarget.querySelector("input").value = 365;
      if (this.priceWeekTarget) {
        this.priceWeekTarget.classList.remove("d-none");
        this.priceWeekTarget
          .querySelector("input")
          .setAttribute("required", "required");
        this.priceNightTarget.classList.add("d-none");
        this.priceNightTarget
          .querySelector("input")
          .removeAttribute("required");
      }
    }
  }

  enableDates() {
    this.startPicker.set("disable", []);
    this.endPicker.set("disable", []);
  }

  disableDates() {
    const unavailableDates = JSON.parse(this.element.dataset.unavailable);
    this.startPicker.set("disable", unavailableDates);
    this.endPicker.set("disable", unavailableDates);
  }
}
