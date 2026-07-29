import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.boundClickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    const isHidden = this.menuTarget.classList.contains("hidden")
    
    // Close other open dropdowns first
    document.querySelectorAll('[data-dropdown-target="menu"]').forEach(el => {
      if (el !== this.menuTarget) el.classList.add("hidden")
    })

    if (isHidden) {
      this.menuTarget.classList.remove("hidden")
    } else {
      this.menuTarget.classList.add("hidden")
    }
  }

  clickOutside(event) {
    if (!this.element.contains(event.target) && this.hasMenuTarget) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
