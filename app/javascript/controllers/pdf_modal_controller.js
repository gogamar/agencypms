import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modalBody"];

  loadModal(event) {
    event.preventDefault();

    console.log("Trying to open the modal");

    // Get parameters from data attributes
    const cleaningCompanyId = event.currentTarget.dataset.cleaningCompanyId;
    const toCleaningDate = event.currentTarget.dataset.toCleaningDate;

    const baseUrl = event.currentTarget.dataset.baseUrl;

    const queryParams = new URLSearchParams({
      cleaning_company_id: cleaningCompanyId,
      to_cleaning_date: toCleaningDate,
      format: "pdf",
    }).toString();

    const url = `${baseUrl}?${queryParams}`;
    const iframe = this.modalBodyTarget.querySelector("iframe");

    console.log("iframe", iframe);

    if (iframe) {
      iframe.src = url;
    } else {
      console.warn("iframe not found in modalBody");
    }
  }
}
