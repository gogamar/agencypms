import "select2";

const initSelect2 = () => {
  $("#persons-ca").select2({
    placeholder: "Núm persones",
    allowClear: true,
  });

  $("#persons-es").select2({
    placeholder: "Núm personas",
    allowClear: true,
  });

  $("#persons-en").select2({
    placeholder: "Num guests",
    allowClear: true,
  });

  $("#persons-fr").select2({
    placeholder: "Num personnes",
    allowClear: true,
  });

  $("#maxprice-ca").select2({
    placeholder: "Màx",
    allowClear: true,
  });

  $("#maxprice-es").select2({
    placeholder: "Máx",
    allowClear: true,
  });

  $("#maxprice-en").select2({
    placeholder: "Max",
    allowClear: true,
  });

  $("#maxprice-fr").select2({
    placeholder: "Max",
    allowClear: true,
  });

  $("#minprice-ca").select2({
    placeholder: "Mín",
    allowClear: true,
  });

  $("#minprice-es").select2({
    placeholder: "Mín",
    allowClear: true,
  });

  $("#minprice-en").select2({
    placeholder: "Min",
    allowClear: true,
  });

  $("#minprice-fr").select2({
    placeholder: "Min",
    allowClear: true,
  });

  $("#town-ca").select2({
    placeholder: "Ubicació",
    allowClear: true,
  });

  $("#town-es").select2({
    placeholder: "Ubicación",
    allowClear: true,
  });

  $("#town-en").select2({
    placeholder: "Location",
    allowClear: true,
  });

  $("#town-fr").select2({
    placeholder: "Emplacement",
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

  $("#select_vrowner-select2").select2({
    placeholder: "Seleccionar propietari",
    allowClear: true,
    theme: "bootstrap-5",
  });

  function updateVrowner(selectedVrownerId) {
    const pathSegments = window.location.pathname;
    const lastSlashIndex = pathSegments.lastIndexOf("/");
    const path = pathSegments.slice(0, lastSlashIndex);

    // Make an AJAX call to update the vrental's vrowner_id
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
          vrowner_id: selectedVrownerId,
        },
      }),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data.vrowner_id);
      })
      .catch((error) => {
        console.error("There was an error updating the vrental:", error);
      });
  }

  $("#edit_vrowner-select2")
    .select2({
      placeholder: "Seleccionar propietari",
      allowClear: true,
      theme: "bootstrap-5",
    })
    .on("select2:select", function (e) {
      const editVrownerBox = document.querySelector(".edit_vrowner-js");

      editVrownerBox.classList.add("d-none");
      const selectedVrownerId = e.params.data.id;
      updateVrowner(selectedVrownerId);
    })
    .on("select2:unselect", function (e) {
      // This function will be triggered when an item is unselected.
      document.querySelector(".edit_vrowner-js").classList.add("d-none");
      updateVrowner(null);
    });
};

export { initSelect2 };
