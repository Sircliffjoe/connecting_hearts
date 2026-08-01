import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "copyBtnText", "copyAccountBtnText", "fileInput", "fileName"]

  openModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      document.body.classList.add("overflow-hidden")
    }
  }

  closeModal() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }

  copyAccountNumber(event) {
    const accNumber = event.currentTarget.dataset.accountNumber || "0040235590"
    navigator.clipboard.writeText(accNumber).then(() => {
      if (this.hasCopyBtnTextTarget) {
        const originalText = this.copyBtnTextTarget.textContent
        this.copyBtnTextTarget.textContent = "Copied!"
        setTimeout(() => {
          this.copyBtnTextTarget.textContent = originalText
        }, 2000)
      }
    }).catch(err => {
      console.error("Copy failed", err)
    })
  }

  copyFullDetails(event) {
    const text = event.currentTarget.dataset.fullDetails
    if (text) {
      navigator.clipboard.writeText(text).then(() => {
        if (this.hasCopyAccountBtnTextTarget) {
          const originalText = this.copyAccountBtnTextTarget.textContent
          this.copyAccountBtnTextTarget.textContent = "Details Copied!"
          setTimeout(() => {
            this.copyAccountBtnTextTarget.textContent = originalText
          }, 2000)
        }
      }).catch(err => {
        console.error("Copy failed", err)
      })
    }
  }

  fileSelected(event) {
    const file = event.target.files[0]
    if (file && this.hasFileNameTarget) {
      this.fileNameTarget.textContent = `Selected: ${file.name}`
      this.fileNameTarget.classList.remove("hidden")
    }
  }
}
