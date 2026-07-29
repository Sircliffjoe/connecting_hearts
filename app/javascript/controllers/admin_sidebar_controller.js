import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileSidebar", "section"]

  toggleMobile() {
    if (this.hasMobileSidebarTarget) {
      this.mobileSidebarTarget.classList.toggle("hidden")
    }
  }

  closeMobile() {
    if (this.hasMobileSidebarTarget) {
      this.mobileSidebarTarget.classList.add("hidden")
    }
  }

  toggleSection(event) {
    event.preventDefault()
    const button = event.currentTarget
    const submenu = button.nextElementSibling
    const icon = button.querySelector(".chevron-icon")

    if (submenu) {
      submenu.classList.toggle("hidden")
    }
    if (icon) {
      icon.classList.toggle("rotate-180")
    }
  }
}
