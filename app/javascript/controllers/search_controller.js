import { Controller } from "@hotwired/stimulus";
import { initFlatpickr as flatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout", "numAdult", "vrentalId"];

  connect() {
    console.log("Search controller.");
    flatpickr();
    // const today = new Date();
    // const checkinDate = new Date(today.setDate(today.getDate() + 1));

    const checkinPicker = this.checkinTarget.flatpickr({
      allowInput: true,
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      minDate: new Date(),
      onChange: function (selectedDates, dateStr, instance) {
        checkoutPicker.set("minDate", new Date(selectedDates).fp_incr(1));
      },
    });

    const checkoutPicker = this.checkoutTarget.flatpickr({
      allowInput: true,
      altInput: true,
      altFormat: "d/m/Y",
      dateFormat: "Y-m-d",
      // defaultDate: checkinDate.setDate(checkinDate.getDate() + 7),
      onChange: function (selectedDates, dateStr, instance) {
        checkinPicker.set("maxDate", dateStr);
      },
    });
  }

  async updatePrice() {
    const checkIn = this.checkinTarget.value;
    const checkOut = this.checkoutTarget.value;
    const numAdult = this.numAdultTarget.value;
    const vrentalId = this.vrentalIdTarget.value;

    const params = new URLSearchParams({
      checkIn,
      checkOut,
      numAdult,
      vrentalId,
    });

    const url = `/get_availability?${params.toString()}`;

    console.log(url);

    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const responseData = await response.json();
      const priceElement = document.getElementById(`${vrentalId}-price`);
      const ratePriceElement = document.getElementById(
        `${vrentalId}-rate-price`
      );

      if (priceElement && ratePriceElement) {
        if (
          typeof responseData.updatedPrice === "number" &&
          typeof responseData.ratePrice === "number"
        ) {
          const priceDifference =
            responseData.ratePrice - responseData.updatedPrice;
          const updatedPriceFormatted = this.formatCurrency(
            responseData.updatedPrice
          );
          const ratePriceFormatted = this.formatCurrency(
            responseData.ratePrice
          );

          if (priceDifference < 5) {
            ratePriceElement.classList.add("d-none");
          } else {
            ratePriceElement.classList.remove("d-none");
          }

          priceElement.textContent = updatedPriceFormatted;
          ratePriceElement.textContent = ratePriceFormatted;
        } else if (responseData.roomsavail) {
          ratePriceElement.classList.add("d-none");
          priceElement.textContent = responseData.roomsavail;
        }
      }
    } catch (error) {
      console.error(error);
    }
  }

  formatCurrency(value) {
    const formattedValue = new Intl.NumberFormat("ca-ES", {
      style: "currency",
      currency: "EUR",
      currencyDisplay: "symbol",
      minimumFractionDigits: 2,
    }).format(value);

    return formattedValue;
  }
}
