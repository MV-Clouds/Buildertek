import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchScheduleData from '@salesforce/apex/scheduleResourceController.fetchScheduleData';
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

    connectedCallback() {
        this.recordId ? (this.scheduleData(), this.isScheduleSelected = true) : this.getScheduleList();
    }

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

    scheduleData() {
        this.isLoading = true;
        fetchScheduleData({ scheduleId: this.recordId ? this.recordId : (this.selectedScheduleId ? this.selectedScheduleId : this.selectedScheduleIdForJS) })
            .then((result) => {
                if (result) {
                    console.log('schedule Data:', JSON.stringify(result));
                    this.tableData = result.scheduleList.map(task => {
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
            })
            .catch((error) => {
                console.log('Error ==>', error);
                this.showToast('Error', 'There was an error while retrieving the schedule data. Please contact the administrator to resolve this issue.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

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
}