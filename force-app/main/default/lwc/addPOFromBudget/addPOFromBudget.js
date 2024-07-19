import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPOData from '@salesforce/apex/BudgetPage.getPOData';
import getcurrency from '@salesforce/apex/BudgetDAO.getcurrency';
import updatePOFromBudget from '@salesforce/apex/BudgetDAO.updatePO';
import updatePOLineFromBudget from '@salesforce/apex/BudgetDAO.updatePOLine';

export default class AddPOFromBudget extends LightningElement {
    @track isLoading;
    @track orgCurrency;
    @track selectedOption = 'Purchase Order';
    @track initialScreen = true;
    @track showPO = false;
    @track showPOL = false;
    @track poList;
    @track poItemList;
    @track selectedRows = [];
    @api budgetId;
    @api budgetLineList = [];
    budgetLineId;

    get availableOptions() {
        return [
            { label: 'Purchase Order', value: 'Purchase Order' },
            { label: 'Purchase Order Line', value: 'Purchase Order Line' },
        ];
    }

    connectedCallback() {
        this.budgetLineId = this.budgetLineList[0].Id;
        this.fetchPOData();
        this.getOrgCurrency();
    }

    // Error handling function
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

    getOrgCurrency() {
        getcurrency()
            .then(result => {
                if (result) {
                    this.orgCurrency = result;
                }
            })
            .catch(error => {
                console.error('Error in fetching currency data', error);
                this.showToast('Error', 'Error in fetching currency data', 'error');
            });
    }

    handleOptionChange(event) {
        this.selectedOption = event.detail.value;
    }

    closeModal() {
        this.showPO = false;
        this.showPOL = false;
        this.dispatchEvent(new CustomEvent('close', { detail: { refresh: false } }));
    }

    nextModal() {
        if (this.selectedOption === 'Purchase Order') {
            this.showPO = true;
            this.showPOL = false;
        } else {
            this.showPO = false;
            this.showPOL = true;
        }
        this.initialScreen = false;
    }

    fetchPOData() {
        this.isLoading = true;
        getPOData({ budgetId: this.budgetId })
            .then(result => {
                if (result) {
                    this.poList = result.poList.length > 0 ? result.poList : undefined;
                    this.poItemList = result.poItemList.length > 0 ? result.poItemList : undefined;
                }
            })
            .catch(error => {
                console.error('Error in fetching PO data', error);
                this.showToast('Error', 'Error in fetching PO data', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    backtoChoosePoAndPoLine() {
        this.initialScreen = true;
        this.showPO = false;
        this.showPOL = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            dissmissible: true,
            duration: 3000
        });
        this.dispatchEvent(event);
    }

    handleCheckboxClick(event) {
        const recordId = event.target.dataset.id;
        if (event.target.checked) {
            this.selectedRows.push({ Id: recordId });
        } else {
            this.selectedRows = this.selectedRows.filter(record => record.Id !== recordId);
        }
    }

    UpdatePO(event) {
        if (this.selectedRows.length === 0) {
            console.error('No selected rows');
            this.showToast('Error', 'No selected rows', 'error');
            return;
        }
        this.isLoading = true;
        if (event.target.dataset.name === 'PO') {
            updatePOFromBudget({ poList: JSON.parse(JSON.stringify(this.selectedRows)), budgetId: this.budgetId, BudgetLineId: this.budgetLineId })
                .then(() => {
                    this.showToast('Success', 'PO added successfully', 'success');
                    this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
                })
                .catch(error => {
                    const { errorMessage, errorObject } = this.returnErrorMsg(error);
                    console.error('Error in updating PO:', errorObject);
                    this.showToast('Error', `Error in updating PO: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } else {
            let poItemListOfID = this.selectedRows.map(obj => obj.Id);

            updatePOLineFromBudget({ POLineId: poItemListOfID, budgetId: this.budgetId, BudgetLineId: [this.budgetLineId] })
                .then(() => {
                    this.showToast('Success', 'PO Line added successfully', 'success');
                    this.dispatchEvent(new CustomEvent('close', { detail: { refresh: true } }));
                })
                .catch(error => {
                    const { errorMessage, errorObject } = this.returnErrorMsg(error);
                    console.error('Error in updating PO Line:', errorObject);
                    this.showToast('Error', `Error in updating PO Line: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

}