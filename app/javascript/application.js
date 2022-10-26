// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./controllers";
import "bootstrap";

// flatpickr instructions from kitt

import { initFlatpickr } from "./plugins/flatpickr";

initFlatpickr();

document.addEventListener("turbo:load", () => {
  initFlatpickr();
});

// testing if turbolinks is uninstalled and turbo installed

// $(document).on("turbolinks:load", () => {
//   console.log("turbolinks!");
// });
// $(document).on("turbo:load", () => {
//   console.log("turbo!");
// });
