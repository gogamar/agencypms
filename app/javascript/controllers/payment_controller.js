import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fields"];

  toggleFields(event) {
    if (event.target.value === "true") {
      this.showFields();
    } else {
      this.hideFields();
    }
  }

  showFields() {
    this.fieldsTarget.classList.remove("d-none");
  }

  hideFields() {
    this.clearFields();
    this.fieldsTarget.classList.add("d-none");
  }

  clearFields() {
    this.fieldsTarget.querySelectorAll("input").forEach((input) => {
      input.value = "";
    });
  }
}
