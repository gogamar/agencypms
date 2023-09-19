import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["selectAll", "checkboxes"];

  toggleAll() {
    const isChecked = this.selectAllTarget.checked;
    const checkboxes = this.checkboxesTarget.querySelectorAll(
      "input[type='checkbox']"
    );

    checkboxes.forEach((checkbox) => {
      checkbox.checked = isChecked;
    });
  }
}
