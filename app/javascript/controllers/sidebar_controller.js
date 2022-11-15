import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["topbartoggler", "dash", "bar", "sidebartoggler", "coll"];

  connect() {
    console.log("Sidebar controller connected.");
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

  togglesidebar() {
    this.barTarget.classList.toggle("toggled");
  }
}
