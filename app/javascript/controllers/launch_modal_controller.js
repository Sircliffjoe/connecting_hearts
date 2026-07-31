import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "countdown"]

  connect() {
    const expireTime = new Date("2026-08-01T18:00:00+01:00").getTime();
    const now = new Date().getTime();

    // Check if expired
    if (now >= expireTime) {
      this.closeModalImmediately();
      return;
    }

    // Always display on root page load/reload until expiration time
    document.body.classList.add("overflow-hidden");
    this.startCountdown(expireTime);
  }

  unlock() {
    document.body.classList.remove("overflow-hidden");

    if (this.hasModalTarget) {
      this.modalTarget.classList.add("opacity-0", "scale-95", "pointer-events-none");
      setTimeout(() => {
        this.modalTarget.classList.add("hidden");
      }, 400);
    }
  }

  closeModalImmediately() {
    document.body.classList.remove("overflow-hidden");
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden");
    }
  }

  startCountdown(expireTime) {
    const update = () => {
      const distance = expireTime - new Date().getTime();
      if (distance <= 0) {
        this.unlock();
        return;
      }

      const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((distance % (1000 * 60)) / 1000);

      if (this.hasCountdownTarget) {
        this.countdownTarget.textContent = `${hours}h ${minutes}m ${seconds}s remaining`;
      }
    };

    update();
    this.timer = setInterval(update, 1000);
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer);
    document.body.classList.remove("overflow-hidden");
  }
}
