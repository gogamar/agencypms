import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["discount", "amount", "ratePrice"];

  connect() {
    this.amountTarget.value = parseFloat(this.amountTarget.value).toFixed(2);
  }

  calculateEarningAmount() {
    const discount = parseFloat(this.discountTarget.value);
    const ratePriceText = this.ratePriceTarget.textContent
      .replace(/[€.]/g, "")
      .replace(",", ".");
    const ratePrice = parseFloat(ratePriceText);
    const amount = ratePrice - ratePrice * (discount / 100);

    this.amountTarget.value = amount.toFixed(2);
  }

  discountValueChanged() {
    this.calculateEarningAmount();
  }
}
