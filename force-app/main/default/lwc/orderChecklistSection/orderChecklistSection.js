import { LightningElement, api, track } from 'lwc';
import getChecklistSectionSubsection from '@salesforce/apex/OrderChecklistController.getChecklistSectionSubsection';
import saveSectionOrderOnServer from '@salesforce/apex/OrderChecklistController.updateCheckListForSectionOrder';
import saveSubsectionOrderOnServer from '@salesforce/apex/OrderChecklistController.updateCheckListForSubsectionOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderChecklistSection extends LightningElement {
    @api checkListId;
    @track presentSections = [];
    @track presentSubsections = [];
    @track comboOptions = [];
    comboValue = '';
    @track orderedSectionList = [];
    @track orderedSubsectionList = [];
    tempArrayToAppendDataForSubSection = [];
    @track jsonStringForSection;
    @track jsonStringForSubsection;
    @api isOrderSection = false;
    globalSubsectionMap = {};


    connectedCallback() {
        console.log('this is checklist id ', this.checkListId);
        this.fetchCheckListSections();
    }

    async fetchCheckListSections() {
        let result = await getChecklistSectionSubsection({ checkListId: this.checkListId });
        console.log('this is result ', result);
        if (result.message === 'success' && this.isOrderSection) {
            this.doOperationForSection(result);
        } else if (result.message === 'success' && !this.isOrderSection) {
            this.doOperationForSubsection(result);
        } else {
            this.showToast('Error', result.message, 'error');
        }
    }

    doOperationForSection(result) {
        let orderedSection = result.storedSectionOrder ? JSON.parse(result.storedSectionOrder) : {};
        console.log('ordered section ', orderedSection);
        result.sectionList.forEach((section, index) => {
            //* create data for the lightning-dual-listbox
            section['label'] = section.Name;
            section['value'] = section.Name;

            //* push data into list for value attribute in lightning-dual-listbox
            if (orderedSection[section.Name]) {
                this.orderedSectionList.push(section.Name);
            }
        });
        this.presentSections = result.sectionList;
    }

    doOperationForSubsection(result) {
        let orderedSubsection = result.storedSubsectionOrder ? JSON.parse(result.storedSubsectionOrder) : {};
        console.log('orderedSubsection : ', orderedSubsection);
        console.log('OUTPUT of subSectionMap : ', result.subSectionMap);

        //* first create data for comboBox 
        this.comboOptions = this.getValuesForComboBox(result.sectionList, result.subSectionMap);

        //* add labels and values in subsection map
        this.globalSubsectionMap = this.addLableAndValues(result.subSectionMap);
    }

    addLableAndValues(subSectionMap) {
        let tempMap = {};
        Object.keys(subSectionMap).forEach((key) => {
            tempMap[key] = [];
            subSectionMap[key].forEach((subSection) => {
                subSection['label'] = subSection.Name;
                subSection['value'] = subSection.Name;
                // subSection['value'] = subSection.Id;
                tempMap[key].push(subSection);
            });
        });
        return tempMap;
    }

    getValuesForComboBox(sectionList, subSectionMap) {
        let tempOptionList = [];
        sectionList.forEach((section) => {
            // Check if the section has subsections in the map
            if (subSectionMap[section.Id] && subSectionMap[section.Id].length > 0) {
                tempOptionList.push({ 'label': section.Name, 'value': section.Id });
            }
        });
        return tempOptionList;
    }

    cancelPopup() {
        const valueChangeEvent = new CustomEvent("valuechange");
        this.dispatchEvent(valueChangeEvent);
    }

    handleChangeInCombo(event) {
        console.log('this is handleChange method for comobo');
        this.comboValue = event.detail.value;
        console.log('check presentSubsections before ',JSON.parse(JSON.stringify(this.presentSubsections)));
        
        this.presentSubsections = this.globalSubsectionMap[this.comboValue];
        let arrayOfSelectedSubsectionValuePerSectionId = [...this.tempArrayToAppendDataForSubSection]
        this.orderedSubsectionList = arrayOfSelectedSubsectionValuePerSectionId.filter(item => item[this.comboValue] !== undefined).map(item => item[this.comboValue]);
        console.log('this is orderedSubsectionList ', JSON.parse(JSON.stringify(this.orderedSubsectionList)));
        console.log('this is sub section list ', JSON.parse(JSON.stringify(this.presentSubsections)));
    }

    handleOrderChange(event) {
        this.orderedSectionList = event.target.value;
        let orderedSectionJson = {};
        this.orderedSectionList.forEach((value, key) => {
            orderedSectionJson[value] = [];
        });

        this.jsonStringForSection = JSON.stringify(orderedSectionJson);
    }

    handleSubOrderChange(event) {
        this.orderedSubsectionList = event.target.value;
        console.log('OUTPUT of orderedSubsectionList: ', JSON.parse(JSON.stringify(this.orderedSubsectionList)));
        console.log('OUTPUT of comboValue: ', JSON.parse(JSON.stringify(this.comboValue)));
        try {
            let selectedComboValue = this.comboValue;
            let orderedSubsectionJson = {};
            let isExistingValue = false;
            console.log('orderedSubsectionJson ', orderedSubsectionJson);
            orderedSubsectionJson[selectedComboValue] = [];

            this.orderedSubsectionList.forEach((value, key) => {
                orderedSubsectionJson[selectedComboValue]?.push(value);
            });
            this.tempArrayToAppendDataForSubSection.forEach((element, key) => {
                if (element[selectedComboValue]) {
                    this.tempArrayToAppendDataForSubSection.splice(key, 1);
                }
            });

            this.tempArrayToAppendDataForSubSection.push(orderedSubsectionJson);
            this.jsonStringForSubsection = JSON.stringify(this.tempArrayToAppendDataForSubSection);
            console.log('chekc your output : ', JSON.parse(JSON.stringify(this.tempArrayToAppendDataForSubSection)));
        } catch (error) {
            console.log('OUTPUT : ', error);
        }
    }

    saveOrder() {
        console.log('orderedSectionList ', JSON.parse(JSON.stringify(this.orderedSectionList)));

        if (this.isOrderSection) {
            saveSectionOrderOnServer({ checkListId: this.checkListId, jsonSectionOrderedString: this.jsonStringForSection })
                .then(this.cancelPopup())
                .catch(error => {
                    let { errorMessage, errorObject } = this.returnErrorMsg(error);
                    this.showToast('Error', errorMessage, 'error');
                });
        } else {
            saveSubsectionOrderOnServer({ checkListId: this.checkListId, jsonSubsectionOrderedString: this.jsonStringForSubsection })
                .then(this.cancelPopup())
                .catch(error => {
                    let { errorMessage, errorObject } = this.returnErrorMsg(error);
                    this.showToast('Error', errorMessage, 'error');
                });
        }
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
