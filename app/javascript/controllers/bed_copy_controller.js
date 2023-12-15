import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["bedField", "bedCountField"];

  connect() {
    console.log("Hello, Stimulus!", this.element);
    this.updateBedFields();
  }

  updateBedFields() {
    const bedCount = parseInt(this.bedCountFieldTarget.value) || 0;
    const bedFields = this.bedFieldTargets;
    console.log(bedFields);

    // Ensure we have at least one "bed-field" div
    while (bedFields.length < bedCount) {
      const clonedBedField = bedFields[0].cloneNode(true);
      this.element.appendChild(clonedBedField);
    }

    // Remove excess "bed-field" divs
    while (bedFields.length > bedCount) {
      const lastBedField = bedFields[bedFields.length - 1];
      // We may need to remove the object by clicking on delete button
      lastBedField.querySelector("input").value = "";
      lastBedField.remove();
    }
  }
}
