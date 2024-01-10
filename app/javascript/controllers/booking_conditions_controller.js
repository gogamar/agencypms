import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "pricePer",
    "discountIncluded",
    "rateMaster",
    "availabilityMaster",
    "dependentRate",
    "dependentAvailability",
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
    }
  }

  toggleRateMaster() {
    if (this.rateMasterTarget) {
      const rateMaster = this.rateMasterTarget.value;
      const dependentRate = this.dependentRateTarget;
      if (rateMaster === "false") {
        dependentRate.classList.remove("d-none");
      } else {
        dependentRate.classList.add("d-none");
        dependentRate.querySelectorAll("input, select").forEach((field) => {
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
