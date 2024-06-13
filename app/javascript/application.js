import "@hotwired/turbo-rails";
import Rails from "@rails/ujs";
import "bootstrap";
import "lightbox2";
import "@nathanvda/cocoon";

// Ensure these are loaded initially if required
import "./packs/slider-bg";
import "./packs/imagesloaded";

window.Rails = Rails;

// Import controllers (if using Stimulus, for example)
import "./controllers";
import "./add_jquery";

// Dynamically import the remaining scripts only when needed
document.addEventListener("turbo:load", async function () {
  const { initSlick } = await import("./components/init_slick");
  const { initSelect2 } = await import("./components/init_select2");
  const { initMagnificPopUp } = await import("./components/init_magnificPopUp");
  const { initFullCalendar } = await import("./plugins/full_calendar");
  const { initFlatpickr } = await import("./plugins/flatpickr");

  initSlick();
  initSelect2();
  initMagnificPopUp();
  initFullCalendar();
  initializeDatepickers(initFlatpickr);
});

document.addEventListener("turbo:frame-load", async function () {
  const { initSelect2 } = await import("./components/init_select2");
  const { initFlatpickr } = await import("./plugins/flatpickr");

  initSelect2();
  initializeDatepickers(initFlatpickr);
});

async function initializeDatepickers(initFlatpickr) {
  const datepickers = document.querySelectorAll(".datepicker");
  datepickers.forEach((datepicker) => {
    initFlatpickr(datepicker);
  });
}

// Import custom scripts that need to be loaded upfront
import "./packs/custom";
