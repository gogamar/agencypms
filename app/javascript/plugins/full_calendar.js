import { Calendar } from "@fullcalendar/core";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";
import esLocale from "@fullcalendar/core/locales/es";
import frLocale from "@fullcalendar/core/locales/fr";
import enLocale from "@fullcalendar/core/locales/en-gb";
import caLocale from "@fullcalendar/core/locales/ca";

export function initFullCalendar() {
  const calendarEl = document.getElementById("calendar");
  const currentLocale = document.body.getAttribute("data-locale");
  if (calendarEl) {
    const bookingsOnCalendarPath = calendarEl.dataset.bookingsOnCalendarPath;
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin],
      locales: [esLocale, frLocale, enLocale, caLocale],
      initialView: "dayGridMonth",
      locale: currentLocale,
      displayEventTime: false,
      events: bookingsOnCalendarPath + ".json",
      contentHeight: 800,
      eventClick: function (info) {
        const eventId = info.event.id;
        const eventTitle = info.event.title;
        const eventFormPath = info.event.extendedProps.form_path;
        openEventDetails(eventId, eventTitle, eventFormPath);
      },
      eventDidMount: function (info) {
        const eventElement = info.el;
        const eventTopPosition = info.event.extendedProps.top_position;
        const eventHarnessElement = eventElement.parentElement;
        if (eventHarnessElement && eventTopPosition) {
          eventHarnessElement.classList.add(eventTopPosition);
        }
      },
    });

    calendar.render();
  }
}

const openEventDetails = (eventId, eventTitle, eventFormPath) => {
  const editOwnerBooking = new bootstrap.Modal(
    document.getElementById("ownerBooking")
  );
  editOwnerBooking.show();

  const modalTitle = document.querySelector("#ownerBooking .modal-title");
  modalTitle.innerHTML = eventTitle;
  const modalBody = document.querySelector("#ownerBooking .modal-body");
  modalBody.innerHTML = "";
  fetch(eventFormPath)
    .then((response) => response.text())
    .then((data) => {
      modalBody.innerHTML = data;
    })
    .catch((error) => {
      console.error("Error fetching data:", error);
    });

  const modalClose = document.querySelector("#ownerBooking .btn-close");
  modalClose.addEventListener("click", function () {
    editOwnerBooking.hide();
  });
};

// const setTopPosition = (eventElement, eventTopPosition) => {
//   const dayEvent = document.querySelector(".fc-daygrid-event-harness");
//   console.log(dayEvent);
//   // const dayEvents = document.querySelectorAll(".fc-daygrid-day-events");

//   // dayEvents.forEach((dayEvent) => {
//   //   const eventHarnesses = dayEvent.querySelectorAll(
//   //     ".fc-daygrid-event-harness"
//   //   );
//   //   for (let i = 0; i < Math.min(eventHarnesses.length, 2); i++) {
//   //     eventHarnesses[i].style.top = "0px";
//   //   }
//   // });
// };
