import { LightningElement, api, track } from "lwc";
import createSectionOrSubsection from '@salesforce/apex/ChooseBTChecklist.createSectionOrSubsection';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class CreateChecklistSectionAndSubsectionCmp extends LightningElement {
  //With this flag we can hide and show the Modal in html file
  @track isOpen = true;
  @api parentSectionId;
  @api checkListId;
  @track formData = {};
  sectionName;
  globalSection;

  connectedCallback() {
    console.log(`checkListId : ${this.checkListId}`);
    console.log(`parentSectionId : ${this.parentSectionId}`);
  }

  hideModal() {
    this.isOpen = false;
    const selectEvent = new CustomEvent('mycustomevent', {
      detail: false
    });
    this.dispatchEvent(selectEvent);
  }

  save() {
    try {
      let sectionName = this.sectionName;
      let globalSection = this.globalSection;
      let selectedCheckListId = this.selectedCheckListId;

      createSectionOrSubsection({
        sectionName: sectionName,
        globalSection: globalSection,
        selectedCheckListId: selectedCheckListId
      })
        .then(result => {
          console.log('result ', result);
          this.isOpen = false;
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Section Created Successfully',
            variant: 'Success',
          });
          this.dispatchEvent(evt);
        })
        .catch(error => {
          console.log('error ', error)
        });
      console.log('sectionName , globalSection, selectedCheckListId ', sectionName, globalSection, selectedCheckListId);
    } catch (error) {
      console.log('error ', error);
    }

  }

  handleFilesChange(event) {
    const field = event.target.dataset.id;
    const value = event.target.value;

    // Update the state based on the input field
    if (field === 'sectionName') {
      this.sectionName = value;
    } else if (field === 'globleSection') {
      this.globalSection = event.target.checked;
    }
    console.log('field ', field);
    console.log('value ', value);
  }

  handleSelected(event) {
    this.selectedCheckListId = event.detail.length > 0 ? event.detail[0].id : null;
    console.log('OUTPUT : ', JSON.parse(JSON.stringify(event.detail)));
  }
}