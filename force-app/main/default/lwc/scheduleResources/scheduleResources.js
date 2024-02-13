
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchScheduleData from '@salesforce/apex/scheduleResourceController.fetchScheduleData';

export default class ScheduleResources extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track tableData = [];

    connectedCallback() {
        this.scheduleData();
    }

    scheduleData() {
        this.isLoading = true;
        fetchScheduleData({ scheduleId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log('schedule Data:', JSON.stringify(result));
                    this.tableData = result.scheduleList.map(task => {
                        return {
                            id: task.Id,
                            project: task.buildertek__Schedule__r.buildertek__Project__r.Name,
                            schedule: task.buildertek__Schedule__r.buildertek__Description__c,
                            taskName: task.Name,
                            internalVendor: task.buildertek__Internal_Resource__c ? this.findInternalResource(task.buildertek__Internal_Resource__c).Name : '',
                            vendorResources1: task.buildertek__Vendor_Resource_1__c ? this.findContractorResource(task.buildertek__Vendor_Resource_1__c) : '',
                            vendorResources2: task.buildertek__Vendor_Resource_2__c ? this.findContractorResource(task.buildertek__Vendor_Resource_2__c) : '',
                            vendorResources3: task.buildertek__Vendor_Resource_3__c ? this.findContractorResource(task.buildertek__Vendor_Resource_3__c) : '',
                            startDate: task.buildertek__Start__c,
                            endDate: task.buildertek__Finish_Date__c
                        };
                    });
                }
            })
            .catch((error) => {
                console.log('Error ==>', error);
                this.showToast('Error', error, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    findInternalResource(internalResourceId) {
        return this.result.internalResourcesList.find(resource => resource.Id === internalResourceId) || {};
    }

    findContractorResource(contractorResourceId) {
        const contractorResource = this.result.contractorAndResourcesList.find(contractor => contractor.Id === contractorResourceId);
        return contractorResource ? contractorResource.Name : '';
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
}
