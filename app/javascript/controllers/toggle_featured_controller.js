import { Controller } from "@hotwired/stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = ["label", "toggleButton", "icon"];

  toggleFeatured(event) {
    event.preventDefault();

    const toggleButton = this.toggleButtonTarget;
    const icon = this.iconTarget;
    const label = this.labelTarget;

    const url = toggleButton.getAttribute("data-url");
    const isFeatured = icon.classList.contains("text-warning");

    console.log("Toggling:", url);

    Rails.ajax({
      type: "PATCH",
      url: url,
      data: { featured: !isFeatured }, // Toggle the featured status, however I'm not using the data in my controller, I just toggle the value
      success: (data, status, xhr) => {
        this.toggleIcon(icon); // Toggle the icon color
        this.updateLabel(label); // Update the label
      },
      error: (error) => {
        console.error("Failed to toggle:", error);
      },
    });
  }

  toggleIcon(icon) {
    icon.classList.toggle("text-warning");
  }

  updateLabel(label) {
    label.classList.toggle("d-none");
  }
}
