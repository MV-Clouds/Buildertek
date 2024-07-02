import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getallData from '@salesforce/apex/QuotePage.getallData';
import { NavigationMixin } from 'lightning/navigation';
export default class NewQuoteItemcmp extends NavigationMixin(LightningElement) {
    isInitalRender = true;
    @api recordId;
    @track isLoading = true;
    @track quoteName;
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
    @track filterValue ='PriceBook' ;
    @track filterOption =[
        {label: 'PriceBook', value: 'PriceBook'},
        {label: 'Vendor', value: 'Vendor'},
    ];
    @track filterGroupId;
    @track showPricebookModal = false;

    connectedCallback(){
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
            `;

            body.appendChild(style);

            this.isInitalRender = false;
        }

    }

    getData(){
        var QuoteId = this.recordId;
        console.log('Quote ID: ' + QuoteId);
        getallData({ quoteId: QuoteId })
            .then(result => {
                console.log({result});
                this.quote = result.Quote;
                this.quoteFields = result.Quotecolumns;

                setTimeout(() => {
                    var statusCSS = this.template.querySelector('.statusCSS');
                    if (statusCSS) {
                        if(result.Quote.buildertek__Status__c === 'Customer Accepted'){
                            statusCSS.style.background = '#18764ad9';
                            statusCSS.style.color = 'white';
                        } else if (result.Quote.buildertek__Status__c === 'Rejected'){
                            statusCSS.style.background = '#af1617';
                            statusCSS.style.color = 'white';
                        }
                    }
                }, 0);

                this.quoteName = result.Quote.Name;
                if(result.Quote.buildertek__Project__c != null){
                    this.projectName = result.Quote.buildertek__Project__r.Name;
                }else{
                    this.projectName = '';
                }

                var quoteData = [];
                for(var i = 0; i < result.Quotecolumns.length; i++){
                    var quoteDataToDisplay = {};
                    quoteDataToDisplay.label = result.Quotecolumns[i].label;
                    quoteDataToDisplay.fieldName = result.Quotecolumns[i].fieldName;
                    quoteDataToDisplay.type = result.Quotecolumns[i].type;
                    if(result.Quotecolumns[i].label === 'Status'){
                        quoteDataToDisplay.isStatus = true;
                    }else{
                        quoteDataToDisplay.isStatus = false;
                    }
                    quoteDataToDisplay.value = result.Quote[result.Quotecolumns[i].fieldName];
                    quoteData.push(quoteDataToDisplay);
                }
                this.quoteData = quoteData;

                //loop on the colums cooming from FieldSet
                for(var i = 0; i < result.columns.length; i++){
                    if(result.columns[i].label === 'Cost Code'){
                        result.columns[i].fieldName = 'CostCode';
                        result.columns[i].type = 'string';
                    }

                    result.columns[i].editable = false;
                    result.columns[i].hideDefaultActions = true;
                    result.columns[i].cellAttributes = { alignment: 'left' };

                    if(result.columns[i].fieldName == 'buildertek__Notes__c'){
                        result.columns[i].wrapText = false;
                    }else{
                        result.columns[i].wrapText = true;
                    }

                    if(result.columns[i].label == 'Notes'){
                        result.columns[i].initialWidth = 200;
                    }
                    else{
                        result.columns[i].initialWidth = result.columns[i].label.length * 15;
                    }


                }

                result.columns.unshift({
                    // label: 'No.',
                    fieldName: 'Number',
                    type: 'string',
                    editable: false,
                    initialWidth: 80,
                    hideDefaultActions: true,
                    cellAttributes: { alignment: 'center' },
                });
                this.columns = result.columns;
                this.totalColumns = result.columns;
                this.quoteLines = result.quoteLineList;

                //loop on the quote lines and group them by Grouping
                for(var i = 0; i < this.quoteLines.length; i++){
                    var groupName = this.quoteLines[i].buildertek__Grouping__r.Name;
                    var groupId = this.quoteLines[i].buildertek__Grouping__c;
                    if(this.quoteLines[i].buildertek__Cost_Code__c != null){
                        this.quoteLines[i].CostCode = this.quoteLines[i].buildertek__Cost_Code__r.Name;
                    }

                    if(this.data.some(item => item.groupName === groupName && item.groupId === groupId)) {
                        this.data.filter(item => item.groupName === groupName && item.groupId === groupId)[0].items.push(this.quoteLines[i]);
                    } else {
                        this.data.push({groupName: groupName, groupId: groupId, items: [this.quoteLines[i]]});
                    }
                    this.quoteLines[i].Number = i+1;
                }
                console.log({data: this.data});
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

    handleAddItem(event) {
        var groupId = event.target.dataset.id;
        console.log('Add Item button clicked for Group Id: ' + groupId);
        if(groupId){
            this.filterModal = true;
            this.filterGroupId = groupId;
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select a group to add item',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }

    }


    closePopUp(event){
        this.isImportRfqTrue = false;
        this.isAddProductTrue = false;
    }

    handleAddProduct(event){
        console.log('Add Product button clicked');
        // this.filterModal = true;
        this.isAddProductTrue = true;
    }

    handleImportRfq(event){
        console.log('Add Product button clicked');
        // this.filterModal = true;
        this.isImportRfqTrue = true;
    }

    applyFilter(){
        var filterValue = this.filterValue;
        console.log("User choose filter value: " + filterValue);
        if(filterValue === 'PriceBook'){
            this.filterModal = false;
            var groupId = this.filterGroupId;
            console.log('Group Id: ' + groupId);
            this.showPricebookModal = true
        }else if(filterValue === 'Vendor'){
            this.filterModal = false;
            this.showVendorModal = true;
        }
    }

    filterChange(event){
        this.filterValue = event.detail.value;
    }

    hideModalBox(){
        this.filterModal = false;
    }

    dropdownHandler(event){
        var groupId = event.target.dataset.id;
        var data = this.data;
        for(var i = 0; i < data.length; i++){
            if(data[i].groupId === groupId){
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
}