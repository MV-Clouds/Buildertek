import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
//import getParticipants from '@salesforce/apex/ParticipantsController.getParticipants';
import getCourseSession from '@salesforce/apex/ParticipantUpdatesController.getCourseSession';
import saveParticipants from '@salesforce/apex/ParticipantsController.saveParticipants';
import getParticipantAccount from '@salesforce/apex/ParticipantsController.getParticipantAccount';
import checkDuplicateSessions from '@salesforce/apex/ParticipantsController.checkDuplicateSessions';
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import ACCOUNT_FIELD from '@salesforce/schema/Contact.AccountId';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import MOBILEPHONE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import readFieldSet from '@salesforce/apex/ParticipantUpdatesController.readFieldSet';
import getContacts from '@salesforce/apex/ParticipantsController.getContacts';


export default class Add_Participants extends NavigationMixin(LightningElement) {
    @api index;
    get position() {
        return this.index + 1;
    }

    ICON_URL = '/apexpages/slds/latest/assets/icons/{0}-sprite/svg/symbols.svg#{1}';
    @track CourseSessionRecordId;
    @track ParticipantsWrapper=[
        {RowNumber:1, ParticipantName:'', ParticipantCompany:'',ParticipantAttended:'No',
        ParticipantScore:'', CourseCompleted:'No',
        Notes:'',
        ContactSelectedValue:'',ParticipantEmail:'',
        showContactLookup:true}];
    @track rowIndex=0; 
    @api YesNoOptions=[{label:'Yes',value:'Yes'},
    {label:'No',value:'No'}];
    @track successMessage=false;
    @track errorMessage=false;
    @track alertMessage='';
    @track coursrsessionName='';
    @track url='';
    @track fieldSetNames=[];
    @track conEmails=[];
    @track isdeleteModalOpen=false;
    @track isopenCompanyModal=false;

  //  newContactFields = [NAME_FIELD, ACCOUNT_FIELD, PHONE_FIELD, MOBILEPHONE_FIELD, EMAIL_FIELD];

    connectedCallback(){
    console.log('connectedCallback');
    let params = (new URL(document.location)).searchParams;
    let recId = params.get('Id'); 
    this.CourseSessionRecordId = recId;
    //this.CourseSessionRecordId = this.recordId;
    //alert(this.CourseSessionRecordId);

    this.url ='/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSessionRecordId+'/view';

        getCourseSession( { coursessId : this.CourseSessionRecordId })
        .then((result) =>  {                          
        this.coursrsessionName=result.Name;
        })
        .catch(error => {

        });
        readFieldSet()
        .then((result) =>  {   
           // alert(result) ;                      
            this.fieldSetNames=result;
            })
            .catch(error => {
    
            });


    }

    @track isModalOpen = false;
    @track participantsFailMSG=false;
    @track addRowModel=false;
    @track contactModel=false;
    @track contactFailModel=false;
    @track accName='';
    openCreateContactModal() {
        this.successMessage = false;
        this.errorMessage = false;
        this.alertMessage='';    
        this.msgheading='';
    
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.isdeleteModalOpen= false;
        
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        
    }
    
