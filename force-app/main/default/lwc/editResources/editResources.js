import { LightningElement, track,api } from 'lwc';
import getContacts from '@salesforce/apex/editResourcesController.getContacts';
import getContactsDup from '@salesforce/apex/editResourcesController.getContactsDup';

 
export default class LwcRadioGroup extends LightningElement {
    @api isLoadedResources =false;
    @api conList;
    @api value = '';
    @api options;
    @api selectedResourceid;
    @api fieldApiName;
    @api isnotFirst = false;
    @api searchVal = ''
    @api searchAccVal= ''
    @api pageNumber = 1;
    @api pageSize = 50;
    @api totalRecords;
    @api recordEnd;
    @api recordStart;
    @api totalpages;
    @api disableNext = false;
    @api disablePrev = false;
    @api showAddContactBtn;
    @api showCreateContactPopup;
    @api disableAddContactSave;
    @api selectedConrecord;
    //CHB-64
    @api recordId;
    @api taskid

    connectedCallback(){
        console.log('RecordID---->'+this.taskid);
        if(!this.isnotFirst){
            this.getContactsList();
        }
    }
    handleNext(){
        var pageNumber = this.pageNumber;
        var pageSize = this.pageSize
        pageNumber++;
        this.pageNumber = pageNumber;
        var contact = this.searchVal;
        var acc = this.searchAccVal;
        var selectedId = ''
        selectedId = this.selectedResourceid ? this.selectedResourceid : '' ;
        this.getContactsList()
        //this.getContacts(pageNumber, pageSize,selectedId, contact,acc);
    }

    handlePrevious(){
        var pageNumber = this.pageNumber;
        var pageSize = this.pageSize
        pageNumber--;
        this.pageNumber = pageNumber;
        var contact = this.searchVal;
        var acc = this.searchAccVal;
        var selectedId = ''
        selectedId = this.selectedResourceid ? this.selectedResourceid : '' ;
        this.getContactsList()
        //this.getContacts(pageNumber, pageSize,selectedId, contact,acc);
    }
    getContactsList(){
        //this.isLoadedResources = true
        var that = this;
        var selectedId = ''
        var str = this.taskid;
        console.log('task id js:--->',str);
        selectedId = this.selectedResourceid ? this.selectedResourceid : ''
        getContactsDup({taskid: str, pageNumber: this.pageNumber, pageSize: this.pageSize,selected: selectedId, searchname: this.searchVal, searchaccount: this.searchAccVal}).then(function(response){
            that.isnotFirst = true;
            console.log(response);
            that.isLoadedResources = false;
            that.conList = response.wrapperList;
            that.pageNumber = response.pageNumber;
            that.totalRecords = response.totalRecords;
            that.recordStart = response.recordStart;
            that.recordEnd = response.recordEnd;
            that.totalpages = Math.ceil(response.totalRecords / that.pageSize)
            if(that.pageNumber >= that.totalpages){
                that.disableNext = true
            }else{
                that.disableNext = false
            }
            if(that.pageNumber == 1){
                that.disablePrev = true
            }else{
                that.disablePrev = false;
            }

            if(!that.conList.length){
                that.showAddContactBtn = true;
            }else if(!that.conList.length){
                that.showAddContactBtn = false;
            }
            //component.set("v.rfqRecordList", resultData.recordList);
                
            /* that.conList = response;
            that.options = response */
            //that.value = that.selectedResourceid;
        }).catch(function(error){
            that.isLoadedResources = false;
            console.log(error);
        })
    }



    closePopup(){
        const closepopuevent = new CustomEvent('closepopuevent', {detail: {'close': true} });
        this.dispatchEvent(closepopuevent);
    }

    saveResource(){
        this.isLoadedResources = true
        const saveres = new CustomEvent('saveres', {detail: {'save': true} });
        if(this.selectedConrecord){
            this.dispatchEvent(saveres);
        }else{
            const closepopuevent = new CustomEvent('closepopuevent', {detail: {'close': true} });
            this.dispatchEvent(closepopuevent);
        }
    }

    handleRadioChange(event) {
        const selectedOption = event.target.value;
        this.selectedConrecord = event.target.value;
        const valueSelectedEvent = new CustomEvent('contactselected', {detail: {'Id': selectedOption,'fieldNameapi' : this.fieldApiName} });
        this.dispatchEvent(valueSelectedEvent);
    }

    serchCon(event){
        if(event.target.value.trim()){
            this.pageNumber = 1
        }
        if(event.target.dataset.searchname == 'account'){
            
            this.searchAccVal = event.target.value.trim()
        }
        if(event.target.dataset.searchname == 'contact'){
            this.searchVal = event.target.value.trim()
        }
        
        this.getContactsList();
    }
    

    //new contact
    addNewContact(){
        console.log('test')
        this.showAddContactBtn = false;
        this.showCreateContactPopup = true;
    }
    cancelAddCon(){
        this.showAddContactBtn = false;
        this.showCreateContactPopup = false;
        this.searchVal = ''
        this.getContactsList();
    }
    handleConSubmit(event){
        this.disableAddContactSave = false;
    }
    handleConSuccess(event) {
        const payload = event.detail;
        console.log('payload>>>');
        console.log(JSON.stringify(payload));
        this.showCreateContactPopup = false;
        this.showAddContactBtn = false;
        this.disableAddContactSave = false;
        this.searchVal = ''
        window.setTimeout(() =>{
            this.getContactsList();
        },800)
       // this.accountId = event.detail.id;
        
    }

}