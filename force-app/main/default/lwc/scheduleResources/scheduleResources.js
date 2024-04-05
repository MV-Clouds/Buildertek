import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/ScheduleLWCCss';
import fetchScheduleData from '@salesforce/apex/scheduleResourceController.fetchScheduleData';
import updateResource from '@salesforce/apex/scheduleResourceController.updateScheduleItemResources';
import getScheduleData from "@salesforce/apex/GetProjectAndScheduleForGanttCmp.getScheduleData";

export default class ScheduleResources extends NavigationMixin(LightningElement) {
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
    @track selectedInternalResourceId = '';
    @track internalResourcesOption = [];
    @track vendorResourcesOptions = [];
    @track scheduleDataWrapper = {};
    @track vendorResourcesMap = {};
    @track vendorResourceConflictJSON = {};
    @track internalResourceConflictJSON = {};
    @track isConflict = false;
    @track conflictingSchedules = [];
    @track intialConflictList = [];
    @track existingConflictScheduleMap = {};
    @track isShowConflictCalled = false;

    connectedCallback() {
        loadStyle(this, myResource)
        // Calls scheduleData if recordId is provided, else calls getScheduleList
        this.recordId ? (this.scheduleData(), this.isScheduleSelected = true) : this.getScheduleList();
    }

    //* Method to fetch the list of schedules
    getScheduleList() {
        this.isLoading = true;
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
                console.error('Error in getting schedule list', error);
                this.showToast('Error', 'Failed to retrieve the schedule list. Please try again later.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
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
        const scheduleId = this.recordId || this.selectedScheduleId || this.selectedScheduleIdForJS;

        fetchScheduleData({ scheduleId })
            .then((result) => {
                if (result) {
                    // console.log('schedule Data:', JSON.stringify(result));
                    this.scheduleDataWrapper = result;
                    this.intialConflictList = this.scheduleDataWrapper.conflictingSchedulesList;
                    this.tableData = this.scheduleDataWrapper.scheduleList.map(task => {
                        return {
                            id: task.Id,
                            project: task.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                            schedule: task.buildertek__Schedule__r?.buildertek__Description__c || '',
                            scheduleId: task.buildertek__Schedule__c,
                            taskName: task.Name,
                            internalResource: task.buildertek__Internal_Resource_1__r?.Name || '',
                            internalResourceId: task.buildertek__Internal_Resource_1__r?.Id || '',
                            vendor: task.buildertek__Contractor__r?.Name || '',
                            vendorId: task.buildertek__Contractor__r?.Id || '',
                            vendorResources1: task.buildertek__Contractor_Resource_1__r?.Name || '',
                            vendorResources1Id: task.buildertek__Contractor_Resource_1__r?.Id || '',
                            vendorResources2: task.buildertek__Contractor_Resource_2__r?.Name || '',
                            vendorResources2Id: task.buildertek__Contractor_Resource_2__r?.Id || '',
                            vendorResources3: task.buildertek__Contractor_Resource_3__r?.Name || '',
                            vendorResources3Id: task.buildertek__Contractor_Resource_3__r?.Id || '',
                            startDate: task.buildertek__Start__c,
                            endDate: task.buildertek__Finish__c,
                            hasConflict: false,
                        };
                    });
                    // console.log('tableData:', JSON.parse(JSON.stringify(this.tableData)));
                }
                this.processScheduleDataWrapper();
            })
            .catch((error) => {
                console.error('Error ==>', error);
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
            // console.log('Project Id ==>', this.selectedProjectId);
            // console.log('Schedule Id ==>', this.selectedScheduleId);
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

    //* Method to handle click on edit button
    editResource(event) {
        this.isLoading = true;

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

            this.vendorResourcesOptions = [{ label: 'None', value: '' }];
            if (this.selectedVendorId) {
                if (this.vendorResourcesMap[this.selectedVendorId]) {
                    this.vendorResourcesOptions = this.vendorResourcesOptions.concat(
                        this.vendorResourcesMap[this.selectedVendorId].map(ele => ({
                            label: ele.label,
                            value: ele.value
                        }))
                    );
                }
            }

            // Set the selected values for the internal resource, vendor and vendor resources
            selectedRecord.selectedVendorId = this.selectedVendorId;

            ['1', '2', '3'].forEach(index => {
                const fieldName = `vendorResources${index}`;
                const fieldValue = selectedRecord[fieldName];
                selectedRecord[`selectedVendorResources${index}`] = fieldValue ? this.vendorResourcesOptions.find(option => option.label === fieldValue)?.value : '';
            });
        }
        selectedRecord['selectedInternalResourceId'] = selectedRecord.internalResource ? this.internalResourcesOption.find(option => option.label === selectedRecord.internalResource)?.value : '';

        console.log(`Selected Vendor Id: ${this.selectedVendorId}, Selected Vendor Resources 1: ${selectedRecord.selectedVendorResources1}, Selected Vendor Resources 2: ${selectedRecord.selectedVendorResources2}, Selected Vendor Resources 3: ${selectedRecord.selectedVendorResources3} Selected Internal Resource: ${selectedRecord.selectedInternalResourceId}`);

        this.selectedVendorResources1 = selectedRecord.selectedVendorResources1;
        this.selectedVendorResources2 = selectedRecord.selectedVendorResources2;
        this.selectedVendorResources3 = selectedRecord.selectedVendorResources3;
        this.selectedInternalResourceId = selectedRecord.selectedInternalResourceId;
        this.isLoading = false;
    }

    closeEditFields() {
        this.isLoading = true;
        this.tableData = this.tableData.map(row => {
            return { ...row, isEditing: false };
        });
        this.isLoading = false;
    }

    //* Method to handle vendor change
    vendorChange(event) {
        this.selectedVendorId = event.target.value;

        // Nullify vendorResources
        this.selectedVendorResources1 = '';
        this.selectedVendorResources2 = '';
        this.selectedVendorResources3 = '';

        this.vendorResourcesOptions = [];
        if (this.selectedVendorId && this.selectedVendorId !== 'None') {
            if (this.vendorResourcesMap[this.selectedVendorId]) {
                this.vendorResourcesOptions = this.vendorResourcesMap[this.selectedVendorId].map(ele => ({
                    label: ele.label,
                    value: ele.value
                }));
            }
        }
    }

    //* Method to handle vendor resources change
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

    // * Method to create a map of conflict data
    processScheduleDataWrapper() {
        this.vendorOptions = this.scheduleDataWrapper.contractorAndResourcesList
            ? [{ label: 'None', value: '' }, ...this.scheduleDataWrapper.contractorAndResourcesList.map(ele => ({
                label: ele.Name,
                value: ele.Id
            }))]
            : [{ label: 'None', value: '' }];


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

        this.internalResourcesOption = this.scheduleDataWrapper.internalResourcesList
            ? [{ label: 'None', value: '' }, ...this.scheduleDataWrapper.internalResourcesList.map(ele => ({
                label: ele.Name,
                value: ele.Id
            }))]
            : [{ label: 'None', value: '' }];

        // Creating Possible VendorResourcesConflict and internalResourceConflict JSON Data 
        for (const contractorAndResource of this.scheduleDataWrapper.contractorAndResourcesList) {
            const vendorId = contractorAndResource.Id;
            this.vendorResourceConflictJSON[vendorId] = {};
            this.internalResourceConflictJSON = {};

            for (const scheduleItem of this.scheduleDataWrapper.conflictingSchedulesList) {
                const resourceId1 = scheduleItem.buildertek__Contractor_Resource_1__c;
                const resourceId2 = scheduleItem.buildertek__Contractor_Resource_2__c;
                const resourceId3 = scheduleItem.buildertek__Contractor_Resource_3__c;
                const internalResourceId = scheduleItem.buildertek__Internal_Resource_1__c;

                if (scheduleItem.buildertek__Contractor__c === vendorId) {
                    if (resourceId1) {
                        if (!this.vendorResourceConflictJSON[vendorId][resourceId1]) {
                            this.vendorResourceConflictJSON[vendorId][resourceId1] = {};
                        }
                        this.vendorResourceConflictJSON[vendorId][resourceId1][scheduleItem.Id] = {
                            StartDate: scheduleItem.buildertek__Start__c,
                            EndDate: scheduleItem.buildertek__Finish__c,
                            resourceId1: resourceId1,
                            resourceName: scheduleItem?.buildertek__Contractor_Resource_1__r?.Name || '',
                            scheduleName: scheduleItem.buildertek__Schedule__r.buildertek__Description__c,
                            projectName: scheduleItem?.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                            taskName: scheduleItem.Name
                        };
                    }

                    if (resourceId2) {
                        if (!this.vendorResourceConflictJSON[vendorId][resourceId2]) {
                            this.vendorResourceConflictJSON[vendorId][resourceId2] = {};
                        }
                        this.vendorResourceConflictJSON[vendorId][resourceId2][scheduleItem.Id] = {
                            StartDate: scheduleItem.buildertek__Start__c,
                            EndDate: scheduleItem.buildertek__Finish__c,
                            resourceId2: resourceId2,
                            resourceName: scheduleItem?.buildertek__Contractor_Resource_2__r?.Name || '',
                            scheduleName: scheduleItem.buildertek__Schedule__r.buildertek__Description__c,
                            projectName: scheduleItem?.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                            taskName: scheduleItem.Name
                        };
                    }

                    if (resourceId3) {
                        if (!this.vendorResourceConflictJSON[vendorId][resourceId3]) {
                            this.vendorResourceConflictJSON[vendorId][resourceId3] = {};
                        }
                        this.vendorResourceConflictJSON[vendorId][resourceId3][scheduleItem.Id] = {
                            StartDate: scheduleItem.buildertek__Start__c,
                            EndDate: scheduleItem.buildertek__Finish__c,
                            resourceId3: resourceId3,
                            resourceName: scheduleItem?.buildertek__Contractor_Resource_3__r?.Name || '',
                            scheduleName: scheduleItem.buildertek__Schedule__r.buildertek__Description__c,
                            projectName: scheduleItem?.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                            taskName: scheduleItem.Name
                        };
                    }
                }
                if (internalResourceId) {
                    if (!this.internalResourceConflictJSON[internalResourceId]) {
                        this.internalResourceConflictJSON[internalResourceId] = {};
                    }
                    this.internalResourceConflictJSON[internalResourceId][scheduleItem.Id] = {
                        StartDate: scheduleItem.buildertek__Start__c,
                        EndDate: scheduleItem.buildertek__Finish__c,
                        internalResourceId: internalResourceId,
                        resourceName: scheduleItem.buildertek__Internal_Resource_1__r.Name,
                        scheduleName: scheduleItem.buildertek__Schedule__r.buildertek__Description__c,
                        projectName: scheduleItem?.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                        taskName: scheduleItem.Name
                    };
                }
            }
        }
        this.internalResourceConflictJSON = Object.fromEntries(
            Object.entries(this.internalResourceConflictJSON)
                .filter(([, value]) => Object.keys(value).length > 0)
        );

        this.vendorResourceConflictJSON = Object.fromEntries(
            Object.entries(this.vendorResourceConflictJSON)
                .filter(([, value]) => Object.keys(value).length > 0)
        );

        // console.log('this.internalResourceConflictJSON:', JSON.stringify(this.internalResourceConflictJSON));
        // console.log('vendorResourceConflictJSON:', JSON.stringify(this.vendorResourceConflictJSON));
        this.getCurrentConflictingSchedules();
    }

    internalResourceChange(event) {
        this.selectedInternalResourceId = event.target.value;
    }

    //* Method to handle save button click
    saveResource() {
        this.isLoading = true;
        // Check if the selected resources are different
        if (!this.areResourcesDifferent(this.selectedVendorResources1, this.selectedVendorResources2, this.selectedVendorResources3)) {
            this.showToast('Warning', 'Please select different resources for the vendor', 'warning');
            this.isLoading = false;
            return;
        }

        // Check for conflicting dates before assigning resources
        if (!this.checkResourceConflict()) {
            this.updateResourceOnScheduleItem();

            this.tableData = this.tableData.map(row => {
                return row.id === this.editRecordId ? { ...row, hasConflict: false } : row;
            });

            setTimeout(() => {
                const taskElement = this.template.querySelector(`div[data-id="${this.editRecordId}"]`);
                if (taskElement) {
                    taskElement.style.backgroundColor = '#ffffff';
                }
            }, 0);
        } else {
            this.isConflict = true;
        }
    }

    //* Method to check if the selected resources are different
    areResourcesDifferent(resource1, resource2, resource3) {
        resource1 = resource1 === "" ? null : resource1;
        resource2 = resource2 === "" ? null : resource2;
        resource3 = resource3 === "" ? null : resource3;

        if (resource1 === null && resource2 === null && resource3 === null) {
            return true;
        }

        if (
            (resource1 !== resource2 && resource1 !== resource3 && resource2 !== resource3) ||
            (resource1 === null && resource2 !== resource3) ||
            (resource2 === null && resource1 !== resource3) ||
            (resource3 === null && resource1 !== resource2)
        ) {
            return true;
        } else {
            return false;
        }
    }

    //* Function to search for schedules
    findSchedules(vendorResourceData, internalResourceData, vendorId, resourceId, internalResourceId) {
        const vendorData = vendorResourceData[vendorId] || {};
        const internalData = internalResourceData || {};
        // console.log(`Vendor Data: ${JSON.stringify(vendorData)} && Internal Data: ${JSON.stringify(internalData)}`);
        const vendorSchedules = [];
        const internalSchedules = [];
        for (const resourceIdKey in vendorData) {
            if (vendorData.hasOwnProperty(resourceIdKey) && resourceIdKey === resourceId) {
                const schedules = vendorData[resourceIdKey];
                for (const scheduleItemId in schedules) {
                    if (scheduleItemId !== this.editRecordId) {
                        vendorSchedules.push({
                            scheduleId: scheduleItemId,
                            StartDate: schedules[scheduleItemId].StartDate,
                            EndDate: schedules[scheduleItemId].EndDate,
                            resourceName: schedules[scheduleItemId].resourceName
                        });
                    }
                }
            }
        }

        for (const resourceIdKey in internalData) {
            if (internalData.hasOwnProperty(resourceIdKey) && resourceIdKey === internalResourceId) {
                const schedules = internalData[resourceIdKey];
                for (const scheduleItemId in schedules) {
                    if (scheduleItemId !== this.editRecordId) {
                        internalSchedules.push({
                            scheduleId: scheduleItemId,
                            StartDate: schedules[scheduleItemId].StartDate,
                            EndDate: schedules[scheduleItemId].EndDate,
                            resourceName: schedules[scheduleItemId].resourceName
                        });
                    }
                }
            }
        }

        // console.log(`Vendor Schedules: ${JSON.stringify(vendorSchedules)} && Internal Schedules: ${JSON.stringify(internalSchedules)}`);
        return { vendorSchedules, internalSchedules };
    }

    //* Check for conflicting dates before assigning resources
    checkResourceConflict() {
        const { editRecordId, tableData, selectedVendorId, selectedInternalResourceId, selectedVendorResources1, selectedVendorResources2, selectedVendorResources3 } = this;
        const selectedRecord = tableData.find(row => row.id === editRecordId);
        const selectedStartDate = selectedRecord.startDate;
        const selectedEndDate = selectedRecord.endDate;
        const selectedResources = [selectedInternalResourceId, selectedVendorResources1, selectedVendorResources2, selectedVendorResources3].filter(Boolean);
        this.conflictingSchedules = [];
        const conflictingItems = [];

        selectedResources.forEach(selectedResource => {
            const schedules = this.findSchedules(this.vendorResourceConflictJSON, this.internalResourceConflictJSON, selectedVendorId, selectedResource, selectedInternalResourceId);

            const conflictScheduleList = schedules.vendorSchedules.concat(schedules.internalSchedules);
            conflictScheduleList.forEach(scheduleItem => {
                if (this.isScheduleConflicting(selectedStartDate, selectedEndDate, scheduleItem)) {
                    const conflictingSchedule = this.intialConflictList.find(row => row.Id === scheduleItem.scheduleId);
                    // Check if the conflicting resource matches the selected resource type
                    if (conflictingSchedule && conflictingSchedule.Id !== editRecordId) {
                        let currentResourceName = selectedResource === selectedInternalResourceId ? this.internalResourcesOption.find(option => option.value === selectedInternalResourceId)?.label : this.vendorResourcesMap[selectedVendorId]?.find(resource => resource.value === selectedResource)?.label || '';
                        conflictingItems.push({
                            id: conflictingSchedule.Id,
                            taskName: conflictingSchedule.Name,
                            startDate: conflictingSchedule.buildertek__Start__c,
                            endDate: conflictingSchedule.buildertek__Finish__c,
                            schedule: conflictingSchedule.buildertek__Schedule__r.buildertek__Description__c,
                            project: conflictingSchedule.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                            scheduleId: conflictingSchedule.buildertek__Schedule__c,
                            resourceName: currentResourceName,
                        });
                    }
                }
            });
        });

        if (conflictingItems.length > 0) {
            conflictingItems.unshift({
                id: selectedRecord.id,
                taskName: selectedRecord.taskName,
                startDate: selectedRecord.startDate,
                endDate: selectedRecord.endDate,
                schedule: selectedRecord.schedule,
                project: selectedRecord.project,
                scheduleId: selectedRecord.scheduleId,
                resourceName: 'Current Schedule Item',
            });

            const groupedConflictingItems = {};
            conflictingItems.forEach(item => {
                const resourceName = item.resourceName;
                if (!groupedConflictingItems[resourceName]) {
                    groupedConflictingItems[resourceName] = [];
                }
                // Use Set to keep track of unique items within each resource group
                const itemSet = new Set(groupedConflictingItems[resourceName].map(JSON.stringify));
                if (!itemSet.has(JSON.stringify(item))) {
                    groupedConflictingItems[resourceName].push(item);
                }
            });

            console.log(groupedConflictingItems);
            const conflictingItemsArray = Object.keys(groupedConflictingItems).map(resourceName => ({
                resourceName: resourceName,
                items: groupedConflictingItems[resourceName]
            }));

            this.groupedConflictingItems = conflictingItemsArray;
            return true;
        }
        return false;
    }

    handleCloseModal() {
        this.isLoading = false;
        this.isConflict = false;
        this.isShowConflictCalled = false;
        this.tableData = this.tableData.map(row => {
            return { ...row, isEditing: false };
        });
    }

    // * Method to Accept conflict and update the resource
    handleAcceptConflict() {
        this.isConflict = false;
        console.log(`ishowConflictCalled: ${this.isShowConflictCalled}`);
        if (!this.isShowConflictCalled) {
            // Update the conflictingSchedules list based on the accepted changes
            this.conflictingSchedules = this.conflictingSchedules.map(conflict => {
                return {
                    ...conflict,
                    vendor: this.vendorOptions.find(option => option.value === this.selectedVendorId)?.label,
                    vendorResources1: this.selectedVendorResources1 !== '' ? this.vendorResourcesOptions.find(option => option.value === this.selectedVendorResources1)?.label : '',
                    vendorResources2: this.selectedVendorResources2 !== '' ? this.vendorResourcesOptions.find(option => option.value === this.selectedVendorResources2)?.label : '',
                    vendorResources3: this.selectedVendorResources3 !== '' ? this.vendorResourcesOptions.find(option => option.value === this.selectedVendorResources3)?.label : '',
                    internalResource: this.internalResourcesOption.find(option => option.value === this.selectedInternalResourceId)?.label
                };
            });

            // Call the updateResourceOnScheduleItem method to persist the changes
            this.updateResourceOnScheduleItem();

            // Update hasConflict to true for the current task
            this.tableData = this.tableData.map(row => {
                return row.id === this.editRecordId ? { ...row, hasConflict: true } : row;
            });

            // Update the bg color for the current task
            setTimeout(() => {
                const taskElement = this.template.querySelector(`div[data-id="${this.editRecordId}"]`);
                if (taskElement) {
                    taskElement.style.backgroundColor = '#ffbabc';
                }
            }, 0);
        } else {
            this.isShowConflictCalled = false;
        }
    }

    // * Redirect to the current schedule
    handleFixConflict(event) {
        this.isConflict = false;
        let scheduleId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: scheduleId,
                objectApiName: 'buildertek__Schedule__c',
                actionName: 'view'
            },
        });
        this.closeEditFields();
    }

