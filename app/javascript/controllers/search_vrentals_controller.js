import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "filterName", "filterStatus", "filterTown"];
  static values = {
    url: String,
  };

  search() {
    const filterName = this.filterNameTarget.value;
    const filterStatus = this.filterStatusTarget.value;
    const filterTown = this.filterTownTarget.value;

    // Construct a new URL with the parameters
    const searchParams = new URLSearchParams();
    if (filterName.trim() !== "") {
      searchParams.set("filter_name", filterName);
    }

    if (filterStatus.trim() !== "") {
      searchParams.set("filter_status", filterStatus);
    }

    if (filterTown.trim() !== "") {
      searchParams.set("filter_town", filterTown);
    }

    const paramString = searchParams.toString();

    if (paramString !== "") {
      history.pushState({}, "", `${this.urlValue}?${paramString}`);
    } else {
      history.pushState({}, "", this.urlValue);
    }

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      Rails.fire(this.formTarget, "submit");
    }, 200);
  }
}
