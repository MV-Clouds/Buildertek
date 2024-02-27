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
    @track customeMessge = 'Loading...'
    @track scheduleDataWrapper = [];
    @track groupedScheduleData = {};
    @track vendor = {};

    @track resouceName = '';
    @track resouceTaks = [];
    @track resourceList = [];


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
                            this.resourceList = resourceListRaw;
                            this.vendor = result.vendor ? result.vendor : {Id: '', Name : '---'};

                        }
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