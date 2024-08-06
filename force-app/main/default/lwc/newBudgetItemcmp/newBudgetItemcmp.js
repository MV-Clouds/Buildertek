import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getallData from '@salesforce/apex/BudgetPage.getallData';
import deleteBudgetLine from '@salesforce/apex/BudgetPage.deleteBudgetLine';
import { NavigationMixin } from 'lightning/navigation';
import saveBL from '@salesforce/apex/BudgetPage.saveBL';
import deleteSelectedItems from '@salesforce/apex/BudgetDAO.deleteSelectedItems';
import addGlobalMarkup from '@salesforce/apex/BudgetPage.addGlobalMarkup';
// import addGlobalMargin from '@salesforce/apex/BudgetPage.addGlobalMargin';

export default class NewQuoteItemcmp extends NavigationMixin(LightningElement) {
    isInitalRender = true;
    @api recordId;
    @track budgetLineEditFields;
    @track isEditModal = false;
    @track isSingleLineenabled;
    @track groupingOption = [];
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
    @track isDeleteModal = false;
    @track columns;
    @track budgetLines;
    @track data = [];
    @track totalColumns;
    @track isImportRfqTrue = false;
    @track EditrecordId;
    @track isAddProductTrue = false;
    @track isAddPOTrue = false;
    @track isAddContractorInvoiceTrue = false;
    @track isAddExpenseTrue = false;
    @track isAddPayableInvoiceTrue = false;
    @track globalMarkup = null;
    // @track globalMargin = null;
    @track isMarkup;
    // @track isMargin;
    @track fields = {
        buildertek__Description__c: '',
        buildertek__Group__c: '',
        buildertek__Notes__c: '',
        buildertek__Quantity__c: 1,
        buildertek__Unit_Price__c: 0.00,
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
    selectedLineObj = {};
    selectedTableData = [];

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

                .lastRowsCSS table tr:last-child {
                    font-weight: 700;
                }

                
                .lastRowsCSS table tr:first-child th:nth-child(1) span,
                .lastRowsCSS table tr:last-child td:nth-child(1) span,
                .lastRowsCSS table tr:last-child td:nth-child(3) span,
                .lastRowsCSS table tr:last-child td:nth-child(4) span,
                .lastRowsCSS table tr:last-child td:nth-child(5) span{
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
        this.selectedTableData = [];
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
        if (!this.isMarkup) {
            delete this.fields.buildertek__Markup__c;
        }
        this.fields.buildertek__Budget__c = this.recordId;
        this.fields.Name = this.fields.buildertek__Description__c;
        
        saveBL({ BL: this.fields })
            .then(result => {
                if (result == 'Success') {
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
                        buildertek__Unit_Price__c: 0.00,
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
                console.error('Error in updating Budget Line:', errorObject);
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

    handleSubmit(event){
        this.isLoading = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Id = this.EditrecordId;
        this.isEditModal = false;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSucess(){
        this.isLoading = false;
        this.refreshData();
        var message = 'Record updated successfully';
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        }));
    }

    handleError(event){
        this.isLoading = false;
        console.log('event error ',JSON.parse(JSON.stringify(event.detail)));
        var message = event.detail?.detail || 'Error updating record';
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
        getallData({ budgetId: budgetId })
            .then(result => {
                console.log('data here ',JSON.parse(JSON.stringify(result)));
                this.budget = result.Budget;
                this.budgetLineEditFields = result.BudgetLineFields;
                this.budgetFields = result.Budgetcolumns;
                this.budgetLines = result.budgetLineList;
                this.currencyCode = result.OrgCurrency;
                this.isSingleLineenabled = !result.checkSingleQLine;
                this.isMarkup = !result.checkButtonMarkup;
                // this.isMargin = !result.checkButtonMargin;
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

                    if(result.columns[i].fieldName === 'buildertek__Markup__c' || result.columns[i].fieldName === 'buildertek__Tax__c' || result.columns[i].fieldName === 'buildertek__Projected_Gross_Profit__c' || result.columns[i].fieldName === 'buildertek__Gross_Profit_Margin__c'){
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

                    this.checkCurrentFieldInData(result.columns[i]);
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

                    if (this.budgetLines[i].buildertek__Projected_Gross_Profit__c != null) {
                        this.budgetLines[i].buildertek__Projected_Gross_Profit__c = this.budgetLines[i].buildertek__Projected_Gross_Profit__c / 100;
                    }

                    if (this.budgetLines[i].buildertek__Gross_Profit_Margin__c != null) {
                        this.budgetLines[i].buildertek__Gross_Profit_Margin__c = this.budgetLines[i].buildertek__Gross_Profit_Margin__c / 100;
                    }

                    if (this.data.some(item => item.groupName === groupName && item.groupId === groupId)) {
                        this.data.filter(item => item.groupName === groupName && item.groupId === groupId)[0].items.push(this.budgetLines[i]);
                    } else {
                        this.data.push({ groupName: groupName, groupId: groupId, items: [this.budgetLines[i]] });
                    }
                    this.budgetLines[i].Number = i + 1;
                }
                this.calculateTotal(this.data);
            })
            .catch(error => {
                console.log(error);
                const { errorMessage, errorObject } = this.returnErrorMsg(error);
                console.error('Error in updating Budget Line:', errorObject);
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

        this.grandTotalList = [grandTotal];
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
        this.EditrecordId = recordId;
        this.isEditModal = true;
    }

    closeEditModal(){
        this.isEditModal = false;
        this.EditrecordId = null;
    }

    handleDelete(recordId) {
        this.showdeleteModal = true;
        this.deleteRecordId = recordId;
    }

    cancelDelete(){
        this.showdeleteModal = false;
        this.deleteRecordId = null;
    }

    deleteBudgetLine(){
        var recordId = this.deleteRecordId;
        if(recordId){
            this.isLoading = true;
            this.cancelDelete();
            deleteBudgetLine({
                budgetItemId: recordId
            }).then(result => {
                if(result == "Sucess"){
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
        this.isAddProductTrue = true;
    }


    closePopUp(event){
        this.isImportRfqTrue = false;
        this.isAddProductTrue = false;
        this.isAddExpenseTrue = false;
        this.isAddContractorInvoiceTrue = false;
        this.isAddPayableInvoiceTrue = false;
        if (event.detail.refresh) {
            this.refreshData();
        }
    }

    handleAddPO(event) {
        if (this.selectedTableData.length === 1) {
            this.isAddPOTrue = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please select only one Budget Line to add PO.',
                    variant: 'warning'
                })
            );
        }
    }

    handleAddCI(event) {
        if (this.selectedTableData.length <= 1) {
            this.isAddContractorInvoiceTrue = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please select one or fewer Budget Lines for the Invoice (PO).',
                    variant: 'warning'
                })
            );
        }
    }

    handleAddPayableInvoice() {
		if (this.selectedTableData.length <= 1) {
			this.isAddPayableInvoiceTrue = true;
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please select one or fewer Budget Lines for the Invoice (AP).',
                    variant: 'warning'
                })
            );
        }
    }

