import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["spinButton"];

  spin() {
    const textSpinning = this.spinButtonTarget.dataset.spinning;
    const textPending = this.spinButtonTarget.dataset.pending;
    const timeSpinning = parseInt(this.spinButtonTarget.dataset.timer, 10);
    const buttonName = this.spinButtonTarget.innerHTML;
    const path = this.spinButtonTarget.href;

    this.spinButtonTarget.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
    ${textSpinning}...`;
    this.spinButtonTarget.classList.add("disabled");

    fetch(this.spinButtonTarget.href).then((response) => {
      console.log("response status", response.status);
      if (response.status === 200) {
        this.spinButtonTarget.innerHTML = `${textPending}...`;
        setTimeout(() => {
          this.spinButtonTarget.innerHTML = buttonName;
          this.spinButtonTarget.classList.remove("disabled");
        }, timeSpinning);
      }
    });
  }
}
