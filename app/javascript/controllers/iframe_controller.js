import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const iframe = document.getElementById("confirm-booking-js");
    if (iframe) {
      const iframeDocument =
        iframe.contentDocument || iframe.contentWindow.document;
      const discountPhrase = iframeDocument.querySelector(
        ".inputdiscountphrase"
      );
      if (discountPhrase) {
        const couponCode = document
          .getElementById("coupon-code")
          .getAttribute("data-coupon");
        if (couponCode) {
          discountPhrase.value = couponCode;
        }
      }
    } else {
      console.error('The iframe with id "confirm-booking-js" was not found.');
    }

    function updateIframeHeight(height) {
      const iframe = document.getElementById("confirm-booking-js");
      if (!iframe) {
        console.error('The iframe with id "confirm-booking-js" was not found.');
        return;
      }

      // Determine base height depending on screen width
      const baseHeight = window.innerWidth < 768 ? 1600 : 1000;
      // Use the height from the message event if available, otherwise use baseHeight
      const finalHeight = height ? parseInt(height, 10) + 20 : baseHeight;

      // Set the height and overflow properties of the iframe
      iframe.style.height = `${finalHeight}px`;
      iframe.style.overflow = "hidden";
    }

    // Event listener for receiving message from iframe
    window.addEventListener(
      "message",
      function (event) {
        // Check origin if you want to restrict messages
        // if (event.origin !== 'http://example.com') return;

        // If the event data contains frameHeight, update the iframe height
        if (event.data.frameHeight) {
          updateIframeHeight(event.data.frameHeight); // Update the height based on the message
        }
      },
      false
    );

    // Event listener for window resize
    window.addEventListener("resize", function () {
      // Update the height based on the current window width
      updateIframeHeight();
    });

    // Call initially to set up the correct size
    updateIframeHeight();
  }
}
