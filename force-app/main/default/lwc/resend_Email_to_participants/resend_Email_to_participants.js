import { LightningElement, track, wire, api } from 'lwc';
import resendEmialToParticipants from '@salesforce/apex/ParticipantUpdatesController.resendEmialToParticipants';
import getParticipantName from '@salesforce/apex/ParticipantUpdatesController.getParticipantName';
export default class Resend_Email_to_participants extends LightningElement {
    @track pname;
    @track pCourseCompletionDate;
    @track isRegistraitonModalOpen=false;
    @track isRegistraitonCompletionModalOpen=false;
    @track isCourseCompletionModalOpen=false; 
    @track isCourseCompletionValidationModalOpen=false;
    @track isModalOpen=true; 
    @api recordId;


    connectedCallback(){
        getParticipantName( { recdId : this.recordId })
    .then((result) =>  {     
         // alert(JSON.stringify(result.buildertek__Course_Completion_Date__c));                 
        this.pname=result.buildertek__Participant_Name__r.Name;
        this.pCourseCompletionDate=result.buildertek__Course_Completion_Date__c;
       // alert(this.pCourseCompletionDate);
    
})
.catch(error => {
    
});
    }
    get options() {
        return [
            { label: 'Registration', value: 'option1' },
            { label: 'Registration Completed ', value: 'option2' },
            { label: 'Course Completed ', value: 'option3' },
        ];
    }   
    
    handleOptions(event){
        //alert(this.recordId);
        const selectedOption = event.detail.value;
        const closeQA = new CustomEvent('Resend_Email_to_participants');
        if(selectedOption=='option1'){
        this.dispatchEvent(closeQA);
            this.isRegistraitonModalOpen=true;
            this.isRegistraitonCompletionModalOpen=false;
            this.isCourseCompletionModalOpen=false;
            this.isCourseCompletionValidationModalOpen = false;
            this.isModalOpen=false;
        }else if(selectedOption=='option2'){
            this.isRegistraitonCompletionModalOpen=true;
            this.isRegistraitonModalOpen=false;
            this.isCourseCompletionModalOpen=false;
           this.isModalOpen=false;
            this.isCourseCompletionValidationModalOpen = false;
        }else if(selectedOption=='option3'){
            this.isRegistraitonCompletionModalOpen=false
            this.isRegistraitonModalOpen=false; 
           this.isModalOpen=false;
            if(this.pCourseCompletionDate!=null){
                this.isCourseCompletionModalOpen=true;
                this.isCourseCompletionValidationModalOpen = false;
            }else{
                this.isCourseCompletionModalOpen=false;
               this.isModalOpen=false;
                this.isCourseCompletionValidationModalOpen = true;
                //this.alertMessage = 'Completion Date is required to send completion email to '+this.pname;
            }
    
        }
    
    }

    closeRegistrationModalformail(){
        this.isRegistraitonModalOpen = false;
        this.isRegistraitonCompletionModalOpen=false;
        this.isCourseCompletionModalOpen=false;
        this.isCourseCompletionValidationModalOpen = false;
        this.isModalOpen=true;
    }
    closeRegistrationCompletionModalformail(){
        this.isRegistraitonModalOpen = false; 
        this.isRegistraitonCompletionModalOpen=false;
        this.isCourseCompletionModalOpen=false;
        this.isCourseCompletionValidationModalOpen = false;
        this.isModalOpen=true;
    }
    closeCourseCompletionModalformail(){
        this.isRegistraitonModalOpen = false;         
        this.isRegistraitonCompletionModalOpen=false;
        this.isCourseCompletionModalOpen=false;
        this.isCourseCompletionValidationModalOpen = false;
        this.isModalOpen=true;
    }
    sendRegistrationMail(){
       
        resendEmialToParticipants( { participantrecId :this.recordId ,EmailTemplate : 'Registration Email'}   )    
        .then((result) =>  {  
            if(result=='success'){
                this.successMessage = true;
                this.errorMessage = false;                
                this.isRegistraitonModalOpen = false;
                this.isRegistraitonCompletionModalOpen = false;
                this.isCourseCompletionModalOpen=false;
                this.alertMessage = 'Successfully sent Registration Email to '+this.pname;
                
            } else{
                
                this.successMessage = false;
                this.errorMessage = true;
               // this.isModalOpen = false;
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
       
        resendEmialToParticipants( { participantrecId :this.recordId ,EmailTemplate : 'Registration Completed' }   )    
        .then((result) =>  { 
            //alert(JSON.stringify(result)); 
            if(result=='success'){
                this.successMessage = true;
                this.errorMessage = false;
              //  this.isModalOpen = false;
                this.isRegistraitonModalOpen = false;
                this.isRegistraitonCompletionModalOpen = false;
                this.isCourseCompletionModalOpen=false;
                this.alertMessage = 'Successfully sent Registration Completion Email to '+this.pname;
            } else{
                //alert(JSON.stringify(result));
                this.successMessage = false;
                this.errorMessage = true;
              //  this.isModalOpen = false;
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

        resendEmialToParticipants( { participantrecId :this.recordId,EmailTemplate : 'Course Completed'  }   )
        
        .then((result) =>  {  
            if(result=='success'){
                this.successMessage = true;
                this.errorMessage = false;
               // this.isModalOpen = false;
                this.isRegistraitonModalOpen = false;
                this.isRegistraitonCompletionModalOpen = false;
                this.isCourseCompletionModalOpen=false;
                this.alertMessage = 'Successfully sent Course Completion email to '+this.pname;
            } else{
                alert(JSON.stringify(result));
                this.successMessage = false;
                this.errorMessage = true;
               // this.isModalOpen = false;
                this.isRegistraitonModalOpen = false;
                this.isRegistraitonCompletionModalOpen = false;
                this.isCourseCompletionModalOpen=false;
                this.alertMessage = 'Failed to resend Course Completion email to '+this.pname;
            }
            
        })
        .catch(error => {
            
        });
    
    }

    closeAlert(){
        this.isModalOpen = true;
        this.successMessage = false;
         this.errorMessage = false;
         this.isCourseCompletionValidationModalOpen=false;
         var url = '/lightning/r/buildertek__Session_Participant__c/'+this.recordId+'/view';
                window.open(url, '_self');
     }

}