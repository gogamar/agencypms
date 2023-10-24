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

  $("#select-vrental").select2({
    placeholder: "Seleccionar immoble",
    allowClear: true,
  });

  $("#select-rate-plan").select2({
    placeholder: "Seleccionar plà de tarifa",
    allowClear: true,
  });

  $("#shorty").select2({
    placeholder: "Show All",
    allowClear: true,
  });

  $("#select_vrental-select2")
    .select2({
      placeholder: "Seleccionar immoble",
      allowClear: true,
      theme: "bootstrap-5",
    })
    .on("select2:select", function (e) {
      const currentURL = window.location.pathname;
      const pattern = /\/(\d+)\/(.*)/;
      const match = currentURL.match(pattern);

      if (match && match.length > 2) {
        window.location.href = e.params.data.id + "/" + match[2];
      } else {
        window.location.href = e.params.data.id;
      }
    });

  $("#select_owner-select2").select2({
    placeholder: "Seleccionar propietari",
    allowClear: true,
    theme: "bootstrap-5",
  });

  function updateOwner(selectedOwnerId) {
    const pathSegments = window.location.pathname;
    const lastSlashIndex = pathSegments.lastIndexOf("/");
    const path = pathSegments.slice(0, lastSlashIndex);
    console.log(path);

    // Make an AJAX call to update the vrental's owner_id
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
        console.log(data.owner_id);
      })
      .catch((error) => {
        console.error("There was an error updating the vrental:", error);
      });
  }

  $("#edit_owner-select2")
    .select2({
      placeholder: "Seleccionar propietari",
      allowClear: true,
      theme: "bootstrap-5",
    })
    .on("select2:select", function (e) {
      const editOwnerBox = document.querySelector(".edit_owner-js");

      editOwnerBox.classList.add("d-none");
      const selectedOwnerId = e.params.data.id;
      updateOwner(selectedOwnerId);
    })
    .on("select2:unselect", function (e) {
      // This function will be triggered when an item is unselected.
      document.querySelector(".edit_owner-js").classList.add("d-none");
      updateOwner(null);
    });
};

export { initSelect2 };
