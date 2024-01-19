import { Controller } from "@hotwired/stimulus";
import SignaturePad from "signature_pad";

export default class extends Controller {
  static targets = [
    "signatureContainer",
    "signaturePad",
    "signatureText",
    "deleteBtn",
    "submitBtn",
  ];
  connect() {
    console.log("Signature capture controller connected");
    // const canvas = document.querySelector("#signature-pad");
    // if (canvas) {
    //   const signaturePad = new SignaturePad(canvas);
    // }
    const signatureContainer = this.signatureContainerTarget;
    const canvas = this.signaturePadTarget;
    this.signaturePad = new SignaturePad(canvas);

    const signatureDataUrl = signaturePad.toDataURL();
    console.log("Signature Data URL:", signatureDataUrl);
    const textDiv = this.signatureTextTarget;
    textDiv.innerHTML = signatureDataUrl;

    let lastDownTarget;
    document.addEventListener(
      "mousedown",
      function (event) {
        lastDownTarget = event.target;
        console.log("lastDownTarget", lastDownTarget);
        alert("Mousedown Event");
      },
      false
    );

    // function handleDrawingStop() {
    //   // This function will be called when drawing stops
    //   console.log("Drawing stopped");
    //   const signatureDataUrl = signaturePad.toDataURL();
    //   console.log("Signature Data URL:", signatureDataUrl);
    //   const textDiv = this.textTarget;
    //   textDiv.innerHTML = signatureDataUrl;
    // }

    // const canvasElement = canvas.getContext("2d");
    // canvasElement.addEventListener("mouseup", handleDrawingStop);

    // Listen for the mouseup event on the canvas
    // signature.addEventListener("mouseup", handleDrawingStop);

    // Listen for the touchend event on the signature (for touchscreen devices)
    // signature.addEventListener("touchend", handleDrawingStop);

    // You can now use the signatureDataUrl as needed (e.g., send it to the server)
    // console.log(signatureDataUrl);
  }

  clearCanvas() {
    this.signaturePad.clear();
  }
}
