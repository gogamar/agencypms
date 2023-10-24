import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "filterName", "filterStatus"];
  static values = {
    url: String,
  };

  search() {
    const filterName = this.filterNameTarget.value;
    const filterStatus = this.filterStatusTarget.value;

    // Construct a new URL with the parameters
    const searchParams = new URLSearchParams();
    if (filterName.trim() !== "") {
      searchParams.set("filter_name", filterName);
    }

    if (filterStatus.trim() !== "") {
      searchParams.set("filter_status", filterStatus);
    }

    const paramString = searchParams.toString();
    console.log("paramString is?", paramString);
    console.log("this.urlValue is?", this.urlValue);

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
