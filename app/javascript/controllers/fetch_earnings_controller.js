import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["startdate", "enddate", "details", "earnings", "expenses"];

  fetchEarnings() {
    const statementEarnings = this.earningsTarget;
    const statementDetails = this.detailsTarget;
    if (statementEarnings) {
      statementEarnings.parentElement.classList.remove("d-none");
    }
    if (statementDetails) {
      statementDetails.classList.add("d-none");
    }
    const startDate = this.startdateTarget.value;
    const endDate = this.enddateTarget.value;

    const path = this.element.dataset.path;

    fetch(`${path}?start_date=${startDate}&end_date=${endDate}`)
      .then((response) => response.text())
      .then((data) => {
        statementEarnings.innerHTML = data;
      })
      .catch((error) => {
        console.error(error);
      });
  }

  showExpenses() {
    const statementExpenses = this.expensesTarget;
    const statementEarnings = this.earningsTarget;

    statementEarnings.parentElement.classList.add("d-none");
    statementExpenses.classList.remove("d-none");
  }

  showEarnings() {
    const statementExpenses = this.expensesTarget;
    const statementEarnings = this.earningsTarget;

    statementExpenses.classList.add("d-none");
    statementEarnings.parentElement.classList.remove("d-none");
  }

  showDetails() {
    const statementDetails = this.detailsTarget;
    const statementEarnings = this.earningsTarget;

    statementEarnings.parentElement.classList.add("d-none");
    statementDetails.classList.remove("d-none");
  }
  x;
}
