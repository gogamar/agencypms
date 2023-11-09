import flatpickr from "flatpickr";
import { Catalan } from "flatpickr/dist/l10n/cat.js";
import { French } from "flatpickr/dist/l10n/fr.js";
import { Spanish } from "flatpickr/dist/l10n/es.js";

const getLocale = (currentLocale) => {
  switch (currentLocale) {
    case "ca":
      return Catalan;
    case "fr":
      return French;
    case "es":
      return Spanish;
    default:
      return null; // Flatpickr will use its default locale (English)
  }
};

const initFlatpickr = (element, options = {}) => {
  const currentLocale = document.body.getAttribute("data-locale");
  const locale = getLocale(currentLocale);

  // The flatpickr function call creates a new Flatpickr instance, which you should return
  return flatpickr(element, {
    allowInput: true,
    altInput: true,
    altFormat: "d/m/Y",
    dateFormat: "Y-m-d",
    disableMobile: true,
    locale: locale,
    ...options, // Merge the provided options
  });
};

export { initFlatpickr };
