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

  calculateDiscount() {
    const amountInput = parseFloat(this.amountTarget.value);
    const ratePriceText = this.ratePriceTarget.textContent
      .replace(/[€.]/g, "")
      .replace(",", ".");
    const ratePrice = parseFloat(ratePriceText);
    let discount;

    if (isNaN(amountInput)) {
      discount = 0;
    } else {
      discount = 1 - amountInput / ratePrice;
    }
    this.discountTarget.value = discount <= 0 ? "" : discount;
  }

  discountValueChanged() {
    this.calculateEarningAmount();
  }

  amountValueChanged() {
    this.calculateDiscount();
  }
}
