import { api, LightningElement, track, wire } from 'lwc';
import getCategoryRecords from '@salesforce/apex/walkThroughController.getCategoryRecords';
import getFieldDetails from '@salesforce/apex/walkThroughController.getFieldDetails';
import fetchWalkthroughLineData from '@salesforce/apex/walkThroughController.fetchWalkthroughLineData';
import getFieldSet from '@salesforce/apex/walkThroughController.getFieldSetValues';
import updateRecord from '@salesforce/apex/walkThroughController.updateRecord';
import deleteRecord from '@salesforce/apex/walkThroughController.deleteRecord';
import { NavigationMixin } from "lightning/navigation";
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

const actions = [
    { label: 'View', name: 'view'},
    { label: 'Edit', name: 'edit' },
    { label: 'File Upload', name: 'na' },
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

    @track isLoading = false;

    // @track isButtonVisible = false;
    @track originalData = [];
    changedFieldValues = {};

    @track field_container = false;

    subscription = {};
    CHANNEL_NAME = '/event/Refresh_Related_List__e';

    connectedCallback() {
        this.recordId = this.getParameterByName();
        console.log('record idd in connected callback==>', this.recordId);

        getCategoryRecords()
            .then((result) => {
                this.categories = result;
                console.log('len-->', result.length);
                if (result.length > 0) {
                    this.selectedCategory = result[0].Id;
                    this.selectedCategoryLabel = result[0].Name;
                    this.assignFirstCategory();
                }
            })
            .catch((error) => {
                console.error(error);
            });

        subscribe(this.CHANNEL_NAME, -1, this.refreshList).then(response => {
            this.subscription = response;
        });
        onError(error => {
            console.error('Server Error--->' + error);
        });
    }

    assignFirstCategory() {
        this.isLoading = true;
        getFieldDetails({ objectName: 'buildertek__Walk_Through_List__c', recordId: this.recordId })
            .then((result) => {
                console.log('result-->', result);
                this.fieldDetails = result.filter(field => field.fieldName.includes(this.selectedCategoryLabel)).map(field => ({
                    fieldLabel: field.fieldLabel,
                    fieldType: this.getFieldValue(field.fieldType),
                    fieldName: field.fieldName,
                    fieldValue: field.fieldValue || '',
                    isPicklist: this.returnTrueOrFalse(field.fieldType),
                    picklistOptions: field.picklistValues ? this.preprocessPicklistValues(field.picklistValues, field.fieldValue) : []
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

    handleCategorySelect(event) {
        this.isLoading = true;
        const selectedCategory = event.currentTarget.value;
        const selectedCategoryLabel = event.currentTarget.label;
        this.selectedCategory = selectedCategory;
        this.selectedCategoryLabel = selectedCategoryLabel;
        getFieldDetails({ objectName: 'buildertek__Walk_Through_List__c', recordId: this.recordId })
            .then((result) => {
                console.log('result-->', result);
                this.fieldDetails = result.filter(field => field.fieldName.includes(selectedCategoryLabel)).map(field => ({
                    fieldLabel: field.fieldLabel,
                    fieldType: this.getFieldValue(field.fieldType),
                    fieldName: field.fieldName,
                    fieldValue: field.fieldValue || '',
                    isPicklist: this.returnTrueOrFalse(field.fieldType),
                    picklistOptions: field.picklistValues ? this.preprocessPicklistValues(field.picklistValues, field.fieldValue) : []
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

    preprocessPicklistValues(picklistValues, fieldValue) {
        return picklistValues.map(option => ({
            value: option,
            selected: option === fieldValue
        }));
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
            return 'NUMBER'; // Return number as is
        } else if (field === 'STRING') {
            return 'TEXT'; // Return text or empty string for other types
        } else {
            return field;
        }
    }

    updatethelatestvalue() {
        const selectedCategoryLabel = this.selectedCategoryLabel;

        getFieldDetails({ objectName: 'buildertek__Walk_Through_List__c', recordId: this.recordId })
            .then((result) => {
                console.log('result-->', result);
                this.fieldDetails = result.filter(field => field.fieldName.includes(selectedCategoryLabel)).map(field => ({
                    fieldLabel: field.fieldLabel,
                    fieldType: this.getFieldValue(field.fieldType),
                    fieldName: field.fieldName,
                    fieldValue: field.fieldValue || '',
                    isPicklist: this.returnTrueOrFalse(field.fieldType),
                    picklistOptions: field.picklistValues ? this.preprocessPicklistValues(field.picklistValues, field.fieldValue) : []
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

    returnTrueOrFalse(field) {
        if (field === 'PICKLIST') {
            return true;
        } else {
            return false;
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
                .datatable_class .slds-cell-fixed{
                    background: #0678FF1A !important;
                }
            `;

            body.appendChild(style);
            this.isInitalRender = false;
        }
    }

    refreshList = () => {
        this.getRelatedRecords();
    }

    disconnectedCallback() {
        unsubscribe(this.subscription, () => {
            console.log('Unsubscribed Channel');
        });
    }

    getRelatedRecords() {
        this.isLoading = true;
        fetchWalkthroughLineData({ wtRecordId: this.recordId, categoryId: this.selectedCategory })
            .then(result => {
                if (result.length > 0) {
                    this.data = result;
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

    @wire(getFieldSet, { sObjectName: 'buildertek__Walk_Through_Line_Items__c', fieldSetName: 'buildertek__FieldsForDT' })
    wiredFields({ error, data }) {
        if (data) {
            data = JSON.parse(data);
            let cols = [];
            data.forEach(currentItem => {
                let col = { label: currentItem.label, fieldName: currentItem.name, type: currentItem.type };
                cols.push(col);
            });
            cols.push({ type: 'action', typeAttributes: { rowActions: actions } })
            this.columns = cols;
        } else if (error) {
            console.log(error);
            this.error = error;
            this.columns = undefined;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const recordId = row.Id;
        switch (actionName) {
            case 'edit':
                this.openEditModel(recordId);
                break;
            case 'na':
                this.openfileattachmodal(recordId);
                console.log('na is pressed');
                break;
            case 'delete':
                this.deleteChild(recordId);
                console.log('delete is pressed');
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


    openfileattachmodal(recordId) {
        console.log('recordId-->', recordId);
        this.showFileUploadModel = true;
        this.wtlId = recordId;
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

    refreshTheDataTable() {
        this.getRelatedRecords();
    }

    inputValueIsChanged(event) {
        console.log('input value is changed');
        const fieldName = event.target.dataset.fieldname;
        const changedValue = event.target.value;

        this.changedFieldValues[fieldName] = changedValue;
        console.log('fieldDetails-->', this.changedFieldValues);

        const saveCancelButton = this.template.querySelector('.save_cancle_btn');
        saveCancelButton.classList.add('add_flex');
    }

    saveChanges() {
        this.isLoading = true;
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
                this.changedFieldValues = {};
                const saveCancelButton = this.template.querySelector('.save_cancle_btn');
                saveCancelButton.classList.remove('add_flex');
                this.updatethelatestvalue();
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error updating record:', error);
                this.isLoading = false;
            });
    }


    revertChanges() {
        this.isLoading = true;

        this.fieldDetails = JSON.parse(JSON.stringify(this.originalData));

        const picklistElements = this.template.querySelectorAll('select[data-fieldname]');

        if (picklistElements != null) {
            picklistElements.forEach(picklist => {
                const fieldName = picklist.dataset.fieldname;
                const originalField = this.originalData.find(field => field.fieldName === fieldName);
                if (originalField) {
                    picklist.value = originalField.fieldValue;
                }
            });
        }

        const saveCancelButton = this.template.querySelector('.save_cancle_btn');
        saveCancelButton.classList.remove('add_flex');

        this.changedFieldValues = {};

        this.isLoading = false;
    }
}