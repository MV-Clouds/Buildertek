import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getcurrency from '@salesforce/apex/BudgetDAO.getcurrency';
import getInvoiceData from '@salesforce/apex/BudgetDAO.getInvioceData';
import saveInvoicePrice from '@salesforce/apex/BudgetDAO.updateInvoicePrice';
import createInvoice from '@salesforce/apex/BudgetDAO.CreateLineAddInvoice';

export default class AddPayableInvoiceFromBudget extends LightningElement {

    @api budgetId;
    @api budgetItemList;
    @track isLoading = false;
    @track invoiceRecordList;
    @track currencycode;
    budgetItemId;

    connectedCallback() {
        this.budgetItemId = this.budgetItemList[0]?.Id;
        this.fetchInvoiceRecords();
        this.fetchCurrencyCode();
    }

    fetchInvoiceRecords() {
        this.isLoading = true;
        getInvoiceData({ pageNumber: 1, pageSize: 10, RecId: this.budgetId })
            .then(result => {
                console.log('fetchInvoiceRecords: ', JSON.parse(JSON.stringify(result)));
                this.invoiceRecordList = result?.recordList.length > 0 ? result.recordList : false;
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
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

    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('close', { detail: { refresh: false } }));
    }

    handleCheckAllInvoices(event) {
        const isChecked = event.target.checked;

        this.invoiceRecordList = this.invoiceRecordList.map(item => {
            return { ...item, Selected: isChecked };
        });
    }

    handleCheckInvoice(event) {
        const itemId = event.target.dataset.id;
        const isChecked = event.target.checked;

        // Update the specific item in the record list
        this.invoiceRecordList = this.invoiceRecordList.map(item => {
            if (item.Id === itemId) {
                return { ...item, Selected: isChecked };
            }
            return item;
        });
        // this.isLoading = true;
    }

    handleSaveInvoice() {
        const selectedInvoicesData = this.invoiceRecordList.filter(item => item.Selected);
        if (selectedInvoicesData.length === 0) {
            this.showToast('Error', 'Please select atleast one Invoice (AP)', 'error');
            return;
        }

        let selectedInvoiceIDList = selectedInvoicesData.map(item => item.Id)
        this.isLoading = true;
        if (this.budgetItemId) {
            this.updateInvoicePrice(selectedInvoiceIDList.toString());
        } else {
            this.addInvoicePO(selectedInvoicesData);
        }
    }

    updateInvoicePrice(selectedInvoiceIDList) {
        saveInvoicePrice({ recordId: selectedInvoiceIDList, budgeLineIds: this.budgetItemId })
            .then(result => {
                console.log('updateInvoicePrice: ', result);
                this.showToast('Success', 'Invoice Price Updated Successfully', 'success');
                this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    addInvoicePO(selectedInvoicesData) {
        createInvoice({ selectedInvoices: selectedInvoicesData, RecId: this.budgetId })
            .then(result => {
                console.log('addInvoicePO: ', result);
                this.showToast('Success', 'Invoice Added Successfully', 'success');
                this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
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