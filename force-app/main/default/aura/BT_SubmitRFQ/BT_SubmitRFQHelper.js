({
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
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "Success",
                    "message": "RFQ is Submitted.",
                });
                
                location.reload()
            }
        });
        $A.enqueueAction(action);
    },
    getrfq : function(component, event, helper){
       // alert("helo");
        var recordId = component.get("v.recordId");
        var action = component.get("c.getrfq");
        action.setParams({
            RecordId: recordId
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var rfqid = response.getReturnValue();
                component.set("v.rfqrecordId", rfqid);
            } 
        });
        $A.enqueueAction(action);
    },
     
    
    rfqsubmit : function(component, event, helper){
       // alert("hai");
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
                        if(result == "Quote Submitted"){
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
                        }else if(result == "Email Sent"){
                             //component.set("v.isRFQsubmitted",true);
                             component.set("v.SubmitRFQ", true);
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
                            helper.getprojectRecord(component, event, helper);
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
})