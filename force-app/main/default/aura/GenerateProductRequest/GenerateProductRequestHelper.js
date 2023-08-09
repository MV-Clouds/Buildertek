({
    doinit : function(component, event) {
        component.set("v.messageData", "");
        var action = component.get('c.getIssues');
        var caseId = component.get('v.recordId');
        action.setParams({
            'caseId' : caseId
        })
        action.setCallback(this, function(result) {
            
            console.log('=====> issues = ' + JSON.stringify(result.getReturnValue()));
            
            if(result.getReturnValue() != undefined){
                if(result.getReturnValue().length == 0){
                   component.set("v.messageData","Please verify - Order Replacement Flag is checked, Failure Mode is added and you have submitted control parts requests for approval."); 
                }
                component.set('v.IssuesRecords', result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    CreatePr : function(component, event) {
        component.set("v.messageData", "");
        var action = component.get('c.createProductRequestandLines');
        var caseId = component.get('v.recordId');
        this.showSpinner(component, event);
        action.setParams({
            'issueList': component.get('v.IssuesRecords'),
            'caseId' : caseId
            
        })
        
        action.setCallback(this,function(result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var resultData = result.getReturnValue();
                component.set("v.resultInfo", resultData);
                console.log('resultData.hasError : '+resultData.hasError);
                console.log('resultData.hasError : '+resultData.message);
                if(resultData.hasError){
                    component.set("v.messageData", resultData.message);
                }else{
                    this.hideSpinner(component, event);
                    //location.reload();
                    window.open('/lightning/r/Case/'+component.get('v.recordId')+'/view','_self');
                }
            } else if (state === "ERROR"){
                console.log('RESULT:' + state);
                this.hideSpinner(component, event);
                console.log('result.getError()' + result.getError());
                //var errMsg = 'Unknown Error';
                var errMsg = 'Account\'s address has problems, please contact your salesforce administrator.';
                //if (result.getError() && Array.isArray(result.getError()) && result.getError().length > 0) {
                    //errMsg = (result.getError())[0].message;
                //}
                var resErrObj= { "hasError" : true , "message" : errMsg};
                component.set("v.resultInfo", resErrObj);
                component.set("v.messageData", resErrObj.message);
            }       
        });
        
        $A.enqueueAction(action);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event) {
        // make Spinner attribute true for display loading spinner 
        //component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    nevigateSobject : function (component, event, helper) {
        window.open('/lightning/r/Case/'+component.get("v.recordId")+'/view','_self');
    }
})