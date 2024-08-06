import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getcurrency from '@salesforce/apex/BudgetDAO.getcurrency';
import getContractInvoice from '@salesforce/apex/BudgetDAO.getInvoicePOData';
import updateCIPrice from '@salesforce/apex/BudgetDAO.updateContractorInvoicePrice';
import addNewInvoicePO from '@salesforce/apex/BudgetDAO.addInvoicePOToBudget';

export default class AddContractorInvoiceFromBudget extends LightningElement {

    @api budgetId;
    @api budgetItemList = [];
    @track invoicePORecordList;
    @track currencycode;
    @track isLoading = false;
    budgetItemId

    connectedCallback() {
        this.budgetItemId = this.budgetItemList[0]?.Id;
        this.fetchCurrencyCode();
        this.fetchInvoicePORecords();
    }

    fetchCurrencyCode() {
        getcurrency()
            .then(result => {
                if (result) {
                    this.currencycode = result;
                }
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            });
    }

    fetchInvoicePORecords() {
        this.isLoading = true;
        getContractInvoice({ RecId: this.budgetId })
            .then(result => {
                this.invoicePORecordList = result.length > 0 ? result : false;
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCheckAllInvoices(event) {
        const isChecked = event.target.checked;

        // Update all items in the record list based on the master checkbox
        this.invoicePORecordList = this.invoicePORecordList.map(item => {
            return { ...item, Selected: isChecked };
        });
    }

    handleCheckInvoice(event) {
        const itemId = event.target.dataset.id;
        const isChecked = event.target.checked;

        // Update the specific item in the record list
        this.invoicePORecordList = this.invoicePORecordList.map(item => {
            if (item.Id === itemId) {
                return { ...item, Selected: isChecked };
            }
            return item;
        });
    }

    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: { refresh: false } }));
    }

    handleSaveInvoice() {
        const selectedInvoices = this.invoicePORecordList.filter(item => item.Selected);
        if (selectedInvoices.length === 0) {
            this.showToast('Error', 'Please select atleast one Invoice (PO)', 'error');
            return;
        }
        let selectedInvoiceIDList = selectedInvoices.map(item => item.Id)
        this.isLoading = true;
        if (this.budgetItemId) {
            this.updateInvoicePrice(selectedInvoiceIDList.toString());
        } else {
            this.addInvoicePO(selectedInvoiceIDList);
        }
    }

    updateInvoicePrice(selectedInvoiceIDList) {
        updateCIPrice({ recordId: selectedInvoiceIDList, budgeLineIds: this.budgetItemId })
            .then(result => {
                if (result === 'Success') {
                    this.showToast('Success', 'Invoice Price updated successfully', 'success');
                    this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
                } else {
                    this.showToast('Error', 'Failed to update Invoice Price', 'error');
                }
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    addInvoicePO(selectedInvoiceIDList) {
        addNewInvoicePO({ invoicePoList: selectedInvoiceIDList, BudgetId: this.budgetId })
            .then(result => {
                if (result === 'Successs') {
                    this.showToast('Success', 'Invoice added successfully', 'success');
                    this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
                } else {
                    this.showToast('Error', 'Failed to add Invoice', 'error');
                }
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    //! Utility Methods
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    returnErrorMsg(error) {
        console.log('An error occurred:', error);

        let errorMessage = 'Unknown error';
        if (error?.body?.message) {
            errorMessage = error.body.message;
        } else if (error?.body?.pageErrors?.[0]?.message) {
            errorMessage = error.body.pageErrors[0].message;
        } else if (error?.message) {
            errorMessage = error.message;
        }

        return { errorMessage, errorObject: error };
    }
}