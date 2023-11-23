import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "pricePer",
    "discountIncluded",
    "rateMaster",
    "availabilityMaster",
    "dependantRate",
    "dependantAvailability",
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

  toggleRateMaster() {
    if (this.rateMasterTarget) {
      const rateMaster = this.rateMasterTarget.value;
      const dependantRate = this.dependantRateTarget;
      if (rateMaster === "false") {
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

  toggleAvailabilityMaster() {
    if (this.availabilityMasterTarget) {
      const availabilityMaster = this.availabilityMasterTarget.value;
      const dependantAvailability = this.dependantAvailabilityTarget;
      if (availabilityMaster) {
        dependantAvailability.classList.remove("d-none");
      } else {
        dependantAvailability.classList.add("d-none");
        dependantAvailability
          .querySelectorAll("input, select")
          .forEach((field) => {
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
      if (masterVrental) {
        rateOffset.classList.remove("d-none");
      } else {
        rateOffset.classList.add("d-none");
        rateOffset.querySelector("input").value = ""; // Reset the value
      }
    }
  }
}
