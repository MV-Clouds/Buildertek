import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/ScheduleLWCCss';
import fetchResouceData_byVendor from '@salesforce/apex/scheduleAssignResources.fetchResouceData_byVendor';
import fetchResouceData from '@salesforce/apex/scheduleAssignResources.fetchResouceData';

export default class ScheduleResourcesAssignee extends LightningElement {

    @api vendorId;
    @api scheduleId;
    @api vendorResourceId;
    
    @track isLoading = false;
    @track scheduleDataWrapper = [];
    @track groupedScheduleData = {};
    @track contractors = {};

    @track resouceName = '';
    @track resouceTaks = [];
    @track resourceList;

    connectedCallback() {
        loadStyle(this, myResource);

        console.log('this.c__vendorId : ', this.vendorId);
        console.log('this.c__scheduleId : ', this.scheduleId);
        console.log('this.c__vendorResourceId : ', this.vendorResourceId);

        if(this.vendorId){
            this.getResourceData_byVendor();
        }
        else if(this.vendorResourceId){
            this.getResourceData();
        }
    }

    getResourceData(){
        try {
            this.isLoading=true;

            fetchResouceData({vendorResourceId : this.vendorResourceId})
            .then(result => {
                if (result.status == 'success') {
                    var resourceDataRaw = result.resourceData;
                    resourceDataRaw.isTaskAssigned = resourceDataRaw.taskList > 0 ? true : false;
                    resourceDataRaw.taskList.forEach(task => {
                        task.DependancyName = task.hasOwnProperty('buildertek__Dependency__r') ? task.buildertek__Dependency__r.Name : null;
                    })
                    this.resourceList.push(result.resourceData);
                    console.log('resourceList : ', JSON.parse(JSON.stringify(this.resourceList)));
                    this.isLoading = false;
                }
                else if(result.status == 'error'){
                    this.showToastUtility('Error',result.returnMessge, result.status);
                    this.isLoading = false;
                }
            })
            .catch(error =>{
                this.isLoading = false;
                console.log('error to call apex fetchResouceData', {error});
            })
            
        } catch (error) {
            console.log('error in getResourceData : ', error.stack);
            
        }
    }

    getResourceData_byVendor() {
        try {
            this.isLoading = true;
            fetchResouceData_byVendor({vendorId: this.vendorId })
                .then(result => {
                    if (result.status == 'success') {
                        console.log('resourceDataList :', JSON.parse(JSON.stringify(result.resourceDataList)));
                        var resourceListRaw = JSON.parse(JSON.stringify(result.resourceDataList));
                        resourceListRaw.forEach(ele => {
                            ele.isTaskAssigned = ele.taskList.length > 0 ? true : false;
                            ele.taskList.forEach(task => {
                                task.DependancyName = task.hasOwnProperty('buildertek__Dependency__r') ? task.buildertek__Dependency__r.Name : '--';
                            })
                        })
                        this.resourceList = resourceListRaw;
                        console.log('resourceList : ', JSON.parse(JSON.stringify(this.resourceList)));
                    }
                    else if(result.status == 'error'){
                        this.showToastUtility('Error',result.returnMessge, result.status);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.isLoading = false;
                    this.showToastUtility('Error', 'Something went wrong!', 'error');
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } catch (error) {
            console.log('error in getScheduleData Method : ', error.stack);
        }
    }

    handleBack(){
        try {
            alert('Work in Progress, be patience, Thank you :) ');
        } catch (error) {
            console.log('error in handleBack : ', error.stack);
            
        }
    }





    showToastUtility(Title, Message, Type){
        try {
            const toast = new ShowToastEvent({
                title: Title,
                message: Message,
                variant: Type
            });
            this.dispatchEvent(toast);
        } catch (error) {
            console.log('error in showToastUtility Method : ', error.stack);
            
        }
    }
}