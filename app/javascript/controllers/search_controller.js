import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = ["checkin", "checkout", "numAdult", "vrentalId"];

  connect() {
    const todayPlusAdvance = this.element.dataset.minAdvance
      ? new Date(
          new Date().setDate(
            new Date().getDate() + parseInt(this.element.dataset.minAdvance)
          )
        )
      : new Date();

    let minStart = new Date();
    let availableDates = [];
    if (this.element.dataset.available) {
      availableDates = JSON.parse(this.element.dataset.available);
      if (availableDates.length > 0) {
        minStart = new Date(availableDates[0]);
      } else {
        minStart = todayPlusAdvance;
      }
    }

    let minStay = 1;
    if (this.element.dataset.minStay) {
      const minStayValue = parseInt(this.element.dataset.minStay);
      if (!isNaN(minStayValue)) {
        minStay = minStayValue;
      }
    }

    const checkinOptions = {
      minDate: minStart,
      enable: availableDates,
      onChange: (selectedDates, dateStr, instance) => {
        const selectedDate = new Date(dateStr);
        const checkoutDate = new Date(selectedDate);
        checkoutDate.setDate(checkoutDate.getDate() + 1);
        this.checkoutPicker.set("minDate", checkoutDate);
        this.checkoutPicker.jumpToDate(checkoutDate);
      },
    };
    this.checkinPicker = initFlatpickr(this.checkinTarget, checkinOptions);

    const minStartDate = new Date(minStart);
    minStartDate.setDate(minStartDate.getDate() + minStay);

    const checkoutOptions = {
      minDate: minStartDate,
      enable: availableDates,
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
      console.log(responseData);
      const priceElement = document.getElementById(`${vrentalId}-price`);
      const ratePriceElement = document.getElementById(
        `${vrentalId}-rate-price`
      );
      const notAvailableElement = document.getElementById(
        `${vrentalId}-not-available`
      );
      const bookNowElement = document.getElementById(`${vrentalId}-book-now`);
      const couponPriceDiv = document.getElementById(
        `${vrentalId}-coupon-price`
      );

      if (priceElement) {
        if (
          responseData.updatedPrice &&
          typeof responseData.updatedPrice === "number"
        ) {
          notAvailableElement.classList.add("d-none");
          bookNowElement.classList.remove("d-none");
          priceElement.classList.remove("d-none");

          const updatedPriceFormatted = this.formatCurrency(
            responseData.updatedPrice
          );
          priceElement.textContent = updatedPriceFormatted;

          if (couponPriceDiv) {
            if (
              responseData.couponPrice &&
              typeof responseData.couponPrice === "number"
            ) {
              if (couponPriceDiv.classList.contains("d-none")) {
                couponPriceDiv.classList.remove("d-none");
              }
              const couponPriceFormatted = this.formatCurrency(
                responseData.couponPrice
              );
              couponPriceDiv.querySelector(".coupon-price-js").textContent =
                couponPriceFormatted;
            } else {
              if (!couponPriceDiv.classList.contains("d-none")) {
                couponPriceDiv.classList.add("d-none");
              }
            }
          }
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
      this.updateRateData();
    } catch (error) {
      console.error(error);
    }
  }

  async updateRateData(event) {
    const selectedDate = event.target.value;
    const vrentalId = event.target.dataset.vrentalId;
    const path = `/get_rate_data?selected_date=${selectedDate}&vrental_id=${vrentalId}`;

    try {
      const response = await fetch(path, {
        headers: {
          Accept: "application/json",
        },
      });

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const responseData = await response.json();
      const updatedMinStay = responseData.min_stay;
      const newMinEndDate = new Date(this.checkinPicker.selectedDates[0]);
      newMinEndDate.setDate(newMinEndDate.getDate() + parseInt(updatedMinStay));
      this.checkoutPicker.set("minDate", newMinEndDate);
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
