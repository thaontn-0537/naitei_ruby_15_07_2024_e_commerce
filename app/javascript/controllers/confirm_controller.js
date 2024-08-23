import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  submitWithConfirmation(event) {
    const message = this.element.dataset.turboConfirm;
    if (!confirm(message)) {
      event.preventDefault();
    }
  }
}
