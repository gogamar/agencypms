import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "form",
    "submitButton",
    "spinner",
    "buttonText",
    "statusMessage",
  ];

  submit(event) {
    event.preventDefault();
    const formData = new FormData(this.formTarget);
    const url = new URL(this.formTarget.action);

    const params = new URLSearchParams(formData);

    // Debugging line to check the content of the URL and parameters
    console.log("formData: ", Array.from(formData.entries()));
    console.log("url with params: ", url.toString() + "?" + params.toString());

    // Append query parameters to the URL
    url.search = params.toString();

    fetch(url, {
      method: "GET",
      headers: {
        Accept: "application/json",
      },
    })
      .then((response) => response.json())
      .then((data) => {
        const jobIdUrl = data.job_id_url;
        this.disableSubmitButton();
        this.checkJobStatus(jobIdUrl);
      })
      .catch((error) => {
        console.error("Error:", error);
        this.enableSubmitButton();
        this.statusMessageTarget.textContent =
          "An error occurred. Please try again.";
      });
  }

  disableSubmitButton() {
    this.submitButtonTarget.setAttribute("disabled", true);
    this.spinnerTarget.classList.remove("d-none");
    this.buttonTextTarget.textContent =
      this.buttonTextTarget.getAttribute("data-loading-text");
  }

  enableSubmitButton() {
    this.submitButtonTarget.removeAttribute("disabled");
    this.spinnerTarget.classList.add("d-none");
    this.buttonTextTarget.textContent =
      this.buttonTextTarget.getAttribute("data-original-text");
  }

  checkJobStatus(jobIdUrl) {
    const checkStatus = () => {
      fetch(jobIdUrl)
        .then((response) => response.json())
        .then((data) => {
          if (data.status === "completed") {
            this.enableSubmitButton();
            this.statusMessageTarget.classList.add("text-success");
            this.statusMessageTarget.textContent =
              this.statusMessageTarget.dataset.success;
          } else if (data.status === "failed") {
            this.enableSubmitButton();
            this.statusMessageTarget.classList.add("text-danger");
            this.statusMessageTarget.textContent =
              this.statusMessageTarget.dataset.failure;
          } else {
            this.statusMessageTarget.classList.add("text-muted");
            this.statusMessageTarget.textContent =
              this.statusMessageTarget.dataset.loading;
            setTimeout(checkStatus, 1000); // Check again after 1 second
          }
        });
    };

    checkStatus();
  }
}
