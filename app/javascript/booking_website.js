import "./add_jquery";
import "./packs/custom";
import "./packs/rangeslider";
import { initSlick } from "./components/init_slick";
import { initMagnificPopUp } from "./components/init_magnificPopUp";

document.addEventListener("turbo:load", function () {
  initSlick();
  initMagnificPopUp();
});
