({
    doInit : function(component, event, helper) {
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result ==> ',{result});
                if(result.IsPortalEnabled == true){
                    component.set("v.Iscommunity",true);
                }
            }
                
            });
            $A.enqueueAction(action);
        
        
        // debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        // debugger;
        var action = component.get("c.getIsNextPAyment");
        action.setParams({"recordId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if(state === "SUCCESS") {
                var resultData = response.getReturnValue();
                console.log(resultData.payment);
                console.log(resultData.payment.buildertek__SOV_Payment_Application__r.buildertek__Status__c );
                //if((resultData.payment.buildertek__IsNextPayment__c == true) /*&& resultData.userrec.isPortalEnabled == true*/){
                if(resultData.NoSOVLines == true){
                    component.set("v.Spinner", false);
                    component.set("v.showMessage", false);
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'There are no Continuation Sheet Lines for this Payment Application.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
                else if(resultData.checkGCWithCompletion == true){
                    component.set("v.Spinner", false);
                    component.set("v.showMessage", false);
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'All the Continuation Sheet Lines are Successfully Completed 100%.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
                else if(resultData.validIsNext == false){
                    component.set("v.Spinner", false);
                    component.set("v.showMessage", false);
                    //  component.set("v.IsSubmitted",true);
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'You have Already Created the Next Payment Application for this Record.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
                else if(resultData.payment.buildertek__SOV_Payment_Application__r.RecordType.Name == "AP" && component.get("v.Iscommunity") == false){
                        component.set("v.Spinner", false);
                        component.set("v.showMessage", false);
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: '',
                            message: 'You cannot create Next Payment Application for Vendor Created Payment Application',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                            mode: "pester",
                        });
                        toastEvent.fire();
                    }
                    else if(resultData.payment.buildertek__SOV_Payment_Application__r.buildertek__Status__c != "Customer Accepted" && component.get("v.Iscommunity") == false){
                        var IsCommunity = component.get("v.Iscommunity")
                        console.log('IsCommunity ==> ',{IsCommunity});
                        component.set("v.Spinner", false);
                        component.set("v.showMessage", false);
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: '',
                            // message: 'You cannot create another Payment Application until this Payment Application is Customer Accepted',
                            message: 'You have an existing Payment Application that is Pending for this Project.  You cannot create a new Payment Application until all Payment Apps are Customer Approved.',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                            mode: "pester",
                        });
                        toastEvent.fire();
                    }
                else if(resultData.payment.buildertek__SOV_Payment_Application__r.buildertek__Status__c != "Company Accepted" && component.get("v.Iscommunity") == true){
                        component.set("v.Spinner", false);
                        component.set("v.showMessage", false);
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: '',
                            message: 'You cannot create another Payment Application until this Payment Application is Company Accepted',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                            mode: "pester",
                        });
                        toastEvent.fire();
                }else if(resultData.isAllVendorAppsApproved == false){
                     component.set("v.Spinner", false);
                        component.set("v.showMessage", false);
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: '',
                            message: 'Please Approve all the Vendor Payment Apps before Creating Next Payment App.',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                            mode: "pester",
                        });
                        toastEvent.fire();
                }
                        else{
                            component.set("v.IsSubmitted",false);
                            var action = component.get("c.cloneAnySobjet");
                            action.setParams({"recordId": component.get("v.recordId")});
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if(state === "SUCCESS") {
                                    component.set("v.Spinner", false);
                                    component.set("v.showMessage", false);
                                    var action1 = component.get("c.updateClonedRecord");
                                    action1.setParams({"recordId": component.get("v.recordId"),
                                                       "newRecId": response.getReturnValue()
                                                      });
                                 /*   action1.setCallback(this, function(response) {
                                        
                                    }); */
                                    $A.enqueueAction(action1);
                                    
                                    
                                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                                    sObjectEvent.setParams({
                                        "recordId": response.getReturnValue(),
                                        //"objectAPIName" : "buildertek__SOV_Payment_Application__c",
                                        "slideDevName": "detail"
                                    });
                                    sObjectEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire()
                                    
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title : 'Success',
                                        message: 'Successfully Cloned The Payment Application',
                                        duration:' 5000',
                                        key: 'info_alt',
                                        type: 'success',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();
                                    
                                    //$A.get("e.force:closeQuickAction").fire();
                                }else if (state === "ERROR"){
                                    var resultData = response.getReturnValue();
                                    var errors = response.getError();
                                    if(errors) {
                                        component.set("v.errorMsg", errors[0].message);
                                        var errorMsg = component.find('errorMsg');
                                        $A.util.removeClass(errorMsg, 'slds-hide');
                                        var field = component.find('field');
                                        $A.util.addClass(field, 'slds-hide');
                                    }
                                }
                            });
                            $A.enqueueAction(action);
                        }
            }
        });
        $A.enqueueAction(action);
    },
    
})