import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["printbutton"];

  connect() {
    console.log("Spinner controller connected.");
    console.log(this.printbuttonTarget.href);
  }

  spin() {
    this.printbuttonTarget.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
    Preparant el pdf...`;
    this.printbuttonTarget.setAttribute("disabled", "");
    fetch(this.printbuttonTarget.href).then((response) => {
      if (response.status === 200) {
        this.printbuttonTarget.innerHTML = `Contracte en PDF`;
      }
    });
  }

  stopspinning() {
    // this.printbuttonTarget.innerHTML = `Contracte en PDF`;
    this.printbuttonTarget.innerHTML = `Contracte en PDF`;
  }
}
