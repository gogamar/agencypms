import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["printbutton"];

  spin() {
    const buttonName = this.printbuttonTarget.innerHTML;
    this.printbuttonTarget.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
    Preparant el pdf...`;
    this.printbuttonTarget.classList.add("disabled");
    fetch(this.printbuttonTarget.href).then((response) => {
      if (response.status === 200) {
        this.printbuttonTarget.innerHTML = `Obrint el pdf...`;
        setTimeout(() => {
          this.printbuttonTarget.innerHTML = buttonName;
          this.printbuttonTarget.classList.remove("disabled");
        }, 4000);
      }
    });
  }
}
