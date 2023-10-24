import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["contractType", "commissionField", "fixedPriceFields"];

  connect() {
    this.toggleFields();
  }

  toggleFields() {
    const contractTypeValue = this.contractTypeTarget.value;

    if (contractTypeValue === "commission") {
      this.commissionFieldTarget.classList.remove("d-none");
      this.fixedPriceFieldsTarget.classList.add("d-none");
    } else if (contractTypeValue === "fixed_price") {
      this.commissionFieldTarget.classList.add("d-none");
      this.fixedPriceFieldsTarget.classList.remove("d-none");
    }
  }
}