    handleAddExpense(event) {
        if(this.selectedTableData.length > 1){
          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Warning',
                message: 'Please select only one Budget Line to add Expense.',
                variant: 'warning'
            })
          );
          return;
        }
        this.isAddExpenseTrue = true;
    }

    handleImportRfq(event) {
        this.isAddProductTrue = true;
    }

    handleImportRfq(event){
        this.isImportRfqTrue = true;
    }

    applyFilter() {
        var filterValue = this.filterValue;
        if (filterValue === 'PriceBook') {
            this.filterModal = false;
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
                componentName: 'buildertek__budgetMassUpdate',
            },
            state: {
                c__budgetId: this.recordId,
            }
        });
    }

    closeAddPO(event){
        this.isAddPOTrue = false;
        if (event.detail.refresh) {
            this.refreshData();
        }
    }

    checkCurrentFieldInData(column){
        let tableBudgetLineData = this.budgetLines;
        tableBudgetLineData.forEach(row => {
            if(!row.hasOwnProperty(column.fieldName) && column.type == 'currency'){
                row[column.fieldName] = 0;
            }
        });
    }

    getSelectedLines(event){
        try {
            let selectedTempTableData = [];
            let selectedRows = event.detail.selectedRows;
            this.selectedLineObj[event.target.dataset.id] = selectedRows;

            Object.keys(this.selectedLineObj).forEach(key => {
                selectedTempTableData = [...selectedTempTableData, ...this.selectedLineObj[key]];
            });

            this.selectedTableData = selectedTempTableData;
        } catch (error) {
            console.log('error ',error);
        }
    }

    returnErrorMsg(error){
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

	deleteSelectedBudgetItem(event) {
		console.log('deleteSelectedBudgetItem');
		if (this.selectedTableData.length > 0) {
			this.isDeleteModal = true;
		} else {
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error',
					message: 'Please select the Budget Line you would like to Delete.',
					variant: 'error'
				})
			);
		}
	}

	deleteBudgetLines(){
		this.isLoading = true;
		let recordIds = this.selectedTableData.map(item => item.Id);
		deleteSelectedItems({
			recordIds: recordIds
		})
		.then(result => {
			if(result == "success"){
				let message = 'Budget Lines deleted successfully';
				this.dispatchEvent(new ShowToastEvent({
					title: 'Success',
					message: message,
					variant: 'success'
				}));
			}else{
				this.dispatchEvent(new ShowToastEvent({
					title: 'Error',
					message: result,
					variant: 'error'
				}));
			}
			this.refreshData();
		})
		.catch(error => {
			const { errorMessage, errorObject } = this.returnErrorMsg(error);
			this.dispatchEvent(new ShowToastEvent({
				title: "Error",
				message: errorMessage,
				variant: "error"
			}));
		})
		.finally(() => {
			this.isLoading = false;
			this.isDeleteModal = false;
		});
	}

	closeDeleteModel(){
		this.isDeleteModal = false;
	}

    handleMarkupChange(event) {
        this.globalMarkup = event.target.value;
    }

    // handleMarginChange(event) {
    //     this.globalMargin = event.target.value;
    // }

    // handleMargin() {
    //     if (!this.globalMargin) {
    //         this.dispatchEvent(new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Please enter a valid margin',
    //             variant: 'error'
    //         }));
    //         return;
    //     }
    //     this.isLoading = true;
    //     addGlobalMargin({
    //         budgetId: this.recordId,
    //         margin: this.globalMargin
    //     })
    //         .then(result => {
    //             if (result == "Success") {
    //                 let message = 'Global Margin updated successfully';
    //                 this.dispatchEvent(new ShowToastEvent({
    //                     title: 'Success',
    //                     message: message,
    //                     variant: 'success'
    //                 }));
    //                 this.refreshData();
    //                 this.globalMargin = null;
    //             } else {
    //                 this.dispatchEvent(new ShowToastEvent({
    //                     title: 'Error',
    //                     message: result,
    //                     variant: 'error'
    //                 }));
    //             }
    //         })
    //         .catch(error => {
    //             const { errorMessage, errorObject } = this.returnErrorMsg(error);
    //             this.dispatchEvent(new ShowToastEvent({
    //                 title: "Error",
    //                 message: errorMessage,
    //                 variant: "error"
    //             }));
    //         })
    //         .finally(() => {
    //             this.isLoading = false;
    //         });
    // }

    handleMarkup() {
        if (!this.globalMarkup) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please enter a valid markup',
                variant: 'error'
            }));
            return;
        }
        this.isLoading = true;
        addGlobalMarkup({
            budgetId: this.recordId,
            markup: this.globalMarkup
        })
            .then(result => {
                if (result == "Success") {
                    let message = 'Global Markup updated successfully';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: message,
                        variant: 'success'
                    }));
                    this.refreshData();
                    this.globalMarkup = null;
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error'
                    }));
                }
            })
            .catch(error => {
                const { errorMessage, errorObject } = this.returnErrorMsg(error);
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: errorMessage,
                    variant: "error"
                }));
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

}