    //* Method to update the resource on the schedule item
    updateResourceOnScheduleItem() {
        this.isLoading = true;
        const updatedRecord = {
            Id: this.editRecordId,
            buildertek__Contractor__c: this.selectedVendorId,
            buildertek__Contractor_Resource_1__c: this.selectedVendorResources1,
            buildertek__Contractor_Resource_2__c: this.selectedVendorResources2,
            buildertek__Contractor_Resource_3__c: this.selectedVendorResources3,
            buildertek__Internal_Resource_1__c: this.selectedInternalResourceId
        };

        // Remove the label if the resource is set to "None"
        if (this.selectedVendorResources1 === '') {
            updatedRecord.buildertek__Contractor_Resource_1__c = null;
        }
        if (this.selectedVendorResources2 === '') {
            updatedRecord.buildertek__Contractor_Resource_2__c = null;
        }
        if (this.selectedVendorResources3 === '') {
            updatedRecord.buildertek__Contractor_Resource_3__c = null;
        }

        updateResource({ scheduleItem: updatedRecord })
            .then((result) => {
                console.log('Result:', result);
                this.showToast('Success', 'Record updated successfully', 'success');
                this.tableData = this.tableData.map(row => {
                    return { ...row, isEditing: false };
                });
                this.tableData = this.tableData.map(row => {
                    return row.id === this.editRecordId ? {
                        ...row,
                        vendorId: this.selectedVendorId,
                        vendor: this.vendorOptions.find(option => option.value === this.selectedVendorId)?.label,
                        vendorResources1Id: this.selectedVendorResources1,
                        vendorResources1: this.selectedVendorResources1 !== '' ? this.vendorResourcesOptions.find(option => option.value === this.selectedVendorResources1)?.label : '',
                        vendorResources2Id: this.selectedVendorResources2,
                        vendorResources2: this.selectedVendorResources2 !== '' ? this.vendorResourcesOptions.find(option => option.value === this.selectedVendorResources2)?.label : '',
                        vendorResources3Id: this.selectedVendorResources3,
                        vendorResources3: this.selectedVendorResources3 !== '' ? this.vendorResourcesOptions.find(option => option.value === this.selectedVendorResources3)?.label : '',
                        internalResource: this.internalResourcesOption.find(option => option.value === this.selectedInternalResourceId)?.label,
                    } : row;
                });
            })
            .catch((error) => {
                console.error('Error:', error);
                this.showToast('Error', 'There was an error while updating the record. Please contact the administrator to resolve this issue.', 'error');
            })
            .finally(() => {
                this.scheduleData();
                this.isLoading = false;
            });
    }

