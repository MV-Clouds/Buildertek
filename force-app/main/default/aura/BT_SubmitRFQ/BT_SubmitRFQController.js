({
    doInit : function(component, event, helper) {
       //  component.set("v.SubmitRFQ", true);
        /*var action = component.get("c.insertProjects");
        action.setParams({
            rfqid : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var fieldname = response.getReturnValue();
            if(fieldname.buildertek__Stage__c == 'Completed'){
                $A.get("e.force:closeQuickAction").fire();
                component.find('notifLib').showNotice({
                    "variant": "Error",
                    "header": "Error",
                    "message": "RFQ is  already Submited.",
                });
            } else{
                helper.getprojectRecord(component, event, helper);
            }
        });
        $A.enqueueAction(action);*/
       // alert("hai");
        var action = component.get("c.checkduedate");
        action.setParams({ 
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                if(result.RFQStatus == 'Awarded'  ){
                     $A.get("e.force:closeQuickAction").fire();
                    component.set("v.isduedate",false);
                    $A.get("e.force:closeQuickAction").fire();
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You cannot Submit an RFQ that has already been Awarded.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire(); 
                    
                    $A.get("e.force:closeQuickAction").fire();
                }else if(result.RFQStatus == 'Accepted'){
                     $A.get("e.force:closeQuickAction").fire();
                    component.set("v.isduedate",false);
                    $A.get("e.force:closeQuickAction").fire();
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You cannot Submit an RFQ that has already been Accepted.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire(); 
                    
                    $A.get("e.force:closeQuickAction").fire();
                
                }else if(result.isdueexp == true){
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.isduedate",false);
                    $A.get("e.force:closeQuickAction").fire();
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You cannot submit this RFQ because the Due Date has passed. If you would still like to submit this RFQ, please contact your system administrator.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire(); 
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    component.set("v.isduedate",false);
                    if(component.get("v.isduedate") == false){
                        var action2 = component.get("c.validateRFIs");
                        action2.setParams({
                            RecordId : component.get("v.recordId")
                        });
                        action2.setCallback(this, function (response) {
                            var status = response.getReturnValue();
                            //alert(status);
                            if(status == 'RFIs Not Closed'){
                                component.set("v.RFIsClosed",false);
                                $A.get("e.force:closeQuickAction").fire();
                                component.find('notifLib').showNotice({
                                    "variant": "Error",
                                    "header": "Error",
                                    "message": " You must close all RFI's before submitting this RFQ.",
                                    // "message": "All RFI's should be closed before submitting the RFQ.",
                                });
                            } else if(status == 'RFIs Closed'){ 
                                component.set("v.RFIsClosed",true);
                                
                                var action1 = component.get("c.getRQToAccount");
                                action1.setParams({
                                    recordId: component.get("v.recordId"),
                                });
                                action1.setCallback(this, function (response) {
                                    if(response.getState() === "SUCCESS"){
                                        var result = response.getReturnValue();
                                        if(result.buildertek__Status__c == "Quote Submitted"){
                                            // $A.get('e.force:refreshView').fire();
                                            $A.get("e.force:closeQuickAction").fire();
                                            var showToast = $A.get( "e.force:showToast" );   
                                            showToast.setParams({   
                                                title : "Error!",
                                                message : "This RFQ is already Submitted.",
                                                type: 'error',
                                                duration: '1000',
                                                key: 'info_alt',
                                                mode: 'pester'
                                            });   
                                            showToast.fire();
                                        }else if(result.buildertek__Status__c == "Email Sent" || (result.buildertek__Status__c == "Rejected" &&
                                                               result.buildertek__RFQ__r.buildertek__Status__c != "Canceled")){
                                             component.set("v.SubmitRFQ", true);
                                           // component.set("v.SubmitRFQ",true);
                                            /*var action = component.get("c.getobjectName");
                            action.setParams({
                                recordId: component.get("v.recordId"),
                            });
                            action.setCallback(this, function (response) {
                                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                                    var objName = response.getReturnValue();
                                    if(objName == 'buildertek__RFQ__c'){
                                        component.set("v.rfqrecordId", recordId);
                                        helper.getprojectRecord(component, event, helper);
                                    }else if(objName == 'buildertek__RFQ_To_Vendor__c'){
                                        var recordId = component.get("v.recordId")
                                        var action = component.get("c.getrfq");
                                        action.setParams({
                                            RecordId: recordId
                                        });
                                        action.setCallback(this, function (response) {
                                            if (response.getState() == 'SUCCESS') {
                                                var rfqid = response.getReturnValue();
                                                component.set("v.rfqrecordId", rfqid);
                                                helper.getprojectRecord(component, event, helper);
                                            } 
                                        });
                                        $A.enqueueAction(action);
                                    }
                                } 
                            });
                            $A.enqueueAction(action);*/
                           // helper.getprojectRecord(component, event, helper);
                        }else{
                            $A.get("e.force:closeQuickAction").fire();
                            var showToast = $A.get( "e.force:showToast" );   
                            showToast.setParams({   
                                title : "Error!",
                                message : "This RFQ is already Submitted.",
                                type: 'error',
                                duration: '1000',
                                key: 'info_alt',
                                mode: 'pester'
                            });   
                            showToast.fire();
                        }
                    }
                });
                $A.enqueueAction(action1);
            }
        });
                           $A.enqueueAction(action2);
                       }
                    
                }
            }     
        });
        $A.enqueueAction(action);
    },
    
     cancelSubmit : function(component, event, helper){
         // alert("haii");
           component.set("v.SubmitRFQ", false);
           $A.get("e.force:closeQuickAction").fire();
          
      },
    
      getprojectRecord : function(component, event, helper){
       // alert("hai");
        // component.set("v.isRFQsubmitted",true);
        var action = component.get("c.UpdateRFQ");
        action.setParams({
            rfqid : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                //alert("2");
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                 var showToast = $A.get( "e.force:showToast" );   
                                            showToast.setParams({   
                                                title : "Success",
                                                message : " RFQ is Submitted Successfully.",
                                                type: 'Success',
                                                duration: '1000',
                                                key: 'info_alt',
                                                mode: 'pester'
                                            });   
                                            showToast.fire();
              /*  component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "Success",
                    "message": "RFQ is Submitted.",
                });*/
                
                location.reload()
            }
        });
        $A.enqueueAction(action);
    },
})