import lookUp from '@salesforce/apex/customLwcLookupCls.search';
import { api, LightningElement, track, wire } from 'lwc';


export default class customLwcLookUp extends LightningElement {

    @api objName;
    @api fieldApiName;
    @api iconName;
    @api valueFromParent;
    @api scheduleId;
    @api filter = '';
    @api searchPlaceholder='Search';
    @api searchTerm = '';
    @api schId;
    @track selectedName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;

   
    
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';

    
    /* @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter', selectedFrompar:'$valueFromParent' })
        wiredRecords({ error, data }) {
            if (data) {
                this.error = undefined;
                this.records = data;
            } else if (error) {
                this.error = error;
                this.records = undefined;
            }
        } */

    fetchData(){
        var that = this;
        lookUp({searchTerm : this.searchTerm, myObject : this.objName, filter : this.filter, selectedFrompar: this.valueFromParent, scheduleId : this.scheduleId}).then(function(response){
            console.log(response)
            let selectedId = response[0].Id;
            let selectedName = response[0].Name;
           // const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
           // this.dispatchEvent(valueSelectedEvent);
           that.isValueSelected = true;
           that.selectedName = selectedName;
           
            //this.records = response;
        }).then(function(res){
            if(that.template.querySelector('.slds-pill'))
            that.template.querySelector('.slds-pill').style.width = '100%'
        })
    }

    fetchDataAll(){
        var that = this;
        lookUp({searchTerm : this.searchTerm, myObject : this.objName, filter : this.filter, selectedFrompar: '',scheduleId : this.scheduleId}).then(function(response){
            console.log(response)
            that.records = response;
            //this.records = response;
        })
    }
    
    connectedCallback() {
        //if(this.selectedValueFromParent)
        if(this.valueFromParent){
            console.log('In conectedCall Back');
            this.fetchData();
            this.fetchDataAll()
        }else{
            this.fetchDataAll();
        }
        console.log(this.valueFromParent)
           
            
    }

    handleClick() {
        
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    
    }

    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }

    onSelect(event) {
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail: {'Id': selectedId,'fieldNameapi' : this.fieldApiName,'selectedName': selectedName} });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.searchTerm='';
        this.selectedName = ''
        this.isValueSelected = false;
        this.fetchDataAll();
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail: {'Id': '','fieldNameapi' : this.fieldApiName,'selectedName': ''} });
        this.dispatchEvent(valueSelectedEvent);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
        this.fetchDataAll()
    }

}