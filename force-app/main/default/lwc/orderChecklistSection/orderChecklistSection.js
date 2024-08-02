import { LightningElement, api, track } from 'lwc';
import getChecklistSectionSubsection from '@salesforce/apex/OrderChecklistController.getChecklistSectionSubsection';
import saveSectionOrderOnServer from '@salesforce/apex/OrderChecklistController.updateCheckListForSectionOrder';

export default class OrderChecklistSection extends LightningElement {
    @api checkListId;
    @track presentSections = [];
    @track presentSubsections = [];
    @track comboOptions = [];
    comboValue = '';
    @track orderedSectionList = [];
    @track orderedSubectionList = [];
    @track jsonStringForSection; 
    @track jsonStringForSubsection; 
    @api isOrderSection = false;
    globalSubsectionMap = {};
    

    connectedCallback() {
        console.log('this is checklist id ',this.checkListId);
        this.fetchCheckListSections();
    }

    fetchCheckListSections() {
        getChecklistSectionSubsection({checkListId: this.checkListId})
            .then(result => {
                console.log('this is result ',result);
                let orderedSection = result.storedSectionOrder ? JSON.parse(result.storedSectionOrder) : {};
                let orderedSubsection = result.storedSubsectionOrder ? JSON.parse(result.storedSubsectionOrder) : {};
                let tempOptionList = [];
                console.log('ordered section ',orderedSection);
                result.sectionList.forEach((section, index) => {
                    section['label'] = section.Name;
                    section['value'] = section.Name;

                    if(orderedSection[section.Name]) {
                        this.orderedSectionList.push(section.Name);
                    }
                    if(section.Id in result?.subSectionMap){
                        tempOptionList.push({'label': section.Name, 'value': section.Id});
                    }
                    // WARN: Adding lable and value for combobox values
                    result.subSectionMap[section.Id].forEach((subSection, index) => {
                        subSection['label'] = subSection.Name;
                        subSection['value'] = subSection.Id;
                    });
                });
                this.presentSections = result.sectionList;
                this.comboOptions = [...tempOptionList];
                this.globalSubsectionMap = result.subSectionMap;
                console.log('combo options ',JSON.parse(JSON.stringify(this.comboOptions)));
            })
            .catch(error => {
                console.log('this is error ',error);
            });
    }

    cancelPopup() {
        const valueChangeEvent = new CustomEvent("valuechange");
        this.dispatchEvent(valueChangeEvent);
    }

    handleChangeInCombo(event){
        console.log('this is handleChange method for comobo');
        this.comboValue = event.detail.value;
        this.presentSubsections = this.globalSubsectionMap[this.comboValue];
        console.log('this is sub section list ',JSON.parse(JSON.stringify(this.presentSubsections)));
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
        this.orderedSubectionList = event.target.value;
        let orderedSubsectionJson = {};
        this.orderedSectionList.forEach((value, key) => {
            orderedSubsectionJson[value] = [];
        });

        this.jsonStringForSubsection = JSON.stringify(orderedSubsectionJson);
    }

    saveOrder() {
        saveSectionOrderOnServer({checkListId: this.checkListId, jsonSectionOrderedString: this.jsonStringForSection})
            .then(result => {
                console.log('this is result ',result);
                this.cancelPopup();
            })
            .catch(error => {
                console.log('this is error ',error);
            });
    }

}
