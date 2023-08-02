import { LightningElement, track,api,wire } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import  getPhaseData from "@salesforce/apex/phaseSubTabForProjectController.getPhaseData";



export default class PhaseSubTabForProject extends LightningElement {
@api recordId;
@api phaseInnerList;
@api ScheduleUrl;
connectedCallback(){
    getPhaseData({
        recordId : this.recordId
    }).then((res)=>{
        console.log(res);

    if(res != null){
        for(var i=0; i<res.length; i++){
            if(res[i].DueDate){
                res[i].DueDate = new Date(res[i].DueDate).toLocaleDateString('en-US');  
            }
            if(res[i].StartDate){
                res[i].StartDate = new Date(res[i].StartDate).toLocaleDateString('en-US');  
            }
            if(res[i].PhaseName == '' || res[i].PhaseName == null){
                res[i].PhaseName = 'No Phase'; 
            }
            if(res[i].CompletionPercent == '' || res[i].CompletionPercent == null){
                res[i].CompletionPercent = 0; 
            }
            if(res[i].ScheduleId != '' || res[i].ScheduleId != null){
                this.ScheduleUrl = '/lightning/r/buildertek__Schedule__c/' +res[i].ScheduleId +'/view' ;
            }
        }
    }

        this.phaseInnerList = res;
    })
}
}