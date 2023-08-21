$(function () {
  "use strict";

  // $(window).on("load", function () {
  //   $("#preloader").delay(350).fadeOut("slow");
  //   $("body").delay(350).css({ overflow: "visible" });
  // }, { passive: true });

  // Advance Single Slider
  $(function () {
    // Card's slider
    var $carousel = $(".slider-for");

    $carousel
      .slick({
        slidesToShow: 1,
        slidesToScroll: 1,
        arrows: false,
        fade: true,
        adaptiveHeight: true,
        asNavFor: ".slider-nav",
      })
      .magnificPopup({
        type: "image",
        delegate: "a:not(.slick-cloned)",
        closeOnContentClick: false,
        tLoading: "Carregant...",
        mainClass: "mfp-zoom-in mfp-img-mobile",
        image: {
          verticalFit: true,
          tError: "<a href=\"%url%\">L'imatge #%curr%</a> no s'ha carregat.",
        },
        gallery: {
          enabled: true,
          navigateByImgClick: true,
          tCounter: '<span class="mfp-counter">%curr% из %total%</span>', // markup of counte
          // preload: [0, 1], // Will preload 0 - before current, and 1 after the current image
        },
        zoom: {
          enabled: true,
          duration: 300,
        },
        removalDelay: 300, //delay removal by X to allow out-animation
        callbacks: {
          open: function () {
            //overwrite default prev + next function. Add timeout for css3 crossfade animation
            $.magnificPopup.instance.next = function () {
              var self = this;
              self.wrap.removeClass("mfp-image-loaded");
              setTimeout(function () {
                $.magnificPopup.proto.next.call(self);
              }, 120);
            };
            $.magnificPopup.instance.prev = function () {
              var self = this;
              self.wrap.removeClass("mfp-image-loaded");
              setTimeout(function () {
                $.magnificPopup.proto.prev.call(self);
              }, 120);
            };
            var current = $carousel.slick("slickCurrentSlide");
            $carousel.magnificPopup("goTo", current);
          },
          imageLoadComplete: function () {
            var self = this;
            setTimeout(function () {
              self.wrap.addClass("mfp-image-loaded");
            }, 16);
          },
          beforeClose: function () {
            $carousel.slick("slickGoTo", parseInt(this.index));
          },
        },
      });
    $(".slider-nav").slick({
      slidesToShow: 6,
      slidesToScroll: 1,
      asNavFor: ".slider-for",
      dots: false,
      centerMode: false,
      focusOnSelect: true,
    });
  });

  // fullwidth home slider
  function inlineCSS() {
    $(".home-slider .item").each(function () {
      var attrImageBG = $(this).attr("data-background-image");
      var attrColorBG = $(this).attr("data-background-color");
      if (attrImageBG !== undefined) {
        $(this).css("background-image", "url(" + attrImageBG + ")");
      }
      if (attrColorBG !== undefined) {
        $(this).css("background", "" + attrColorBG + "");
      }
    });
  }
  inlineCSS();

  // Search Radio
//   function searchTypeButtons() {
//     $('.property-search-type label.active input[type="radio"]').prop(
//       "checked",
//       true
//     );
//     var buttonWidth = $(".property-search-type label.active").width();
//     var arrowDist = $(".property-search-type label.active").position();
//     $(".property-search-type-arrow").css("left", arrowDist + buttonWidth / 2);
//     $(".property-search-type label").on("change", function () {
//       $('.property-search-type input[type="radio"]')
//         .parent("label")
//         .removeClass("active");
//       $('.property-search-type input[type="radio"]:checked')
//         .parent("label")
//         .addClass("active");
//       var buttonWidth = $(".property-search-type label.active").width();
//       var arrowDist = $(".property-search-type label.active").position().left;
//       $(".property-search-type-arrow").css({
//         left: arrowDist + buttonWidth / 1.7,
//         transition: "left 0.4s cubic-bezier(.95,-.41,.19,1.44)",
//       });
//     });
//   }
//   if ($(".hero-banner").length) {
//     searchTypeButtons();
//     $(window).on("load resize", function () {
//       searchTypeButtons();
//     });
//   }
});
