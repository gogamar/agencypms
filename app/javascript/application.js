import "@hotwired/turbo-rails";
import Rails from "@rails/ujs";
import "./controllers";
import "./add_jquery";
import "bootstrap";
import { initSlick } from "./components/init_slick";
import { initMagnificPopUp } from "./components/init_magnificPopUp";
import { initSelect2 } from "./components/init_select2";
import "lightbox2";
import "./packs/slider-bg";
import "./packs/imagesloaded";

import "./packs/custom";

import { initFlatpickr } from "./plugins/flatpickr";

window.Rails = Rails;

document.addEventListener("turbo:load", function () {
  initSlick();
  initMagnificPopUp();
  initSelect2();
  initFlatpickr();
});
