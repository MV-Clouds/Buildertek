import { LightningElement, track, wire, api } from 'lwc';
import getParticipants from '@salesforce/apex/ParticipantUpdatesController.getParticipants';
import getCourseSession from '@salesforce/apex/ParticipantUpdatesController.getCourseSession';
import getCourse from '@salesforce/apex/ParticipantUpdatesController.getCourse';
import updateParticipants from '@salesforce/apex/ParticipantUpdatesController.updateParticipants';
import getSkillLevel from '@salesforce/apex/ParticipantUpdatesController.getSkillLevel';
import sendEmialToParticipants from '@salesforce/apex/ParticipantUpdatesController.sendEmialToParticipants';
import deleteparticipant from '@salesforce/apex/ParticipantUpdatesController.deleteparticipant';
//import Massdeleteparticipant from '@salesforce/apex/ParticipantUpdatesController.Massdeleteparticipant';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { Navigation } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class participant_Updates  extends LightningElement {
//value = '';
@api listOptions = [];

@api selectedvalues=[];
 
@wire(getSkillLevel)
fetSkillLevelData({error,data}){
    if(data){
        this.listOptions = data;        
    }
    if(error){
        this.error = error;	
    }
}


get options() {
    return [
        { label: 'Registration', value: 'option1' },
        { label: 'Registration Completed ', value: 'option2' },
        { label: 'Course Completed ', value: 'option3' },
    ];
}
@track isModalOpen = false;
@track isdeleteModalOpen = false;
@track isMassdeleteModalOpen = false;
@track NoRecordsToDeleteModel = false;
@track isRegistraitonModalOpen=false;
@track isRegistraitonCompletionModalOpen=false;

@track CourseSchrecordId;    
@track ParticipantsWrapper=[];
@track rowIndex=0; 
@api YesNoOptions=[{label:'Yes',value:'Yes'},
{label:'No',value:'No'}];
@track successMessage=false;
@track delsuccessMessage=false;
@track errorMessage=false;
@track failupdateMessage=false;
@track noRecords=false
@track updateMessage=false;
@track alertMessage='';
@track coursrsessionName='';
@track courseName='';
@track  mailsent='';
@track url='';
@api recordId;
@track recId='';  
@track delrowId=''; 
@track isChecked = false;
@track delIds = [];
@api selectedContactIdList=[];
@track isMassEmailModalOpen=false;
@track NoRecordsToMassEmailModel = false;
@track isResendMassEmailModalOpen=false;
@track alterheader='';

checkboxvalues(event) {
    var isChecked = event.target.checked; 
    if(isChecked == true){
        var deleteId =this.ParticipantsWrapper[event.target.accessKey].RecordId;
            this.delIds.push(deleteId);
            //alert("IDS---------"+this.delIds);
    }else if(isChecked == false){     
        var delIdsTmp=[];
        
        for(var i=0;i<this.delIds.length;i++){
            delIdsTmp.push(this.delIds[i]);
        }
        this.delIds=[];
        var newids = [];
        for(var j=0;j<delIdsTmp.length;j++){
            if(delIdsTmp[j]!=this.ParticipantsWrapper[event.target.accessKey].RecordId){
                //alert(delIdsTmp[j]);
                this.delIds.push(delIdsTmp[j]);
            }
        }
        /*if(newids.length>0){
            this.delIds.push(newids);        
        }*/
        //alert(this.delIds.length);
    }

}

selectAllRecords(event){
    var isSelected = event.target.checked;
    if(isSelected==true){
            let i;
        let checkboxes = this.template.querySelectorAll('[data-id="checkboxId"]');
        for(i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
            //alert(this.ParticipantsWrapper[i].RecordId);
            this.delIds.push(this.ParticipantsWrapper[i].RecordId);
            //this.delIds=this.ParticipantsWrapper[i].RecordId;
        }
    //alert("this.delIds"+this.delIds);
        
    }else{ let i;
        let checkboxes = this.template.querySelectorAll('[data-id="checkboxId"]')
        for(i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = false;
            this.delIds=[];
        }
    }
}

