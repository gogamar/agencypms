import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "form",
    "filterName",
    "filterCheckin",
    "filterCheckout",
    "filterGuests",
    "filterLocation",
    "filterPb",
    "filterPt",
    "filterPf",
  ];
  static values = {
    url: String,
  };

  connect() {
    console.log("SearchPropertiesController connected");
  }

  addParams() {
    const mainPageUrl = new URL(window.location.href);
    const searchParams = new URLSearchParams(mainPageUrl.search);

    searchParams.delete("n");

    const filters = [
      {
        target: "FilterCheckinTarget",
        targetName: "filterCheckinTarget",
        param: "check_in",
      },
      {
        target: "FilterCheckoutTarget",
        targetName: "filterCheckoutTarget",
        param: "check_out",
      },
      {
        target: "FilterGuestsTarget",
        targetName: "filterGuestsTarget",
        param: "guests",
      },
      {
        target: "FilterLocationTarget",
        targetName: "filterLocationTarget",
        param: "location",
      },
    ];

    const checkedFilters = [
      {
        target: "FilterPbTarget",
        targetName: "filterPbTargets",
        param: "pb",
      },
      {
        target: "FilterPfTarget",
        targetName: "filterPfTargets",
        param: "pf[]",
      },
      {
        target: "FilterPtTarget",
        targetName: "filterPtTargets",
        param: "pt[]",
      },
    ];

    console.log(checkedFilters);

    filters.forEach((filter) => {
      if (this[`has${filter.target}`]) {
        const element = this[filter.targetName];
        const value = element.value.trim();
        searchParams.set(filter.param, value);
      }
    });

    checkedFilters.forEach((filter) => {
      if (this[`has${filter.target}`]) {
        const checkedElements = this[filter.targetName].filter(
          (el) => el.checked
        );
        const checkedValues = checkedElements.map((el) => el.value.trim());

        console.log("checked values:", checkedValues);

        // Remove all values for the filter.param
        searchParams.delete(filter.param);

        // Append only checked values
        checkedValues.forEach((value) => {
          searchParams.append(filter.param, value);
        });
      }
    });

    // if (this.hasFilterLocationTarget) {
    //   const filterLocation = this.filterLocationTarget.value;
    //   if (filterLocation.trim() !== "") {
    //     searchParams.set("location", filterLocation);
    //   }
    // }

    const paramString = searchParams.toString();
    console.log("this is paramString", paramString);

    if (paramString !== "") {
      history.pushState({}, "", `${mainPageUrl.pathname}?${paramString}`);
    } else {
      history.pushState({}, "", mainPageUrl.pathname);
    }
  }

  clearFilter(event) {
    event.preventDefault();
    const inputFields = event.currentTarget
      .closest(".clear-filter-js")
      .querySelectorAll("input");

    inputFields.forEach((input) => {
      input.checked = false;
    });
  }
}
