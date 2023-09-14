import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["discount", "amount", "ratePrice"];

  calculateEarningAmount() {
    const discountInput = this.discountTarget.value;
    const ratePriceText = this.ratePriceTarget.textContent
      .replace(/[€.]/g, "")
      .replace(",", ".");
    const ratePrice = parseFloat(ratePriceText);
    let discount;
    let amount;

    if (discountInput == undefined || discountInput == "") {
      amount = ratePrice;
    } else {
      discount = parseFloat(discountInput);
      amount = ratePrice - ratePrice * discount;
    }
    this.amountTarget.value = amount.toFixed(2);
  }

  discountValueChanged() {
    this.calculateEarningAmount();
  }
}
