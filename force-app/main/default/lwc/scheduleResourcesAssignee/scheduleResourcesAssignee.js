import { LightningElement, api, track, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/ScheduleLWCCss';
import fetchResouceData from '@salesforce/apex/scheduleAssignResources.fetchResouceData';
import { NavigationMixin } from 'lightning/navigation';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';

export default class ScheduleResourcesAssignee extends NavigationMixin(LightningElement) {

    @api vendorId;
    @api scheduleId;
    @api vendorResourceId;
    
    @track isLoading = false;
    @track IsTaskAvailable = false;
    @track customeMessge = ''
    @track scheduleDataWrapper = [];
    @track groupedScheduleData = {};
    @track vendor = {};

    @track resouceName = '';
    @track resouceTaks = [];
    @track resourceList = [];

    @track projectColorMap = {};

    connectedCallback() {
        loadStyle(this, myResource);

        this.vendorId = this.vendorId ? this.vendorId : null;
        this.vendorResourceId = this.vendorResourceId ? this.vendorResourceId : null;

        console.log('this.c__vendorId : ', this.vendorId);
        console.log('this.c__scheduleId : ', this.scheduleId);
        console.log('this.c__vendorResourceId : ', this.vendorResourceId);

        this.getResourceData();
    }

    getResourceData() {
        try {
            this.isLoading = true;
            fetchResouceData({vendorId: this.vendorId,  vendorResourceId : this.vendorResourceId})
                .then(result => {
                    if (result.status == 'success') {
                        console.log('resourceDataList :', JSON.parse(JSON.stringify(result.resourceDataList)));
                        var resourceListRaw = JSON.parse(JSON.stringify(result.resourceDataList));
                        this.IsTaskAvailable = resourceListRaw.length > 0 ? true : false;
                        this.customeMessge = resourceListRaw.length > 0 ? '' : 'No task available';
                        if(resourceListRaw.length > 0){
                            resourceListRaw.forEach(ele => {
                                ele.isTaskAssigned = ele.taskList.length > 0 ? true : false;
                                ele.taskList.forEach(task => {
                                    task.DependancyName = task.hasOwnProperty('buildertek__Dependency__r') ? task.buildertek__Dependency__r.Name : '--';
                                })
                            })
                            resourceListRaw = this.customSorting(resourceListRaw);
                            this.resourceList = resourceListRaw;
                        }
                        this.vendor = result.hasOwnProperty('vendor') ? result.vendor[0] : {Id: '', Name : '---'};
                        this.projectColorMap = result.uniqueProjectColorMap;
                        console.log('this.projectColorMap : ', result.uniqueProjectColorMap);
                        console.log('resourceList : ', JSON.parse(JSON.stringify(this.resourceList)));
                        this.updateProjectColorMap();
                    }
                    else if(result.status == 'error'){
                        this.showToastUtility('Error',result.returnMessge, result.status);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.showToastUtility('Error', 'Something went wrong!', 'error');
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } catch (error) {
            console.log('error in getScheduleData Method : ', error.stack);
        }
    }

    updateProjectColorMap() {
        setTimeout(() => {
            let projectElements = this.template.querySelectorAll('[data-id]');
            for (let i = 0; i < projectElements.length; i++) {
                let key = projectElements[i].getAttribute('data-id');
                projectElements[i].style.backgroundColor = this.projectColorMap[key];
            }
        }, 0);
    }

    handleBack(){
        try {
            getFocusedTabInfo().then((tabInfo) => {
                closeTab(tabInfo.tabId);
            }).catch(function(error) {
                console.log(error);
            });

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId : this.scheduleId,
                    objectApiName: 'buildertek__Schedule__c',
                    actionName: 'view'
                },
            });
        } catch (error) {
            console.log('error in handleBack : ', error.stack);
            
        }
    }

    redirectTOsobject(event){
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId : event.currentTarget.dataset.id,
                    objectApiName: event.currentTarget.dataset.objname,
                    actionName: 'view'
                },
            });
        } catch (error) {
            console.log('error in redirectTOsobject : ', error.stack);
            
        }
    }

    customSorting(resourceListRaw){
        try {
            console.log('resourceListRaw : ', JSON.stringify(resourceListRaw));
            resourceListRaw.sort((a, b) => a.resource.Name.localeCompare(b.resource.Name));
            resourceListRaw.forEach(ele => {
                ele.taskList.sort((a, b) => {
                    const Project_A = a.buildertek__Schedule__r.buildertek__Project__c ? (a.buildertek__Schedule__r.buildertek__Project__r.Name).toUpperCase() : '';
                    const Project_B = b.buildertek__Schedule__r.buildertek__Project__c ? (b.buildertek__Schedule__r.buildertek__Project__r.Name).toUpperCase() : '';
                    if(Project_A < Project_B){
                        return -1;
                    }
                    if(Project_A > Project_B){
                        return 1;
                    }
                    if(Project_A == Project_B){
                        const Schduel_A = (a.buildertek__Schedule__r.buildertek__Description__c).toUpperCase();
                        const Schduel_B = (b.buildertek__Schedule__r.buildertek__Description__c).toUpperCase();
                        if(Schduel_A < Schduel_B){
                            return -1;
                        }
                        if(Schduel_A > Schduel_B){
                            return 1;
                        }
                        if(Schduel_A == Schduel_B){
                            const taskName_A = a.Name;
                            const taskName_B = b.Name;
                            if(taskName_A < taskName_B){
                                return -1
                            }
                            if(taskName_A > taskName_B){
                                return 1;
                            }
                            if(taskName_A == taskName_B){
                                const dependancy_A = a.buildertek__Dependency__c ? (a.buildertek__Dependency__r.Name).toUpperCase() : '';
                                const dependancy_B = b.buildertek__Dependency__c ? (b.buildertek__Dependency__r.Name).toUpperCase() : '';
                                console.log("dependancy_A : ", dependancy_A);
                                if(dependancy_A < dependancy_B){
                                    return -1;
                                }
                                if(dependancy_A > dependancy_B){
                                    return 1;
                                }
                                if(dependancy_A == dependancy_B){
                                    const startDate_A = a.buildertek__Start__c;
                                    const startDate_B = b.buildertek__Start__c;
                                    if(startDate_A < startDate_B){
                                        return -1;
                                    }
                                    if(startDate_A > startDate_B){
                                        return 1;
                                    }
                                    if(startDate_A == startDate_B){
                                        const endDate_A = a.buildertek__Finish__c;
                                        const endDate_B = b.buildertek__Finish__c;
                                        if(startDate_A < startDate_B){
                                            return -1;
                                        }
                                        if(startDate_A > startDate_B){
                                            return 1;
                                        }
                                        if(endDate_A == endDate_B){
                                            return 0;
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            });
            return resourceListRaw;
            
        } catch (error) {
            console.log('error in customSorting : ',error.stack);
            
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