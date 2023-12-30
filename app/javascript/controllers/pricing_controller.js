import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["master", "masterRate", "offsetInputs", "wDiscountInc"];

  connect() {
    this.toggleMasterField();
    this.toggleOffsetInputs();
    this.toggleWDiscountInc();
  }

  toggleMasterField() {
    const masterRateSelected = this.masterRateTarget.checked;
    this.masterTarget.classList.toggle("d-none", masterRateSelected);
  }

  toggleOffsetInputs() {
    const masterVrentalSelected = this.masterTarget.value;
    this.offsetInputsTarget.classList.toggle("d-none", !masterVrentalSelected);
  }

  toggleWDiscountInc() {
    const weeklyDiscountEntered = this.wDiscountTarget.value;
    this.wDiscountIncTarget.classList.toggle("d-none", !weeklyDiscountEntered);
  }
}
