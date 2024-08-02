import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getallData from '@salesforce/apex/QuotePage.getallData';
import deleteQuoteLine from '@salesforce/apex/QuotePage.deleteQuoteLine';
import { NavigationMixin } from 'lightning/navigation';
import addGlobalMarkup from '@salesforce/apex/QuotePage.addGlobalMarkup';
import addGlobalMargin from '@salesforce/apex/QuotePage.addGlobalMargin';
import saveQL from '@salesforce/apex/QuotePage.saveQL';
import updateCustomerVisible from '@salesforce/apex/QuotePage.updateCustomerVisible';
import updateCustomerVisiblebyLine from '@salesforce/apex/QuotePage.updateCustomerVisiblebyLine';
import { RefreshEvent } from 'lightning/refresh';

export default class NewQuoteItemcmp extends NavigationMixin(LightningElement) {
    isInitalRender = true;
    @api recordId;
    @track nameFilter = '';
    @track subgroupFilter = 'All';
    @track phaseFilter = 'All';
    @track filterModalSelected = [];
    @track filteredquoteItems;
    @track filteredquoteItemsFinal;
    @track filtermodalColumns = [];
    @track groupsNotConsidered = [];
    @track subgroupOptions = [{ label: '--All--', value: 'All' }];
    @track phaseOptions = [{ label: '--All--', value: 'All' }];
    @track quoteLineEditFields;
    @track isEditModal = false;
    @track isSingleLineenabled;
    @track isMarkup;
    @track isMargin;
    @track groupingOption = [];
    @track presentGroups = [];
    @track globalMarkup = null;
    @track globalMargin = null;
    @track isLoading = true;
    @track showdeleteModal = false;
    @track showfilterModal = false;
    @track showfilterLineModal = false;
    @track deleteRecordId;
    @track quoteName;
    @track currencyCode;
    @track projectName;
    @track quoteData;
    @track quote;
    @track quoteFields;
    @track totalColumns;
    @track columns;
    @track quoteLines;
    @track data = [];
    @track isImportRfqTrue = false;
    @track EditrecordId;
    @track isAddProductTrue = false;
    @track fields = {
        buildertek__Description__c: '',
        buildertek__Grouping__c: '',
        buildertek__Notes__c: '',
        buildertek__Quantity__c: 1,
        buildertek__Unit_Cost__c: 0.00,
        buildertek__Margin__c: null,
        buildertek__Markup__c: null
    };
    @track grandTotalList = [];
    @track filterModal = false;
    @track filterValue = 'PriceBook';
    @track filterOption = [
        { label: 'PriceBook', value: 'PriceBook' },
        { label: 'Vendor', value: 'Vendor' },
    ];
    @track filterGroupId;
    @track showPricebookModal = false;
    @track selectedGroupForAddProduct;
    connectedCallback() {
        this.getData();
        this.handleMassUpdate = this.handleMassUpdate.bind(this);
        window.addEventListener('message', this.handleMessage.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.handleMessage.bind(this));
    }

    renderedCallback() {
        if (this.isInitalRender) {
            console.log('Inital Render');
            const body = document.querySelector("body");
            const style = document.createElement('style');
            style.innerText = `
                .quote-table .slds-cell-fixed{
                    background: #e0ebfa !important;
                    color:#0176d3;
                }

                .lastRowCSS table tr:last-child {
                    font-weight: 700;
                }

                .lastRowCSS table tr:last-child td:nth-child(2) span,
                .lastRowCSS table tr:last-child td:nth-child(3) span,
                .lastRowCSS table tr:last-child td:nth-child(4) span{
                    display: none;
                }
                .editForm {
                    position: relative;
                    height: unset !important;
                    max-height: unset !important;
                }
                .editForm .slds-modal__container {
                    max-width: 42rem !important;
                    width: 70% !important;
                }
                .editForm .cuf-content {
                    padding:  0rem !important;
                }
                .editForm .slds-p-around--medium {
                    padding: 0rem !important;
                }

                .editForm .slds-input {
                    padding-left: 10px;
                }
                
            `;

            body.appendChild(style);
            this.isInitalRender = false;
        }

    }

    refreshData() {
        this.data = [];
        this.getData();
        this.selectedGroupForAddProduct = null;
        this.dispatchEvent(new RefreshEvent());
    }