MassDelete(event){
    if(this.delIds.length>0){
       this.isMassdeleteModalOpen = true;
    }else{
        this.NoRecordsToDeleteModel = true;
    }    
}


MassdeleteRow(event){
    //alert(this.delIds.length);
    deleteparticipant({deleterecordIds : JSON.stringify(this.delIds)})
    .then((result) => {
        if(result=='sucess'){
            //alert('result--------'+result);
            this.successMessage = false;
            this.isdeleteModalOpen = false;
            this.errorMessage = false;
            this.massdelsuccessMessage=true;
            this.isMassdeleteModalOpen = false;
            this.alertMessage='Selected records are deleted successfully!';         
            //location.reload();
        }
    })
    .catch(error => {
        
    });

}
closeMassDelSucessAlert(){
    this.successMessage = false;
    this.errorMessage = false;
    this.delsuccessMessage=false;
    this.failupdateMessage=false;
    this.updateMessage=false;
    this.noRecords=false;
    this.massdelsuccessMessage=false;  
    location.reload();  
    /*var url = '/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSchrecordId+'/view';
    window.open(url, '_self');*/ 
}


MassEmail(event){
    if(this.delIds.length>0){
       this.isResendMassEmailModalOpen = true;
    }else{
        this.NoRecordsToMassEmailModel = true;
    }    
}


@track rowaccesskey;

openCreateContactModal(event) {
    this.successMessage = false;
    this.errorMessage = false;
    this.alertMessage='';    
    this.recId=this.ParticipantsWrapper[event.target.accessKey].RecordId;
    this.rowaccesskey = event.target.accessKey;
    this.pname=this.ParticipantsWrapper[event.target.accessKey].ParticipantName;
    // to open modal set isModalOpen tarck value as true
    this.isModalOpen = true;
    //alert("Model"+recId);
}
openDeletewarrningModel(event) {
    //alert("In Delete");
    this.successMessage = false;
    this.errorMessage = false;
    this.alertMessage='';    
    this.recId=this.ParticipantsWrapper[event.target.accessKey].RecordId;
    //alert("recId------"+this.recId);
    this.pname=this.ParticipantsWrapper[event.target.accessKey].ParticipantName;
    // to open modal set isModalOpen tarck value as true
    this.isdeleteModalOpen = true;
    this.delrowId=event.target.accessKey;
    //alert("Model"+recId);
}

closeModal() {
    // to close modal set isModalOpen tarck value as false
    this.isModalOpen = false;
    this.isdeleteModalOpen = false;  
    this. isMassdeleteModalOpen = false;  
    this.NoRecordsToDeleteModel = false;
    this.delrowId='';
    this.isCourseCompletionModalOpen=false;
    this.isMassEmailModalOpen = false;
    this.NoRecordsToMassEmailModel = false;
    this.isResendMassEmailModalOpen = false;
}

