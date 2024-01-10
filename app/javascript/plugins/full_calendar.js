import { Calendar } from "@fullcalendar/core";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";
import esLocale from "@fullcalendar/core/locales/es";
import frLocale from "@fullcalendar/core/locales/fr";
import enLocale from "@fullcalendar/core/locales/en-gb";
import caLocale from "@fullcalendar/core/locales/ca";
import { initFlatpickr } from "./flatpickr";

export function initFullCalendar() {
  const calendarEl = document.getElementById("calendar");
  const currentLocale = document.body.getAttribute("data-locale");
  if (calendarEl) {
    const bookingsOnCalendarPath = calendarEl.dataset.bookingsOnCalendarPath;
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin],
      locales: [esLocale, frLocale, enLocale, caLocale],
      initialView: "dayGridMonth",
      editable: true,
      selectable: true,
      locale: currentLocale,
      displayEventTime: false,
      events: bookingsOnCalendarPath + ".json",
      contentHeight: 800,
      eventClick: function (info) {
        console.log(info.event);
        const eventTitle = info.event.title;
        const eventFormPath = info.event.extendedProps.form_path;
        updateOwnerBooking(eventTitle, eventFormPath);
      },
      eventDidMount: function (info) {
        const eventElement = info.el;
        const eventTopPosition = info.event.extendedProps.top_position;
        const eventHarnessElement = eventElement.parentElement;
        if (eventHarnessElement && eventTopPosition) {
          eventHarnessElement.classList.add(eventTopPosition);
        }
      },
      select: function (selectionInfo) {
        const startDate = selectionInfo.startStr;
        const endDate = selectionInfo.endStr;
        createOwnerBooking(startDate, endDate);
      },
    });

    calendar.render();
  }
}

const createOwnerBooking = (startDate, endDate) => {
  const newOwnerBooking = new bootstrap.Modal(
    document.getElementById("newOwnerBooking")
  );
  newOwnerBooking.show();

  const checkinDate = new Date(startDate);
  const checkoutDate = new Date(endDate);

  const modalNew = document.getElementById("newOwnerBooking");
  const checkinField = modalNew.querySelector("#owner_booking_checkin");
  const checkoutField = modalNew.querySelector("#owner_booking_checkout");

  const checkinOptions = {
    defaultDate: new Date(startDate),
  };
  const checkinPicker = initFlatpickr(checkinField, checkinOptions);

  const checkoutOptions = {
    defaultDate: new Date(endDate),
  };
  const checkoutPicker = initFlatpickr(checkoutField, checkoutOptions);

  const modalClose = modalNew.querySelector(".btn-close");
  modalClose.addEventListener("click", function () {
    newOwnerBooking.hide();
  });
};

const updateOwnerBooking = (eventTitle, eventFormPath) => {
  const editOwnerBooking = new bootstrap.Modal(
    document.getElementById("editOwnerBooking")
  );
  editOwnerBooking.show();

  const modalEdit = document.getElementById("editOwnerBooking");

  const modalTitle = modalEdit.querySelector(".modal-title");
  modalTitle.innerHTML = eventTitle;
  const modalBody = modalEdit.querySelector(".modal-body");

  modalBody.innerHTML = "";

  fetch(eventFormPath)
    .then((response) => response.text())
    .then((data) => {
      modalBody.innerHTML = data;
      const obpickers = modalEdit.querySelectorAll(".obpicker");
      obpickers.forEach((obpicker) => {
        initFlatpickr(obpicker);
      });
    })
    .catch((error) => {
      console.error("Error fetching data:", error);
    });

  const modalClose = modalEdit.querySelector(".btn-close");
  modalClose.addEventListener("click", function () {
    editOwnerBooking.hide();
  });
};