    handleSingleLineSave() {
        this.isLoading = true;
        this.fields.buildertek__Quantity__c = parseInt(this.fields.buildertek__Quantity__c);
        if (!this.fields.buildertek__Description__c) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Description is required',
                    variant: 'error'
                })
            );
            this.isLoading = false;
            return;
        } else if (!this.fields.buildertek__Quantity__c || this.fields.buildertek__Quantity__c <= 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Quantity should be greater than 0',
                    variant: 'error'
                })
            );
            this.isLoading = false;
            return;
        }

        if (!this.isMarkup) {
            delete this.fields.buildertek__Markup__c;
        }
        if (!this.isMargin) {
            delete this.fields.buildertek__Margin__c;
        }
        //check if fields.buildertek__Grouping__c has the value in groupsNotConsidered then add buildertek__Not_Customer_Visible__c = true
        // if (this.groupsNotConsidered.includes(this.fields.buildertek__Grouping__c)) {
        //     this.fields.buildertek__Not_Customer_Visible__c = true;
        // }
        this.fields.buildertek__Quote__c = this.recordId;
        this.fields.Name = this.fields.buildertek__Description__c;
        console.log({ fields: this.fields });

        saveQL({ QL: this.fields })
            .then(result => {
                console.log({ result });
                if (result == 'Success') {
                    console.log('Record saved successfully');
                    //show toast message 
                    var message = 'Record created successfully';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: message,
                        variant: 'success'
                    }));
                    this.refreshData();
                    this.fields = {
                        buildertek__Description__c: '',
                        buildertek__Grouping__c: '',
                        buildertek__Notes__c: '',
                        buildertek__Quantity__c: 1,
                        buildertek__Unit_Cost__c: 0.00,
                        buildertek__Margin__c: null,
                        buildertek__Markup__c: null
                    };
                } else {
                    var message = 'Error saving record';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error'
                    }));
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log(error);
                const { errorMessage, errorObject } = this.returnErrorMsg(error);
                console.error('Error in updating quote Line:', errorObject);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.isLoading = false;
            })

    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        this.fields[fieldName] = event.target.value;
    }

    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Id = this.EditrecordId;
        this.isEditModal = false;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSucess() {
        this.isLoading = false;
        this.refreshData();
        var message = 'Record updated successfully';
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        }));
    }

    handleError(event) {
        this.isLoading = false;
        console.log('event error ', JSON.parse(JSON.stringify(event.detail)));
        var message = event.detail?.detail || 'Error updating record';
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        }));
    }

    submitDetails2() {
        const btn = this.template.querySelector(".hidden");
        if (btn) {
            btn.click();
        }
    }

    handlePicklistChange(event) {
        this.fields.buildertek__Grouping__c = event.target.value;
    }

    getData() {
        this.isLoading = true;
        var QuoteId = this.recordId;
        console.log('Quote ID: ' + QuoteId);
        getallData({ quoteId: QuoteId })
            .then(result => {
                console.log({ result });
                this.quote = result.Quote;
                this.quoteLineEditFields = result.QuoteLineFields;
                this.quoteFields = result.Quotecolumns;
                this.currencyCode = result.OrgCurrency;
                this.isSingleLineenabled = !result.checkSingleQLine;
                this.isMarkup = !result.checkButtonMarkup;
                this.isMargin = !result.checkButtonMargin;
                let groupingOption = [];
                for (var i = 0; i < result.QuoteItemGroupList.length; i++) {
                    label: result.QuoteItemGroupList[i].Name;
                    value: result.QuoteItemGroupList[i].Id;
                    groupingOption.push({ label: result.QuoteItemGroupList[i].Name, value: result.QuoteItemGroupList[i].Id });
                    if (result.QuoteItemGroupList[i].Name === 'No Grouping') {
                        this.fields.buildertek__Grouping__c = result.QuoteItemGroupList[i].Id;
                    }
                }
                this.groupingOption = groupingOption;

                setTimeout(() => {
                    var statusCSS = this.template.querySelector('.statusCSS');
                    if (statusCSS) {
                        if (result.Quote.buildertek__Status__c === 'Customer Accepted') {
                            statusCSS.style.background = '#18764ad9';
                            statusCSS.style.color = 'white';
                        } else if (result.Quote.buildertek__Status__c === 'Rejected') {
                            statusCSS.style.background = '#af1617';
                            statusCSS.style.color = 'white';
                        }
                    }
                }, 0);

                this.quoteName = result.Quote.Name;

                var quoteData = [];
                for (var i = 0; i < result.Quotecolumns.length; i++) {
                    var quoteDataToDisplay = {};
                    quoteDataToDisplay.label = result.Quotecolumns[i].label;
                    quoteDataToDisplay.fieldName = result.Quotecolumns[i].fieldName;
                    quoteDataToDisplay.type = result.Quotecolumns[i].type;
                    if (result.Quotecolumns[i].label === 'Status') {
                        quoteDataToDisplay.isStatus = true;
                    } else {
                        quoteDataToDisplay.isStatus = false;
                    }
                    if (result.Quotecolumns[i].type === 'currency') {
                        quoteDataToDisplay.isCurrency = true;
                        quoteDataToDisplay.currencyCode = this.currencyCode;
                    } else {
                        quoteDataToDisplay.isCurrency = false;
                    }
                    quoteDataToDisplay.value = result.Quote[result.Quotecolumns[i].fieldName];
                    quoteData.push(quoteDataToDisplay);
                }
                this.quoteData = quoteData;
                this.columns = result.columns;
                this.filtermodalColumns = result.columns;

                //loop on the colums cooming from FieldSet
                for (var i = 0; i < this.columns.length; i++) {
                    for (var i = 0; i < this.columns.length; i++) {
                        if (this.columns[i].label === 'Cost Code') {
                            this.columns[i].fieldName = 'CostCode';
                            this.columns[i].type = 'string';
                        }

                        if (this.columns[i].label === 'Sub Group') {
                            this.columns[i].fieldName = 'SubGroup';
                            this.columns[i].type = 'string';
                        }

                        if (this.columns[i].fieldName === 'buildertek__Markup__c' || this.columns[i].fieldName === 'buildertek__Tax__c' || this.columns[i].fieldName === 'buildertek__Profit_Margin__c') {
                            this.columns[i].type = 'percent';
                            this.columns[i].typeAttributes = { minimumFractionDigits: 2, maximumFractionDigits: 2 };
                        }

                        this.columns[i].editable = false;
                        this.columns[i].hideDefaultActions = true;
                        this.columns[i].cellAttributes = { alignment: 'left', class: { fieldName: 'format' } };

                        if (this.columns[i].fieldName == 'buildertek__Notes__c') {
                            this.columns[i].wrapText = false;
                        } else {
                            this.columns[i].wrapText = true;
                        }

                        if (this.columns[i].label == 'Notes') {
                            this.columns[i].initialWidth = 200;
                        }
                        else {
                            this.columns[i].initialWidth = this.columns[i].label.length * 15;
                        }
                    }


                }

                let cols = [
                    {
                        label: '',
                        fieldName: 'viewButton',
                        type: 'button-icon',
                        fixedWidth: 25,
                        typeAttributes: {
                            iconName: 'utility:edit',
                            name: 'edit_called',
                            title: 'Edit Icon',
                            variant: 'bare',
                            alternativeText: 'Edit Icon'
                        },
                        hideDefaultActions: true
                    },
                    {
                        label: '',
                        fieldName: 'deleteButton',
                        type: 'button-icon',
                        fixedWidth: 25,
                        typeAttributes: {
                            iconName: 'utility:delete',
                            name: 'delete_called',
                            title: 'Delete Icon',
                            variant: 'bare',
                            alternativeText: 'Delete Icon'
                        },
                        hideDefaultActions: true
                    },
                    {
                        label: '',
                        fieldName: 'navigateButton',
                        type: 'button-icon',
                        fixedWidth: 25,
                        typeAttributes: {
                            iconName: 'utility:new_window',
                            name: 'navigate_called',
                            title: 'Navigate Icon',
                            variant: 'bare',
                            alternativeText: 'Navigate Icon'
                        },
                        hideDefaultActions: true
                    },
                ];
                this.columns = cols.concat(result.columns);
                this.columns.unshift({
                    // label: 'No.',
                    fieldName: 'Number',
                    type: 'string',
                    editable: false,
                    initialWidth: 80,
                    hideDefaultActions: true,
                    cellAttributes: { alignment: 'center' },
                });
                let totalCol = this.colums;

                this.totalColumns = totalCol;
                this.quoteLines = result.quoteLineList;
                this.filteredquoteItems = result.quoteLineList;
                this.filteredquoteItemsFinal = result.quoteLineList;

                for (var i = 0; i < this.quoteLines.length; i++) {
                    var groupName = this.quoteLines[i].buildertek__Grouping__r.Name;
                    var groupId = this.quoteLines[i].buildertek__Grouping__c;

                    //if not customer visible then add the id to filterModalSelected
                    if (this.quoteLines[i].buildertek__Not_Customer_Visible__c) {
                        this.filterModalSelected.push(this.quoteLines[i].Id);
                    }

                    if (this.quoteLines[i].buildertek__Sub_Group__r != null) {
                        if (!this.subgroupOptions.some(item => item.value === this.quoteLines[i].buildertek__Sub_Group__r.Id)) {
                            this.subgroupOptions.push({ label: this.quoteLines[i].buildertek__Sub_Group__r.Name, value: this.quoteLines[i].buildertek__Sub_Group__r.Id });
                        }
                    }

                    if (this.quoteLines[i].buildertek__Grouping__r != null) {
                        if (!this.phaseOptions.some(item => item.value === this.quoteLines[i].buildertek__Grouping__r.Id)) {
                            this.phaseOptions.push({ label: this.quoteLines[i].buildertek__Grouping__r.Name, value: this.quoteLines[i].buildertek__Grouping__r.Id });
                        }
                    }
                
                    if (this.quoteLines[i].buildertek__Cost_Code__c != null) {
                        this.quoteLines[i].CostCode = this.quoteLines[i].buildertek__Cost_Code__r.Name;
                    }

                    if (this.quoteLines[i].buildertek__Sub_Group__c != null) {
                        this.quoteLines[i].SubGroup = this.quoteLines[i].buildertek__Sub_Group__r.Name;
                    }
                
                    if (this.quoteLines[i].buildertek__Markup__c != null) {
                        this.quoteLines[i].buildertek__Markup__c = this.quoteLines[i].buildertek__Markup__c / 100;
                    }
                
                    if (this.quoteLines[i].buildertek__Tax__c != null) {
                        this.quoteLines[i].buildertek__Tax__c = this.quoteLines[i].buildertek__Tax__c / 100;
                    }
                
                    if (this.quoteLines[i].buildertek__Profit_Margin__c != null) {
                        this.quoteLines[i].buildertek__Profit_Margin__c = this.quoteLines[i].buildertek__Profit_Margin__c / 100;
                    }
                
                    if (this.data.some(item => item.groupName === groupName && item.groupId === groupId)) {
                        let currentItem = this.data.find(item => item.groupName === groupName && item.groupId === groupId);
                
                        if (this.quoteLines[i].buildertek__Not_Customer_Visible__c) {
                            this.quoteLines[i]['format'] = 'slds-text-color_error';
                            // currentItem.isConsidered = false;
                        }
                
                        currentItem.items.push(this.quoteLines[i]);
                    } else {
                        let isConsidered = !this.quoteLines[i].buildertek__Not_Customer_Visible__c;
                        if (!isConsidered) {
                            this.quoteLines[i]['format'] = 'slds-text-color_error';
                        }
                        this.data.push({ groupName: groupName, isConsidered: true , groupId: groupId, items: [this.quoteLines[i]] });
                    }
                
                    this.quoteLines[i].Number = i + 1;
                }
                this.calculateTotal(this.data);
            })
            .catch(error => {
                console.log(error);
                const { errorMessage, errorObject } = this.returnErrorMsg(error);
                console.error('Error in updating Quote Line:', errorObject);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }


    calculateTotal(data) {
        let columns = this.columns;
        let totalColumns = columns.filter(col => (col.type === 'number' || col.type === 'currency') && col.fieldName !== 'buildertek__Unit_Cost__c');
        let grandTotal = {};
        this.groupsNotConsidered = [];
        this.presentGroups = [];

        this.data.forEach(item => {

            item.isConsidered = true;
            let length = item.items.length;
            let count = 0;
            for (let i = 0; i < length; i++) {
                if (item.items[i].buildertek__Not_Customer_Visible__c) {
                    count++;
                }
            }
            if (count === length) {
                item.isConsidered = false;
            }

            if (!item.isConsidered) {
                this.groupsNotConsidered.push(item.groupId);
            }
            this.presentGroups.push({ label: item.groupName, value: item.groupId });

            let subtotalList = [];
            let subTotal = {};
            totalColumns.forEach(col => {
                subTotal[col.fieldName] = item.items
                    .filter(currentItem => !currentItem.buildertek__Not_Customer_Visible__c)
                    .reduce((acc, currentItem) => acc + currentItem[col.fieldName], 0);
                grandTotal[col.fieldName] = grandTotal[col.fieldName] || 0;
                if (grandTotal[col.fieldName]) {
                    grandTotal[col.fieldName] += subTotal[col.fieldName];
                } else {
                    grandTotal[col.fieldName] = subTotal[col.fieldName];
                }
            });
            subTotal['Name'] = 'Subtotal';
            item.items.push(subTotal);
            subtotalList.push(subTotal);
            item.subtotal = subtotalList;
            item.isVisible = true;
        });

        this.grandTotalList = [JSON.parse(JSON.stringify(grandTotal))];

        console.log({ grandTotal });
        console.log({ data });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const recordId = row.Id;

        switch (actionName) {
            case 'edit_called':
                this.handleEdit(recordId);
                break;
            case 'delete_called':
                this.handleDelete(recordId);
                break;
            case 'navigate_called':
                this.handleNavigate(recordId);
                break;
            default:
                break;
        }

    }

    handleEdit(recordId) {
        console.log('Edit button clicked for Record Id: ' + recordId);
        this.EditrecordId = recordId;
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: recordId,
        //         actionName: 'edit',
        //     },
        // });
        this.isEditModal = true;
    }

    closeEditModal() {
        this.isEditModal = false;
        this.EditrecordId = null;
    }

    handleDelete(recordId) {
        console.log('Delete button clicked for Record Id: ' + recordId);
        this.showdeleteModal = true;
        this.deleteRecordId = recordId;
    }

    cancelDelete() {
        this.showdeleteModal = false;
        this.deleteRecordId = null;
    }

    deleteQuoteLine() {
        var recordId = this.deleteRecordId;
        if (recordId) {
            this.isLoading = true;
            this.cancelDelete();
            deleteQuoteLine({
                quoteItemId: recordId
            }).then(result => {
                console.log({ result });
                if (result == "Sucess") {
                    console.log('Record deleted successfully');
                    //show toast message 
                    var message = 'Record deleted successfully';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: message,
                        variant: 'success'
                    }));
                    this.refreshData();
                } else {
                    var message = 'Error deleting record';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: message,
                        variant: 'error'
                    }));
                    this.isLoading = false;
                }
            });
        } else {
            var message = 'Please select a record to delete';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
        }
    }

    handleNavigate(recordId) {
        console.log('Navigate button clicked for Record Id: ' + recordId);

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'buildertek__Quote_Item__c',
                actionName: 'view'
            }
        });
    }


    handleAdd(event) {
        console.log('Add button clicked');
        this.isAddProductTrue = true;
    }

    handleAddItem(event) {
        this.selectedGroupForAddProduct = event.target.dataset.id;
        console.log('Group: ' + this.selectedGroupForAddProduct);
        this.handleAddProduct();

    }


    closePopUp(event) {
        this.isImportRfqTrue = false;
        this.isAddProductTrue = false;
        if (event.detail.refresh) {
            this.refreshData();
        }
    }

    handleAddProduct(event) {
        console.log('Add Product button clicked');
        // this.filterModal = true;
        this.isAddProductTrue = true;
    }

    handleImportRfq(event) {
        console.log('Add Product button clicked');
        // this.filterModal = true;
        this.isAddProductTrue = true;
    }

    handleImportRfq(event) {
        console.log('Add Product button clicked');
        // this.filterModal = true;
        this.isImportRfqTrue = true;
    }

    applyFilter() {
        var filterValue = this.filterValue;
        console.log("User choose filter value: " + filterValue);
        if (filterValue === 'PriceBook') {
            this.filterModal = false;
            var groupId = this.filterGroupId;
            console.log('Group Id: ' + groupId);
            this.showPricebookModal = true
        } else if (filterValue === 'Vendor') {
            this.filterModal = false;
            this.showVendorModal = true;
        }
    }

    filterChange(event) {
        this.filterValue = event.detail.value;
    }

    hideModalBox() {
        this.filterModal = false;
    }

    dropdownHandler(event) {
        var groupId = event.target.dataset.id;
        var data = this.data;
        for (var i = 0; i < data.length; i++) {
            if (data[i].groupId === groupId) {
                data[i].isVisible = !data[i].isVisible;
            }
        }
    }

    handleMessage(event) {
        if (event.origin !== window.location.origin) {
            return;
        }
        if (event.data.action === 'closeSubtab') {
            this.refreshData();
        }
    }

    handleMassUpdate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'buildertek__quoteMassUpdateHelper'
            },
            state: {
                c__quoteId: this.recordId,
            }
        });
    }

    handleMarkupChnage(event) {
        this.globalMarkup = event.target.value;
    }

    handleMarginChnage(event) {
        this.globalMargin = event.target.value;
    }

    handleMargin() {
        this.isLoading = true;
        var globalMargin = this.globalMargin;
        console.log('Global Markup: ' + globalMargin);
        //if globalMargin is null then show error message
        if (globalMargin == null || globalMargin == '') {
            var message = 'Please enter Global Margin';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            this.isLoading = false;
            return;
        }
        //call addGlobalMarkup and pass recordId and globalMargin
        addGlobalMargin({
            quoteId: this.recordId,
            margin: globalMargin
        }).then(result => {
            console.log({ result });
            if (result == 'Success') {
                console.log('Global Margin updated successfully');
                //show toast message 
                var message = 'Global Margin updated successfully';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: message,
                    variant: 'success'
                }));
                this.refreshData();
                this.globalMargin = null;
            } else {
                var message = 'Error updating Global Markup';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
            }
        }).catch(error => {
            console.log(error);
            const { errorMessage, errorObject } = this.returnErrorMsg(error);
            console.error('Error in updating Quote Line:', errorObject);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }).finally(() => {
            this.isLoading = false;
        });

    }

    handleMarkup() {
        this.isLoading = true;
        var globalMarkup = this.globalMarkup;
        console.log('Global Markup: ' + globalMarkup);
        //if globalMarkup is null then show error message
        if (globalMarkup == null || globalMarkup == '') {
            var message = 'Please enter Global Markup';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            this.isLoading = false;
            return;
        }
        //call addGlobalMarkup and pass recordId and globalMarkup
        addGlobalMarkup({
            quoteId: this.recordId,
            markup: globalMarkup
        }).then(result => {
            console.log({ result });
            if (result == 'Success') {
                console.log('Global Markup updated successfully');
                //show toast message 
                var message = 'Global Markup updated successfully';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: message,
                    variant: 'success'
                }));
                this.refreshData();
                this.globalMarkup = null;
            } else {
                this.isLoading = false;
                var message = 'Error updating Global Markup';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
            }
        });

    }

    returnErrorMsg(error) {
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

    handleFilter() {
        // this.showfilterModal = true;
        this.showfilterLineModal = true;
    }

    cancelFilter() {
        this.showfilterModal = false;
    }

    hidefilterLineModal() {
        this.showfilterLineModal = false;
    }

    handleGroupChange(event) {
        this.groupsNotConsidered = event.target.value;
        console.log(JSON.stringify(this.groupsNotConsidered));
    }

    saveFilter() {
        this.showfilterModal = false;
        this.isLoading = true;
        var groupsNotConsidered = this.groupsNotConsidered;
        console.log('Groups Not Considered: ' + groupsNotConsidered);
        var presentGroups = this.presentGroups;
        var groupsConsidered = [];
        for (var i = 0; i < presentGroups.length; i++) {
            if (!groupsNotConsidered.includes(presentGroups[i].value)) {
                groupsConsidered.push(presentGroups[i].value);
            }
        }
        console.log('Groups Considered: ' + groupsConsidered);

        updateCustomerVisible({
            quoteId: this.recordId,
            notConsideredIds: groupsNotConsidered,
            consideredIds: groupsConsidered
        }).then(result => {
            console.log({ result });
            this.isLoading = false;
            if (result == 'Success') {
                console.log('Groups updated successfully');
                //show toast message 
                var message = 'Groups updated successfully';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: message,
                    variant: 'success'
                }));
            } else {
                var message = 'Error updating groups';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
            }
        })
            .finally(() => {
                this.refreshData();
            });


    }

    handleNameFilter(event) {
        this.nameFilter = event.target.value;
        this.handleFilterhere();
    }

    handleSubgroupFilter(event) {
        this.subgroupFilter = event.target.value;
        this.handleFilterhere();
    }

    handlePhaseFilter(event) {
        this.phaseFilter = event.target.value;
        this.handleFilterhere();
    }

    handleRowSelection(event) {
        var selectedRows = event.detail.selectedRows;
        this.filterModalSelected = selectedRows.map(item => item.Id);
    }

    handleFilterhere(){
        console.log(this.filterModalSelected);

        console.log('Name Filter: ' + this.nameFilter);
        console.log('Subgroup Filter: ' + this.subgroupFilter);
        console.log('Phase Filter: ' + this.phaseFilter);

        this.filteredquoteItems = this.filteredquoteItemsFinal.filter(item => {
            if (this.nameFilter === '' && this.subgroupFilter === 'All' && this.phaseFilter === 'All') {
            return true;
            } else if (this.nameFilter !== '' && this.subgroupFilter === 'All' && this.phaseFilter === 'All') {
            return item.Name.toLowerCase().includes(this.nameFilter.toLowerCase());
            } else if (this.nameFilter === '' && this.subgroupFilter !== 'All' && this.phaseFilter === 'All') {
            return item.buildertek__Sub_Group__c === this.subgroupFilter;
            } else if (this.nameFilter === '' && this.subgroupFilter === 'All' && this.phaseFilter !== 'All') {
            return item.buildertek__Grouping__c === this.phaseFilter;
            } else if (this.nameFilter !== '' && this.subgroupFilter !== 'All' && this.phaseFilter === 'All') {
            return item.Name.toLowerCase().includes(this.nameFilter.toLowerCase()) && item.buildertek__Sub_Group__c === this.subgroupFilter;
            } else if (this.nameFilter !== '' && this.subgroupFilter === 'All' && this.phaseFilter !== 'All') {
            return item.Name.toLowerCase().includes(this.nameFilter.toLowerCase()) && item.buildertek__Grouping__c === this.phaseFilter;
            } else if (this.nameFilter === '' && this.subgroupFilter !== 'All' && this.phaseFilter !== 'All') {
            return item.buildertek__Sub_Group__c === this.subgroupFilter && item.buildertek__Grouping__c === this.phaseFilter;
            } else {
            return item.Name.toLowerCase().includes(this.nameFilter.toLowerCase()) && item.buildertek__Sub_Group__c === this.subgroupFilter && item.buildertek__Grouping__c === this.phaseFilter;
            }
        });

        this.filteredquoteItems = this.filteredquoteItems.filter(item => !this.filterModalSelected.includes(item.Id));
        this.filterModalSelected.forEach(item => {
            this.filteredquoteItems.unshift(this.filteredquoteItemsFinal.find(quoteItem => quoteItem.Id === item));
        });

    }

    applyFilterLine() {
        var seletecdIds = this.filterModalSelected;
        var allIds = this.filteredquoteItemsFinal.map(item => item.Id);
        var nonselectedIds = allIds.filter(item => !seletecdIds.includes(item));

        console.log('Selected Ids: ' + JSON.stringify(seletecdIds));
        console.log('Non Selected Ids: ' + JSON.stringify(nonselectedIds));
        this.filterModalSelected = [];
        this.nameFilter = '';
        this.subgroupFilter = 'All';
        this.phaseFilter = 'All';

        this.isLoading = true;
        this.showfilterLineModal = false;
        updateCustomerVisiblebyLine({
            quoteId: this.recordId,
            consideredIds: seletecdIds,
            notConsideredIds: nonselectedIds
        }).then(result => {
            console.log({ result });
            this.isLoading = false;
            if (result == 'Success') {
                console.log('Filter applied successfully');
                //show toast message 
                var message = 'Filter applied successfully';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: message,
                    variant: 'success'
                }));
            } else {
                var message = 'Error updating groups';
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: message,
                    variant: 'error'
                }));
            }
        })
            .finally(() => {
                this.refreshData();
            });
    }
}