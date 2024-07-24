import { LightningElement, track, api, wire } from "lwc";
import getBudgetDataFromServer from "@salesforce/apex/BudgetDAO.getExpenseData";
import addExpenseToBudget from "@salesforce/apex/BudgetDAO.addExpenseToBudget";
import CreateLineAddExpense from "@salesforce/apex/BudgetDAO.CreateLineAddExpense";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const columns = [
    {
        label: "EXPENSE NAME",
        fieldName: "Name",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
    },
    {
        label: "DESCRIPTION",
        fieldName: "buildertek__Description__c",
        type: "text",
        hideDefaultActions: true,
    },
    {
        label: "EXPENSE TOTAL",
        fieldName: "buildertek__Total_Expense__c",
        type: "currency",
        typeAttributes: {
            currencyCode: { fieldName: "CurrencyIso" },
            currencyDisplayAs: "code",
        },
        cellAttributes: { alignment: "left" },
        hideDefaultActions: true,
    },
    {
        label: "VENDOR",
        fieldName: "vendorName",
        type: "text",
        hideDefaultActions: true,
    },
];

export default class AddExpenseFromBudget extends LightningElement {
    showSpinner = false;
    @api budgetId;
    @api selectedBudgetLines = [];
    @track tableData = [];
    @track empty = false;
    selectedRecords = [];
    @track selectedBudgetLineRecords = [];
    columns = columns;

    connectedCallback() {
        this.fetchBudgetData();
        console.log('selected budget LInes ',JSON.parse(JSON.stringify(this.selectedBudgetLines)));
    }

    fetchBudgetData() {
        console.log('budgetId ',JSON.parse(JSON.stringify(this.budgetId)));
        getBudgetDataFromServer({ RecId: this.budgetId })
            .then((result) => {
                console.log('result ',result);
                this.tableData = result.map((record)=> { record['vendorName'] = record.buildertek__Vendor__c ? record.buildertek__Vendor__r.Name : ''; return record; });
                this.empty = this.tableData.length > 0 ? false : true;
                console.log('after result ',result);
                console.log('after tableData ',JSON.parse(JSON.stringify(this.tableData)));
            })
            .catch((error) => {
                let { errorMessage, errorObject } = this.returnErrorMsg(error);
                this.showToastMsg('Error', errorMessage, 'error');
            });
    }

    resetValues() {
        this.selectedBudgetLineRecords = [];
        this.tableData = [];
    }

    hideModalBox() {
        this.closeChildScreen(false);
    }

    closeChildScreen(isRefresh) {
        this.resetValues();
        if (isRefresh) {
            this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
            return;
        }
        this.dispatchEvent(new CustomEvent('close', { detail: { refresh: false } }));
    }

    handlSave(){
        this.showSpinner = true;
        this.selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(this.selectedRecords.length == 0){
            this.showToastMsg('Error', 'Please Select Atleast One Expense', 'error');
            this.showSpinner = false;
            return;
        }

        let selectedBudgetLineIds = this.selectedBudgetLines.length > 0 ? this.selectedBudgetLines.map((record)=> record.Id) : [];
        console.log('selectedBudgetLineIds ',selectedBudgetLineIds);
        console.log('selectedRecords In DataTable ',this.selectedRecords);

        if(selectedBudgetLineIds.length > 0){
          addExpenseToBudget({budgeLineIds: selectedBudgetLineIds.toString(),selectedExpenses:this.selectedRecords})
          .then((result) => {
              this.showToastMsg('Success', 'Expense Added Successfully.', 'success');
              this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
          })
          .catch((error) => {
              let { errorMessage, errorObject } = this.returnErrorMsg(error);
              this.showToastMsg('Error', errorMessage, 'error');
          }) 
          .finally(() => {
              this.showSpinner = false; 
              this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
          });
        } else {
            CreateLineAddExpense({selectedExpenses:this.selectedRecords, RecId:this.budgetId})
            .then((result) => {
              this.showToastMsg('Success', 'Expense Added Successfully.', 'success');
            })
            .catch((error) => {
              let { errorMessage, errorObject } = this.returnErrorMsg(error);
              this.showToastMsg('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
                this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
            }); 
        }
      
    }

    showToastMsg(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
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
}
