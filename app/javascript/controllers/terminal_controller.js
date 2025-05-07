import { Controller } from "@hotwired/stimulus"
import { HttpStatus } from "helpers/http_helpers"

export default class extends Controller {
  static targets = [ "input", "form", "confirmation" ]
  static classes = [ "error", "confirmation", "help" ]

  // Actions

  focus() {
    this.inputTarget.focus()
  }

  executeCommand(event) {
    if (this.#hasShowHelpMenuCommand) {
      this.#showHelpMenu()
      event.preventDefault()
      event.stopPropagation()
    } else {
      this.hideHelpMenu()
    }
  }

  hideHelpMenu() {
    if (this.#isHelpMenuOpened) {
      if (this.#hasShowHelpMenuCommand) { this.#reset() }
      this.element.classList.remove(this.helpClass)
    }
  }

  handleCommandResponse(event) {
    if (event.detail.success) {
      this.#reset()
    } else {
      const response = event.detail.fetchResponse.response
      this.#handleErrorResponse(response)
    }
  }

  restoreCommand(event) {
    const target = event.target.querySelector("[data-line]") || event.target
    if (target.dataset.line) {
      this.#reset(target.dataset.line)
      this.focus()
    }
  }

  get #hasShowHelpMenuCommand() {
    return this.inputTarget.value == "/help" || this.inputTarget.value == "/?"
  }

  #showHelpMenu() {
    this.element.classList.add(this.helpClass)
  }

  get #isHelpMenuOpened() {
    return this.element.classList.contains(this.helpClass)
  }

  async #handleErrorResponse(response) {
    const status = response.status
    const message = await response.text()

    if (status === HttpStatus.UNPROCESSABLE) {
      this.#showError()
    } else if (status === HttpStatus.CONFLICT) {
      this.#requestConfirmation(message)
    }
  }

  #reset(inputValue = "") {
    this.formTarget.reset()
    this.inputTarget.value = inputValue
    this.confirmationTarget.value = ""

    this.element.classList.remove(this.errorClass)
    this.element.classList.remove(this.confirmationClass)
  }

  #showError() {
    this.element.classList.add(this.errorClass)
  }

  async #requestConfirmation(message) {
    const originalInputValue = this.inputTarget.value
    this.element.classList.add(this.confirmationClass)
    this.inputTarget.value = `${message}? [Y/n] `

    try {
      await this.#waitForConfirmation()
      this.#submitWithConfirmation(originalInputValue)
    } catch {
      this.#reset(originalInputValue)
    }
  }

  #waitForConfirmation() {
    return new Promise((resolve, reject) => {
      this.inputTarget.addEventListener("keydown", (event) => {
        event.preventDefault()
        const key = event.key.toLowerCase()

        if (key === "enter" || key === "y") {
          resolve()
        } else {
          reject()
        }
      }, { once: true })
    })
  }

  #submitWithConfirmation(inputValue) {
    this.inputTarget.value = inputValue
    this.confirmationTarget.value = "confirmed"
    this.formTarget.requestSubmit()
  }
}
