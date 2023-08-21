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
};

export { initSelect2 };