closeRegistrationModal(){
    this.isRegistraitonModalOpen = false;
    this.isResendMassEmailModalOpen = true;
    this.isRegistraitonCompletionModalOpen=false;
    this.isCourseCompletionModalOpen=false;
    this.isMassRegistraitonModalOpen=false;
}
closeRegistrationModalformail(){
    this.isRegistraitonModalOpen = false;
    this.isModalOpen = true;
    this.isRegistraitonCompletionModalOpen=false;
    this.isCourseCompletionModalOpen=false;
    this.isMassRegistraitonModalOpen=false; 
}
closeRegistrationCompletionModal(){
    this.isRegistraitonModalOpen = false; 
    this.isResendMassEmailModalOpen = true;
    this.isRegistraitonCompletionModalOpen=false;
    this.isCourseCompletionModalOpen=false;
    this.isMassRegistraitonCompletionModalOpen=false;
}
closeRegistrationCompletionModalformail(){
    this.isRegistraitonModalOpen = false; 
    this.isModalOpen = true;
    this.isRegistraitonCompletionModalOpen=false;
    this.isCourseCompletionModalOpen=false;
    this.isMassRegistraitonCompletionModalOpen=false;
}
closeCourseCompletionModal(){
    this.isRegistraitonModalOpen = false; 
    this.isResendMassEmailModalOpen = true;
    this.isRegistraitonCompletionModalOpen=false;
    this.isCourseCompletionModalOpen=false;
    this.isMassCourseCompletionModalOpen=false;
}
closeCourseCompletionModalformail(){
    this.isRegistraitonModalOpen = false; 
    this.isModalOpen = true;
    this.isRegistraitonCompletionModalOpen=false;
    this.isCourseCompletionModalOpen=false;
    this.isMassCourseCompletionModalOpen=false;
}
connectedCallback(){

let params = (new URL(document.location)).searchParams;
let recId = params.get('Id'); 
this.CourseSchrecordId = recId;
 
//this.CourseSchrecordId = this.recordId;
this.url ='/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSchrecordId+'/view';
//alert(this.CourseSchrecordId);
    this.fetchParticipants();    
    getCourseSession( { coursessId : this.CourseSchrecordId })
    .then((result) =>  {                          
        this.coursrsessionName=result.Name;
    
    
})
.catch(error => {
    
});

getCourse( { coursessId : this.CourseSchrecordId })
    .then((result) =>  {   
    this.courseName=result.Name;
    
})
.catch(error => {
    
});
    
}

    
fetchParticipants(){
    getParticipants( { couserSessionId : this.CourseSchrecordId }   )
    .then((result) =>  {                   
        if(result!==undefined && result!=''){
           //alert(JSON.parse(JSON.stringify(result)));
            this.ParticipantsWrapper = JSON.parse(JSON.stringify(result));            
        }
    })
    .catch(error => {
        this.message = undefined;
        this.error = error;
        console.log('error'+error);
        this.successMessage = false;
        this.errorMessage = true;
        this.alertMessage = 'Error while fetching fields';
    });

}

    
ParticipantChangeHandler(event){     
    //alert(event.target.accessKey); 
    //const selectedOptionsList = event.detail.value;
    //alert('Options selected:'+selectedOptionsList);  
    if(event.target.name==='ParticipantName'){
        
        this.ParticipantsWrapper[event.target.accessKey].ParticipantName=event.target.value;
    }
    else if(event.target.name==='ParticipantCompany'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantCompany=event.target.value;
    }
    else if(event.target.name==='ParticipantAttended'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantAttended=event.target.value;
        // alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantAttended);
    }
    else if(event.target.name==='IsParticipantAttend'){
        this.ParticipantsWrapper[event.target.accessKey].IsParticipantAttend=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantAttended);
    }
    else if(event.target.name==='SkillLevel'){
        this.ParticipantsWrapper[event.target.accessKey].SkillLevel=event.detail.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].SkillLevel);
        //this.selectedvalues = event.target.value;
    }
    else if(event.target.name==='ParticipantScore'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantScore=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantScore);
    }
    else if(event.target.name==='ParticipantTitle'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantTitle=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantTitle);
    }
    else if(event.target.name==='ParticipantEmail'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantEmail=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantEmail);
    }
    else if(event.target.name==='ParticipantPhone'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantPhone=event.target.value;
       // alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantPhone);
    }
    /*else if(event.target.name==='TrainingExpirationDate'){
        this.ParticipantsWrapper[event.target.accessKey].TrainingExpirationDate=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].TrainingExpirationDate);
    }*/
    else if(event.target.name==='CourseCompleted'){
        this.ParticipantsWrapper[event.target.accessKey].CourseCompleted=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].CourseCompleted);
    }
    else if(event.target.name==='CourseCompletionDate'){
        this.ParticipantsWrapper[event.target.accessKey].CourseCompletionDate=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].CourseCompletionDate);
    }

    else if(event.target.name==='Notes'){
        this.ParticipantsWrapper[event.target.accessKey].Notes=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].Notes);
    }
    else if(event.target.name==='RecordId'){
        this.ParticipantsWrapper[event.target.accessKey].RecordId=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].Notes);
    }
    
}

