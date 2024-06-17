import { LightningElement, api, track } from "lwc";
import createSectionOrSubsection from "@salesforce/apex/ChooseBTChecklist.createSectionOrSubsection";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CreateChecklistSectionAndSubsectionCmp extends LightningElement {
  //With this flag we can hide and show the Modal in html file
  @track isOpen = true;
  @api parentSectionId;
  @api checkListId;
  @track formData = {};
  @track disableLookup = false;
  @track disableButton = true;
  @track defaultCheckListLookupValue;
  sectionName = "";
  globalSection = false;

  connectedCallback() {
    console.log(`checkListId : ${this.checkListId}`);
    console.log(`parentSectionId : ${this.parentSectionId}`);
  }

  hideModal() {
    this.isOpen = false;
    const selectEvent = new CustomEvent("mycustomevent", {
      detail: false,
    });
    this.dispatchEvent(selectEvent);
  }

  save() {
    try {
      let sectionName = this.sectionName;
      let globalSection = this.globalSection;
      let selectedCheckListId = this.selectedCheckListId;
      console.log("sectionName ", sectionName);
      console.log("globalSEction ", globalSection);
      console.log("selectedCheckListId ", selectedCheckListId);

      if (this.disableButton) {
        const evt = new ShowToastEvent({
          title: "Warning",
          message:
            "Along with Name please fill checkList field or Global Checkbox.",
          variant: "Warning",
          mode: "dismissible",
          duration: 3000,
        });
        this.dispatchEvent(evt);
        return;
      }

      createSectionOrSubsection({
        sectionName: sectionName,
        isGlobal: globalSection,
        checkListId: selectedCheckListId,
        parentId: this.parentSectionId,
      })
        .then((result) => {
          console.log("result ", result);
          if (result == "success") {
            this.isOpen = false;
            const evt = new ShowToastEvent({
              title: "Success",
              message: "Section Created Successfully",
              variant: "Success",
            });
            this.dispatchEvent(evt);
          } else {
            const evt = new ShowToastEvent({
              title: "Error",
              message: result,
              variant: "Error",
            });
            this.dispatchEvent(evt);
          }
        })
        .catch((error) => {
          console.log("error ", error);
        });
      console.log(
        "sectionName , globalSection, selectedCheckListId ",
        sectionName,
        globalSection,
        selectedCheckListId
      );
    } catch (error) {
      console.log("error ", error);
    }
  }

  handleFilesChange(event) {
    try {
      const field = event.target.dataset.id;
      const value = event.target.value;
      let selectedCheckListId = this.selectedCheckListId;
      let defaultCheckListLookupValue = this.defaultCheckListLookupValue;

      console.log("selectedChechKistId ", selectedCheckListId);
      console.log("defaultCheckListLookupValue ", defaultCheckListLookupValue);
      console.log("disableLookup ", this.disableLookup);
      // Update the state based on the input field
      if (field === "sectionName") {
        this.sectionName = value;
      } else if (field === "globleSection") {
        this.globalSection = event.target.checked;
        if (this.globalSection) {
          this.disableLookup = true;
        } else {
          this.disableLookup = false;
        }
        this.template.querySelector("c-lookup").handleClearSelection();
      }

      //  NOTE: Below lines will be disable save button based on the condition
      this.disableButton =
        this.sectionName.length > 0 &&
        (this.globalSection || this.selectedCheckListId)
          ? false
          : true;
      console.log("field ", field);
      console.log("value ", value);
    } catch (error) {
      console.log("error ", error);
    }
  }

  handleSelected(event) {
    this.selectedCheckListId =
      event.detail.length > 0 ? event.detail[0].id : null;

    //  NOTE: Below lines will be disable save button based on the condition
    this.disableButton =
      this.sectionName.length > 0 &&
      (this.globalSection || this.selectedCheckListId)
        ? false
        : true;

    console.log("OUTPUT : ", JSON.parse(JSON.stringify(event.detail)));
  }
}
