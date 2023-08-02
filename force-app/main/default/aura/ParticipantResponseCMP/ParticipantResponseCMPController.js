({
    doInit: function(component) {
         //Site Url Get 
         var url = window.location.href;
         var siteUrl = url.split('?');
         if(siteUrl[0] !='' && siteUrl[0] != undefined){
             component.set("v.siteUrl",siteUrl[0].replace('/buildertek__ParticipantResponseVF','')); 
         }
         else{
             component.set("v.siteUrl",'/');
         }
  
  		//alert(component.get("v.siteUrl"));
        var action = component.get("c.getparticipant");
        action.setParams({
            sId: component.get("v.recordId")            
        });
        
        action.setCallback(this, function(response) {          
            var state = response.getState();
            //alert(state);
            var data = response.getReturnValue();
            // alert(data);
             //alert('data-->'+JSON.stringify(data));
            
            if (state === "SUCCESS"){
                //component.set("v.error1",true);
                // document.getElementById('box').style.display = 'none';
                // component.set("v.box","slds-hide");
                //$A.util.addClass(component.find("box"), "slds-hide");
                //component.set("v.message",'you have already submitted response!');
            }      
        });
        $A.enqueueAction(action);
        
        let params = (new URL(document.location)).searchParams;
        let recId = params.get('Id'); 
        component.set("v.recordId",recId);
        
        var id= component.get("v.recordId");
        var action = component.get("c.getCousreDetails");
        action.setParams({
            sId: component.get("v.recordId")            
        });
        
        action.setCallback(this, function(response) {          
            var state = response.getState();
             //alert(state);
            var data = response.getReturnValue();
             //alert(data);
             //alert('data-->'+JSON.stringify(data));
            if (state === "SUCCESS"){
                //alert('State------'+state);
                component.set("v.sessionObj",data);
                //alert('data set');
                /*alert('Name------'+data.buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__r.Name);
                if(data.buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__r.Name != null){
                    component.set("v.course",data.buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__r.Name);
                }else{
                    alert('In else ');
                }*/
            } 
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getAttachmentData");
        action.setParams({
            sId: component.get("v.recordId")            
        });
        action.setCallback(this,function(a){
            if(a.getState()==='SUCCESS'){
                var result = a.getReturnValue(); 
                //alert(component.get("v.siteUrl"));

                component.set("v.imgUrl",component.get("v.siteUrl")+"/servlet/servlet.FileDownload?file="+result);
                //component.set("v.imgUrl","https://builderteklightning-developer-edition.na75.force.com/servlet/servlet.FileDownload?file="+result);
                //https://builderteklightning-developer-edition.na75.force.com/
            }
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.getTrainingSettings");
        action.setParams({
            sId: component.get("v.recordId")            
        });
        action.setCallback(this,function(a){
            if(a.getState()==='SUCCESS'){
                var result = a.getReturnValue();
                component.set("v.TrainingSetObj",result);
            }
        });
        $A.enqueueAction(action);
        
        
        
    },
    handleChange: function (component, event) {
       var changeValue = event.getParam("value");
       component.set("v.selectedValue",changeValue)  
    },
    handleClose:function (component, event) {
            	window.close('/apex/buildertek__ParticipantResponseVF');   
            	//window.close('/apex/buildertek__BTPaymentSuccessVFPage');  
    },
    savesession: function (component, event) {
       component.set("v.message",'');
        component.set("v.error",false);
        component.set("v.success",false);

        if(component.get("v.success")!=true){
            if(component.get("v.selectedValue")!=' '){
                var tempsessoion = component.get("v.sessionObj");
                //alert('tempsessoion-->'+JSON.stringify(tempsessoion));
                var vipVal = component.get("v.picklistValue");
                var FstName = component.get("v.sessionObj.buildertek__Participant_Name__r.FirstName");
                var LstName = component.get("v.sessionObj.buildertek__Participant_Name__r.LastName");
                var phn = component.get("v.sessionObj.buildertek__Participant_Name__r.Phone");
                var til = component.get("v.sessionObj.buildertek__Participant_Name__r.Title");
                var mail = component.get("v.sessionObj.buildertek__Participant_Name__r.Email");
                var City = component.get("v.sessionObj.buildertek__Participant_Name__r.MailingCity");
                var Street = component.get("v.sessionObj.buildertek__Participant_Name__r.MailingStreet");
                var State = component.get("v.sessionObj.buildertek__Participant_Name__r.MailingState");
                var Country = component.get("v.sessionObj.buildertek__Participant_Name__r.MailingCountry");
                var PostalCode = component.get("v.sessionObj.buildertek__Participant_Name__r.MailingPostalCode");
                var CompanyName = component.get("v.sessionObj.buildertek__Participant_Company__r.Name");
                //alert('CompanyName---------'+CompanyName);
                if(vipVal != undefined && vipVal.length > 0){
                    var isparticipant=vipVal[0];
                    
                    //tempsessoion.Is_Participant_Attending__c = vipVal[0]; 
                }   
                var action = component.get("c.savesessionobj");
                action.setParams({
                    ssId: component.get("v.recordId"),
                    tss:isparticipant ,
                    lst:LstName,
                    FstNme:FstName,
                    Phon:phn,
                    Title:til,
                    Email:mail,
                    Cit:City,
                    Stre:Street,
                    Stat:State,
                    Coun:Country,
                    Pc:PostalCode,
                    CmpNme:CompanyName
                });
                
                action.setCallback(this, function(response) {
                     //alert(response.getState());  
                    var state = response.getState();
                    
                    if (state === "SUCCESS"){   
                        component.set("v.success",true);
                        component.set("v.message","Your response has been submitted successfully.");                 
                        $A.util.addClass(component.find("box"), "slds-hide");
                    }else if (state === "ERROR") {
                        component.set("v.error",true);
                        component.set("v.message",'Failed to submit your response!');                
                    }else {
                        component.set("v.error",true);
                    } 
                    
                });
                $A.enqueueAction(action);
                
            }else{
                component.set("v.error",true);
                component.set("v.message",'Please select Yes / No!');
            }
           
            
        }else{
           // $A.util.addClass(component.find("box"), "slds-hide");
           // component.set("v.message",'you have already submitted response!');
        }
        
      
        
        
    },
    
})