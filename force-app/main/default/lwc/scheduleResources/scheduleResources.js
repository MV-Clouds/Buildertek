import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/ScheduleLWCCss';
import fetchScheduleData from '@salesforce/apex/scheduleResourceController.fetchScheduleData';
import updateResource from '@salesforce/apex/scheduleResourceController.updateScheduleItemResources';
import getScheduleData from "@salesforce/apex/GetProjectAndScheduleForGanttCmp.getScheduleData";

export default class ScheduleResources extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track tableData = [];
    @track isScheduleSelected = false;
    @track scheduleWithoutProjectList = [];
    @track projectOptions = [];
    @track mapOfSchedulesOptionsByProject = {};
    @track SchedulesOptions = [];
    @track ProjectNameSet = [];
    @track selectedProjectId;
    @track selectedScheduleId;
    @track selectedScheduleIdForJS;
    @track editRecordId;
    @track selectedVendorId;
    @track selectedVendorResources1 = '';
    @track selectedVendorResources2 = '';
    @track selectedVendorResources3 = '';
    @track vendorOptions = [];
    @track vendorResourcesOptions = [];
    @track scheduleDataWrapper = {};
    @track vendorResourcesMap = {};

    connectedCallback() {
        loadStyle(this, myResource)
        // Calls scheduleData if recordId is provided, else calls getScheduleList
        this.recordId ? (this.scheduleData(), this.isScheduleSelected = true) : this.getScheduleList();
    }

    //* Method to fetch the list of schedules
    getScheduleList() {
        getScheduleData()
            .then((result) => {
                console.log('result', result);
                this.scheduleWithoutProjectList = result.scheduleWithoutProjectList;
                this.mapOfSchedulesOptionsByProject = result.mapOfSchedulesByProject;
                this.ProjectNameSet.push({ label: 'No Project', value: '' })
                for (let key in this.mapOfSchedulesOptionsByProject) {
                    this.ProjectNameSet.push({ label: this.mapOfSchedulesOptionsByProject[key][0].buildertek__Project__r.Name, value: this.mapOfSchedulesOptionsByProject[key][0].buildertek__Project__r.Id });
                }
                this.projectOptions = this.ProjectNameSet;
                console.log('this.projectOptions', this.projectOptions);
            })
            .catch((error) => {
                console.log('Error in getting schedule list', error);
                this.showToast('Error', 'Failed to retrieve the schedule list. Please try again later.', 'error');
            });
    }

    //* Event handler for change in dropdown selection
    handleChange(event) {
        var scheduleWithoutProjectList = [];
        this.callscheduleComponent = false;
        if (event.target.name === 'project') {
            this.selectedProjectId = event.detail.value;
            this.isDisabled = true;
        } else if (event.target.name === 'schedule') {
            this.selectedScheduleIdForJS = event.detail.value;
            this.selectedScheduleId = event.detail.value;
            this.isDisabled = false;
        }

        if (this.selectedProjectId === '') {
            this.scheduleWithoutProjectList.forEach(ele => {
                scheduleWithoutProjectList.push({ label: ele.buildertek__Description__c, value: ele.Id });
            });
            this.SchedulesOptions = scheduleWithoutProjectList;
        } else {
            this.mapOfSchedulesOptionsByProject[this.selectedProjectId].forEach(ele => {
                scheduleWithoutProjectList.push({ label: ele.buildertek__Description__c, value: ele.Id });
            })
            this.SchedulesOptions = scheduleWithoutProjectList;
        }
    }

    //* Method to fetch schedule Item data
    scheduleData() {
        this.isLoading = true;
        fetchScheduleData({ scheduleId: this.recordId ? this.recordId : (this.selectedScheduleId ? this.selectedScheduleId : this.selectedScheduleIdForJS) })
            .then((result) => {
                if (result) {
                    console.log('schedule Data:', JSON.stringify(result));
                    this.scheduleDataWrapper = result;
                    console.log('scheduleDataWrapper:', this.scheduleDataWrapper);
                    this.tableData = this.scheduleDataWrapper.scheduleList.map(task => {
                        return {
                            id: task.Id,
                            project: task.buildertek__Schedule__r.hasOwnProperty('buildertek__Project__r') ? task.buildertek__Schedule__r.buildertek__Project__r.Name : '',
                            schedule: task.buildertek__Schedule__r.buildertek__Description__c,
                            taskName: task.Name,
                            vendor: task.hasOwnProperty('buildertek__Contractor__r') ? task.buildertek__Contractor__r.Name : '',
                            vendorResources1: task.hasOwnProperty('buildertek__Contractor_Resource_1__r') ? task.buildertek__Contractor_Resource_1__r.Name : '',
                            vendorResources2: task.hasOwnProperty('buildertek__Contractor_Resource_2__r') ? task.buildertek__Contractor_Resource_2__r.Name : '',
                            vendorResources3: task.hasOwnProperty('buildertek__Contractor_Resource_3__r') ? task.buildertek__Contractor_Resource_3__r.Name : '',
                            startDate: task.buildertek__Start__c,
                            endDate: task.buildertek__Finish_Date__c
                        };
                    });
                }
                this.processScheduleDataWrapper();
            })
            .catch((error) => {
                console.log('Error ==>', error);
                this.showToast('Error', 'There was an error while retrieving the schedule data. Please contact the administrator to resolve this issue.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    //* Method to handle click on schedule
    handleScheduleClick() {
        if (this.selectedScheduleIdForJS) {
            this.isScheduleSelected = true;
            console.log('Project Id ==>', this.selectedProjectId);
            console.log('Schedule Id ==>', this.selectedScheduleId);
            this.scheduleData();
        } else {
            this.showToast('Error', 'Please select a schedule', 'error');
        }
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }

    // * Method to handle click on edit button
    editResource(event) {
        this.editRecordId = event.currentTarget.dataset.id;
        let currentVendorId = event.currentTarget.dataset.vendorid;
        // Enable the edit mode for the selected record and disable for others
        this.tableData = this.tableData.map(row => ({
            ...row,
            isEditing: row.id === this.editRecordId
        }));

        const selectedRecord = this.tableData.find(row => row.id === this.editRecordId);
        if (selectedRecord.isEditing) {
            this.selectedVendorId = currentVendorId ? this.vendorOptions.find(option => option.label === selectedRecord.vendor)?.value : '';

            if (this.selectedVendorId) {
                this.vendorResourcesOptions = [{ label: 'None', value: '' }];
                if (this.vendorResourcesMap[this.selectedVendorId]) {
                    this.vendorResourcesOptions = this.vendorResourcesOptions.concat(
                        this.vendorResourcesMap[this.selectedVendorId].map(ele => ({
                            label: ele.label,
                            value: ele.value
                        }))
                    );
                }
            }

            // Set the selected values for the vendor and vendor resources
            selectedRecord.selectedVendorId = this.selectedVendorId;

            ['1', '2', '3'].forEach(index => {
                const fieldName = `vendorResources${index}`;
                const fieldValue = selectedRecord[fieldName];
                selectedRecord[`selectedVendorResources${index}`] = fieldValue ? this.vendorResourcesOptions.find(option => option.label === fieldValue)?.value : '';
            });
        }

        console.log(`Selected Vendor Id: ${this.selectedVendorId}, Selected Vendor Resources 1: ${selectedRecord.selectedVendorResources1}, Selected Vendor Resources 2: ${selectedRecord.selectedVendorResources2}, Selected Vendor Resources 3: ${selectedRecord.selectedVendorResources3}`);
    }

    closeEditFields() {
        this.tableData = this.tableData.map(row => {
            return { ...row, isEditing: false };
        });
    }

    // * Method to handle vendor change
    vendorChange(event) {
        this.selectedVendorId = event.target.value;
        console.log('Selected Vendor:', this.selectedVendorId);

        if (this.selectedVendorId) {
            this.vendorResourcesOptions = [{ label: 'None', value: '' }];
            if (this.vendorResourcesMap[this.selectedVendorId]) {
                this.vendorResourcesOptions = this.vendorResourcesOptions.concat(
                    this.vendorResourcesMap[this.selectedVendorId].map(ele => ({
                        label: ele.label,
                        value: ele.value
                    }))
                );
            }
        } else {
            this.selectedVendorResources1 = '';
            this.selectedVendorResources2 = '';
            this.selectedVendorResources3 = '';
        }

        console.log('vendorResourcesOptions:', this.vendorResourcesOptions);
    }

    // TODO - Implement the vendorResourcesChange methods
    vendorResourcesChange(event) {
        console.log('Selected Vendor Resources', event.target.value);
        const fieldName = event.target.dataset.field;

        if (fieldName === 'selectedVendorResources1') {
            this.selectedVendorResources1 = event.target.value;
        } else if (fieldName === 'selectedVendorResources2') {
            this.selectedVendorResources2 = event.target.value;
        } else if (fieldName === 'selectedVendorResources3') {
            this.selectedVendorResources3 = event.target.value;
        }
    }

    // * Create map of vendor and its resources 
    processScheduleDataWrapper() {
        this.vendorOptions = this.scheduleDataWrapper.contractorAndResourcesList ?
            this.scheduleDataWrapper.contractorAndResourcesList.map(ele => ({
                label: ele.Name,
                value: ele.Id
            })) : [];
        console.log('vendorOptions:', JSON.parse(JSON.stringify(this.vendorOptions)));

        if (this.scheduleDataWrapper.contractorAndResourcesList) {
            this.scheduleDataWrapper.contractorAndResourcesList.forEach(vendor => {
                const vendorId = vendor.Id;
                const resources = [];
                if (vendor.Contacts) {
                    vendor.Contacts.forEach(resource => {
                        resources.push({ label: resource.Name, value: resource.Id });
                    });
                }
                this.vendorResourcesMap[vendorId] = resources;
            });
        }
        console.log('vendorResourcesMap:', JSON.parse(JSON.stringify(this.vendorResourcesMap)));
    }

    // * Method to handle save button click
    saveResource() {
        this.isLoading = true;
        const updatedRecord = {
            Id: this.editRecordId,
            buildertek__Contractor__c: this.selectedVendorId,
            buildertek__Contractor_Resource_1__c: this.selectedVendorResources1,
            buildertek__Contractor_Resource_2__c: this.selectedVendorResources2,
            buildertek__Contractor_Resource_3__c: this.selectedVendorResources3
        };
        console.log('Updated Record:', updatedRecord);
        updateResource({ scheduleItem: updatedRecord })
            .then((result) => {
                console.log('Result:', result);
                this.showToast('Success', 'Record updated successfully', 'success');
                this.tableData = this.tableData.map(row => {
                    return { ...row, isEditing: false };
                });
            })
            .catch((error) => {
                console.log('Error:', error);
                this.showToast('Error', 'There was an error while updating the record. Please contact the administrator to resolve this issue.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
}