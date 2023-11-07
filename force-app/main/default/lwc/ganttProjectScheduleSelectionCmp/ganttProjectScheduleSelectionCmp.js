import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getScheduleData from "@salesforce/apex/GetProjectAndScheduleForGanttCmp.getScheduleData";
import setScheduleDataIntoCustomSetting from "@salesforce/apex/GetProjectAndScheduleForGanttCmp.setScheduleDataIntoCustomSetting";
import getScheduleDateFromCustomSetting from "@salesforce/apex/GetProjectAndScheduleForGanttCmp.getScheduleDateFromCustomSetting";

export default class GanttProjectSchedulesOptionselectionCmp extends LightningElement {
    @track scheduleWithoutProjectList = [];
    @track projectOptions = [];
    @track mapOfSchedulesOptionsByProject = {};
    @track SchedulesOptions = [];
    @track ProjectNameSet = [];
    @track selectedProjectId;
    @track selectedScheduleId;
    @track selectedScheduleIdForJS;
    @track callscheduleComponent = false;
    @track isDisabled = true;

    connectedCallback() {
        this.getScheduleList();
        this.getScheduleIdFromCustomSetting();
    }

    getScheduleIdFromCustomSetting() {
        getScheduleDateFromCustomSetting()
            .then((result) => {
                if (result) {
                    this.selectedProjectId = result.buildertek__Project_Selected__c;
                    this.selectedScheduleId = result.buildertek__Schedule_Selected__c;
                    let checkProjectId = result.hasOwnProperty('buildertek__Project_Selected__c');
                    if (!checkProjectId) {
                        this.selectedProjectId = '';
                    }
                    console.log('result', result);
                    var scheduleWithoutProjectList = [];
                    this.callscheduleComponent = false;
                    console.log('Selected Project ID:', this.selectedProjectId);
                    if (this.selectedProjectId == undefined || this.selectedProjectId == '') {
                        this.scheduleWithoutProjectList.forEach(ele => {
                            scheduleWithoutProjectList.push({ label: ele.buildertek__Description__c, value: ele.Id });
                        });
                        console.log('scheduleWithoutProjectList', scheduleWithoutProjectList);
                        this.SchedulesOptions = scheduleWithoutProjectList;
                    } else {
                        this.mapOfSchedulesOptionsByProject[this.selectedProjectId].forEach(ele => {
                            scheduleWithoutProjectList.push({ label: ele.buildertek__Description__c, value: ele.Id });
                        })
                        this.SchedulesOptions = scheduleWithoutProjectList;
                    }
                    if (this.selectedScheduleId) {
                        this.onloadScheduleData();
                    }
                }
            })
            .catch((error) => {
                console.log('Error in getting schedule Id', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Unknown error',
                        variant: "error",
                    })
                );
            });
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
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: error.message,
                        variant: "error",
                    })
                );
            });
    }

    handleChange(event) {
        var scheduleWithoutProjectList = [];
        this.callscheduleComponent = false;
        if (event.target.name === 'project') {
            this.selectedProjectId = event.detail.value;
            console.log('Selected Project ID:', this.selectedProjectId);
            this.isDisabled = true;
        } else if (event.target.name === 'schedule') {
            this.selectedScheduleIdForJS = event.detail.value;
            this.selectedScheduleId = event.detail.value;
            console.log('Selected Schedule ID:', this.selectedScheduleId);
            this.isDisabled = false;
        }

        if (this.selectedProjectId === '') {
            this.scheduleWithoutProjectList.forEach(ele => {
                scheduleWithoutProjectList.push({ label: ele.buildertek__Description__c, value: ele.Id });
            });
            console.log('scheduleWithoutProjectList', scheduleWithoutProjectList);
            this.SchedulesOptions = scheduleWithoutProjectList;
        } else {
            this.mapOfSchedulesOptionsByProject[this.selectedProjectId].forEach(ele => {
                scheduleWithoutProjectList.push({ label: ele.buildertek__Description__c, value: ele.Id });
            })
            this.SchedulesOptions = scheduleWithoutProjectList;
        }
    }

    onloadScheduleData() {
        if (this.selectedScheduleId) {
            this.callscheduleComponent = true;
            console.log('Project Id ==>', this.selectedProjectId);
            console.log('Schedule Id ==>', this.selectedScheduleId);
            setScheduleDataIntoCustomSetting({ ScheduleId: this.selectedScheduleId, ProjectId: this.selectedProjectId })
                .then((result) => {
                    console.log('result', result);
                })
                .catch((error) => {
                    console.log('Error in getting schedule list', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: error.message,
                            variant: "error",
                        })
                    );
                });
        } else {
            this.callscheduleComponent = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Please select schedule",
                    variant: "error",
                })
            );
        }
    }

    handleScheduleClick() {
        if (this.selectedScheduleIdForJS) {
            this.callscheduleComponent = true;
            console.log('Project Id ==>', this.selectedProjectId);
            console.log('Schedule Id ==>', this.selectedScheduleId);
            setScheduleDataIntoCustomSetting({ ScheduleId: this.selectedScheduleId, ProjectId: this.selectedProjectId })
                .then((result) => {
                    console.log('result', result);
                })
                .catch((error) => {
                    console.log('Error in getting schedule list', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: error.message,
                            variant: "error",
                        })
                    );
                });
        } else if (this.selectedScheduleIdForJS === undefined) {
            this.onloadScheduleData();
            console.log('=========================');
        } else {
            this.callscheduleComponent = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Please select schedule",
                    variant: "error",
                })
            );
        }
    }

}