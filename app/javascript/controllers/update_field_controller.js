import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["vrentalName", "propKey"];

  connect() {
    this.updatePropKey();
  }

  updatePropKey() {
    const name = this.vrentalNameTarget.value;
    const propKey =
      name.replace(/[-.'\s]/g, "").toLowerCase() + "2022987123654";
    this.propKeyTarget.value = propKey;
  }
}