handleSave(){
    this.updateHelper('update',null);   
}

updateHelper(calledfrom,ids){
    if(this.ParticipantsWrapper.length>0){        
        updateParticipants( 
            { 
                records : JSON.stringify(this.ParticipantsWrapper),
                sendemailrecordIds : JSON.stringify(ids)
            } 
        )          
        .then((result) =>  {
            //alert('result-->'+result);
           
            if(result=='updated' || result=='Send' ){
                if(calledfrom=='update'){
                    this.successMessage = false;
                    this.errorMessage = false;
                    this.updateMessage = true;
                    this.alertMessage = 'Participant records are updated successfully!';
                    var count=0;    
                }else if(calledfrom=='completionemail'){
                        this.successMessage = true;
                        this.errorMessage = false;
                        this.isModalOpen = false;
                        this.isRegistraitonModalOpen = false;
                        this.isRegistraitonCompletionModalOpen = false;
                        this.isCourseCompletionModalOpen=false;
                        this.alertMessage = 'Successfully sent Course Completion Email to '+this.pname;                                        
                }else{
                    this.successMessage = true;
                    this.errorMessage = false;
                    this.isMassRegistraitonModalOpen=false;
                    this.isMassRegistraitonCompletionModalOpen=false;
                    this.isMassCourseCompletionModalOpen=false; 
                    this.alertMessage = 'Successfully sent Course Completion Email';        
                }
                                
            }else if(result=='error'){
                if(calledfrom=='update'){
                    this.successMessage = false;
                    this.errorMessage = false;
                    this.updateMessage = false;
                    this.failupdateMessage=true;
                    this.alertMessage = 'Cannot update record(s)';
                    var count=0;
                    for(var i=0;i<200;i++){
                        //alert(count);
                        count=count+1;
                    }
                    if(count==200){
                        var url='/apex/buildertek__ParticipantUpdatesVFPage?Id='+this.CourseSchrecordId;
                       // var url = '/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSchrecordId+'/view';
                        window.open(url, '_self');
                    }
                }else  if(calledfrom=='completionemail'){
                    this.successMessage = false;
                    this.errorMessage = true;
                    this.isModalOpen = false;
                    this.isRegistraitonModalOpen = false;
                    this.isRegistraitonCompletionModalOpen = false;
                    this.isCourseCompletionModalOpen=false;
                    this.alertMessage = 'Failed to resend Course Completion Email to '+this.pname;                
                }else{
                    this.successMessage = false;
                    this.errorMessage = true;
                    this.isMassRegistraitonModalOpen=false;
                    this.isMassRegistraitonCompletionModalOpen=false;
                    this.isMassCourseCompletionModalOpen=false; 
                    this.alertMessage = 'Failed to resend Course Completion Email';        
                }

                
            }
    
            /*if(result=='updated'){
                alert('click'); 
                const evt = new ShowToastEvent({
                    title: 'success',
                    message: 'Updated Successfully!',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }
            else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while updating records ',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
            }*/ 
            
        })
        .catch(error => {
            //alert(JSON.stringify(error));
        });	 
    }else{
        this.successMessage = false;
                this.errorMessage = false;
                this.updateMessage = false;
                this.failupdateMessage=false;
                this.noRecords=true;
                this.alertMessage = 'There are no records to update!';
    }

}