    openCompanyModal(){
        this.isopenCompanyModal=true;
    }
    handleSubmit(event) {
        this.isModalOpen = false;
        this.successMessage = false;
        this.contactModel = true;
        this.errorMessage = false;
        this.alertMessage = 'Contact saved successfully!';
        var firstname =  event.detail.fields.FirstName;
        var contactname =  '';
        var contactEmail='';
        if(firstname!=null){
           
            contactname = firstname+' '+event.detail.fields.LastName+'';
            contactEmail=event.detail.fields.Email;
          
        }else{
            contactname = event.detail.fields.LastName+'';
            contactEmail=event.detail.fields.Email;
        }
        //alert(event.detail.fields.Email);

        //alert(this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue);
        
        var dup=false;
        if(this.errorMessage==false){           
            checkDuplicateSessions({participantEmail:event.detail.fields.Email,CourseSessionRecordId : this.CourseSessionRecordId
            }).then((result) =>  {
                console.log('result--->'+result);
                if(result==true){
                   
                        this.successMessage = false;
                        this.errorMessage = true;
                        dup = true;
                        this.msgheading = 'Duplicate participant';
                        var emailid='';
                        if(event.detail.fields.Email!=null){
                            emailid = event.detail.fields.Email;
                        }
                        this.alertMessage = 'There is another participant, '+contactname+' with this email address  '+emailid+'. You cannot add two participants with the same email address.';
                    }else if(result==false){
                        
                        //alert('false false');
                        dup = false;
                    } 
                    
                })
                .catch(error => {
                });	
            }

            
            if(dup==false){
                
                let result = false;
                //alert('dup--->'+dup);
                for(var i=0; i<this.ParticipantsWrapper.length;i++){
                    if(result==false){ 
                       // alert('event------'+event.detail.fields.Email);  
                       // alert('wrap-----------'+this.ParticipantsWrapper[i].ParticipantEmail);                                         
                        if(this.ParticipantsWrapper[i].ParticipantEmail == event.detail.fields.Email){                           
                            result = true;
                           // alert(result);
                            break;
                        }                       
                    }
                }
                 

                if(result==false){
                    //alert('result--->'+result);
                    if(this.ParticipantsWrapper.length>0){
                    if(this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue==''){
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].showContactLookup=false;
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue=contactname;  
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantEmail=contactEmail;    
                        console.log('contactname-->'+ JSON.stringify ( this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue ));    
                    }else if(this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue!=''){
                        this.rowIndex = this.rowIndex+1;
                        var rownumber = this.ParticipantsWrapper.length+1;
                        this.ParticipantsWrapper.push({
                            RowNumber:rownumber,
                            ParticipantName:'',
                            ParticipantCompany:'',
                            ParticipantAttended:'No',
                            //IsParticipantAttend:'',
                            ParticipantScore:'',
                            //TrainingExpirationDate:'',
                            CourseCompleted:'No',
                            Notes:'',
                            ContactSelectedValue:'',
                            ParticipantEmail:'',
                            showContactLookup:true
                        }); 
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].showContactLookup=false;
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue=contactname;
                       this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantEmail=contactEmail;    
                    }      
                }else{
                    //alert('else 111'+this.ParticipantsWrapper.length); 
                    this.rowIndex = this.rowIndex+1;
                        var rownumber = 1;
                        this.ParticipantsWrapper.push({
                            RowNumber:rownumber,
                            ParticipantName:'',
                            ParticipantCompany:'',
                            ParticipantAttended:'No',
                            //IsParticipantAttend:'',
                            ParticipantScore:'',
                            //TrainingExpirationDate:'',
                            CourseCompleted:'No',
                            Notes:'',
                            ContactSelectedValue:'',
                            ParticipantEmail:'',
                            showContactLookup:true
                        });
                        //alert('else 222'+this.ParticipantsWrapper.length); 
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].showContactLookup=false;
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue=contactname; 
                        this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantName=contactEmail;    
                }      
                }else{
                    //alert('result else Duplicate');
                    //alert(this.ParticipantsWrapper.length); 

                    this.successMessage = false;
                    this.errorMessage = true;
                    this.msgheading = 'Duplicate participant';
                    var emailid='';
                    if(event.detail.fields.Email!=null){
                        emailid = event.detail.fields.Email;
                    }
                    this.alertMessage = 'There is another participant, '+contactname+' with this email address  '+emailid+'. You cannot add two participants with the same email address.';

                    this.rowIndex = this.rowIndex+1;
                    var rownumber = this.ParticipantsWrapper.length+1;
                    this.ParticipantsWrapper.push({
                        RowNumber:rownumber,
                        ParticipantName:'',
                        ParticipantCompany:'',
                        ParticipantAttended:'No',
                        //IsParticipantAttend:'',
                        ParticipantScore:'',
                        //TrainingExpirationDate:'',
                        CourseCompleted:'No',
                        Notes:'',
                        ContactSelectedValue:'',
                        ParticipantEmail:'',
                        showContactLookup:true
                    });
                    //alert('else Duplicate'+this.ParticipantsWrapper.length); 
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].showContactLookup=false;
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue=contactname; 
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantName=contactEmail;   
                }


                //alert(this.msgheading);

            }


            
    }

    handleSuccess(event) {
        //alert('handleSuccess--->'+this.msgheading);
        //alert(this.rowIndex);
        //alert(this.ParticipantsWrapper.length);
        if(this.msgheading!='Duplicate participant'){
            this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantName=event.detail.id;
            this.fetchParticipantAccountHelper(this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantName,this.ParticipantsWrapper.length-1);    
        }else if(this.msgheading=='Duplicate participant'){
            this.ParticipantsWrapper[this.rowIndex].showContactLookup=true;
            this.ParticipantsWrapper[this.rowIndex].ParticipantCompany=' ';
            this.ParticipantsWrapper[this.rowIndex].ParticipantName='';
            this.ParticipantsWrapper[this.rowIndex].ParticipantEmail='';    
            this.ParticipantsWrapper[this.rowIndex].ContactSelectedValue='';
        }

    }
    
   addParticipantChangeHandler(event){
    if(event.target.name==='ParticipantAttended'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantAttended=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantAttended);
    }
    else if(event.target.name==='ParticipantScore'){
        this.ParticipantsWrapper[event.target.accessKey].ParticipantScore=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantScore);
    }
   /* else if(event.target.name==='IsParticipantAttend'){
        this.ParticipantsWrapper[event.target.accessKey].IsParticipantAttend=event.target.value;
        //alert(this.ParticipantsWrapper[event.target.accessKey].ParticipantScore);
    }*/
   /* else if(event.target.name==='TrainingExpirationDate'){
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
   }

   addRow(){
    this.successMessage = false;
    this.errorMessage = false;
    this.addRowModel=false;
    this.addparticipantsErrorMSG=false;
    this.alertMessage='';    
    var lastrowindex = this.ParticipantsWrapper.length-1;
    console.log('lastrowindex-->'+lastrowindex);
    if( this.ParticipantsWrapper.length>0){
        if(this.ParticipantsWrapper[lastrowindex].ParticipantName==''){
            this.addRowModel=true;
            this.alertMessage = 'Please provide participant details for row '+this.ParticipantsWrapper.length+'!';
        }    
    }   
    
    if(this.addRowModel==false){
        this.rowIndex = this.rowIndex+1;
        var rownumber = this.ParticipantsWrapper.length+1;
        this.ParticipantsWrapper.push({
            RowNumber:rownumber,
            ParticipantName:'',
            ParticipantCompany:'',
            ParticipantAttended:'No',
            //IsParticipantAttend:'',
            ParticipantScore:'',
            //TrainingExpirationDate:'', 
            CourseCompleted:'No',
            Notes:'',
            ContactSelectedValue:'',
            ParticipantEmail:'',
            showContactLookup:true
        }); 
    }  

   }



   deleteRow(event){
        this.successMessage = false;
        this.errorMessage = false;
        this.alertMessage='';    

       if(this.ParticipantsWrapper.length>=1){
           this.ParticipantsWrapper.splice(event.target.accessKey,1);
           this.ParticipantsWrapper-1;
       }

       for(var i=0;i<this.ParticipantsWrapper.length;i++){
           this.ParticipantsWrapper[i].RowNumber = (i+1);
       }
      
   }    


   contactfields = ["Name"];
   contactdisplayFields = 'Name, Email';
   accountfields = ["Name"];
   accountdisplayFields = 'Name, Phone';

   @track selectedRecord;
   @track duplicate=false;
   @track msgheading='Failed to insert participants!';
   @track contactRecList;
   @track accrec='';
   @track columns = [
    { label: 'Id', fieldName: 'id', type: 'text' },  
    { label: 'Name', fieldName: 'Name', type: 'text' },  
       { label: 'First Name', fieldName: 'FirstName', type: 'text' },  
       { label: 'Last Name', fieldName: 'LastName', type: 'text' },         
       { label: 'Phone', fieldName: 'Phone', type: 'phone' },
       { label: 'Email', fieldName: 'Email', type: 'text' },  
       { label: 'Skill Level', fieldName: 'buildertek__Skill_Level__c', type: 'text' },     
   ];   
handleAccountLookup(event){
       this.accrec=event.detail.recordId;
       this.accName=event.detail.selectedValue;
      // alert(JSON.stringify ( event.detail));  
       
       getContacts( { accId :this.accrec,couserSessionId:this.CourseSessionRecordId }  )    
       .then(result=>{
      // alert(JSON.stringify (result));  
        this.contactRecList = result;
    })
    .catch(error=>{
        this.contactRecList = undefined;
    });

}

//@track conEmailsList=[{contactId:'',contactname:'',contactEmail:''}];
@track conEmailsList=[];
@track conEmailsListUnchecked=[{contactId1:'',contactname1:'',contactEmail1:''}];

handleSelect(event){       
    var checked = event.target.checked;
    if(checked == true){
        if(this.contactRecList[event.target.value].FirstName!=null){       
            this.conEmailsList.push({
                contactId:this.contactRecList[event.target.value].Id,
                contactname:this.contactRecList[event.target.value].FirstName+' '+this.contactRecList[event.target.value].LastName,
                contactEmail:this.contactRecList[event.target.value].Email
            }); 
        }else{
            this.conEmailsList.push({
                contactId:this.contactRecList[event.target.value].Id,
                contactname:this.contactRecList[event.target.value].LastName,
                contactEmail:this.contactRecList[event.target.value].Email
            }); 
        }
    }else if(checked==false){
        
        var recIdsTmp=[];
        //alert('conEmailsList--->'+this.conEmailsList.length);

        for(var i=0;i<this.conEmailsList.length;i++){
            recIdsTmp.push(this.conEmailsList[i]);
        }
        //alert('recIdsTmp--->'+recIdsTmp.length);
        this.conEmailsList=[];

        for(var j=0;j<recIdsTmp.length;j++){
            if(recIdsTmp[j].contactId!=this.contactRecList[event.target.value].Id){
                //alert('not equal');
                this.conEmailsList.push(recIdsTmp[j]);
            }
        }
    }
    //alert(this.conEmailsList.length);


}


handleparticipantsSave(){
    //alert('add participants from company--->'+this.conEmailsList.length);

    // empty 
    if(this.conEmailsList.length>0){
    let map = {};
    let result = false;
    for(let k = 0; k <= this.conEmailsList.length-1; k++) {
        // check if object contains entry with this element as key
        if(map[this.conEmailsList[k].contactEmail]) {
            result = true;
            // terminate the loop
            break;
        }
        // add entry in object with the element as key
        map[this.conEmailsList[k].contactEmail] = true;
    }
    if(result) {
        var duplicate = false;
        for(var i=0; i<this.ParticipantsWrapper.length;i++){
            if(duplicate==false){
                for(var j=0; j<=this.conEmailsList.length-1; j++){
                    //alert('part-->'+this.ParticipantsWrapper[i].ParticipantEmail);
                    //alert('con-->'+this.conEmailsList[j].contactEmail);
                    if(this.ParticipantsWrapper[i].ParticipantEmail == this.conEmailsList[j].contactEmail){
                        duplicate = true;
                        break;
                    }
                }    
            }
        }
        if(duplicate==true){
            result = true;
        }
    } else {

        var duplicate = false;
        for(var i=0; i<this.ParticipantsWrapper.length;i++){
            if(duplicate==false){
                for(var j=0; j<=this.conEmailsList.length-1; j++){
                    //alert('part-->'+this.ParticipantsWrapper[i].ParticipantEmail);
                    //alert('con-->'+this.conEmailsList[j].contactEmail);
                    if(this.ParticipantsWrapper[i].ParticipantEmail == this.conEmailsList[j].contactEmail){
                        duplicate = true;
                        break;
                    }
                }    
            }
        }
        if(duplicate==true){
            result = true
        }
    }

    if(result==false){

        for(var i=0;i<=this.conEmailsList.length-1;i++){ 
            
            if(this.ParticipantsWrapper.length>0){
                if(this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue==''){
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].showContactLookup=false;
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue=this.conEmailsList[0].contactname;  
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantName=this.conEmailsList[0].contactId;
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantCompany=this.accName;
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantCompanyId=this.accrec;
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantAttended='No';
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].CourseCompleted='No';
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].Notes='';
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantScore='';
                    this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ParticipantEmail=this.conEmailsList[0].contactEmail;
                    console.log('contactname-->'+ JSON.stringify ( this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue ));    
                }else if(this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue!=''){
                    this.rowIndex = this.rowIndex+1;
                    var rownumber = this.ParticipantsWrapper.length+1;
                    this.ParticipantsWrapper.push({
                        RowNumber:rownumber,
                        ParticipantName:this.conEmailsList[i].contactId,
                        ParticipantCompany:this.accName,
                        ParticipantCompanyId:this.accrec,
                        ParticipantAttended:'No',
                        //IsParticipantAttend:'',
                        ParticipantScore:'',
                        //TrainingExpirationDate:'', 
                        CourseCompleted:'No',
                        Notes:'',
                        ContactSelectedValue:this.conEmailsList[i].contactname,
                        ParticipantEmail:this.conEmailsList[i].contactEmail,
                        showContactLookup:false
                    }); 
                    
                      
                }
            }else{
                
                this.rowIndex = this.rowIndex+1;
                var rownumber = this.ParticipantsWrapper.length+1;
                this.ParticipantsWrapper.push({
                    RowNumber:rownumber,
                    ParticipantName:this.conEmailsList[i].contactId,
                    ParticipantCompany:this.accName,
                    ParticipantCompanyId:this.accrec,
                    ParticipantAttended:'No',
                    //IsParticipantAttend:'',
                    ParticipantScore:'',
                    //TrainingExpirationDate:'', 
                    CourseCompleted:'No',
                    Notes:'',
                    ContactSelectedValue:this.conEmailsList[i].contactname,
                    ParticipantEmail:this.conEmailsList[i].contactEmail,
                    showContactLookup:false
                });                 

            }
                

        }
   
    }else{
        this.successMessage = false;
        this.errorMessage = true;
        this.msgheading = 'Duplicate participant';
        this.alertMessage = 'Duplicate participants exists with same email address. Please check and add participants';
    }

    
this.conEmailsList=[];
this.isopenCompanyModal=false;
this.accrec='';
this.accName=''; 
this.contactRecList='';    
this.conEmailsListUnchecked=[];        
    }else{
       
        this.addparticipantsErrorMSG = true;
        this.isopenCompanyModal=false;
        this.alertMessage = 'Please select participants';
       // this.alertMessage = 'Please Select participants!';
    }     

}   
addparticipantsErrorMSGclose(){
    this.isopenCompanyModal=true;
    this.addparticipantsErrorMSG = false;
}
   
closeparticipantsModel(){
    this.participantsFailMSG=false;

}
   handleContactLookup(event){
    this.successMessage = false;
    this.errorMessage = false;
    this.duplicate = false;
    var dup = false;
       console.log('Participant=='+JSON.stringify ( event.detail) )
       var del = JSON.stringify(event.detail);
       this.selectedRecord = event.detail;  
       //alert(event.detail.selectedValue);
       //alert(event.detail.recordId);
       //alert(event.detail.accessKey);
       //alert(event.detail.Email);
       this.ParticipantsWrapper[event.detail.accessKey].ParticipantName=event.detail.recordId;
       this.ParticipantsWrapper[event.detail.accessKey].showContactLookup=false;
       this.ParticipantsWrapper[event.detail.accessKey].ContactSelectedValue=event.detail.selectedValue;
       this.ParticipantsWrapper[event.detail.accessKey].ParticipantEmail=event.detail.Email;
       
       if(this.errorMessage==false){
        checkDuplicateSessions({participantEmail:event.detail.Email,CourseSessionRecordId : this.CourseSessionRecordId
        }).then((result) =>  {
            console.log('result--->'+result);
            if(result==true){
                    this.successMessage = false;
                    this.errorMessage = true;
                    dup = true;
                    this.msgheading = 'Duplicate participant';
                    var emailid='';
                    if(event.detail.Email!=null){
                        emailid = event.detail.Email;
                    }
                    this.alertMessage = 'There is another participant, '+event.detail.selectedValue+' with this email address  '+emailid+'. You cannot add two participants with the same email address.';
                    this.ParticipantsWrapper[event.detail.accessKey].showContactLookup=true;
                    this.ParticipantsWrapper[event.detail.accessKey].ParticipantCompany=' ';
                    this.ParticipantsWrapper[event.detail.accessKey].ParticipantName='';
                    this.ParticipantsWrapper[event.detail.accessKey].ParticipantName='';
                    this.ParticipantsWrapper[event.detail.accessKey].ContactSelectedValue='';
                }else if(result==false){
                    //alert('false false');
                    dup = false;
                } 
               
            })
            .catch(error => {
            });	
        }




        if(dup==false){

            for(var i=0;i<this.ParticipantsWrapper.length;i++){
                if(i!=event.detail.accessKey &&
                    this.ParticipantsWrapper[i].ParticipantEmail==event.detail.Email){
                    //alert('duplicate');
                    this.ParticipantsWrapper[event.detail.accessKey].showContactLookup=true;
                    this.ParticipantsWrapper[event.detail.accessKey].ParticipantCompany=' ';
                    this.ParticipantsWrapper[event.detail.accessKey].ParticipantName='';
                    this.ParticipantsWrapper[event.detail.accessKey].ParticipantEmail='';    
                    this.ParticipantsWrapper[event.detail.accessKey].ContactSelectedValue='';
                    this.template.querySelector('c-search-component').handleClose();

                    this.successMessage = false;
                    this.errorMessage = true;
                    this.duplicate = true;
                    this.msgheading = 'Duplicate participant';
                    var emailid='';
                    if(event.detail.Email!=null){
                        emailid = event.detail.Email;
                    }
                    this.alertMessage = 'There is another participant, '+event.detail.selectedValue+' with this email address '+emailid+'. You cannot add two participants with the same email address.';
                    break;
                }
               
            }

            if(this.duplicate ==true ){
                this.ParticipantsWrapper[event.detail.accessKey].ParticipantCompany=' ';
                this.ParticipantsWrapper[event.detail.accessKey].ParticipantName='';
                this.ParticipantsWrapper[event.detail.accessKey].ParticipantEmail='';
                this.ParticipantsWrapper[event.detail.accessKey].showContactLookup=true;
            }

            if(this.duplicate==false){
                this.fetchParticipantAccountHelper(event.detail.recordId,event.target.accessKey);
            }            
        }    
      
   }

   fetchParticipantAccountHelper(participantId,accessKey){
        this.successMessage = false;
        this.errorMessage = false;
        //alert('fetchParticipantAccountHelper');
        console.log('participantId--->'+participantId);
        console.log('accessKey--->'+accessKey);
 
        if(this.duplicate==false){
            getParticipantAccount({participantId:participantId
            }).then((result) =>  {
            //alert(result);
                if(this.ParticipantsWrapper[accessKey].ParticipantName!=''){
                    this.ParticipantsWrapper[accessKey].ParticipantCompany=result.Account.Name;
                    this.ParticipantsWrapper[accessKey].ParticipantCompanyId=result.AccountId;    
                }
            })
            .catch(error => {
            });	    
        }

   }



   /*handleAccountLookup(event){
    console.log( JSON.stringify ( event.detail) )
    var del = JSON.stringify(event.detail);
    //alert(event.detail.recordId);
    //alert(event.detail.accessKey);

    this.ParticipantsWrapper[event.detail.accessKey].ParticipantCompany=event.detail.recordId;
    //alert(this.ParticipantsWrapper[event.detail.accessKey].ParticipantName);
}*/

