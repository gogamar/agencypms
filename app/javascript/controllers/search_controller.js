import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout", "numAdult", "vrentalId"];

  connect() {
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);

    const checkinOptions = {
      minDate: today,
      onChange: (selectedDates, dateStr, instance) => {
        const selectedDate = new Date(dateStr);
        const checkoutDate = new Date(selectedDate);
        checkoutDate.setDate(checkoutDate.getDate() + 1);
        this.checkoutPicker.set("minDate", checkoutDate);
        this.checkoutPicker.jumpToDate(checkoutDate);
      },
    };
    this.checkinPicker = initFlatpickr(this.checkinTarget, checkinOptions);

    const checkoutOptions = {
      minDate: tomorrow,
    };
    this.checkoutPicker = initFlatpickr(this.checkoutTarget, checkoutOptions);
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
      const notAvailableElement = document.getElementById(
        `${vrentalId}-not-available`
      );
      const bookNowElement = document.getElementById(`${vrentalId}-book-now`);

      if (priceElement) {
        if (typeof responseData.updatedPrice === "number") {
          notAvailableElement.classList.add("d-none");
          bookNowElement.classList.remove("d-none");
          priceElement.classList.remove("d-none");

          const updatedPriceFormatted = this.formatCurrency(
            responseData.updatedPrice
          );

          priceElement.textContent = updatedPriceFormatted;
        } else if (responseData.notAvailable) {
          priceElement.classList.add("d-none");
          notAvailableElement.classList.remove("d-none");
          bookNowElement.classList.add("d-none");
        }
      }

      if (ratePriceElement) {
        if (
          responseData.notAvailable ||
          typeof responseData.ratePrice !== "number"
        ) {
          ratePriceElement.classList.add("d-none");
        } else {
          ratePriceElement.classList.remove("d-none");
          const ratePriceFormatted = this.formatCurrency(
            responseData.ratePrice
          );

          if (typeof responseData.updatedPrice === "number") {
            const priceDifference =
              responseData.ratePrice - responseData.updatedPrice;

            if (priceDifference < 5) {
              ratePriceElement.classList.add("d-none");
            } else {
              ratePriceElement.textContent = ratePriceFormatted;
            }
          } else {
            ratePriceElement.textContent = ratePriceFormatted;
          }
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
