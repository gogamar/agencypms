import "magnific-popup";

const initMagnificPopUp = () => {
  // MagnificPopup
  $("body").magnificPopup({
    type: "image",
    delegate: "a.mfp-gallery",
    fixedContentPos: true,
    fixedBgPos: true,
    overflowY: "auto",
    closeBtnInside: false,
    preloader: true,
    removalDelay: 0,
    mainClass: "mfp-fade",
    gallery: {
      enabled: true,
    },
  });
};

export { initMagnificPopUp };