handleClose(event){
    this.successMessage = false;
    this.errorMessage = false;
    this.ParticipantsWrapper[event.target.accessKey].showContactLookup=true;
    this.ParticipantsWrapper[event.target.accessKey].ParticipantCompany='';
    this.ParticipantsWrapper[event.target.accessKey].ParticipantName='';
    //this.ParticipantsWrapper[this.ParticipantsWrapper.length-1].ContactSelectedValue='';
    this.ParticipantsWrapper[event.target.accessKey].ContactSelectedValue='';
    this.ParticipantsWrapper[event.target.accessKey].ParticipantEmail='';
      
    //alert(this.ParticipantsWrapper[event.target.accessKey].ContactSelectedValue);
    //alert('handleClose');
}

   handleSave(){
      // alert(JSON.stringify (this.ParticipantsWrapper));
        //sendEmailsToParticipants()

        if(this.ParticipantsWrapper.length==0){
            this.successMessage = false;
            //this.contactFailModel = true;            
            this.errorMessage = true;
            this.msgheading='Add Participants'
            this.alertMessage = 'Please add participants!';            
        }else{
            this.errorMessage = false;
        }

        if(this.errorMessage==false){

            var isSave=true;
            for(var i=0;i<this.ParticipantsWrapper.length;i++){
                if(this.ParticipantsWrapper[i].ContactSelectedValue==''){
                    isSave=false;
                    break;
                }
            }



            if(isSave==true){
            saveParticipants( 
                { 
                    records : JSON.stringify(this.ParticipantsWrapper),
                    CourseSessionRecordId : this.CourseSessionRecordId
                } 
            )          
            .then((result) =>  {
               // alert(result);
                if(result=='Saved'){ 
                    this.successMessage = true;
                    this.errorMessage = false;
                    this.alertMessage = 'Participants are added successfully!';
                    var count=0;
                   
                  
                }
            })
            .catch(error => {
                this.successMessage = false;
                    this.errorMessage = true;
                    this.msgheading='Failed to insert participants!';
                    this.alertMessage = 'Cannot create record(s)';
                    var count=0;
                    for(var i=0;i<200;i++){
                        count=count+1;
                    }
                    if(count==200){
                        var url = '/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSessionRecordId+'/view';
                        window.open(url, '_self');
                    }
                    //alert(JSON.stringify(error));
                    
            });	
            }else{
                this.successMessage = false;
                this.contactFailModel = true;
                this.alertMessage = 'Please select participant name';
               // this.alertMessage = 'Please Select Participant Name';
                
            }
           
            
        }
      

   }
   navigateToCourseSessionPage() {
        
    var url = '/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSessionRecordId+'/view';
          window.open(url, '_self');
}
navigateToContactPage(){
    let temp = {
        type: 'standard__objectPage',
        attributes: {
            objectApiName: 'Contact',
            actionName: 'new'                
        },
        
    };
    this[NavigationMixin.Navigate](temp);
}
closeAlert(){
    // alert('close');
     this.successMessage = false;
     this.errorMessage = false;
     this.addRowModel = false;
     this.contactModel=false;
     this.contactFailModel=false;
     this.isopenCompanyModal=false;
     this.accName = "";
     this.contactRecList=[];
 }
 gotoCourseSessionPage(){    
    this.successMessage=false;
    var url = '/lightning/r/buildertek__Course_Session_Scheduling__c/'+this.CourseSessionRecordId+'/view';
                window.open(url, '_self');
}
}