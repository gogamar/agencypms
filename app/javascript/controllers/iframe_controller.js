import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const iframe = document.getElementById("confirm-booking-js");
    if (!iframe) {
      console.error('The iframe with id "confirm-booking-js" was not found.');
      return;
    }

    const couponCode = this.element.dataset.coupon;
    if (iframe) {
      iframe.onload = function () {
        this.contentWindow.postMessage({ couponCode }, "*");
      };
    }

    function updateIframeHeight(height) {
      if (height) {
        const finalHeight = parseInt(height, 10) + 20;

        iframe.style.height = `${finalHeight}px`;
        iframe.style.overflow = "hidden";
      } else {
        height = iframe.contentWindow.document.body.scrollHeight;
      }
    }

    window.addEventListener(
      "message",
      function (event) {
        // Check origin if you want to restrict messages
        // if (event.origin !== 'http://example.com') return;
        if (event.data.frameHeight) {
          updateIframeHeight(event.data.frameHeight);
        }
        if (event.data.closeAlerts) {
          console.log("closing alerts...");
          const chargeAlerts = document.getElementById("charge-alerts-js");
          if (chargeAlerts) {
            chargeAlerts.classList.add("d-none");
          }
        }
      },
      false
    );

    window.addEventListener("resize", function () {
      updateIframeHeight();
    });

    // Call initially to set up the correct size
    updateIframeHeight();
  }
}
