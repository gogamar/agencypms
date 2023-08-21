import "slick-carousel";

const initSlick = () => {
  // $(".slick").slick();

  // Home Slider
  $(".home-slider").slick(
    {
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
    },
    { passive: true }
  );

  $(".click").slick(
    {
      slidesToShow: 1,
      slidesToScroll: 1,
      autoplay: false,
      autoplaySpeed: 2000,
      arrows: true,
    },
    { passive: true }
  );
  // Featured Slick Slider
  $(".featured-slick-slide").slick(
    {
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
    },
    { passive: true }
  );
  // smart-textimonials
  $("#smart-textimonials").slick(
    {
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
    },
    { passive: true }
  );

  // Property Slide
  $(".property-slide").slick(
    {
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
    },
    { passive: true }
  );

  // Single Property Slide
  $(".single-advance-property").slick(
    {
      centerMode: true,
      infinite: true,
      centerPadding: "40px",
      autoplay: true,
      slidesToShow: 2,
      responsive: [
        {
          breakpoint: 768,
          settings: {
            arrows: true,
            centerMode: true,
            centerPadding: "20px",
            slidesToShow: 3,
          },
        },
        {
          breakpoint: 480,
          settings: {
            arrows: false,
            centerMode: true,
            centerPadding: "20px",
            slidesToShow: 1,
          },
        },
      ],
    },
    { passive: true }
  );

  // location Slide
  $(".location-slide").slick(
    {
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
    },
    { passive: true }
  );

  // Property Slide
  $(".team-slide").slick(
    {
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
    },
    { passive: true }
  );

  // Featured Slick Slider
  $(".featured_slick_gallery").slick(
    {
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
            slidesToShow: 3,
          },
        },
        {
          breakpoint: 480,
          settings: {
            arrows: false,
            centerMode: true,
            centerPadding: "20px",
            slidesToShow: 1,
          },
        },
      ],
    },
    { passive: true }
  );

  // Slider
  $(".clior").slick(
    {
      slidesToShow: 1,
      slidesToScroll: 1,
      arrows: false,
      autoplay: true,
      fade: true,
      dots: true,
      autoplaySpeed: 4000,
    },
    { passive: true }
  );
};

export { initSlick };
