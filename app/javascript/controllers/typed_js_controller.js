import { Controller } from "@hotwired/stimulus";
import Typed from "typed.js";

export default class extends Controller {
  static values = { typedtext: Array };

  connect() {
    console.log(this.typedtextValue);
    new Typed(this.element, {
      strings: this.typedtextValue,
      loop: true,
      typeSpeed: 20,
      backSpeed: 20,
      startDelay: 100,
      backDelay: 1500,
    });
  }
}
