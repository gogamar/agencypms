import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["create", "select"];

  connect() {
    this.hideCreateCard();
    this.hideSelectCard();
  }

  showCreateCard() {
    this.clearSelectForm();
    this.createTarget.classList.remove("d-none");
    this.selectTarget.classList.add("d-none");
  }

  showSelectCard() {
    this.clearCreateFormFields();
    this.selectTarget.classList.remove("d-none");
    this.createTarget.classList.add("d-none");
  }

  hideCreateCard() {
    this.createTarget.classList.add("d-none");
  }

  hideSelectCard() {
    this.selectTarget.classList.add("d-none");
  }

  clearCreateFormFields() {
    const formInputs = this.createTarget.querySelector(".form-inputs");
    formInputs.querySelectorAll("input, select").forEach((field) => {
      field.value = "";
    });
  }

  clearSelectForm() {
    const selectInput = this.selectTarget.querySelector("select");
    if (selectInput) {
      $(selectInput).val(null).trigger("change.select2"); // Clear Select2 selections
    }
  }

  clearAllForms() {
    this.clearCreateFormFields();
    this.clearSelectForm();
  }
}