navigateToCourseSessionPage() {
    
            var url = '/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSchrecordId+'/view';
                window.open(url, '_self');
}
@track isCourseCompletionValidationModalOpen=false;
handleOptions(event){
    const selectedOption = event.detail.value;
    if(selectedOption=='option1'){
        //this.isRegistraitonModalOpen=true;
        this.isModalOpen=false;
        this.isRegistraitonCompletionModalOpen=false;
        this.isCourseCompletionModalOpen=false;

        if(this.ParticipantsWrapper[this.rowaccesskey].ParticipantEmail!=null){
            this.isRegistraitonModalOpen=true;
        }else{
            this.isCourseCompletionValidationModalOpen = true;
            this.alterheader='Re-Send registration email validation!';
            this.alertMessage = 'Participants email is required to send registration email to ';
        }
    }else if(selectedOption=='option2'){
        
        this.isRegistraitonModalOpen=false;
        this.isModalOpen=false;
        this.isCourseCompletionModalOpen=false;
        if(this.ParticipantsWrapper[this.rowaccesskey].ParticipantEmail!=null){
            this.isRegistraitonCompletionModalOpen=true;
        }else{
            this.isCourseCompletionValidationModalOpen = true;
            this.alterheader='Re-Send registration completion email validation!';
            this.alertMessage = 'Participants email is required to send registration completion email to ';
        }
    }else if(selectedOption=='option3'){
        this.isModalOpen=false;
        this.isRegistraitonCompletionModalOpen=false
        this.isRegistraitonModalOpen=false;    

        if(this.ParticipantsWrapper[this.rowaccesskey].CourseCompletionDate!=null){
            this.isCourseCompletionModalOpen=true;
        }else if(this.ParticipantsWrapper[this.rowaccesskey].ParticipantEmail==null){
            this.isCourseCompletionValidationModalOpen = true;
            this.alterheader='Re-Send course completion email validation!';
            this.alertMessage = 'Participants email is required to send course completion email to ';
        }else{
            this.isCourseCompletionValidationModalOpen = true;
            this.alterheader='Course completion date validation!';
            this.alertMessage = 'Completion Date is required to send completion email to ';
        }

    }

}

@track isMassRegistraitonModalOpen=false;
@track isMassRegistraitonCompletionModalOpen=false;
@track isMassCourseCompletionModalOpen=false;
@track isMassCourseCompletionValidationModalOpen = false;
handleMassEmailOptions(event){
    const selectedOption = event.detail.value;
    if(selectedOption=='option1'){
        this.isMassRegistraitonModalOpen=true;
        this.isResendMassEmailModalOpen=false;
        this.isMassCourseCompletionModalOpen=false;
        this.isMassRegistraitonCompletionModalOpen=false;
    }else if(selectedOption=='option2'){
        this.isMassRegistraitonCompletionModalOpen=true;
        this.isMassRegistraitonModalOpen=false;
        this.isResendMassEmailModalOpen=false;
        this.isMassCourseCompletionModalOpen=false;
    }else if(selectedOption=='option3'){
        this.isMassRegistraitonCompletionModalOpen=false;
        this.isResendMassEmailModalOpen=false;
        this.isMassRegistraitonModalOpen=false;  
        
        var showvalidation=false;
        for(var i=0;i<this.ParticipantsWrapper.length;i++){
            for(var j=0;j<this.delIds.length;j++){
                if(this.ParticipantsWrapper[i].RecordId==this.delIds[j]){
                    if(this.ParticipantsWrapper[i].CourseCompletionDate==null){
                        showvalidation = true;
                    }
                }
            }
        }

        if(showvalidation==true){
            this.isMassCourseCompletionModalOpen=false;
            this.isMassCourseCompletionValidationModalOpen = true;
        }else{
            this.isMassCourseCompletionModalOpen=true; 
        }


          
    }
}



sendRegistrationMail(){
    var recId = [];
    recId.push(this.recId);
    sendEmialToParticipants( { recordIds : JSON.stringify(recId),EmailTemplate : 'Registration Email'}   )    
    .then((result) =>  {  
        if(result=='success'){
            this.successMessage = true;
            this.errorMessage = false;
            this.isModalOpen = false;
            this.isRegistraitonModalOpen = false;
            this.isRegistraitonCompletionModalOpen = false;
            this.isCourseCompletionModalOpen=false;
            this.alertMessage = 'Successfully sent Registration Email to '+this.pname;
            
        } else{
            
            this.successMessage = false;
            this.errorMessage = true;
            this.isModalOpen = false;
            this.isRegistraitonModalOpen = false;
            this.isRegistraitonCompletionModalOpen = false;
            this.isCourseCompletionModalOpen=false;
            this.alertMessage = 'Failed to resend Registration Email to '+this.pname;
        }
        
    })
    .catch(error => {
        //alert(JSON.stringify(error));
    });
}

