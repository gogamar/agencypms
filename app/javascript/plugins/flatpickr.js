// instructions from kitt modified to include catalan:
import flatpickr from "flatpickr";
import { Catalan } from "flatpickr/dist/l10n/cat.js";
flatpickr.localize(Catalan);

const initFlatpickr = () => {
  flatpickr(".datepicker", {
    altInput: true,
    minDate: "today",
    dateFormat: "d/m/Y",
  });
};

export { initFlatpickr };
