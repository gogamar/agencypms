import "@hotwired/turbo-rails";
import Rails from "@rails/ujs";
import "./controllers";
import "./add_jquery";
import "bootstrap";
import "lightbox2";
import "./packs/slider-bg";
import "./packs/imagesloaded";

import { initSlick } from "./components/init_slick";
import { initMagnificPopUp } from "./components/init_magnificPopUp";
import { initSelect2 } from "./components/init_select2";
import { initFlatpickr } from "./plugins/flatpickr";

window.Rails = Rails;

document.addEventListener("turbo:load", function () {
  initSlick();
  initSelect2();
  initMagnificPopUp();
  initFlatpickr();
});

document.addEventListener("turbo:frame-load", function () {
  initSelect2();
});

import "./packs/custom";
