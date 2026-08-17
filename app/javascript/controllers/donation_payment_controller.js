import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitBtn", "submitText", "submitSpinner", "errorContainer", "errorList"]

  connect() {
    this.ensurePaystackScript()
  }

  ensurePaystackScript() {
    if (!window.PaystackPop && !document.getElementById("paystack-inline-js")) {
      const script = document.createElement("script")
      script.id = "paystack-inline-js"
      script.src = "https://js.paystack.co/v1/inline.js"
      script.async = true
      document.head.appendChild(script)
    }
  }

  async submit(event) {
    const selectedMethod = this.element.querySelector('input[name="payment_method"]:checked')?.value || "paystack"
    
    // If bank transfer selected, allow standard form submission
    if (selectedMethod !== "paystack") {
      return
    }

    event.preventDefault()
    this.hideErrors()
    this.setLoading(true)

    const form = this.hasFormTarget ? this.formTarget : (event.target.tagName === "FORM" ? event.target : this.element.querySelector("form"))
    if (!form) return

    const formData = new FormData(form)

    try {
      const response = await fetch(form.action, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || ""
        },
        body: formData
      })

      const data = await response.json()

      if (!response.ok || !data.success) {
        this.showErrors(data.errors || ["Unable to process donation. Please check form fields."])
        this.setLoading(false)
        return
      }

      // Open Paystack Popup Modal with the created donation record
      this.openPaystackModal(data)
    } catch (err) {
      console.error("Donation submission error:", err)
      this.setLoading(false)
      // Fallback: submit standard form if fetch failed
      form.submit()
    }
  }

  openPaystackModal(data) {
    const triggerPopup = () => {
      try {
        const handler = window.PaystackPop.setup({
          key: data.public_key,
          email: data.donor_email,
          amount: data.amount_in_kobo,
          currency: data.currency || "NGN",
          ref: data.payment_reference,
          metadata: {
            donor_name: data.donor_name,
            purpose: data.purpose,
            custom_fields: [
              { display_name: "Purpose", variable_name: "purpose", value: data.purpose },
              { display_name: "Reference Code", variable_name: "reference", value: data.payment_reference }
            ]
          },
          callback: (response) => {
            // Successful payment in popup modal
            const ref = response.reference || data.payment_reference
            window.location.href = `/donate/callback?reference=${encodeURIComponent(ref)}`
          },
          onClose: () => {
            this.setLoading(false)
            // Redirect to confirmation page where user can see reference and complete transfer or retry
            window.location.href = data.confirmation_url
          }
        })

        handler.openIframe()
      } catch (e) {
        console.error("Error opening Paystack modal:", e)
        window.location.href = data.confirmation_url
      }
    }

    if (typeof window.PaystackPop === "undefined") {
      this.ensurePaystackScript()
      // Wait shortly for script to finish initializing if needed
      let checks = 0
      const interval = setInterval(() => {
        checks++
        if (typeof window.PaystackPop !== "undefined") {
          clearInterval(interval)
          triggerPopup()
        } else if (checks > 20) {
          clearInterval(interval)
          window.location.href = data.confirmation_url
        }
      }, 100)
    } else {
      triggerPopup()
    }
  }

  // Open Paystack modal directly on confirmation page for pending donation
  openDirect(event) {
    event.preventDefault()
    const btn = event.currentTarget
    const publicKey = btn.dataset.publicKey
    const email = btn.dataset.email
    const amountInKobo = parseInt(btn.dataset.amountInKobo, 10)
    const reference = btn.dataset.reference
    const donorName = btn.dataset.donorName || "Anonymous Donor"
    const purpose = btn.dataset.purpose || "General Foundation Support"

    const triggerPopup = () => {
      try {
        const handler = window.PaystackPop.setup({
          key: publicKey,
          email: email,
          amount: amountInKobo,
          currency: "NGN",
          ref: reference,
          metadata: {
            donor_name: donorName,
            purpose: purpose,
            custom_fields: [
              { display_name: "Purpose", variable_name: "purpose", value: purpose },
              { display_name: "Reference Code", variable_name: "reference", value: reference }
            ]
          },
          callback: (response) => {
            const ref = response.reference || reference
            window.location.href = `/donate/callback?reference=${encodeURIComponent(ref)}`
          },
          onClose: () => {
            // Modal closed without completing payment
          }
        })

        handler.openIframe()
      } catch (e) {
        console.error("Error opening Paystack iframe:", e)
        alert("Could not load payment gateway. Please use bank transfer details.")
      }
    }

    if (typeof window.PaystackPop === "undefined") {
      this.ensurePaystackScript()
      let checks = 0
      const interval = setInterval(() => {
        checks++
        if (typeof window.PaystackPop !== "undefined") {
          clearInterval(interval)
          triggerPopup()
        } else if (checks > 15) {
          clearInterval(interval)
          alert("Loading payment gateway took too long. Please refresh the page or transfer directly.")
        }
      }, 100)
    } else {
      triggerPopup()
    }
  }

  setLoading(isLoading) {
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.disabled = isLoading
    }
    if (this.hasSubmitSpinnerTarget) {
      this.submitSpinnerTarget.classList.toggle("hidden", !isLoading)
    }
    if (this.hasSubmitTextTarget) {
      this.submitTextTarget.textContent = isLoading ? "Opening Secure Payment..." : "Donate Now"
    }
  }

  showErrors(errors) {
    if (this.hasErrorContainerTarget && this.hasErrorListTarget) {
      this.errorListTarget.innerHTML = errors.map(e => `<li>${e}</li>`).join("")
      this.errorContainerTarget.classList.remove("hidden")
      this.errorContainerTarget.scrollIntoView({ behavior: "smooth", block: "nearest" })
    }
  }

  hideErrors() {
    if (this.hasErrorContainerTarget) {
      this.errorContainerTarget.classList.add("hidden")
    }
  }
}
