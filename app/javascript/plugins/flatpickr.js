// // catalan version:

// import flatpickr from "flatpickr";
// import "flatpickr/dist/l10n/cat.js";

// const initFlatpickr = () => {
//   flatpickr(".datepicker", {
//     altInput: true,
//     minDate: "today",
//     dateFormat: "j \\de F \\de Y",
//     locale: "cat",
//   });
// };

// export { initFlatpickr };

// instructions from kitt modified to include catalan:
import flatpickr from "flatpickr";
import { Catalan } from "flatpickr/dist/l10n/cat.js";
flatpickr.localize(Catalan);

const initFlatpickr = () => {
  flatpickr(".datepicker", {
    altInput: true,
    minDate: "today",
  });
};

export { initFlatpickr };
