import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getallData from '@salesforce/apex/BudgetPage.massUpdateBudget';
import update from '@salesforce/apex/BudgetPage.massUpdateBudgetItem';

export default class MassUpdateOnBudget extends LightningElement {
    @api budgetId;
    @track budgetItem;
    @track data = [];
    @track BudgetName;
    @track availableGroupingOption = [];
    showSpinner = false;

    connectedCallback() {
        this.showSpinner = true;
        getallData({ Budget: this.budgetId })
            .then(result => {
                this.budgetItem = result.BudgetItemList;
                this.BudgetName = this.budgetItem[0].buildertek__Budget__r.Name;
                let groupingOption = [];
                for (let i = 0; i < result.BudgetItemGroupList.length; i++) {
                    groupingOption.push({ label: result.BudgetItemGroupList[i].Name, value: result.BudgetItemGroupList[i].Id });
                }
                this.availableGroupingOption = groupingOption;
                this.groupBudgetItems();
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    groupBudgetItems() {
        let groupedData = {};
        let counter = 1;

        this.budgetItem.forEach(item => {
            let groupName = item.buildertek__Group__r?.Name ?? 'No Grouping';
            let groupId = item.buildertek__Group__c ?? 'no-group';

            item.Number = counter++;

            if (!groupedData[groupId]) {
                groupedData[groupId] = {
                    groupName: groupName,
                    groupId: groupId,
                    items: []
                };
            }

            groupedData[groupId].items.push(item);
        });
        this.data = Object.values(groupedData);
    }

    handleInputChange(event) {
        const { id, field } = event.target.dataset;
        const value = event.target.value;
        const updatedItem = this.budgetItem.find(item => item.Id === id);
        if (updatedItem) {
            updatedItem[field] = value;
        }
    }

    handleSave() {
        this.showSpinner = true;
        const invalidItem = this.budgetItem.find(item => !item.Name || item.buildertek__Quantity__c <= 0);

        if (invalidItem) {
            const errorMessage = !invalidItem.Name ? 'Name field cannot be empty' : 'Quantity must be greater than or equal to 1';
            this.showToast('Error', errorMessage, 'error');
            this.showSpinner = false;
            return;
        }
        let dataToSave = JSON.stringify(this.prepareDataForSave());
        update({ BudgetItems: dataToSave })
            .then(result => {
                if (result === 'Success') {
                    this.showToast('Success', 'Budget items updated successfully', 'success');
                } else {
                    this.showToast('Error', 'Error while saving budget items', 'error');
                }
            })
            .catch(error => {
                const { errorMessage } = this.returnErrorMsg(error);
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
                this.dispatchEvent(new CustomEvent('cancel', { detail: { refresh: true } }));
            });
    }

    prepareDataForSave() {
        return this.budgetItem.map(item => {
            return {
                BudgetItemId: item.Id,
                Name: item.Name,
                Quantity: item.buildertek__Quantity__c,
                UnitCost: item.buildertek__Unit_Price__c,
                Markup: item.buildertek__Markup__c,
                Tax: item.buildertek__Tax__c,
                ForeToComplete: item.buildertek__Forecast_To_Complete__c,
            };
        });
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel', { detail: { refresh: false } }));
    }

    returnErrorMsg(error) {
        console.error('An error occurred:', error);

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

    showToast(title, message, variant = 'info') {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissable',
            duration: 3000
        });
        this.dispatchEvent(event);
    }
}