import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "name", "email", "emailLink", "subject", "date", "status", "message", "deleteForm"]

  open(event) {
    const button = event.currentTarget
    const name = button.dataset.name || "Anonymous"
    const email = button.dataset.email || ""
    const subject = button.dataset.subject || ""
    const date = button.dataset.date || ""
    const status = button.dataset.status || "pending"
    const message = button.dataset.message || ""
    const deleteUrl = button.dataset.deleteUrl || ""

    if (this.hasNameTarget) this.nameTarget.textContent = name
    if (this.hasEmailTarget) this.emailTarget.textContent = email
    if (this.hasEmailLinkTarget) this.emailLinkTarget.href = `mailto:${email}?subject=Re: ${encodeURIComponent(subject)}`
    if (this.hasSubjectTarget) this.subjectTarget.textContent = subject
    if (this.hasDateTarget) this.dateTarget.textContent = date
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = status
      this.statusTarget.className = `px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase ${
        status === 'pending' ? 'bg-amber-950 text-amber-300 border border-amber-800' : 'bg-emerald-950 text-emerald-300 border border-emerald-800'
      }`
    }
    if (this.hasMessageTarget) this.messageTarget.textContent = message
    if (this.hasDeleteFormTarget && deleteUrl) {
      this.deleteFormTarget.action = deleteUrl
    }

    if (this.hasModalTarget) {
      this.modalTarget.classList.remove("hidden")
      document.body.classList.add("overflow-hidden")
    }
  }

  close() {
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
