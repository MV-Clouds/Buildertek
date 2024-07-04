import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getallData from '@salesforce/apex/QuotePage.getallData';
import deleteQuoteLine from '@salesforce/apex/QuotePage.deleteQuoteLine';
import { NavigationMixin } from 'lightning/navigation';
import addGlobalMarkup from '@salesforce/apex/QuotePage.addGlobalMarkup';
export default class NewQuoteItemcmp extends NavigationMixin(LightningElement) {
    isInitalRender = true;
    @api recordId;
    @track globalMarkup = null;
    @track isLoading = true;
    @track showdeleteModal = false;
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
    @track totalColumns;
    @track isImportRfqTrue = false;
    @track isAddProductTrue = false;
    @track rotationClass = '';
    @track grandTotalList = [];
    @track filterModal = false;
    @track filterValue = 'PriceBook';
    @track filterOption = [
        { label: 'PriceBook', value: 'PriceBook' },
        { label: 'Vendor', value: 'Vendor' },
    ];
    @track filterGroupId;
    @track showPricebookModal = false;

    connectedCallback() {
        this.getData();
    }

    renderedCallback() {
        if (this.isInitalRender) {
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
            `;

            body.appendChild(style);

            this.isInitalRender = false;
        }

    }

    refreshData() {
        this.data = [];
        this.getData();
    }

    getData() {
        var QuoteId = this.recordId;
        console.log('Quote ID: ' + QuoteId);
        getallData({ quoteId: QuoteId })
            .then(result => {
                console.log({ result });
                this.quote = result.Quote;
                this.quoteFields = result.Quotecolumns;
                this.currencyCode = result.OrgCurrency;

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
                if (result.Quote.buildertek__Project__c != null) {
                    this.projectName = result.Quote.buildertek__Project__r.Name;
                } else {
                    this.projectName = '';
                }

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
                            iconName: 'utility:open',
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
                this.quoteLines = result.quoteLineList;


                //loop on the quote lines and group them by Grouping
                for (var i = 0; i < this.quoteLines.length; i++) {
                    var groupName = this.quoteLines[i].buildertek__Grouping__r.Name;
                    var groupId = this.quoteLines[i].buildertek__Grouping__c;
                    if (this.quoteLines[i].buildertek__Cost_Code__c != null) {
                        this.quoteLines[i].CostCode = this.quoteLines[i].buildertek__Cost_Code__r.Name;
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
                        this.data.filter(item => item.groupName === groupName && item.groupId === groupId)[0].items.push(this.quoteLines[i]);
                    } else {
                        this.data.push({ groupName: groupName, groupId: groupId, items: [this.quoteLines[i]] });
                    }
                    this.quoteLines[i].Number = i + 1;
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
            });;
    }

    calculateTotal(data) {
        let columns = this.columns;
        let totalColumns = columns.filter(col => col.type === 'number' || col.type === 'currency');
        let grandTotal = {};

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
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'edit',
            },
        });
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

    handleMassUpdate(event) {
        console.log('Mass Update button clicked');
        this.isMassUpdateEnabled = true;
    }

    handleAdd(event) {
        console.log('Add button clicked');
        this.isAddProductTrue = true;
    }

    handleAddItem(event) {
        var groupId = event.target.dataset.id;
        console.log('Add Item button clicked for Group Id: ' + groupId);
        if (groupId) {
            this.filterModal = true;
            this.filterGroupId = groupId;
        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select a group to add item',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }

    }


    closePopUp(event) {
        this.isImportRfqTrue = false;
        this.isAddProductTrue = false;
        this.refreshData();
    }

    handleAddProduct(event) {
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

    handleMassUpdate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__quoteMassUpdateHelper'
            },
            state: {
                c__quoteId: this.recordId,
            }
        });
    }

    handleMarkupChnage(event){
        this.globalMarkup = event.target.value;
    }

    handleMarkup(){
        this.isLoading = true;
        var globalMarkup = this.globalMarkup;
        console.log('Global Markup: ' + globalMarkup);
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
}