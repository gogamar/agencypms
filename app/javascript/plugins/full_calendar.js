import { Calendar } from "@fullcalendar/core";
import dayGridPlugin from "@fullcalendar/daygrid";
import interactionPlugin from "@fullcalendar/interaction";
import multiMonthPlugin from "@fullcalendar/multimonth";
import esLocale from "@fullcalendar/core/locales/es";
import frLocale from "@fullcalendar/core/locales/fr";
import enLocale from "@fullcalendar/core/locales/en-gb";
import caLocale from "@fullcalendar/core/locales/ca";

export function initFullCalendar() {
  const calendarEl = document.getElementById("calendar");
  const currentLocale = document.body.getAttribute("data-locale");
  if (calendarEl) {
    console.log("connected");
    const ownerBookingsPath = calendarEl.dataset.ownerBookingsPath;
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, interactionPlugin, multiMonthPlugin],
      locales: [esLocale, frLocale, enLocale, caLocale],
      initialView: "multiMonthFourMonth",
      locale: currentLocale,
      views: {
        multiMonthFourMonth: {
          type: "multiMonth",
          duration: { months: 4 },
        },
      },
      displayEventTime: false,
      events: ownerBookingsPath + ".json",
      contentHeight: 800,
      eventClick: function (info) {
        var eventId = info.event.id;
        var eventTitle = info.event.title;

        openEventDetails(eventId, eventTitle);
      },
    });

    calendar.render();
  }
}

const openEventDetails = (eventId, eventTitle) => {
  const editOwnerBooking = new bootstrap.Modal(
    document.getElementById("ownerBooking")
  );
  editOwnerBooking.show();
  document
    .getElementById("saveEventChanges")
    .addEventListener("click", function () {
      // Retrieve and update event data from modal fields
      var newTitle = document.getElementById("eventTitle").value;
      // Update other event properties as needed

      // Update the event in FullCalendar
      // You might need to pass more information like the event object, start date, end date, etc.
      // For example: updateEvent(eventId, newTitle, startDate, endDate);
      // Implement the updateEvent function accordingly

      // Close the modal
      editEventModal.style.display = "none";
    });

  // Handle the modal close button click
  document
    .getElementById("closeEventModal")
    .addEventListener("click", function () {
      // Close the modal without saving changes
      editEventModal.style.display = "none";
    });
};
