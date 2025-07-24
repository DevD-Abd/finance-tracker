import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mobile-menu"
export default class extends Controller {
  static targets = ["menu", "button"]

  toggle() {
    const menu = this.menuTarget
    const menuIcon = this.buttonTarget.querySelector('.menu-icon')
    const closeIcon = this.buttonTarget.querySelector('.close-icon')
    
    menu.classList.toggle('hidden')
    menuIcon.classList.toggle('hidden')
    closeIcon.classList.toggle('hidden')
  }
}
