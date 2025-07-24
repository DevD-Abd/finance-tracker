import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash-message"
export default class extends Controller {
  connect() {
    // Auto-dismiss success messages after 5 seconds
    if (this.element.classList.contains('bg-emerald-50')) {
      this.autoDismissTimer = setTimeout(() => {
        this.dismiss()
      }, 5000)
    }
  }

  disconnect() {
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }
  }

  dismiss() {
    // Clear auto-dismiss timer if it exists
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }

    // Add fade-out animation
    this.element.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out'
    this.element.style.opacity = '0'
    this.element.style.transform = 'translateY(-10px)'
    
    // Remove element after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
