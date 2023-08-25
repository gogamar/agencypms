import "@hotwired/turbo-rails";
import "./controllers";
import "bootstrap";
import "./add_jquery";
// import "./packs/custom";
import { initSelect2 } from "./components/init_select2";
// import { initSlick } from "./components/init_slick";
// import { initMagnificPopUp } from "./components/init_magnificPopUp";
import { initFlatpickr } from "./plugins/flatpickr";

document.addEventListener("turbo:load", function () {
  initSelect2();
  // initSlick();
  // initMagnificPopUp();
  initFlatpickr();
});