    // * Method to navigate to the vendor resource page
    viewVendorResource(event) {
        const viewResource = event.currentTarget.dataset.vendorid;
        const fieldName = event.currentTarget.dataset.name;
        // debugger
        console.log(`View Resource: ${viewResource}, Field Name: ${fieldName}`);
        const state = {
            c__fieldName: fieldName,
            c__scheduleId: this.recordId || this.selectedScheduleId || this.selectedScheduleIdForJS,
        };

        if (fieldName === 'resource') {
            state.c__vendorResourceId = viewResource || '';
        } else {
            state.c__vendorId = viewResource || '';
        }
        console.log('state', state);
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__scheduleResourceAssign',
            },
            state: state
        });
    }

    // * Method to get conflicting schedule for all task
    getCurrentConflictingSchedules() {
        this.existingConflictScheduleMap = {};

        this.tableData.forEach(task => {
            const taskId = task.id;
            const selectedStartDate = task.startDate;
            const selectedEndDate = task.endDate;
            const selectedVendorId = task.vendorId;
            const internalResourceId = task.internalResourceId;
            const selectedResources = [internalResourceId, task.vendorResources1Id, task.vendorResources2Id, task.vendorResources3Id].filter(Boolean);
            selectedResources.forEach(selectedResource => {
                const schedules = this.findSchedules(this.vendorResourceConflictJSON, this.internalResourceConflictJSON, selectedVendorId, selectedResource, internalResourceId);
                const conflictScheduleList = schedules.vendorSchedules.concat(schedules.internalSchedules);
                conflictScheduleList.forEach(scheduleItem => {
                    if (this.isScheduleConflicting(selectedStartDate, selectedEndDate, scheduleItem)) {
                        const conflictingSchedule = this.intialConflictList.find(row => row.Id === scheduleItem.scheduleId);
                        // console.log(`Schedule Item Id ==== ${JSON.stringify(scheduleItem.scheduleId)}`);
                        // console.log(`conflictingSchedule ==== ${JSON.stringify(conflictingSchedule)}`);
                        if (conflictingSchedule && conflictingSchedule.Id !== task.id) {
                            if (!this.existingConflictScheduleMap[taskId]) {
                                this.existingConflictScheduleMap[taskId] = {};
                            }

                            if (!this.existingConflictScheduleMap[taskId][selectedResource]) {
                                this.existingConflictScheduleMap[taskId][selectedResource] = [];
                            }

                            this.existingConflictScheduleMap[taskId][selectedResource].push({
                                id: conflictingSchedule.Id,
                                taskName: conflictingSchedule.Name,
                                startDate: conflictingSchedule.buildertek__Start__c,
                                endDate: conflictingSchedule.buildertek__Finish__c,
                                schedule: conflictingSchedule.buildertek__Schedule__r.buildertek__Description__c,
                                project: conflictingSchedule.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                                scheduleId: conflictingSchedule.buildertek__Schedule__c,
                                resourceName: selectedResource === internalResourceId ? task.internalResource : this.vendorResourcesMap[selectedVendorId]?.find(resource => resource.value === selectedResource)?.label || '',
                            });
                            task.hasConflict = true;
                        }
                    }
                });
            });

            // Set the background color for the conflicting tasks
            setTimeout(() => {
                const hasConflict = !!this.existingConflictScheduleMap[taskId];
                const taskElement = this.template.querySelector(`div[data-id="${taskId}"]`);
                if (taskElement) {
                    taskElement.style.backgroundColor = hasConflict ? '#ffbabc' : '';
                }
            }, 0);
        });

        console.log('existingConflictScheduleMap:', JSON.parse(JSON.stringify(this.existingConflictScheduleMap)));
        return this.existingConflictScheduleMap;
    }

    isScheduleConflicting(selectedStartDate, selectedEndDate, scheduleItem) {
        const { StartDate: startDate, EndDate: endDate } = scheduleItem;
        return (
            (selectedStartDate <= endDate && selectedEndDate >= startDate) ||
            (startDate <= selectedEndDate && endDate >= selectedStartDate)
        );
    }

    showCurrentConflict(event) {
        this.isShowConflictCalled = true;
        this.conflictingSchedules = [];
        const taskId = event.currentTarget.dataset.id;
        this.editRecordId = event.currentTarget.dataset.id;

        const conflictingItems = [];
        const selectedScheduleItem = this.scheduleDataWrapper.scheduleList.find(item => item.Id === taskId);
        if (!selectedScheduleItem) {
            console.error('Error: Schedule item not found.');
            return conflictingItems;
        }

        const selectedStartDate = selectedScheduleItem.buildertek__Start__c;
        const selectedEndDate = selectedScheduleItem.buildertek__Finish__c;
        const selectedVendorId = selectedScheduleItem.buildertek__Contractor__c;
        const internalResourceId = selectedScheduleItem.buildertek__Internal_Resource_1__c;
        const selectedResources = [
            internalResourceId,
            selectedScheduleItem.buildertek__Contractor_Resource_1__c,
            selectedScheduleItem.buildertek__Contractor_Resource_2__c,
            selectedScheduleItem.buildertek__Contractor_Resource_3__c
        ].filter(Boolean);

        selectedResources.forEach(selectedResource => {
            const schedules = this.findSchedules(
                this.vendorResourceConflictJSON,
                this.internalResourceConflictJSON,
                selectedVendorId,
                selectedResource,
                internalResourceId
            );
            const conflictScheduleList = schedules.vendorSchedules.concat(schedules.internalSchedules);
            conflictScheduleList.forEach(scheduleItem => {
                if (this.isScheduleConflicting(selectedStartDate, selectedEndDate, scheduleItem)) {
                    const conflictingSchedule = this.intialConflictList.find(row => row.Id === scheduleItem.scheduleId);
                    if (conflictingSchedule && conflictingSchedule.Id !== selectedScheduleItem.Id) {
                        // Check if the conflicting resource matches the selected resource type
                        if ((selectedResource === internalResourceId && conflictingSchedule.buildertek__Internal_Resource_1__c === internalResourceId) ||
                            (selectedResource !== internalResourceId &&
                                (conflictingSchedule.buildertek__Contractor_Resource_1__c === selectedResource ||
                                    conflictingSchedule.buildertek__Contractor_Resource_2__c === selectedResource ||
                                    conflictingSchedule.buildertek__Contractor_Resource_3__c === selectedResource))) {
                            conflictingItems.push({
                                id: conflictingSchedule.Id,
                                taskName: conflictingSchedule.Name,
                                startDate: conflictingSchedule.buildertek__Start__c,
                                endDate: conflictingSchedule.buildertek__Finish__c,
                                schedule: conflictingSchedule.buildertek__Schedule__r.buildertek__Description__c,
                                project: conflictingSchedule.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
                                scheduleId: conflictingSchedule.buildertek__Schedule__c,
                                resourceName: selectedResource === internalResourceId ? selectedScheduleItem.buildertek__Internal_Resource_1__r.Name :
                                    this.vendorResourcesMap[selectedVendorId]?.find(resource => resource.value === selectedResource)?.label || ''
                            });
                        }
                    }
                }
            });
        });

        conflictingItems.unshift({
            id: selectedScheduleItem.Id,
            taskName: selectedScheduleItem.Name,
            startDate: selectedStartDate,
            endDate: selectedEndDate,
            schedule: selectedScheduleItem.buildertek__Schedule__r.buildertek__Description__c,
            project: selectedScheduleItem.buildertek__Schedule__r?.buildertek__Project__r?.Name || '',
            scheduleId: selectedScheduleItem.buildertek__Schedule__c,
            resourceName: 'Current Schedule Item',
        });

        const groupedConflictingItems = conflictingItems.reduce((groups, item) => {
            const resourceName = item.resourceName;
            if (!groups[resourceName]) {
                groups[resourceName] = [];
            }
            // Remove duplicates from the list of conflicting items
            const existingItemIndex = groups[resourceName].findIndex(groupItem => groupItem.id === item.id);
            if (existingItemIndex === -1) {
                groups[resourceName].push(item);
            }
            return groups;
        }, {});

        console.log(groupedConflictingItems);

        const conflictingItemsArray = Object.keys(groupedConflictingItems).map(resourceName => ({
            resourceName: resourceName,
            items: groupedConflictingItems[resourceName]
        }));

        this.groupedConflictingItems = conflictingItemsArray;
        this.isConflict = true;
    }

}