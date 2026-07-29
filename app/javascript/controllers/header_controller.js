import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll)
    this.onScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  onScroll() {
    if (window.scrollY > 20) {
      this.element.classList.add("header-scrolled")
      this.element.classList.remove("header-transparent")
    } else {
      this.element.classList.add("header-transparent")
      this.element.classList.remove("header-scrolled")
    }
  }
}