sendRegistrationCompletionMail(){
    //alert('this.recId--->'+this.recId);
    var recId = [];
    recId.push(this.recId);
    sendEmialToParticipants( { recordIds : JSON.stringify(recId),EmailTemplate : 'Registration Completed' }   )    
    .then((result) =>  { 
        //alert(JSON.stringify(result)); 
        if(result=='success'){
            this.successMessage = true;
            this.errorMessage = false;
            this.isModalOpen = false;
            this.isRegistraitonModalOpen = false;
            this.isRegistraitonCompletionModalOpen = false;
            this.isCourseCompletionModalOpen=false;
            this.alertMessage = 'Successfully sent Registration Completion Email to '+this.pname;
        } else{
            //alert(JSON.stringify(result));
            this.successMessage = false;
            this.errorMessage = true;
            this.isModalOpen = false;
            this.isRegistraitonModalOpen = false;
            this.isRegistraitonCompletionModalOpen = false;
            this.isCourseCompletionModalOpen=false;
            this.alertMessage ='Failed to resend Registration Completion Email to '+this.pname;
        }
        
    })
    .catch(error => {
        
    });
}
sendCourseCompletionMail(){
    var recid=[];
    recid.push(this.recId);
    this.updateHelper('completionemail',recid);   

    /*sendEmialToParticipants( { recordIds : JSON.stringify(this.recId),EmailTemplate : 'Course Completed'  }   )
    
    .then((result) =>  {  
        if(result=='success'){
            this.successMessage = true;
            this.errorMessage = false;
            this.isModalOpen = false;
            this.isRegistraitonModalOpen = false;
            this.isRegistraitonCompletionModalOpen = false;
            this.isCourseCompletionModalOpen=false;
            this.alertMessage = 'Successfully sent Course Completion email to '+this.pname;
        } else{
            alert(JSON.stringify(result));
            this.successMessage = false;
            this.errorMessage = true;
            this.isModalOpen = false;
            this.isRegistraitonModalOpen = false;
            this.isRegistraitonCompletionModalOpen = false;
            this.isCourseCompletionModalOpen=false;
            this.alertMessage = 'Failed to resend Course Completion email to '+this.pname;
        }
        
    })
    .catch(error => {
        
    });*/

}


sendMassRegistrationMail(){
    sendEmialToParticipants( { recordIds : JSON.stringify(this.delIds),EmailTemplate : 'Registration Email'}   )    
    .then((result) =>  {  
        if(result=='success'){
            this.successMessage = true;
            this.errorMessage = false;
            this.isMassRegistraitonModalOpen=false;
            this.isMassRegistraitonCompletionModalOpen=false;
            this.isMassCourseCompletionModalOpen=false; 
            this.alertMessage = 'Successfully sent Registration Email';
            
        } else{
            //alert(JSON.stringify(result));
            this.successMessage = false;
            this.errorMessage = true;
            this.isMassRegistraitonModalOpen=false;
            this.isMassRegistraitonCompletionModalOpen=false;
            this.isMassCourseCompletionModalOpen=false; 
            this.alertMessage = 'Failed to resend Registration Email';
        }
        
    })
    .catch(error => {
        console.log('error--->'+JSON.stringify(error));
        //alert('error--->'+JSON.stringify(error));
    });
}

