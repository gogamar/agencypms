import "select2";

const initSelect2 = () => {
  $("#guests").val(null).trigger("change");

  $("#guests").select2({
    placeholder: $("#guests").data("placeholder"),
    allowClear: true,
  });

  $("#location").val(null).trigger("change");
  $("#location").select2({
    placeholder: $("#location").data("placeholder"),
    allowClear: true,
  });

  const url = new URL(window.location.href);
  const guestsParam = url.searchParams.get("guests");
  const locationParam = url.searchParams.get("location");

  if (guestsParam !== null) {
    $("#guests").val(guestsParam).trigger("change");
  }

  if (locationParam !== null) {
    $("#location").val(locationParam).trigger("change");
  }

  $("#type").select2({
    placeholder: $("#type").data("placeholder"),
    allowClear: true,
  });

  $("#bedrooms").select2({
    placeholder: $("#bedrooms").data("placeholder"),
    allowClear: true,
  });

  $("#bathrooms").select2({
    placeholder: $("#bathrooms").data("placeholder"),
    allowClear: true,
  });

  $("#maxprice").select2({
    placeholder: $("#maxprice").data("placeholder"),
    allowClear: true,
  });

  $("#minprice").select2({
    placeholder: $("#minprice").data("placeholder"),
    allowClear: true,
  });

  $("#shorty").select2({
    placeholder: "Show All",
    allowClear: true,
  });

  $("#select_vrental").select2({
    placeholder: $("#select_vrental").data("placeholder"),
    allowClear: true,
  });

  $("#sort_order")
    .select2({
      placeholder: $("#sort_order").data("placeholder"),
      allowClear: true,
    })
    .on("select2:select", function (e) {
      clearTimeout(this.timeout);
      this.timeout = setTimeout(() => {
        Rails.fire(this.closest("form"), "submit");
      }, 200);
    });

  $("#select_vrental-select2")
    .select2({
      placeholder: $("#select_vrental-select2").data("placeholder"),
      allowClear: true,
    })
    .on("select2:select", function (e) {
      const currentURL = window.location.pathname;
      const segments = currentURL.split("/");

      if (segments.length > 3) {
        const partial_path = "/" + segments[3];
        window.location.href = e.params.data.id + partial_path;
      } else {
        window.location.href = e.params.data.id;
      }
    });

  function updateOwner(selectedOwnerId) {
    const path = document.getElementById("owners").dataset.path;
    fetch(path, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content, // for Rails CSRF protection
      },
      body: JSON.stringify({
        vrental: {
          owner_id: selectedOwnerId,
        },
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log("Success:", data);
        if (data.owner_id === null) {
          showAddButton();
        }
      })
      .catch((error) => {
        console.error("There was an error updating the vrental:", error);
      });
  }

  function hideButtons() {
    const editOwnerButton = document.querySelector(".edit_owner-js");
    const addOwnerButton = document.querySelector(".add_owner-js");
    if (!addOwnerButton.classList.contains("d-none")) {
      addOwnerButton.classList.add("d-none");
    }
    if (!editOwnerButton.classList.contains("d-none")) {
      editOwnerButton.classList.add("d-none");
    }
  }

  function showAddButton() {
    const addOwnerButton = document.querySelector(".add_owner-js");
    if (addOwnerButton.classList.contains("d-none")) {
      addOwnerButton.classList.remove("d-none");
    }
  }

  $("#owners")
    .select2({
      placeholder: $("#owners").data("placeholder"),
      allowClear: true,
      debug: true,
    })
    .on("select2:select", function (e) {
      hideButtons();
      const selectedOwnerId = e.params.data.id;
      updateOwner(selectedOwnerId);
    })
    .on("select2:unselect", function (e) {
      hideButtons();
      $("#owners").val(null).trigger("change");
      updateOwner(null);
    });
};

export { initSelect2 };
