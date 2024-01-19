import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["pdfViewer", "pdfSpinner"];

  connect() {
    this.pdfViewerTarget.addEventListener("load", () => {
      this.pdfSpinnerTarget.classList.remove("d-flex");
      this.pdfSpinnerTarget.classList.add("d-none");
    });

    this.pdfViewerTarget.addEventListener("beforeunload", () => {
      this.pdfSpinnerTarget.classList.remove("d-none");
    });
  }
}