sendMassRegistrationCompletionMail(){
    sendEmialToParticipants( { recordIds : JSON.stringify(this.delIds),EmailTemplate : 'Registration Completed'}   )    
    .then((result) =>  {  
        if(result=='success'){
            this.successMessage = true;
            this.errorMessage = false;
            this.isMassRegistraitonModalOpen=false;
            this.isMassRegistraitonCompletionModalOpen=false;
            this.isMassCourseCompletionModalOpen=false; 
            this.alertMessage = 'Successfully sent Registration Completion Email';
            
        } else{
            //alert(JSON.stringify(result));
            this.successMessage = false;
            this.errorMessage = true;
            this.isMassRegistraitonModalOpen=false;
            this.isMassRegistraitonCompletionModalOpen=false;
            this.isMassCourseCompletionModalOpen=false; 
            this.alertMessage = 'Failed to resend Registration Completion Email';
        }
        
    })
    .catch(error => {
        //alert('error--->'+JSON.stringify(error));
    });
}

sendMassCourseCompletionMail(){
    //alert('test');
    this.updateHelper('masscompletionemail',this.delIds);   

    /*sendEmialToParticipants( { recordIds : JSON.stringify(this.delIds),EmailTemplate : 'Course Completed'}   )    
    .then((result) =>  {  
        if(result=='success'){
            this.successMessage = true;
            this.errorMessage = false;
            this.isMassRegistraitonModalOpen=false;
            this.isMassRegistraitonCompletionModalOpen=false;
            this.isMassCourseCompletionModalOpen=false; 
            this.alertMessage = 'Successfully sent Course Completion email';
            
        } else{
            //alert(JSON.stringify(result));
            this.successMessage = false;
            this.errorMessage = true;
            this.isMassRegistraitonModalOpen=false;
            this.isMassRegistraitonCompletionModalOpen=false;
            this.isMassCourseCompletionModalOpen=false; 
            this.alertMessage = 'Failed to resend Course Completion email';
        }
        
    })
    .catch(error => {
        //alert('error--->'+JSON.stringify(error));
    });*/


}



deleteRow(event){
    //alert('delete'+this.recId);
    //alert(this.ParticipantsWrapper.length);
    var delrecid=[];
    if(this.recId!=''){
        delrecid.push(this.recId);
    }
    deleteparticipant({deleterecordIds : delrecid})    
    .then((result) => {
        //alert('result'+result);
        if(result=='sucess'){
            this.successMessage = false;
            this.isdeleteModalOpen = false;
            this.errorMessage = false;
            this.delsuccessMessage=true;
            this.alertMessage=this.pname+' deleted successfully!';
            if(this.ParticipantsWrapper.length>=1){
                //alert(this.delrowId);
                this.ParticipantsWrapper.splice(this.delrowId,1);
                this.ParticipantsWrapper-1;
            }
            for(var i=0;i<this.ParticipantsWrapper.length;i++){
                this.ParticipantsWrapper[i].RowNumber = (i+1);
            }

        }
    })
    .catch(error => {
        
    });
    
}

closeAlert(){
   // alert('close');
    
    this.errorMessage = false;
    this.delsuccessMessage=false;
    this.failupdateMessage=false;
    this.updateMessage=false;
    this.noRecords=false;    
    this.isMassRegistraitonModalOpen=false;
    this.isMassRegistraitonCompletionModalOpen=false;
    if(this.isMassCourseCompletionModalOpen==true
        || this.successMessage==true){
        this.isMassCourseCompletionModalOpen=false; 
        this.successMessage = false;
        location.reload();

    }
    
    this.isCourseCompletionValidationModalOpen=false;
    this.isMassCourseCompletionValidationModalOpen=false;
}

gotoCourseSessionPage(){
    this.successMessage = false;
    this.errorMessage = false;
    this.delsuccessMessage=false;
    this.failupdateMessage=false;
    this.noRecords=false;
    this.updateMessage=false;
    var url='/apex/buildertek__ParticipantUpdatesVFPage?Id='+this.CourseSchrecordId;
   // var url = '/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSchrecordId+'/view';
                window.open(url, '_self');
}

}