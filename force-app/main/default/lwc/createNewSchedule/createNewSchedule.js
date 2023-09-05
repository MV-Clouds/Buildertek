import { LightningElement, track, api } from 'lwc';
import searchProject from '@salesforce/apex/bryntumGanttController.searchProject';
import searchUsers from '@salesforce/apex/bryntumGanttController.searchUsers';
import fetchScheduleList from '@salesforce/apex/bryntumGanttController.fetchScheduleList';
import getScheduleItemList from '@salesforce/apex/bryntumGanttController.getScheduleItemList';
import createNewSchedule from '@salesforce/apex/bryntumGanttController.createNewSchedule';
import getProjectName from '@salesforce/apex/bryntumGanttController.getProjectName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateNewSchedule extends NavigationMixin(LightningElement) {

    @track searchProjectName = '';
    @track suggestedProjectName = [];
    @track showProjectName = false;
    @track projectId;
    @track userId;
    @track searchProjectManager = '';
    @track suggestedProjectManagerName = [];
    @track showProjectManagerName = false;
    @track searchbarValue = '';
    @track masterId = '';
    @track masterRec = '';
    @track listOfFields = [];
    @track scheduleLineItems = [];
    @track initialStartDate;
    @track isLoading = false;
    @track description = '';
    @track type = 'Standard';
    @track url = '';
    @track showProjectIcon = false;
    @track showUserIcon = false;
    @track isInputEnabledForProject = false;
    @track isInputEnabledForUser = false;
    @track projectSchedule = false;

    connectedCallback(event) {
        document.addEventListener('click', this.handleDocumentEvent.bind(this));
        this.getFields();
        let name = 'inContextOfRef';
        let url = window.location.href;
        let regex = new RegExp("[?&]" + name + "(=1.([^&#]*)|&|#|$)");
        let results = regex.exec(url);
        console.log('results:', results);
        let value = decodeURIComponent(results[2].replace(/\+/g, " "));
        console.log('value:', value);
        let context = JSON.parse(window.atob(value));
        let parentRecordId = context.attributes.recordId;
        if (parentRecordId) {
            console.log(parentRecordId);
            this.getProjectNameFromId(parentRecordId);
        }
    }

    getProjectNameFromId(parentRecordId) {
        console.log('parentRecordId:', parentRecordId);
        this.projectSchedule = true;
        getProjectName({ parentRecordId: parentRecordId })
            .then((result) => {
                this.searchProjectName = result;
                this.isInputEnabledForProject = true;
                this.showProjectIcon = true;
                this.projectId = parentRecordId;
                console.log('result:', result);
            })
            .catch((error) => {
                console.log('error:', JSON.stringify(error));
            });
    }

    handleProjectSearch(event) {
        try {
            this.searchProjectName = event.target.value;
            this.searchbarValue = event.target.dataset.id;
            console.log(`searchProjectName: ${this.searchProjectName}`);
            if (this.searchProjectName.length != 0) {
                clearTimeout(this.searchTimeout);
                this.searchTimeout = setTimeout(() => {
                    searchProject({ searchProjectName: this.searchProjectName })
                        .then((result) => {
                            this.suggestedProjectName = result;
                            console.log('result', result);
                            this.showProjectName = true;
                        })
                        .catch((error) => {
                            console.log('error:', JSON.stringify(error));
                        });
                }, 300);
            } else {
                this.showProjectName = false;
                this.suggestedProjectName = [];
            }
        } catch (error) {
            console.log('error', JSON.stringify(error));
        }
    }

    handleProjectManagerSearch(event) {
        try {
            this.searchProjectManager = event.target.value;
            this.searchbarValue = event.target.dataset.id;
            console.log(`searchProjectManager: ${this.searchProjectManager}`);
            if (this.searchProjectManager.length != 0) {
                clearTimeout(this.searchTimeout);
                this.searchTimeout = setTimeout(() => {
                    searchUsers({ searchProjectManagerName: this.searchProjectManager })
                        .then((result) => {
                            this.suggestedProjectManagerName = result;
                            console.log('result', result);
                            this.showProjectManagerName = true;
                        })
                        .catch((error) => {
                            console.log('error:', JSON.stringify(error));
                        });
                }, 300);
            } else {
                this.showProjectManagerName = false;
                this.suggestedProjectManagerName = [];
            }
        } catch (error) {
            console.log('error', JSON.stringify(error));
        }
    }

    handleDocumentEvent(event) {
        const clickedElement = event.target;
        const componentElement = this.template.querySelector('.detailContainer');
        if (componentElement && !componentElement.contains(clickedElement)) {
            console.log('handleDocumentEvent condition');
            this.showProjectName = false;
            this.showProjectManagerName = false;
        }
    }

    selectedRecord(event) {
        const selectedValue = event.target.innerText;
        let pId = event.currentTarget.dataset.id;
        console.log('selectedValue', selectedValue);
        console.log('Id', pId);

        if (this.searchbarValue === 'project') {
            this.searchProjectName = selectedValue;
            this.showProjectIcon = true;
            this.isInputEnabledForProject = true;
            this.projectId = pId;
        } else {
            this.searchProjectManager = selectedValue;
            this.isInputEnabledForUser = true;
            this.showUserIcon = true;
            this.userId = pId;
        }

    }

    getFields() {
        fetchScheduleList()
            .then((result) => {
                this.masterId = result;
                console.log('masterId', this.masterId);
                console.log('Type masterId', typeof (this.masterId));
            })
            .catch((error) => {
                console.log('error', JSON.stringify(error));
            })
    }

    saveSelectedPO(event) {
        this.masterRec = event.currentTarget.dataset.id;
        console.log('masterId', this.masterRec);
        getScheduleItemList({ masterId: this.masterRec })
            .then((result) => {
                this.scheduleLineItems = result;
                console.log('scheduleLineItems:', this.scheduleLineItems);
            })
            .catch((error) => {
                console.log('error', JSON.stringify(error));
            })
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleStartDateChange(event) {
        this.initialStartDate = event.target.value;
        console.log('formattedDate', this.initialStartDate);
    }

    handleTypeChange(event) {
        this.type = event.target.value;
        console.log('type:', this.type);
    }

    createSchedule() {
        if (this.description.length != 0) {
            this.isLoading = true;
            console.log(`description: ${this.description} projectId: ${this.projectId} formattedDate: ${this.initialStartDate} type: ${this.type} userId: ${this.userId} masterRec: ${this.masterRec}`);
            createNewSchedule({ description: this.description, project: this.projectId, initialStartDate: this.initialStartDate, type: this.type, user: this.userId, masterId: this.masterRec })
                .then((result) => {
                    console.log('url:', result);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            objectApiName: 'buildertek__Schedule__c',
                            actionName: 'view'
                        },
                    }, true);
                    this.isLoading = false;
                })
                .catch((error) => {
                    console.log('error:', error);
                    this.isLoading = false;
                })
        } else {
            const event = new ShowToastEvent({
                title: 'Error creating schedule',
                message: 'Description field is empty !!!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }

    }

    onSaveandNew() {
        if (this.description.length != 0) {
            this.isLoading = true;
            console.log(`description: ${this.description} projectId: ${this.projectId} formattedDate: ${this.initialStartDate} type: ${this.type} userId: ${this.userId} masterRec: ${this.masterRec}`);
            createNewSchedule({ description: this.description, project: this.projectId, initialStartDate: this.initialStartDate, type: this.type, user: this.userId, masterId: this.masterRec })
                .then((result) => {
                    console.log('schId:', result);
                    this.isLoading = false;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: 'Schedule created !!!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                })
                .catch((error) => {
                    console.log('error:', error);
                    this.isLoading = false;
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Error creating schedule !!!',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                })
                .finally(() => {
                    this.template.querySelector('form').reset();
                    if (!this.projectSchedule) {
                        this.searchProjectName = '';
                        this.showProjectIcon = false;
                        this.isInputEnabledForProject = false;
                        this.projectId = undefined;
                    }
                    this.description = '';
                    this.initialStartDate = undefined;
                    this.type = 'Standard';
                    this.userId = undefined;
                    this.masterRec = undefined;
                    this.searchProjectManager = '';
                    this.showUserIcon = false;
                    this.isInputEnabledForUser = false;
                    console.log(`description: ${this.description} projectId: ${this.projectId} formattedDate: ${this.initialStartDate} type: ${this.type} userId: ${this.userId} masterRec: ${this.masterRec}`);
                })
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Description field is empty !!!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    }

    onCancelHandle() {
        console.log('Redirect the page');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'buildertek__Schedule__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        })
        let close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
        this.dispatchEvent(closeclickedevt);
    }

    getLink(event) {
        let scheduleName = event.currentTarget.dataset.id;
        let val = this.masterId.find((schId) => schId.Name == scheduleName);
        console.log('ScheduleName:', scheduleName);
        this.url = `/${val.Id}`
        console.log('Url:', this.url);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleDocumentEvent.bind(this));
    }

    clearInput(event) {
        let clearInputForType = event.currentTarget.dataset.id;
        console.log('clearInputForType', clearInputForType);
        if (clearInputForType === 'project') {
            this.searchProjectName = '';
            this.projectId = undefined;
            this.showProjectIcon = false;
            this.isInputEnabledForProject = false;
        } else {
            this.searchProjectManager = '';
            this.userId = undefined;
            this.showUserIcon = false;
            this.isInputEnabledForUser = false;
        }
    }
}