import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/ScheduleLWCCss';
import fetchScheduleData from '@salesforce/apex/scheduleAssignResources.fetchScheduleData';

export default class ScheduleResourcesAssignee extends LightningElement {
    @api vendor = '0011K00002WXnixQAD';
    @api schedule = 'a101K00000GoeOkQAJ';
    @track isLoading = false;
    @track scheduleDataWrapper = [];
    @track groupedScheduleData = {};
    @track contractors = {};

    connectedCallback() {
        loadStyle(this, myResource)
        this.scheduleData();
    }
    scheduleData() {
        this.isLoading = true;
        fetchScheduleData({ scheduleId: this.schedule, vendorId: this.vendor })
            .then(result => {
                if (result) {
                    console.log('schedule Data:', JSON.parse(JSON.stringify(result)));
                    this.scheduleDataWrapper = result.scheduleList;
                    this.groupedScheduleData = this.scheduleDataWrapper.forEach((item) => {
                        
                    });
                   
                }
            })
            .catch(error => {
                console.error('Error:', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}