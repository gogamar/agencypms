import { Controller } from "@hotwired/stimulus";
import SignaturePad from "signature_pad";

export default class extends Controller {
  static targets = [
    "signaturePad",
    "signatureDataField",
    "resetBtn",
    "signBtn",
  ];
  connect() {
    const canvas = this.signaturePadTarget;
    const signatureDataField = this.signatureDataFieldTarget;
    this.signaturePad = new SignaturePad(canvas);
    const signBtn = this.signBtnTarget;
    const resetBtn = this.resetBtnTarget;

    this.signaturePad.addEventListener("afterUpdateStroke", () => {
      signBtn.disabled = false;
      resetBtn.disabled = false;
      signatureDataField.value = this.signaturePad.toDataURL();
    });
  }

  clearCanvas() {
    this.signaturePad.clear();
  }
}
