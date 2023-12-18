import "@hotwired/turbo-rails";
import Rails from "@rails/ujs";
import "./controllers";
import "./add_jquery";
import "bootstrap";
import "lightbox2";
import "./packs/slider-bg";
import "./packs/imagesloaded";
import "@nathanvda/cocoon";

import { initSlick } from "./components/init_slick";
import { initMagnificPopUp } from "./components/init_magnificPopUp";
import { initSelect2 } from "./components/init_select2";
import { initFlatpickr } from "./plugins/flatpickr";
import { initFullCalendar } from "./plugins/full_calendar";

window.Rails = Rails;

document.addEventListener("turbo:load", function () {
  initSlick();
  initSelect2();
  initMagnificPopUp();
  initFullCalendar();
  const datepickers = document.querySelectorAll(".datepicker");
  datepickers.forEach((datepicker) => {
    initFlatpickr(datepicker);
  });
});

document.addEventListener("turbo:frame-load", function () {
  initSelect2();
});

import "./packs/custom";
