import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "indicator"]

  connect() {
    this.currentStep = 0
    this.showStep(this.currentStep)
  }

  next(event) {
    event.preventDefault()
    if (this.currentStep < this.stepTargets.length - 1) {
      this.currentStep++
      this.showStep(this.currentStep)
    }
  }

  previous(event) {
    event.preventDefault()
    if (this.currentStep > 0) {
      this.currentStep--
      this.showStep(this.currentStep)
    }
  }

  showStep(index) {
    this.stepTargets.forEach((el, i) => {
      if (i === index) {
        el.classList.remove("hidden")
      } else {
        el.classList.add("hidden")
      }
    })

    if (this.hasIndicatorTargets) {
      this.indicatorTargets.forEach((ind, i) => {
        if (i <= index) {
          ind.classList.add("bg-plum-800", "text-white")
          ind.classList.remove("bg-warm-200", "text-charcoal-500")
        } else {
          ind.classList.remove("bg-plum-800", "text-white")
          ind.classList.add("bg-warm-200", "text-charcoal-500")
        }
      })
    }
    window.scrollTo({ top: 150, behavior: 'smooth' })
  }
}
