({
    doInit : function(component, event, helper) {
        debugger;
        var action1 = component.get("c.getRFQStatus");
        action1.setParams({
            recordId : component.get("v.recordId")    
        });
        action1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.buildertek__RFQ__r.buildertek__Status__c == 'Awarded'){
                    if(result.buildertek__Status__c == 'Awarded'){
                        component.set("v.IsAwarded", true);
                         component.set("v.isalreadyawarded", false); 
                         component.set("v.isalreadyaccepted", false); 
                    }else{
                       component.set("v.IsAwarded", false); 
                       component.set("v.isalreadyawarded", true); 
                        component.set("v.isalreadyaccepted", false); 
                    }
                }
                 var action3 = component.get("c.getRQToAccount");
                      //  var loggedInVendor = component.get("v.Vendorname");
                        action3.setParams({
                            recordId : component.get("v.recordId")
                        });
                        action3.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                var result = response.getReturnValue();
                                //alert('&&'+JSON.stringify(result));
                                if(result == "Accepted"){
                                    component.set("v.isRFQAccepted",true);
                                }else if(result == "Rejected"){
                                    component.set("v.isRFQRejected",true);
                                        component.set("v.IsAwarded", false);
                                       // setTimeout(() => {
                                            
                                            //component.set("v.isRFQRejected", false);    
                                       // }, 500);
                                    }else{
                                    debugger;
                                    var action4 = component.get("c.getrejectMessage");
                                   // var loggedInVendor = component.get("v.Vendorname");
                                    action4.setParams({
                                        recordId : component.get("v.recordId")
                                    });
                                    action4.setCallback(this, function(response){
                                        if(response.getState() === "SUCCESS"){
                                            var result = response.getReturnValue();
                                            if(result.buildertek__RFQ__r.buildertek__Status__c == 'Accepted'){
                                                 component.set("v.isAnotherVendor",true);
                                            }else if(result.buildertek__RFQ__r.buildertek__Status__c == 'Canceled'){
                                                 component.set("v.isRFQRejectedbyanthoervendor",true);
                                            }/*else{
                                                alert('hi');
                                                component.set("v.isalreadyaccepted",true);
                                            }*/
                                        }
                                    });
                                    $A.enqueueAction(action4);
                                }
                            }
                        });
                $A.enqueueAction(action3);
            }
        })
        $A.enqueueAction(action1);
    },
    rejectRFQ: function (component, event, helper) {
        var action = component.get("c.checkduedate");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == true){
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You can not Reject this RFQ , because the Due Date of this RFQ is expired. Please Contact System Administrate.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire(); 
                }else{
                  component.set("v.rejectPopUp",true);
                }
            }     
        });
        $A.enqueueAction(action);
    },
    acceptRFQ: function (component, event, helper) {
        var action = component.get("c.checkduedate");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == true){
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You can not Accept this RFQ , because the Due Date of this RFQ is expired. Please Contact System Administrate.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire(); 
                }else{
                   component.set("v.acceptPopUp",true);
                }
            }         
        });
        $A.enqueueAction(action);
    },
    cancelSubmit: function (component, event, helper) {
        component.set("v.rejectPopUp",false);
        component.set("v.acceptPopUp",false);
    },    
    confirmAccept: function (component, event, helper) {
        component.set("v.acceptPopUp",false);
        component.set("v.loaded", true);
       // var loggedInVendor = component.get("v.Vendorname");
        var action = component.get("c.acceptrfqAndChild");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'RFQ has been Accepted Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }     
            component.set("v.loaded", false);
        });
        $A.enqueueAction(action);
    },
      confirmReject: function (component, event, helper) {
        component.set("v.rejectPopUp",false);
        component.set("v.loaded", true);
        var action = component.get("c.rejectRfq");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                
                 $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'RFQ has been Canceled Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }     
            component.set("v.loaded", true);
        });
        $A.enqueueAction(action);
    },
})