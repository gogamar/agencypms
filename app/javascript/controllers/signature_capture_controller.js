import { Controller } from "@hotwired/stimulus";
import SignaturePad from "signature_pad";

export default class extends Controller {
  static targets = ["signaturePad", "signatureDataField"];
  connect() {
    const canvas = this.signaturePadTarget;
    const signatureDataField = this.signatureDataFieldTarget;
    this.signaturePad = new SignaturePad(canvas);
    this.signaturePad.addEventListener("afterUpdateStroke", () => {
      signatureDataField.value = this.signaturePad.toDataURL();
    });
  }

  clearCanvas() {
    this.signaturePad.clear();
  }
}
