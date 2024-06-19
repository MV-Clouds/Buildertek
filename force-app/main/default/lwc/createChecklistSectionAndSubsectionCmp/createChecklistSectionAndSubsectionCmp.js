import { LightningElement, api, track } from "lwc";
import createSectionOrSubsection from "@salesforce/apex/ChooseBTChecklist.createSectionOrSubsection";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CreateChecklistSectionAndSubsectionCmp extends LightningElement {
  //With this flag we can hide and show the Modal in html file
  @track isOpen = true;
  @api parentSectionId;
  @api parentSectionList;
  @track defaultSectionName;
  @api defaultCheckListId;
  @api checkListId;
  @track disableLookup = false;
  @track disableButton = true;
  @track isSaveClicked = false;
  sectionName = "";
  globalSection = false;

  connectedCallback() {
    try{
      console.log('in connectedCallback defaultCheckListId : ');
      let t = this.defaultCheckListId;
      // BUG: checkThis line in the morning First
      console.log('in connectedCallback defaultCheckListId : ', JSON.stringify(t));
      console.log(`checkListId : ${this.checkListId}`);
      console.log(`parentSectionId : ${this.parentSectionId}`);
      let da = this.parentSectionList;
      console.log('parentSectionList ', JSON.parse(JSON.stringify(da)));
      if(this.parentSectionId){
        da?.sectionList?.forEach(section => {
          if(section.Id == this.parentSectionId){
            this.defaultSectionName = section.Name;
            return;
          }
        });
      }
    } catch (error) {
      console.log("error ", error);
    }
  }

  hideModal() {
    this.isOpen = false;
    this.defaultCheckListId = {};
    this.checkListId = null;
    this.parentSectionId = null;
    this.defaultSectionName = "";

    const selectEvent = new CustomEvent("mycustomevent", {
      detail: false,
    });
    this.dispatchEvent(selectEvent);
  }

  save() {
    try {
      this.isSaveClicked = true;
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
        this.isSaveClicked = false;
        return;
      }
 
      createSectionOrSubsection({
        sectionName: sectionName,
        isGlobal: globalSection,
        checkListId: selectedCheckListId || this.defaultCheckListId[0]?.id,
        parentId: this.parentSectionId,
      })
        .then((result) => {
          this.isSaveClicked = false;
          console.log("result ", result);
          if (result == "success") {
            this.isOpen = false;
            this.defaultCheckListId = {};
            this.checkListId = null;
            this.parentSectionId = null;
            this.defaultSectionName = "";
            const evt = new ShowToastEvent({
              title: "Success",
              message: "Section Created Successfully",
              variant: "Success",
            });
            this.dispatchEvent(evt);
            const selectEvent = new CustomEvent("mycustomevent", {
              detail: false,
            });
            this.dispatchEvent(selectEvent);

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

      console.log("handleFileChanges called");
      console.log("defaultCheckListId ", this.defaultCheckListId);
      const field = event.target.dataset.id;
      const value = event.target.value;
      let selectedCheckListId = this.selectedCheckListId;

      console.log("selectedChechKistId ", selectedCheckListId);
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
        (this.globalSection || this.selectedCheckListId || this.defaultCheckListId)
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
      (this.globalSection || this.selectedCheckListId || this.defaultCheckListId?.id)
      ? false
      : true;

    console.log("OUTPUT : ", JSON.parse(JSON.stringify(event.detail)));
  }
}
