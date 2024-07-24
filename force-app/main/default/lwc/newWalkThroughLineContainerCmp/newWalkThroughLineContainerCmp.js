import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCategoryRecords from '@salesforce/apex/walkThroughController.getCategoryRecords';
import getFieldDetails from '@salesforce/apex/walkThroughController.getFieldDetails';
import fetchDataAndFieldSetValues from '@salesforce/apex/walkThroughController.fetchDataAndFieldSetValues';
import updateRecord from '@salesforce/apex/walkThroughController.updateRecord';
import deleteRecord from '@salesforce/apex/walkThroughController.deleteRecord';
import getSharinPixSetting from '@salesforce/apex/walkThroughController.getSharinPixSetting';

const actions = [
    { label: 'View', name: 'view' },
    { label: 'Edit', name: 'edit' },
    { label: 'Add Images', name: 'fileupload' },
    { label: 'Delete', name: 'delete' }
];

export default class NewWalkThroughLineContainerCmp extends NavigationMixin(LightningElement) {
    @track categories;
    @track selectedCategory = '';
    @track selectedCategoryLabel = '';
    @track fieldDetails = [];
    @api recordId;
    @track dataAvailable = false;
    @track isColumnsDataAvailable = false;
    @track acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx'];
    @track wtlId = '';

    @track data;
    @track columns;
    @track error;
    fldsItemValues = [];
    isInitalRender = true;
    isEditable = true;
    @track isUpdate = false;
    @track reloadVar = true;
    @track showNewModel = false;
    @track showFileUploadModel = false;

    @track isLoading = true;

    // @track isButtonVisible = false;
    @track originalData = [];
    changedFieldValues = {};

    @track field_container = false;

    SharinPixIsEnable;
    SharinPixPreSubValue;
    SharinPixPostSubValue;

    @api inputFieldClassFromParent = '';
    @api fieldLabel;
    @api disabled = false;
    @api placeholder = "Select";
    @api options;
    @api value = "";
    @api errMsgs;

    connectedCallback() {
        console.log('recordId-->', this.recordId);
        this.getCategoryData();
        this.getAdminSettingForSharinPix();
    }

