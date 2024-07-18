import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getallData from '@salesforce/apex/BudgetPage.getallData';
import deleteQuoteLine from '@salesforce/apex/BudgetPage.deleteQuoteLine';
import { NavigationMixin } from 'lightning/navigation';
import addGlobalMarkup from '@salesforce/apex/BudgetPage.addGlobalMarkup';
import addGlobalMargin from '@salesforce/apex/BudgetPage.addGlobalMargin';
import saveQL from '@salesforce/apex/BudgetPage.saveQL';
import { RefreshEvent } from 'lightning/refresh';

export default class NewQuoteItemcmp extends NavigationMixin(LightningElement) {
    isInitalRender = true;
    @api recordId;
    @track budgetLineEditFields;
    @track isEditModal = false;
    @track isSingleLineenabled;
    @track isMarkup;
    @track isMargin;
    @track groupingOption = [];
    @track globalMarkup = null;
    @track globalMargin = null;
    @track isLoading = true;
    @track showdeleteModal = false;
    @track deleteRecordId;
    @track budgetName;
    @track currencyCode;
    @track projectNfame;
    @track budgetData;
    @track budget;
    @track budgetFields;
    @track totalColumns;
    @track columns;
    @track budgetLines;
    @track data = [];
    @track totalColumns;
    @track isImportRfqTrue = false;
    @track EditrecordId;
    @track isAddProductTrue = false;
    @track isAddPOTrue = false;
    @track fields = {
        buildertek__Description__c: '',
        buildertek__Group__c: '',
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
            const body = document.querySelector("body");

            const style = document.createElement('style');
            style.innerText = `
                .budget-table .slds-cell-fixed{
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
    }

    handleSingleLineSave(){
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

        if(!this.isMarkup){
            delete this.fields.buildertek__Markup__c;
        }
        if(!this.isMargin){
            delete this.fields.buildertek__Margin__c;
        }
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
                        buildertek__Group__c: '',
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
                        message: message,
                        variant: 'error'
                    }));
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
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

    handleSubmit(event){
        this.isLoading = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Id = this.EditrecordId;
        this.isEditModal = false;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSucess(){
        this.refreshData();
        var message = 'Record updated successfully';
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        }));
    }

    handleError(){
        var message = 'Error updating record';
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        }));
    }

    submitDetails2(){
        const btn = this.template.querySelector( ".hidden" );
        if( btn ){ 
            btn.click();
        }
    }

    handlePicklistChange(event) {
        this.fields.buildertek__Group__c = event.target.value;
    }

    getData() {
        this.isLoading = true;
        var budgetId = this.recordId;
        console.log('Budget ID: ' + budgetId);
        getallData({ budgetId: budgetId })
            .then(result => {
                console.log({ result });
                this.budget = result.Budget;
                this.budgetLineEditFields = result.BudgetLineFields;
                this.budgetFields = result.Budgetcolumns;
                this.currencyCode = result.OrgCurrency;
                this.isSingleLineenabled = !result.checkSingleQLine;
                this.isMarkup = !result.checkButtonMarkup;
                this.isMargin = !result.checkButtonMargin;
                let groupingOption = [];
                for (var i = 0; i < result.BudgetItemGroupList.length; i++) {
                    label: result.BudgetItemGroupList[i].Name;
                    value: result.BudgetItemGroupList[i].Id;
                    groupingOption.push({ label: result.BudgetItemGroupList[i].Name, value: result.BudgetItemGroupList[i].Id });
                }
                this.groupingOption = groupingOption;

                setTimeout(() => {
                    var statusCSS = this.template.querySelector('.statusCSS');
                    if (statusCSS) {
                        if (result.Budget.buildertek__Status__c === 'Customer Accepted') {
                            statusCSS.style.background = '#18764ad9';
                            statusCSS.style.color = 'white';
                        } else if (result.Budget.buildertek__Status__c === 'Rejected') {
                            statusCSS.style.background = '#af1617';
                            statusCSS.style.color = 'white';
                        }
                    }
                }, 0);

                this.budgetName = result.Budget.Name;

                var budgetData = [];
                for (var i = 0; i < result.Budgetcolumns.length; i++) {
                    var quoteDataToDisplay = {};
                    quoteDataToDisplay.label = result.Budgetcolumns[i].label;
                    quoteDataToDisplay.fieldName = result.Budgetcolumns[i].fieldName;
                    quoteDataToDisplay.type = result.Budgetcolumns[i].type;
                    if (result.Budgetcolumns[i].label === 'Status') {
                        quoteDataToDisplay.isStatus = true;
                    } else {
                        quoteDataToDisplay.isStatus = false;
                    }
                    if (result.Budgetcolumns[i].type === 'currency') {
                        quoteDataToDisplay.isCurrency = true;
                        quoteDataToDisplay.currencyCode = this.currencyCode;
                    } else {
                        quoteDataToDisplay.isCurrency = false;
                    }
                    quoteDataToDisplay.value = result.Budget[result.Budgetcolumns[i].fieldName];
                    budgetData.push(quoteDataToDisplay);
                }
                this.budgetData = budgetData;

                //loop on the colums cooming from FieldSet
                for (var i = 0; i < result.columns.length; i++) {
                    if (result.columns[i].label === 'Cost Code') {
                        result.columns[i].fieldName = 'CostCode';
                        result.columns[i].type = 'string';
                    }

                    if(result.columns[i].fieldName === 'buildertek__Markup__c' || result.columns[i].fieldName === 'buildertek__Tax__c' || result.columns[i].fieldName === 'buildertek__Profit_Margin__c' ){
                        result.columns[i].type = 'percent';
                        result.columns[i].typeAttributes = { minimumFractionDigits: 2, maximumFractionDigits: 2 };
                    }

                    result.columns[i].editable = false;
                    result.columns[i].hideDefaultActions = true;
                    result.columns[i].cellAttributes = { alignment: 'left' };

                    if (result.columns[i].fieldName == 'buildertek__Notes__c') {
                        result.columns[i].wrapText = false;
                    } else {
                        result.columns[i].wrapText = true;
                    }

                    if (result.columns[i].label == 'Notes') {
                        result.columns[i].initialWidth = 200;
                    }
                    else {
                        result.columns[i].initialWidth = result.columns[i].label.length * 15;
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
                result.columns = cols.concat(result.columns);
                result.columns.unshift({
                    // label: 'No.',
                    fieldName: 'Number',
                    type: 'string',
                    editable: false,
                    initialWidth: 80,
                    hideDefaultActions: true,
                    cellAttributes: { alignment: 'center' },
                });
                let totalCol = result.colums;  

                this.totalColumns = totalCol;
                this.columns = result.columns;
                this.budgetLines = result.budgetLineList;


                //loop on the budget lines and group them by Grouping
                for (var i = 0; i < this.budgetLines.length; i++) {
                    var groupName = this.budgetLines[i].buildertek__Group__r.Name;
                    var groupId = this.budgetLines[i].buildertek__Group__c;
                    if (this.budgetLines[i].buildertek__Cost_Code__c != null) {
                        this.budgetLines[i].CostCode = this.budgetLines[i].buildertek__Cost_Code__r.Name;
                    }

                    if (this.budgetLines[i].buildertek__Markup__c != null) {
                        this.budgetLines[i].buildertek__Markup__c = this.budgetLines[i].buildertek__Markup__c / 100;
                    }

                    if (this.budgetLines[i].buildertek__Tax__c != null) {
                        this.budgetLines[i].buildertek__Tax__c = this.budgetLines[i].buildertek__Tax__c / 100;
                    }

                    if (this.budgetLines[i].buildertek__Profit_Margin__c != null) {
                        this.budgetLines[i].buildertek__Profit_Margin__c = this.budgetLines[i].buildertek__Profit_Margin__c / 100;
                    }

                    if (this.data.some(item => item.groupName === groupName && item.groupId === groupId)) {
                        this.data.filter(item => item.groupName === groupName && item.groupId === groupId)[0].items.push(this.budgetLines[i]);
                    } else {
                        this.data.push({ groupName: groupName, groupId: groupId, items: [this.budgetLines[i]] });
                    }
                    this.budgetLines[i].Number = i + 1;
                }
                console.log({ data: this.data });
                this.calculateTotal(this.data);
            })
            .catch(error => {
                console.log(error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
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
        let totalColumns = columns.filter(col => col.type === 'number' || col.type === 'currency');
        let grandTotal = {};

        console.log('data : ',JSON.parse(JSON.stringify(data)));

        data.forEach(item => {
            let subtotalList = [];
            let subTotal = {};
            totalColumns.forEach(col => {
                subTotal[col.fieldName] = item.items.reduce((acc, currentItem) => acc + currentItem[col.fieldName], 0);
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
        console.log({ grandTotalList: this.grandTotalList });
        console.log({ data });
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const recordId = row.Id;

        switch(actionName){
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

    closeEditModal(){
        this.isEditModal = false;
        this.EditrecordId = null;
    }

    handleDelete(recordId) {
        console.log('Delete button clicked for Record Id: ' + recordId);
        this.showdeleteModal = true;
        this.deleteRecordId = recordId;
    }

    cancelDelete(){
        this.showdeleteModal = false;
        this.deleteRecordId = null;
    }

    deleteQuoteLine(){
        var recordId = this.deleteRecordId;
        if(recordId){
            this.isLoading = true;
            this.cancelDelete();
            deleteQuoteLine({
                quoteItemId: recordId
            }).then(result => {
                console.log({result});
                if(result == "Sucess"){
                    console.log('Record deleted successfully');
                    //show toast message 
                    var message = 'Record deleted successfully';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: message,
                        variant: 'success'
                    }));
                    this.refreshData();
                }else{
                    var message = 'Error deleting record';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: message,
                        variant: 'error'
                    }));
                    this.isLoading = false;
                }
            });
        }else{
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


    closePopUp(event){
        this.isImportRfqTrue = false;
        this.isAddProductTrue = false;
        if (event.detail.refresh) {
            this.refreshData();
        }
    }

    handleAddPO(event) {
        console.log('Add PO button clicked');
        this.isAddPOTrue = true;
    }

    handleImportRfq(event) {
        console.log('Add Product button clicked');
        // this.filterModal = true;
        this.isAddProductTrue = true;
    }

    handleImportRfq(event){
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

    handleMarkupChnage(event){
        this.globalMarkup = event.target.value;
    }

    handleMarginChnage(event){
        this.globalMargin = event.target.value;
    }

    handleMargin(){
        this.isLoading = true;
        var globalMargin = this.globalMargin;
        console.log('Global Markup: ' + globalMargin);
        //if globalMargin is null then show error message
        if(globalMargin == null || globalMargin == ''){
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
            console.log({result});
            if(result == 'Success'){
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
            }else{
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

    handleMarkup(){
        this.isLoading = true;
        var globalMarkup = this.globalMarkup;
        console.log('Global Markup: ' + globalMarkup);
        //if globalMarkup is null then show error message
        if(globalMarkup == null || globalMarkup == ''){
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
            console.log({result});
            if(result == 'Success'){
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
            }else{
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

    closeAddPO(event){
        this.isAddPOTrue = false;
        if (event.detail.refresh) {
            this.refreshData();
        }
    }
}