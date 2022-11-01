import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sidebutton", "dash", "bar", "coll"];

  connect() {
    console.log("Sidebar controller connected");
  }
  // Toggle the side navigation
  toggleit() {
    this.dashTarget.classList.toggle("sidebar-toggled");
    this.barTarget.classList.toggle("toggled");
    if (this.barTarget.classList.contains("toggled")) {
      this.barTarget.collapse("hide");
      this.collTarget.collapse("hide");
    }
  }

  // Close any open menu accordions when window is resized below 768px
  closeaccordions() {
    if (window.width() < 768) {
      this.barTarget.collapse("hide");
    }
    if (window.width() < 480 && !this.barTarget.classList.contains("toggled")) {
      this.dashTarget.classList.add("sidebar-toggled");
      this.barTarget.classList.add("toggled");
      this.barTarget.collapse("hide");
    }
  }
}
