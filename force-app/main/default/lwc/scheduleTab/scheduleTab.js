import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import getScheduleDataByProjectId from "@salesforce/apex/GetProjectAndScheduleForGanttCmp.getScheduleDataByProjectId";

export default class ScheduleTab extends NavigationMixin(LightningElement) {

    @api projectId;
    @api recordId;
    @track SchedulesOptions = [];
    @track selectedScheduleId;
    @track scheduleNameSet = [];
    @track isScheduleAvailable = false;
    @track callscheduleComponent = false;
    @track hideToolbar = true;

    connectedCallback() {
        console.log('Project Id: ' + this.projectId);
        this.getScheduleData();
    }

    getScheduleData() {
        getScheduleDataByProjectId({ projectId: this.projectId })
            .then((result) => {
                console.log('result: ' + JSON.stringify(result));
                if (result.length > 0) {
                    result.forEach(ele => {
                        this.scheduleNameSet.push({ label: ele.buildertek__Description__c, value: ele.Id });
                    });
                    this.SchedulesOptions = this.scheduleNameSet;
                    this.selectedScheduleId = this.SchedulesOptions[0]?.value;
                    this.isScheduleAvailable = true;
                    this.callscheduleComponent = true;
                }
                console.log('SchedulesOptions: ' + JSON.stringify(this.SchedulesOptions));
            })
            .catch((error) => {
                console.log('Error in getting schedule data', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Unknown error occur while getting schedule data',
                        variant: "error"
                    })
                );
            });
    }

    handleScheduleChange(event) {
        try {
            this.selectedScheduleId = event.detail.value;
            console.log('selectedScheduleId: ' + this.selectedScheduleId);
            this.template.querySelector('c-gantt_component').updaterecordId(this.selectedScheduleId);
        } catch (error) {
            console.log('Error in handling schedule change', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: 'Unknown error occur while handling schedule change',
                    variant: "error"
                })
            );
        }
    }

    handleViewSchedule() {
        console.log('Current scheduleId: ' + this.selectedScheduleId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.selectedScheduleId,
                objectApiName: 'buildertek__Schedule__c',
                actionName: 'view'
            },
        });
    }

}