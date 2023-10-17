import "@hotwired/turbo-rails";
import Rails from "@rails/ujs";
import "./controllers";
import "bootstrap";
import "./add_jquery";
import "./packs/custom";
// import "./packs/imagesloaded";
// import "./packs/jquery.magnific-popup.min";
// import "./packs/lightbox";
// import "./packs/rangeslider";
// import "./packs/slick";
// import "./packs/slider-bg.min";
import { initSelect2 } from "./components/init_select2";
import { initFlatpickr } from "./plugins/flatpickr";

window.Rails = Rails;

document.addEventListener("turbo:load", function () {
  initSelect2();
  initFlatpickr();
});
