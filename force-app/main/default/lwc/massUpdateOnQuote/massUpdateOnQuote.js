import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getallData from '@salesforce/apex/QuotePage.massUpdateQuote';
import update from '@salesforce/apex/QuotePage.massUpdateQuoteItem';

export default class MassUpdateOnQuote extends LightningElement {
    @api quoteId;
    @track quoteItem;
    @track data = [];

    showSpinner = false;
    connectedCallback() {
        this.showSpinner = true;
        getallData({ Quote: this.quoteId })
            .then(result => {
                console.log('Quote Information: ', result);
                this.quoteItem = result;
                this.groupQuoteItems();
            })
            .catch(error => {
                console.error('error: ', error);
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    groupQuoteItems() {
        let groupedData = {};
        let counter = 1;

        this.quoteItem.forEach(item => {
            let groupName = item.buildertek__Grouping__r?.Name ?? 'No Grouping';
            let groupId = item.buildertek__Grouping__c ?? 'no-group';

            if (item.buildertek__Cost_Code__c != null) {
                item.CostCode = item.buildertek__Cost_Code__r.Name;
            }

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
        console.log({ data: this.data });
    }

    handleInputChange(event) {
        const { id, field } = event.target.dataset;
        const value = event.target.value;
        const updatedItem = this.quoteItem.find(item => item.Id === id);
        if (updatedItem) {
            updatedItem[field] = value;
        }
    }

    handleSave() {
        this.showSpinner = true;
        let dataToSave = JSON.stringify(this.prepareDataForSave());
        update({ QuoteItems: dataToSave })
            .then(result => {
                if (result === 'Success') {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote Items updated successfully',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    console.log('Data saved successfully');
                } else {
                    throw new Error(result);
                }
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while saving quote items: ' + error.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                console.error('Error saving data: ' + error.message);
            })
            .finally(() => {
                this.showSpinner = false;
                this.dispatchEvent(new CustomEvent('cancel'));
            });
    }

    prepareDataForSave() {
        return this.quoteItem.map(item => {
            return {
                QuoteItemId: item.Id,
                Name: item.Name,
                Quantity: item.buildertek__Quantity__c,
                UnitCost: item.buildertek__Unit_Cost__c,
                Markup: item.buildertek__Markup__c,
                Tax: item.buildertek__Tax__c,
                Notes: item.buildertek__Notes__c
            };
        });
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}