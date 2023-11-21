import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "pricePer",
    "discountIncluded",
    "masterRate",
    "dependantRate",
    "masterVrental",
    "rateOffset",
  ];

  toggleDiscountIncluded() {
    const pricePer = this.pricePerTarget.value;
    const discountIncluded = this.discountIncludedTarget;
    if (pricePer === "week") {
      discountIncluded.classList.remove("d-none");
    } else {
      discountIncluded.classList.add("d-none");
      discountIncluded.querySelector("select").value = ""; // Reset the value
    }
  }

  toggleMasterVrental() {
    if (this.masterRateTarget) {
      const masterRate = this.masterRateTarget.value;
      const dependantRate = this.dependantRateTarget;
      console.log("masterRate", masterRate);
      if (masterRate === "false") {
        dependantRate.classList.remove("d-none");
      } else {
        dependantRate.classList.add("d-none");
        dependantRate.querySelectorAll("input, select").forEach((field) => {
          if (
            field.type === "text" ||
            field.tagName.toLowerCase() === "select"
          ) {
            field.value = ""; // Reset the value
          }
        });
      }
    }
  }

  toggleRateOffset() {
    if (this.masterVrentalTarget) {
      const masterVrental = this.masterVrentalTarget.value;
      const rateOffset = this.rateOffsetTarget;
      console.log("masterVrental", masterVrental);
      if (masterVrental) {
        rateOffset.classList.remove("d-none");
      } else {
        rateOffset.classList.add("d-none");
        rateOffset.querySelector("input").value = ""; // Reset the value
      }
    }
  }
}
