({
     showToastMessage : function( type, title, message ) {
        
        if( type && title && message ) {
            var toastEvent = $A.get( "e.force:showToast" );
            
            if( toastEvent ) {
                toastEvent.setParams({
                    'type' : type,
                    'title' : title,
                    'message': message				
                });
                toastEvent.fire();
            }
        }
    },
    getOppInfo : function(component, event) {
        var getOppInfoAction = component.get("c.getOppInfo");
        getOppInfoAction.setParams({
            "oppId" : component.get("v.recordId")
        });
        getOppInfoAction.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state:' + state);
            if (state === "SUCCESS") {
                console.log("v.issueWrapperObj" + JSON.stringify(response.getReturnValue()));
                component.set("v.opportunityObj", response.getReturnValue());
            } 
        });
        $A.enqueueAction(getOppInfoAction);
    },
    createCase : function(component, event,helper) {
        var allValid = component.find('createIssueForm').reduce(function (validSoFar, inputCmp) {
            console.log(inputCmp.get('v.label'));
            inputCmp.showHelpMessageIfInvalid();
             console.log('-acctId-',component.get('v.acctId'));
            return validSoFar && !inputCmp.get('v.validity').valueMissing && inputCmp.get('v.validity').valid;
        }, true);
        console.log('allValid:' + allValid);
        if(allValid) {
            var createCaseAction = component.get("c.createCase");
            createCaseAction.setParams({
                "accId" : component.get("v.acctId"),
                "oppId" : component.get("v.recordId"),
                "customerSiteId" : component.get("v.customerSiteId"),
                "contactId" : component.get("v.contactId"),
                "subject" : component.get("v.subject"),
                "caseType" : component.get("v.caseType"),
                "issueStrDate" : component.get("v.issueStartDate"),
                "description" : component.get("v.description")
            });
            createCaseAction.setCallback(this, function(response) {
                 var successMsgEle = component.find('successMsg_submit');
            var errorMsgEle = component.find('errorMsg_submit');
                var state = response.getState();
                console.log('state:' + state);
                if (state === "SUCCESS") {
                    console.log("Case" + JSON.stringify(response.getReturnValue()));
                    component.set("v.caseId", response.getReturnValue().Id);
                    this.navigateTologIssues(component, event);
                } else if(response.getState() === "ERROR") {
                    var errors = response.getError();  
                	console.log(response.getError());
                    if (errors) {
                      var allErrMsgs = '';
                    errors.forEach( function (error){
                        console.log('error.message' + error.message);
                        //top-level error.  there can be only one
                        if (error.message){
                            allErrMsgs = error.message;					
                        }
        
                        //page-level errors (validation rules, etc)
                        if (error.pageErrors){
                            error.pageErrors.forEach( function(pageError) {
                                console.log('pageError' + pageError);
                                allErrMsgs =  allErrMsgs + pageError.message + '\n';				
                            });					
                        }
        
                        if (error.fieldErrors){
                            //field specific errors--we'll say what the field is					
                            for (var fieldName in error.fieldErrors) {
                                 console.log('fieldName' , fieldName);
                                //each field could have multiple errors
                                error.fieldErrors[fieldName].forEach( function (errorList){	
                                    allErrMsgs =  allErrMsgs + errorList.message + '\n';						
                                });                                
                            };  //end of field errors forLoop					
                        } //end of fieldErrors if
                    }); //end Errors forEach
                    console.log('allErrMsgs:' + allErrMsgs);
                        helper.showToastMessage( 'error', 'Error!', allErrMsgs );
                   // component.set("v.submitErrorMessage", allErrMsgs);    
                } 
                  
                }
            });
            $A.enqueueAction(createCaseAction);
        } 
        
    },
    handleLookUpFldEvt : function(component, event) {
        if(event.getParam("reqType") == "caseContact") {
            component.set("v.contactId", event.getParam("selectedRecId"));
        }else if(event.getParam("reqType") == "customerSiteSrch") {
            component.set("v.customerSiteId", event.getParam("selectedRecId"));
        }
    },
    getCustomerSites : function(component, event) {
        if(component.get("v.opportunityObj.Id") != "") {
            var getCustomerSitesAction = component.get("c.getCustomerSites");
            getCustomerSitesAction.setParams({
                "oppId" : component.get("v.recordId")
            });
            getCustomerSitesAction.setCallback(this, function(response) {
                var state = response.getState();
                console.log('getCustomerSitesAction state:' + state);
                
                if (state === "SUCCESS") {
                    console.log('==length=',response.getReturnValue().length);
                    var allCustSites = [];
                    if(response.getReturnValue().length != 1) {
                    
                    var custSiteEmpty = new Object();
                    custSiteEmpty.label = '--None--';
                    custSiteEmpty.value = '';
                    allCustSites.push(custSiteEmpty);
                    }
                    for(var i=0; i< response.getReturnValue().length; i++){
                        console.log('Each Item');
                        var eachCustSite = new Object();
                        eachCustSite.label = response.getReturnValue()[i].Name;
                        eachCustSite.value = response.getReturnValue()[i].Id;
                        allCustSites.push(eachCustSite);
                        if(response.getReturnValue().length == 1) {
                            component.set("v.customerSiteId", eachCustSite.value);
                        }
                    }
                    console.log('allContacts:' + allCustSites);
                    component.set("v.custSiteOpts", allCustSites);
                } else {
                    console.log('Error Get Failure Modes');
                    component.set("v.custSiteOpts", null);
                } 
            });
            $A.enqueueAction(getCustomerSitesAction);
        }
    },
    getAccts : function(component, event) {
        if(component.get("v.opportunityObj.Id") != "") {
            var getAcctsAction = component.get("c.getAccounts");
            getAcctsAction.setParams({
                "oppId" : component.get("v.recordId")
                
            });
            getAcctsAction.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state:' + state);
                
                if (state === "SUCCESS") {
                    var returnval = JSON.stringify(response.getReturnValue());
                    console.log('returnval get Acc:' + returnval);
                    var allAccts = [];
                    for(var i=0; i< response.getReturnValue().length; i++){
                        console.log('Each Item',response.getReturnValue()[i].lable);
                        var eachAcct = new Object();
                        eachAcct.label = response.getReturnValue()[i].lable;
                        eachAcct.value = response.getReturnValue()[i].Ids;
                        allAccts.push(eachAcct);
                       /* if(response.getReturnValue().length == 1) {
                            component.set("v.acctId", eachAcct.value);
                        }*/
                    }
                    console.log('allAccounts:' + allAccts);
                    component.set("v.acctOpts", allAccts);
                    component.set("v.acctId", allAccts[0].value);
                    //component.set("v.acctId", component.get("v.opportunityObj.AccountId"));
                     //this.getContacts(component, event,component.get("v.opportunityObj.AccountId"));
                    this.getContacts(component, event,allAccts[0].value);
                } else {
                    component.set("v.acctOpts", null);
                } 
            });
            $A.enqueueAction(getAcctsAction);
        }
    },
      getContacts : function(component, event, selectedAccount) {
         
         console.log('selectedAccount===',selectedAccount);
         if(!selectedAccount){
            selectedAccount= component.get("v.opportunityObj.AccountId");
         }
       
         if(selectedAccount){
              console.log('selectedAccount=in if==',selectedAccount,'oppid',component.get("v.recordId"));
              var getContactsAction = component.get("c.fetchContacts");
            getContactsAction.setParams({
                "oppId" : component.get("v.recordId"),
                "accountId" : selectedAccount
            });
            getContactsAction.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state==',state);
                console.log('state:' + state);
                if (state === "SUCCESS") {
                    console.log('Success Get Failure Modes');
                    var allContacts = [];
                    var contactEmpty = new Object();
                    contactEmpty.label = '--None--';
                    contactEmpty.value = '';
                    allContacts.push(contactEmpty);
                    for(var i=0; i< response.getReturnValue().length; i++){
                        console.log('Each Item');
                        var eachContact = new Object();
                        if(response.getReturnValue()[i].Contact.Title  === undefined){
                            eachContact.label = response.getReturnValue()[i].Contact.Name 
                            					+' - '+response.getReturnValue()[i].Role;
                        }else if(response.getReturnValue()[i].Role === undefined){
                            eachContact.label = response.getReturnValue()[i].Contact.Name +'  -  '+
                            				response.getReturnValue()[i].Contact.Title;
                        }else{
                            eachContact.label = response.getReturnValue()[i].Contact.Name +' - '+
                            				response.getReturnValue()[i].Contact.Title;
                        }
                        
                        eachContact.value = response.getReturnValue()[i].ContactId;
                        allContacts.push(eachContact);
                        if(response.getReturnValue().length == 1) {
                            component.set("v.contactId", eachContact.value);
                        }
                    }
                    console.log('allContacts:' + allContacts);
                    component.set("v.contactOpts", allContacts);
                } else {
                    console.log('Error Get Failure Modes');
                    component.set("v.contactOpts", null);
                } 
            });
            $A.enqueueAction(getContactsAction);
        
         }
        
    },
    navigateTologIssues : function(component, event, helper) {
        var recordId = component.get("v.caseId");
       // var url = '/apex/logIssues_Page?id=' + recordId;
       // var urlEvent = $A.get("e.force:navigateToURL");
       var evt = $A.get("e.force:navigateToComponent");
           evt.setParams({
        componentDef : "c:LogIssuesCmp",
        componentAttributes: {
            recordId : recordId
        }
    });
 
      /*  evt.setParams({
            "url": url
        });*/
        evt.fire();
    }
})