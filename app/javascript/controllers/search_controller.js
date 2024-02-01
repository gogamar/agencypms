import { Controller } from "@hotwired/stimulus";
import { initFlatpickr } from "../plugins/flatpickr";

export default class extends Controller {
  static targets = [
    "checkin",
    "checkout",
    "numAdult",
    "vrentalId",
    "price",
    "ratePrice",
    "notAvailable",
    "bookNow",
    "couponPrice",
  ];

  connect() {
    const currentDate = new Date();
    const oneYearFromNow = new Date();
    oneYearFromNow.setFullYear(currentDate.getFullYear() + 1);

    const defaultEnableDates = [
      {
        from: currentDate,
        to: oneYearFromNow,
      },
    ];

    let availableCheckin = defaultEnableDates;

    if (this.element.dataset.availableCheckin) {
      availableCheckin = JSON.parse(this.element.dataset.availableCheckin);
    }

    let availableCheckout = defaultEnableDates;

    if (this.element.dataset.availableCheckout) {
      availableCheckout = JSON.parse(this.element.dataset.availableCheckout);
    }

    const checkinOptions = {
      minDate: "today",
      enable: availableCheckin,
    };
    this.checkinPicker = initFlatpickr(this.checkinTarget, checkinOptions);

    const checkoutOptions = {
      minDate: "today",
      enable: availableCheckout,
    };
    this.checkoutPicker = initFlatpickr(this.checkoutTarget, checkoutOptions);
  }

  async updateCheckout() {
    const checkIn = this.checkinTarget.value;
    const checkOut = this.checkoutTarget.value;
    const vrentalId = this.vrentalIdTarget.value;

    const params = new URLSearchParams({
      checkIn,
      vrentalId,
    });

    const url = `/get_checkout_dates?${params.toString()}`;

    try {
      const response = await fetch(url);

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const checkoutDates = await response.json();

      console.log("responseData checkoutDates", checkoutDates);

      if (checkoutDates) {
        this.checkoutPicker.set("enable", checkoutDates);

        if (!checkoutDates.includes(checkOut)) {
          this.checkoutPicker.setDate(checkoutDates[0]);
          this.checkoutPicker.jumpToDate(checkoutDates[0]);
        }
      }
    } catch (error) {
      console.error(error);
    }
    this.updatePrice();
  }

  async updatePrice() {
    const checkIn = this.checkinTarget.value;
    const checkOut = this.checkoutTarget.value;
    const numAdult = this.numAdultTarget.value;
    const vrentalId = this.vrentalIdTarget.value;
    const priceElement = this.priceTarget;
    const ratePriceElement = this.ratePriceTarget;
    const notAvailableElement = this.notAvailableTarget;
    const bookNowElement = this.bookNowTarget;
    const couponPriceDiv = this.couponPriceTarget;

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
          couponPriceDiv.classList.add("d-none");
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
