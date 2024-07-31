import { LightningElement, track, api, wire } from "lwc";
import getQuoteDataFromServer from "@salesforce/apex/RFQDAO.getAllApprovedRFQ";
import saveData from "@salesforce/apex/QuoteDAO.createQuoteItem";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from "lightning/platformResourceLoader";
import myResource from "@salesforce/resourceUrl/newImportRfqOnQuoteExternalCss";

const columns = [
  {
    label: "Name",
    fieldName: "Name",
    type: "text",
    sortable: false,
    hideDefaultActions: true,
  },
  {
    label: "RFQ Details",
    fieldName: "buildertek__RFQ_Details__c",
    type: "text",
    hideDefaultActions: true,
  },
  {
    label: "Project",
    fieldName: "projectName",
    type: "text",
    hideDefaultActions: true,
  },
  {
    label: "Vendor",
    fieldName: "vendorName",
    type: "text",
    hideDefaultActions: true,
  },
  {
    label: "Contractor Ammount",
    fieldName: "buildertek__Vendor_Quote__c",
    type: "currency",
    typeAttributes: {
      currencyCode: { fieldName: "CurrencyIso" },
      currencyDisplayAs: "code",
    },
    cellAttributes: { alignment: "left" },
    hideDefaultActions: true,
  },
  {
    label: "Status",
    fieldName: "buildertek__Status__c",
    type: "text",
    hideDefaultActions: true,
  },
];

export default class ImportRfqLwcCmp extends LightningElement {
  @track isNextScreen = false;
  showSpinner = false;
  @api quoteId;
  @track data = [];
  @track filteredData = [];
  @track selectedQuoteLineRecords = [];
  columns = columns;
  @track btnName = "Next";

  connectedCallback() {
    loadStyle(this, myResource);
    this.fetchQuoteData();
  }

  fetchQuoteData() {
    getQuoteDataFromServer({ quotId: this.quoteId })
      .then((result) => {
        result.forEach((ele) => {
          ele["vendorName"] = ele.buildertek__Vendor__r?.Name;
          ele["projectName"] = ele.buildertek__Project__r?.Name;
        });
        this.data = result;
        this.filteredData = result;
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.data = undefined;
      });
  }

  resetValues() {
    this.isNextScreen = false;
    this.btnName = "Next";
    this.selectedQuoteLineRecords = [];
    this.filteredData = [];
    this.data = [];
  }

  hideModalBox() {
    this.closeChildScreen(false);
  }

  handleKeyUp(evt) {
    let searchKey = evt.target.value;
    searchKey = searchKey.toLowerCase();

    if (searchKey == "") {
      this.filteredData = this.data;
      return;
    }

    if (evt.target.name == "enter-name") {
      this.filteredData = this.data.filter((ele) => {
        return ele.Name?.toLowerCase().includes(searchKey);
      });
    } else if (evt.target.name == "enter-project") {
      this.filteredData = this.data.filter((ele) => {
        return ele.projectName?.toLowerCase().includes(searchKey);
      });
    } else if (evt.target.name == "enter-vendor") {
      this.filteredData = this.data.filter((ele) => {
        return ele.vendorName?.toLowerCase().includes(searchKey);
      });
    }
  }

  goToNextScreen() {
    this.showSpinner = true;
    if (this.btnName === "Next") {
      let selectedRecords = this.template
        .querySelector("lightning-datatable")
        .getSelectedRows();
      let selectedQuoteLineRecords = [];
      if (selectedRecords?.length == 0) {
        console.log("in if  ");
        this.showSpinner = false;
        this.showToastMsg("Error", "Please select at least one RFQ.", "error");
        return;
      }

      selectedRecords.forEach((row) => {
        let obj = {};
        obj.buildertek__RFQ__c = row.Id;
        obj.Name = row.Name;
        obj.buildertek__Item_Name__c = row.Name;
        obj.buildertek__Description__c = row.Name;
        obj.buildertek__Quantity__c = 1;
        obj.buildertek__Unit_Price__c = row.buildertek__Vendor_Quote__c;
        obj.buildertek__Unit_Cost__c = row.buildertek__Vendor_Quote__c;
        obj.buildertek__Markup__c = 0;
        obj.buildertek__Quote__c = this.quoteId;
        selectedQuoteLineRecords.push(obj);
      });

      this.selectedQuoteLineRecords = [...selectedQuoteLineRecords];
      this.isNextScreen = true;
      this.btnName = "Save";
      this.showSpinner = false;
    } else if (this.btnName === "Save") {
      // do apex callout here
      let listOfQuoteLines = this.selectedQuoteLineRecords;

      for (let i = 0; i < listOfQuoteLines.length; i++) {
        let ele = listOfQuoteLines[i];
        if (ele.Name == "" || ele.Name == undefined) {
          this.showToastMsg("Error", "Please enter QuoteLine Name.", "error");
          this.showSpinner = false;
          return;
        }
      }

      this.callApexSaveData();
    }
  }

  callApexSaveData() {
      console.log('this.selectedQuoteLineRecords ',JSON.parse(JSON.stringify(this.selectedQuoteLineRecords)));
      debugger
    saveData({ quoteItemsJSON: JSON.stringify(this.selectedQuoteLineRecords) })
      .then((result) => {
        if (result == "Success") {
          this.showToastMsg(
            "Success",
            "Quote Line Created Successfully.",
            "success"
          );
          this.closeChildScreen(true);
        } else {
          this.showToastMsg("Error", result, "error");
        }
        this.showSpinner = false;
      })
      .catch((error) => {
        console.log(error);
        this.showToastMsg("Error", error[0].message, "error");
      });
  }

  handleSelected(event) {
    let rowId = event.target.dataset;
    console.log("rowId ", rowId);
    let selectedGrouping = event.detail;
    for (let i = 0; i < this.selectedQuoteLineRecords.length; i++) {
      let ele = this.selectedQuoteLineRecords[i];
      if (ele.buildertek__RFQ__c == rowId.id) {
        ele.buildertek__Grouping__c =
          selectedGrouping.length > 0 ? selectedGrouping[0].id : null;
        break;
      }
    }
  }

  handleInputChange(event) {
    const { id, field } = event.target.dataset;
    const value = event.target.value;
    const updatedItem = this.selectedQuoteLineRecords.find(
      (item) => item.buildertek__RFQ__c === id
    );
    if (updatedItem) {
      updatedItem[field] = value;
    }
  }

  closeChildScreen(isRefresh) {
    this.resetValues();
    if (isRefresh) {
      this.dispatchEvent(
        new CustomEvent("closechildscreen", { detail: { refresh: true } })
      );
      return;
    }
    this.dispatchEvent(
      new CustomEvent("closechildscreen", { detail: { refresh: false } })
    );
  }

  showToastMsg(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      })
    );
  }
}
