import "slick-carousel";

const initSlick = () => {
  // Compare Slide
  $(".csm-trigger").on("click", function () {
    $(".compare-slide-menu").toggleClass("active");
  });
  $(".compare-button").on("click", function () {
    $(".compare-slide-menu").addClass("active");
  });

  // smart-textimonials
  $("#smart-textimonials").slick({
    slidesToShow: 3,
    infinite: true,
    arrows: false,
    autoplay: true,
    responsive: [
      {
        breakpoint: 768,
        settings: {
          arrows: false,
          slidesToShow: 2,
        },
      },
      {
        breakpoint: 480,
        settings: {
          arrows: false,
          slidesToShow: 1,
        },
      },
    ],
  });

  // Property Slide
  $(".property-slide").slick({
    slidesToShow: 3,
    arrows: false,
    dots: true,
    autoplay: true,
    responsive: [
      {
        breakpoint: 1024,
        settings: {
          arrows: false,
          slidesToShow: 2,
        },
      },
      {
        breakpoint: 600,
        settings: {
          arrows: false,
          slidesToShow: 1,
        },
      },
    ],
  });

  // slide-livok
  $(".slide-livok").slick({
    slidesToShow: 4,
    arrows: true,
    dots: false,
    autoplay: true,
    responsive: [
      {
        breakpoint: 1400,
        settings: {
          arrows: true,
          slidesToShow: 3,
        },
      },
      {
        breakpoint: 1023,
        settings: {
          arrows: true,
          slidesToShow: 2,
        },
      },
      {
        breakpoint: 800,
        settings: {
          arrows: true,
          slidesToShow: 1,
        },
      },
    ],
  });

  // location Slide
  $(".location-slide").slick({
    slidesToShow: 4,
    dots: true,
    arrows: false,
    autoplay: true,
    responsive: [
      {
        breakpoint: 1024,
        settings: {
          arrows: false,
          slidesToShow: 3,
        },
      },
      {
        breakpoint: 600,
        settings: {
          arrows: false,
          slidesToShow: 1,
        },
      },
    ],
  });

  // Property Slide
  $(".team-slide").slick({
    slidesToShow: 4,
    arrows: false,
    autoplay: true,
    dots: true,
    responsive: [
      {
        breakpoint: 1023,
        settings: {
          arrows: false,
          dots: true,
          slidesToShow: 3,
        },
      },
      {
        breakpoint: 768,
        settings: {
          arrows: false,
          slidesToShow: 2,
        },
      },
      {
        breakpoint: 480,
        settings: {
          arrows: false,
          slidesToShow: 1,
        },
      },
    ],
  });

  // Property Slide
  $(".featured-prt-slide").slick({
    slidesToShow: 4,
    arrows: true,
    autoplay: true,
    dots: false,
    responsive: [
      {
        breakpoint: 1600,
        settings: {
          arrows: true,
          dots: false,
          slidesToShow: 3,
        },
      },
      {
        breakpoint: 1024,
        settings: {
          arrows: true,
          slidesToShow: 2,
        },
      },
      {
        breakpoint: 767,
        settings: {
          arrows: true,
          slidesToShow: 1,
        },
      },
    ],
  });

  // Featured Slick Slider
  $(".featured_slick_gallery-slide").slick({
    centerMode: true,
    infinite: true,
    centerPadding: "40px",
    slidesToShow: 2,
    responsive: [
      {
        breakpoint: 768,
        settings: {
          arrows: true,
          centerMode: true,
          centerPadding: "20px",
          slidesToShow: 1,
        },
      },
      {
        breakpoint: 480,
        settings: {
          arrows: true,
          centerMode: true,
          centerPadding: "20px",
          slidesToShow: 1,
        },
      },
    ],
  });

  // Slider
  $(".clior").slick({
    slidesToShow: 1,
    slidesToScroll: 1,
    arrows: false,
    autoplay: true,
    fade: true,
    dots: true,
    autoplaySpeed: 4000,
  });

  // Single Reviews
  $(".single-reviews").slick({
    slidesToShow: 1,
    slidesToScroll: 1,
    arrows: false,
    autoplay: true,
    fade: true,
    dots: false,
    autoplaySpeed: 2000,
  });

  // Home Slider
  $(".home-slider").slick({
    centerMode: false,
    slidesToShow: 1,
    responsive: [
      {
        breakpoint: 768,
        settings: {
          arrows: true,
          slidesToShow: 1,
        },
      },
      {
        breakpoint: 480,
        settings: {
          arrows: false,
          slidesToShow: 1,
        },
      },
    ],
  });

  $(".click").slick({
    slidesToShow: 1,
    slidesToScroll: 1,
    autoplay: true,
    dots: true,
    autoplaySpeed: 4000,
  });

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
        tLoading: "Загрузка...",
        mainClass: "mfp-zoom-in mfp-img-mobile",
        image: {
          verticalFit: true,
          tError: '<a href="%url%">Фото #%curr%</a> не загрузилось.',
        },
        gallery: {
          enabled: true,
          navigateByImgClick: true,
          tCounter: '<span class="mfp-counter">%curr% из %total%</span>', // markup of counte
          preload: [0, 1], // Will preload 0 - before current, and 1 after the current image
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

  // Featured Slick Slider
  $(".featured-slick-slide").slick({
    centerMode: true,
    centerPadding: "80px",
    slidesToShow: 2,
    responsive: [
      {
        breakpoint: 768,
        settings: {
          arrows: true,
          centerMode: true,
          centerPadding: "60px",
          slidesToShow: 2,
        },
      },
      {
        breakpoint: 480,
        settings: {
          arrows: false,
          centerMode: true,
          centerPadding: "40px",
          slidesToShow: 1,
        },
      },
    ],
  });
};

export { initSlick };
