import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["startdate"];

  connect() {
    flatpickr();
    console.log("Tasks controller connected");
    const unavailableTimes = JSON.parse(this.element.dataset.unavailable);

    const startdatePicker = this.startdateTarget.flatpickr({
      allowInput: true,
      enableTime: true,
      defaultDate: JSON.parse(this.element.dataset.default),
      // noCalendar: true,
      defaultHour: 12,
      defaultMinute: 0,
      altInput: true,
      altFormat: "H:i",
      minDate: "today",
      minTime: "08:00",
      maxTime: "20:00",
      disable: unavailableTimes,
    });

    // const starttimePicker = this.starttimeTarget.flatpickr({
    //   allowInput: true,
    //   enableTime: true,
    //   noCalendar: true,
    //   // dateFormat: "H:i",
    //   defaultHour: 12,
    //   defaultMinute: 0,
    //   altInput: true,
    //   altFormat: "H:i",
    //   minDate: "today",
    //   minTime: "08:00",
    //   maxTime: "20:00",
    //   disable: unavailableTimes,
    // });
  }
}
