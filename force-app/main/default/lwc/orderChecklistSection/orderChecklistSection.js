import { LightningElement, api, track } from 'lwc';
import getChecklistSectionSubsection from '@salesforce/apex/OrderChecklistController.getChecklistSectionSubsection';
import saveSectionOrderOnServer from '@salesforce/apex/OrderChecklistController.updateCheckListForSectionOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderChecklistSection extends LightningElement {
    @api checkListId;
    @track presentSections = [];
    @track orderedSectionList = [];
    @track jsonStringForSection;

    connectedCallback() {
        console.log('this is checklist id ', this.checkListId);
        this.fetchCheckListSections();
    }

    async fetchCheckListSections() {
        let result = await getChecklistSectionSubsection({ checkListId: this.checkListId });
        console.log('this is result ', result);
        if (result.message === 'success') {
            this.doOperationForSection(result);
        } else {
            this.showToast('Error', result.message, 'error');
        }
    }

    doOperationForSection(result) {
        let orderedSection = result.storedSectionOrder ? JSON.parse(result.storedSectionOrder) : {};
        this.orderedSectionList = Object.keys(orderedSection);
        console.log('ordered section ', orderedSection);
        result.sectionList.forEach((section, index) => {
            //* create data for the lightning-dual-listbox
            section['label'] = section.Name;
            section['value'] = section.Name;
        });
        this.presentSections = result.sectionList;
    }

    cancelPopup() {
        const valueChangeEvent = new CustomEvent("valuechange");
        this.dispatchEvent(valueChangeEvent);
    }

    handleOrderChange(event) {
        this.orderedSectionList = event.target.value;
        let orderedSectionJson = {};
        this.orderedSectionList.forEach((value, key) => {
            orderedSectionJson[value] = [];
        });

        this.jsonStringForSection = JSON.stringify(orderedSectionJson);
    }

    saveOrder() {
        console.log('orderedSectionList ', JSON.parse(JSON.stringify(this.orderedSectionList)));
        saveSectionOrderOnServer({ checkListId: this.checkListId, jsonSectionOrderedString: this.jsonStringForSection })
            .then(result => {
                this.showToast('Success', 'Order For Section Updated.', 'success');
                this.cancelPopup();
            })
            .catch(error => {
                let { errorMessage, errorObject } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            });
    }

    returnErrorMsg(error) {
        console.error('An error occurred:', error);

        let errorMessage = 'Unknown error';
        if (error && error.body) {
            if (error.body.message) {
                errorMessage = error.body.message;
            } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                errorMessage = error.body.pageErrors[0].message;
            }
        } else if (error && error.message) {
            errorMessage = error.message;
        }

        return { errorMessage, errorObject: error };
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