    getCategoryData(){
        getCategoryRecords({recordId: this.recordId})
            .then((result) => {
                this.categories = result;
                console.log('this.categories-->', this.categories);
                if (result.length > 0) {
                    this.selectedCategory = result[0].Id;
                    this.selectedCategoryLabel = result[0].Name;
                    this.assignFirstCategory();
                } else {
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.error(error);
                this.showToast('Error', 'No Category found, please select the category on walkthrough.', 'error');
                this.isLoading = false;
            });
    }

    getAdminSettingForSharinPix() {
        getSharinPixSetting()
            .then((result) => {
                if (result != null) {
                    this.SharinPixIsEnable = result[0].buildertek__SharinPix_Feature__c;
                    this.SharinPixPreSubValue = result[0].buildertek__SharinPix_Pre_Sub_Token__c;
                    this.SharinPixPostSubValue = result[0].buildertek__SharinPix_Post_Sub_Token__c;
                } else {
                    this.SharinPixIsEnable = false;
                }
            })
            .catch((error) => {
                console.log('error-->', error);
            })
    }

    assignFirstCategory() {
        const selectedCategoryLabel = this.selectedCategoryLabel;

        getFieldDetails({ objectName: 'buildertek__Walk_Through_List__c', recordId: this.recordId })
            .then((result) => {
                console.log('result-->', result);
                this.fieldDetails = result.filter(field => {
                    const lowerCaseFieldName = field.fieldName.toLowerCase();
                    const lowerCaseSelectedCategoryLabel = selectedCategoryLabel.replace(/\s+/g, '_').toLowerCase();
                    return lowerCaseFieldName.includes(lowerCaseSelectedCategoryLabel);
                }).map(field => ({
                    fieldLabel: field.fieldLabel,
                    fieldType: this.getFieldValue(field.fieldType),
                    fieldName: field.fieldName,
                    fieldValue: field.fieldValue ? this.changefieldvalue(field.fieldValue, field.fieldType) : '',
                    isPicklist: this.returnTrueOrFalseForPicklist(field.fieldType),
                    isCheckBox: this.returnTrueOrFalseForCheckbox(field.fieldType),
                    isDateTime: this.returnTrueOrFalseForDateTime(field.fieldType),
                    isRegular: this.returnTrueOrFalseForRegular(field.fieldType),
                    picklistOptions: field.picklistValues ? field.picklistValues : []
                }));
                this.field_container = true;
                console.log('this.fieldDetails-->', this.fieldDetails);
                this.originalData = this.fieldDetails;
                this.dataAvailable = true;
                this.getRelatedRecords();
            })
            .catch((error) => {
                console.error(error);
                this.isLoading = false;
            });
    }

    handleCategorySelect(event) {
        this.isLoading = true;
        const selectedCategory = event.currentTarget.value;
        const selectedCategoryLabel = event.currentTarget.label;
        this.selectedCategory = selectedCategory;
        this.selectedCategoryLabel = selectedCategoryLabel;
        getFieldDetails({ objectName: 'buildertek__Walk_Through_List__c', recordId: this.recordId })
            .then((result) => {
                console.log('result-->', result);
                this.fieldDetails = result.filter(field => {
                    const lowerCaseFieldName = field.fieldName.toLowerCase();
                    const lowerCaseSelectedCategoryLabel = selectedCategoryLabel.replace(/\s+/g, '_').toLowerCase();
                    return lowerCaseFieldName.includes(lowerCaseSelectedCategoryLabel);
                }).map(field => ({
                    fieldLabel: field.fieldLabel,
                    fieldType: this.getFieldValue(field.fieldType),
                    fieldName: field.fieldName,
                    fieldValue: field.fieldValue ? this.changefieldvalue(field.fieldValue, field.fieldType) : '',
                    isPicklist: this.returnTrueOrFalseForPicklist(field.fieldType),
                    isCheckBox: this.returnTrueOrFalseForCheckbox(field.fieldType),
                    isDateTime: this.returnTrueOrFalseForDateTime(field.fieldType),
                    isRegular: this.returnTrueOrFalseForRegular(field.fieldType),
                    picklistOptions: field.picklistValues ? field.picklistValues : []
                }));
                this.field_container = true;
                this.originalData = this.fieldDetails;
                this.dataAvailable = true;
                this.getRelatedRecords();
            })
            .catch((error) => {
                console.error(error);
                this.isLoading = false;
            });

        const saveCancelButton = this.template.querySelector('.save_cancle_btn');
        if (saveCancelButton != null) {
            saveCancelButton.classList.remove('add_flex');
        }

    }

    get isPicklist() {
        for (let i = 0; i < this.fieldDetails.length; i++) {
            if (this.fieldDetails[i].fieldType === 'PICKLIST') {
                return true;
            }
        }

        return false;
    }

    getFieldValue(field) {
        if (field === 'DOUBLE' || field === 'INTEGER') {
            return 'NUMBER';
        } else if (field === 'STRING') {
            return 'TEXT';
        } else if (field === 'BOOLEAN') {
            return 'CHECKBOX';
        } else if (field === 'DATETIME') {
            return 'DATETIME-LOCAL';
        } else {
            return field;
        }
    }

    updatethelatestvalue() {
        const selectedCategoryLabel = this.selectedCategoryLabel;

        getFieldDetails({ objectName: 'buildertek__Walk_Through_List__c', recordId: this.recordId })
            .then((result) => {
                console.log('result-->', result);
                this.fieldDetails = result.filter(field => {
                    const lowerCaseFieldName = field.fieldName.toLowerCase();
                    const lowerCaseSelectedCategoryLabel = selectedCategoryLabel.replace(/\s+/g, '_').toLowerCase();
                    return lowerCaseFieldName.includes(lowerCaseSelectedCategoryLabel);
                }).map(field => ({
                    fieldLabel: field.fieldLabel,
                    fieldType: this.getFieldValue(field.fieldType),
                    fieldName: field.fieldName,
                    fieldValue: field.fieldValue ? this.changefieldvalue(field.fieldValue, field.fieldType) : '',
                    isPicklist: this.returnTrueOrFalseForPicklist(field.fieldType),
                    isCheckBox: this.returnTrueOrFalseForCheckbox(field.fieldType),
                    isDateTime: this.returnTrueOrFalseForDateTime(field.fieldType),
                    isRegular: this.returnTrueOrFalseForRegular(field.fieldType),
                    picklistOptions: field.picklistValues ? field.picklistValues : []
                }));
                this.field_container = true;
                this.originalData = this.fieldDetails;
                this.dataAvailable = true;
                this.getRelatedRecords();
            })
            .catch((error) => {
                console.error(error);
                this.isLoading = false;
            });
    }

    returnTrueOrFalseForPicklist(field) {
        if (field === 'PICKLIST') {
            return true;
        } else {
            return false;
        }
    }

    returnTrueOrFalseForCheckbox(field) {
        if (field === 'BOOLEAN') {
            return true;
        } else {
            return false;
        }
    }

    returnTrueOrFalseForDateTime(field) {
        if (field === 'DATE' || field === 'DATETIME' || field === 'TIME') {
            return true;
        } else {
            return false;
        }
    }

    returnTrueOrFalseForRegular(field) {
        if (field === 'DATE' || field === 'PICKLIST' || field === 'BOOLEAN' || field === 'DATETIME' || field === 'TIME') {
            return false;
        } else {
            return true;
        }
    }

    changefieldvalue(fieldValue, fieldType) {
        if (fieldType == 'DATETIME') {
            let datetimeValue = '2024-05-15T19:12:00.000Z';
            let datetimeLocalValue = datetimeValue.slice(0, -1);
            return datetimeLocalValue;
        } else if (fieldType == 'TIME') {
            let timeValue = fieldValue;
            let date = new Date(timeValue);
            let hours = date.getHours().toString().padStart(2, '0');
            let minutes = date.getMinutes().toString().padStart(2, '0');
            let timeString = hours + ':' + minutes;
            return timeString;
        } else {
            return fieldValue;
        }
    }

    getParameterByName(name) {
        var url = window.location.href;
        var regex = /buildertek__Walk_Through_List__c\/([^\/]+)/;
        var match = regex.exec(url);
        if (match && match.length > 1) {
            return match[1];
        }
        return null;
    }

    renderedCallback() {
        if (this.isInitalRender) {
            const body = document.querySelector("body");

            const style = document.createElement('style');
            style.innerText = `
                .datatable_class .slds-cell-fixed {
                    background: #e0ebfa !important;
                    color:#0176d3;
                }

                .slds-dropdown_length-with-icon-10{
                    max-height: 55vh !important;
                }
            `;

            body.appendChild(style);
            this.isInitalRender = false;
        }

    }

    getRelatedRecords() {
        this.data = undefined;
        this.isLoading = true;
        fetchDataAndFieldSetValues({
            wtRecordId: this.recordId,
            categoryId: this.selectedCategory,
            sObjectName: 'buildertek__Walk_Through_Line_Items__c',
            fieldSetName: 'buildertek__FieldsForDT'
        })
            .then(result => {
                console.log('result', result.FieldSetValues);
                const labelsToFilter = ["SharinPix Token", "SharinPix Tag"];
                let cols = [
                    {
                        label: '',
                        fieldName: 'cameraButton',
                        type: 'button-icon',
                        fixedWidth: 50,
                        typeAttributes: {
                            iconName: 'utility:photo',
                            name: 'camera_icon_click',
                            title: 'Camera Icon',
                            variant: 'bare',
                            alternativeText: 'Camera Icon'
                        },
                        hideDefaultActions: true
                    }
                ];
                result.FieldSetValues.forEach(currentItem => {
                    let col = { label: currentItem.label, fieldName: currentItem.name, type: currentItem.type };
                    cols.push(col);
                });
                cols = cols.filter(col => !labelsToFilter.includes(col.label));
                cols.push({ type: 'action', typeAttributes: { rowActions: actions } });
                this.columns = cols;
                if (result.WalkthroughLineItems.length > 0) {
                    this.data = result.WalkthroughLineItems;
                    this.error = undefined;
                    this.isColumnsDataAvailable = true;
                } else {
                    this.data = undefined;
                    this.error = undefined;
                    this.isColumnsDataAvailable = false;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.data = undefined;
                this.isLoading = false;
            });
    }
    
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const recordId = row.Id;
        const sharinPixToken = row.buildertek__SharinPix_Token__c;
        const sharinPixTag = row.buildertek__SharinPix_Tag__c;
        switch (actionName) {
            case 'edit':
                this.openEditModel(recordId);
                break;
            case 'fileupload':
            case 'camera_icon_click':
                this.openfileattachmodal(recordId, sharinPixToken, sharinPixTag);
                break;
            case 'delete':
                this.deleteChild(recordId);
                break;
            case 'view':
                this.navigateToRecordViewPage(recordId);
                break;
            default:
        }
    }

    deleteChild(recordId) {
        this.isLoading = true;
        deleteRecord({ recordId: recordId })
            .then(result => {
                console.log('Record deleted successfully-->', result);
                this.getRelatedRecords();
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error deleting record:', error);
                this.isLoading = false;
            });
    }

    navigateToRecordViewPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view',
            },
        });
    }

    openfileattachmodal(recordId, sharinPixToken, sharinPixTag) {
        if (this.SharinPixIsEnable == true) {
            if (sharinPixToken != undefined) {
                var SharinPixUrl;
                if (sharinPixTag != undefined && sharinPixTag != null && sharinPixTag != '') {
                    SharinPixUrl = this.SharinPixPreSubValue + sharinPixToken + sharinPixTag + this.SharinPixPostSubValue;
                } else {
                    SharinPixUrl = this.SharinPixPreSubValue + sharinPixToken + this.SharinPixPostSubValue;
                }
                console.log('SharingPix url---> ', SharinPixUrl);
                
                const config = {
                    type: 'standard__webPage',
                    attributes: {
                        url: SharinPixUrl
                    }
                };
                this[NavigationMixin.Navigate](config);
            } else {
                this.showToast('Error', 'Token is missing, please enter the token first.', 'error');
            }
        } else {
            this.showFileUploadModel = true;
            this.wtlId = recordId;
        }
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles-->', uploadedFiles);
        this.showFileUploadModel = false;
    }


    hideModalBox() {
        this.showFileUploadModel = false;
    }

    openEditModel(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'edit',
            },
        });
    }

    handlePlusButtonClick() {
        this.showNewModel = true;
    }

    handleClose() {
        this.showNewModel = false;
    }

    handleCloseAndRefresh() {
        this.showNewModel = false;
        this.refreshTheDataTable();
    }

    handlerefresh(){
        this.showNewModel = false;
        this.refreshTheDataTable();
        setTimeout(() => {
            const plusIcon = this.template.querySelector('.plusIcon');
            plusIcon.click();
        }, 0);
    }

    refreshTheDataTable() {
        this.getRelatedRecords();
    }

    inputValueIsChanged(event) {
        console.log('input value is changed');
        const fieldName = event.target.dataset.fieldname;
        const fieldType = event.target.dataset.fieldtype;
        var changedValue;
        if (fieldType == 'CHECKBOX') {
            changedValue = event.target.checked;
        } else {
            changedValue = event.target.value;
        }

        this.changedFieldValues[fieldName] = changedValue;
        console.log('fieldDetails-->', this.changedFieldValues);

        const saveCancelButton = this.template.querySelector('.save_cancle_btn');
        saveCancelButton.classList.add('add_flex');
    }

    saveChanges() {
        // this.isLoading = true;
        const spinnerShow = this.template.querySelector('.hidden');
        spinnerShow.classList.add('showSpinner');

        const changedFields = {};
        Object.keys(this.changedFieldValues).forEach(fieldName => {
            const originalValue = this.originalData.find(detail => detail.fieldName === fieldName).fieldValue;
            const changedValue = this.changedFieldValues[fieldName];
            if (originalValue !== changedValue) {
                changedFields[fieldName] = changedValue;
            }
        });

        updateRecord({ recordId: this.recordId, newFieldValues: changedFields })
            .then(result => {
                console.log('Record updated successfully-->', result);
                if (result == 'success') {
                    this.changedFieldValues = {};
                    const saveCancelButton = this.template.querySelector('.save_cancle_btn');
                    saveCancelButton.classList.remove('add_flex');
                    this.showToast('Success', 'Your record has been successfully updated.', 'success');
                    // this.updatethelatestvalue();
                    // this.isLoading = false;
                    const spinnerHide = this.template.querySelector('.hidden');
                    spinnerHide.classList.remove('showSpinner');
                } else {
                    this.showToast('Failed to Update Record', result, 'error');
                    // this.revertChanges();
                    // this.isLoading = false;
                    const spinnerHide1 = this.template.querySelector('.hidden');
                    spinnerHide1.classList.remove('showSpinner');
                }

            })
            .catch(error => {
                console.error('Error updating record:', error);
                // this.isLoading = false;
                this.showToast('Failed to Update Record', 'A internal error has occurred.', 'error');
                const spinnerHide1 = this.template.querySelector('.hidden');
                spinnerHide1.classList.remove('showSpinner');
            });
    }


    revertChanges() {
        this.isLoading = true;

        this.fieldDetails = JSON.parse(JSON.stringify(this.originalData));

        const saveCancelButton = this.template.querySelector('.save_cancle_btn');
        saveCancelButton.classList.remove('add_flex');

        this.changedFieldValues = {};

        this.isLoading = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    optionsClickHandler(event) {
        try {
            const fieldName = event.currentTarget.dataset.fieldname;
            const selectedValue = event.currentTarget.dataset.value;
    
            const inputField = this.template.querySelector(`input[data-fieldname="${fieldName}"]`);
            inputField.value = selectedValue;
    
            this.changedFieldValues[fieldName] = selectedValue;

            const divElement = this.template.querySelector(`[data-dropdown-id="${fieldName}"]`);
            divElement.classList.remove('slds-is-open');

            const saveCancelButton = this.template.querySelector('.save_cancle_btn');
            saveCancelButton.classList.add('add_flex');

        } catch (error) {
            console.error('Error in optionsClickHandler:', error);
        }
    }
 
    closeDropdown(event) {
        const fieldName = event.currentTarget.dataset.fieldname;

        const divElement = this.template.querySelector(`[data-dropdown-id="${fieldName}"]`);

        if (divElement) {
            divElement.classList.remove('slds-is-open');
        }
    }
 
    handleInputClick(event) {
        const fieldName = event.currentTarget.dataset.fieldname;

        const divElement = this.template.querySelector(`[data-dropdown-id="${fieldName}"]`);

        if (divElement) {
            divElement.classList.add('slds-is-open');
        }

    }

    preventHide(event) {
        event.preventDefault();
    }
    
}