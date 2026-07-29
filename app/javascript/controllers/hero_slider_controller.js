import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (typeof Swiper !== "undefined") {
      this.swiper = new Swiper(this.element, {
        loop: true,
        autoplay: {
          delay: 5500,
          disableOnInteraction: false,
        },
        speed: 800,
        effect: "fade",
        fadeEffect: {
          crossFade: true,
        },
        pagination: {
          el: ".swiper-pagination",
          clickable: true,
        },
        navigation: {
          nextEl: ".swiper-button-next",
          prevEl: ".swiper-button-prev",
        },
      })
    } else {
      // Fallback slider if Swiper script is loading asynchronously
      setTimeout(() => this.connect(), 200)
    }
  }

  disconnect() {
    if (this.swiper) {
      this.swiper.destroy()
    }
  }
}
