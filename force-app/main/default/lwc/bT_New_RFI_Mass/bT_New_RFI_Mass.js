import { LightningElement,  track, wire, api } from 'lwc';

export default class BT_New_RFI_Mass extends LightningElement {

@track rowIndex=0; 
@track RFIsWrapper=[
    {RowNumber:1, Subject:'', Question:'',DueDate:'No',
    AssignedTo:'' ,
    showContactLookup:true}];

addRow(){
    this.rowIndex = this.rowIndex+1; 
}

deleteRow(event){
    if(this.RFIsWrapper.length>=1){
        this.RFIsWrapper.splice(event.target.accessKey,1);
        this.RFIsWrapper-1;
    }

    for(var i=0;i<this.RFIsWrapper.length;i++){
        this.RFIsWrapper[i].RowNumber = (i+1);
    }
    
}    
    





}