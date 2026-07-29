import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer"]

  toggle() {
    this.drawerTarget.classList.toggle("hidden")
  }

  close() {
    this.drawerTarget.classList.add("hidden")
  }
}
