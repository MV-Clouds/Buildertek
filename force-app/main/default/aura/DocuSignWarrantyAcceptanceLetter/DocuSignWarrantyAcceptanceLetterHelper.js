({
    doInitHelper : function(component, event, helper) {
        var action = component.get('c.getOpportunity');
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var account = response.getReturnValue();
                component.set('v.opportunity', account);
                helper.sendForDocusign(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    sendForDocusign : function(component, event, helper) {
        //********* Option Declarations (Do not modify )*********// 
        var recordId = component.get("v.recordId");  
		var opportunity = component.get("v.opportunity"); 
        var pmEmail = opportunity.PM_Email__c;        
        var projectManager;
        var projectManagerId = opportunity.Project_Manager__c;
        
        if(projectManagerId != undefined && projectManagerId!= null){
            projectManager = opportunity.Project_Manager__r.Name;
        }
               		
        var RC = '';var RSL='';var RSRO='';var RROS='';var CCRM='';var CCTM='';var CCNM='';var CRCL='';var CRL='';var OCO='';var DST='';var LA='';var CEM='';var CES='';var STB='';var SSB='';var SES='';var SEM='';var SRS='';var SCS ='';var RES=''; 
        //*************************************************// 
        DST=$A.get("$Label.c.Docusign_Template_Id"); // DcouSign Template ID 
        CRL='Email~'+pmEmail+';LastName~'+projectManager+';Role~Admin 1,Email~'+pmEmail+';LastName~'+projectManager+';Role~Signer 1,LoadDefaultContacts~1';//Custom Recipient List 
        CCRM='Signer 1~Signer 1;OM Signee~Signer 2';//Custom Contact Role Map 
        RROS='1'; //Contact Routing Order Sequential 
        RSRO='1'; 
        LA='0'; //List Attachments 
        //********* Page Callout (Do not modify) *********// 
        window.location.href ="/apex/dsfs__DocuSign_CreateEnvelope?DSEID=0&SourceID="+recordId+"&RC="+RC+"&RSL="+RSL+"&RSRO="+RSRO+"&RROS="+RROS+"&CCRM="+CCRM+"&CCTM="+CCTM+"&CRCL="+CRCL+"&CRL="+CRL+"&OCO="+OCO+"&DST="+DST+"&CCNM="+CCNM+"&LA="+LA+"&CEM="+CEM+"&CES="+CES+"&SRS="+SRS+"&STB="+STB+"&SSB="+SSB+"&SES="+SES+"&SEM="+SEM+"&SRS="+SRS+"&SCS="+SCS+"&RES="+RES;
        //*******************************************//
    }
})