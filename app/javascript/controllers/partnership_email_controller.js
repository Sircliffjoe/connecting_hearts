import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "recipient", "recipientEmail", "subject", "message", "mailtoFallback"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  open(event) {
    const button = event.currentTarget
    const org = button.dataset.org || "Organization"
    const contact = button.dataset.contact || ""
    const email = button.dataset.email || ""
    const actionUrl = button.dataset.actionUrl || ""
    const defaultSubject = button.dataset.subject || (org ? `Re: Partnership Proposal - ${org}` : "Re: Partnership Proposal")

    if (this.hasRecipientTarget) {
      this.recipientTarget.textContent = contact ? `${contact} — ${org}` : org
    }

    if (this.hasRecipientEmailTarget) {
      this.recipientEmailTarget.textContent = email
    }

    if (this.hasSubjectTarget) {
      this.subjectTarget.value = defaultSubject
    }

    if (this.hasMessageTarget) {
      this.messageTarget.value = ""
    }

    if (this.hasFormTarget && actionUrl) {
      this.formTarget.action = actionUrl
    }

    if (this.hasMailtoFallbackTarget) {
      this.mailtoFallbackTarget.href = `mailto:${email}?subject=${encodeURIComponent(defaultSubject)}`
    }

    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      document.body.classList.add("overflow-hidden")
      document.addEventListener("keydown", this.boundHandleKeydown)
      setTimeout(() => {
        if (this.hasMessageTarget) {
          this.messageTarget.focus()
        }
      }, 100)
    }
  }

  close() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
      document.removeEventListener("keydown", this.boundHandleKeydown)
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
