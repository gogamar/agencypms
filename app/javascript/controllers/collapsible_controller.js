import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.checkAndShowCollapsibles();
  }

  checkAndShowCollapsibles() {
    const collapsibles = this.element.querySelectorAll(".collapse");

    collapsibles.forEach((collapsible) => {
      const links = collapsible.querySelectorAll("li");

      for (let i = 0; i < links.length; i++) {
        if (links[i].classList.contains("active")) {
          collapsible.classList.add("show");
          break;
        }
      }
    });
  }
}
