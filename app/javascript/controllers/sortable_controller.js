import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  connect() {
    console.log("Sortable.");
    const container = this.element.querySelector("#sortable-list");

    this.sortable = Sortable.create(container, {
      animation: 150,
      onUpdate: this.updateOrder.bind(this),
    });
  }

  updateOrder(event) {
    const updateOrderPath = this.element.dataset.url;
    const imageUrlIds = Array.from(event.target.children).map(
      (li) => li.dataset.imageId
    );
    const sortedElements = JSON.stringify(imageUrlIds);

    fetch(updateOrderPath, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({
        order: {
          sortedElements,
        },
      }),
      // body: JSON.stringify({ order: sortedElements }),
    })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
      })
      .catch((error) => {
        console.error("Error updating order:", error);
      });
  }
}
