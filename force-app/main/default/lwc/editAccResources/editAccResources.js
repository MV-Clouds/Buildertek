import { LightningElement, track,api } from 'lwc';
import getAccounts from '@salesforce/apex/editResourcesController.getAccounts';

export default class EditAccResources extends LightningElement {


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
    @api selectedAccrecord;
    connectedCallback(){
        if(!this.isnotFirst){
            this.getAccountsList();
        }
    }
    handleNext(){
        var pageNumber = this.pageNumber;        
        pageNumber++;
        this.pageNumber = pageNumber;                
        var selectedId = '';
        selectedId = this.selectedResourceid ? this.selectedResourceid : '' ;
        this.getAccountsList()        
    }

    handlePrevious(){
        var pageNumber = this.pageNumber;        
        pageNumber--;
        this.pageNumber = pageNumber;          
        var selectedId = ''
        selectedId = this.selectedResourceid ? this.selectedResourceid : '' ;
        this.getAccountsList()     
    }
    getAccountsList(){
        
        var that = this;
        var selectedId = '';        
        selectedId = this.selectedResourceid ? this.selectedResourceid : ''
        getAccounts({pageNumber: this.pageNumber, pageSize: this.pageSize,selected: selectedId,searchaccount: this.searchAccVal}).then(function(response){
            that.isnotFirst = true;
            
            that.isLoadedResources = false;            
            that.conList = response.accRecList;            
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
        if(this.selectedAccrecord){
            this.dispatchEvent(saveres);
        }else{
            const closepopuevent = new CustomEvent('closepopuevent', {detail: {'close': true} });
            this.dispatchEvent(closepopuevent);
        }
    }

    handleRadioChange(event) {                
        const ids = event.target.id;
        const id = ids.split('-')[0];        
        const selectedOption = event.target.value;        
        this.selectedAccrecord = event.target.value;                
        const valueSelectedEvent = new CustomEvent('contactselected', {detail: {'Id': id,'name' : selectedOption,'fieldNameapi' : this.fieldApiName} });
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
        
        this.getAccountsList();
    }
    
    handleConSubmit(event){
        this.disableAddContactSave = false;
    }
    handleConSuccess(event) {
        const payload = event.detail;        
        this.showCreateContactPopup = false;
        this.showAddContactBtn = false;
        this.disableAddContactSave = false;
        this.searchVal = ''
        window.setTimeout(() =>{
            this.getAccountsList();
        },800)       
        
    }

}