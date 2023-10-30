import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["show", "unhide"];

  password() {
    if (this.value.innerHTML === `<i class="fas fa-eye-slash fa-sm"></i>`) {
      this.value.innerHTML = `<i class="fas fa-eye fa-sm"></i>`;
      this.input.type = "text";
    } else if (this.value.innerHTML === `<i class="fas fa-eye fa-sm"></i>`) {
      this.value.innerHTML = `<i class="fas fa-eye-slash fa-sm"></i>`;
      this.input.type = "password";
    }
  }

  get value() {
    return this.showTarget;
  }
  get input() {
    return this.unhideTarget;
  }
}
