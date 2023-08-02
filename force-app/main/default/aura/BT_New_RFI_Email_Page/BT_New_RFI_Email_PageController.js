({
    doInit: function (component, event, helper) {
        //alert(component.get("v.rfqRecord"));
        var action = component.get("c.getFieldSet");
        var recordid=component.get("v.projRecordId");
        action.setParams({
            sObjectName : "buildertek__RFI__c",
            fieldSetName  : "buildertek__New_RFI_Community_Field_Set",
            parentRecordId : component.get("v.rfqRecord")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            var listofchange = component.get("v.fieldSetValues");
            var collist = [];
            for (var i = 0; i < listofchange.length; i++) {
                if(listofchange[i].name != 'Name' && listofchange[i].name != 'buildertek__Assigned_To__c' && listofchange[i].name != 'OwnerId'){
                    collist.push(listofchange[i]);
                }
                component.set("v.fieldSetValues",collist);
            }
        })
        $A.enqueueAction(action);
        //alert(component.get("v.rfqRecord"));
        var action1 = component.get("c.getproject");
        action1.setParams({
            projectId : component.get("v.recordId")
        })
        action1.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            component.set("v.parentprojectRecordId", fieldSetObj);
        })
        $A.enqueueAction(action1);
        var action2 = component.get("c.getcontact");
        action2.setCallback(this, function (response) {
            var getcon = response.getReturnValue();
            component.set("v.contactid", response.getReturnValue());
        })
        $A.enqueueAction(action2);
        var action3 = component.get("c.fetchUser");
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action3);
    },
    handleSubmit: function (component, event, helper) {
        // var getcon = '';
        component.set("v.IsSpinner",true);
        var username = component.get("v.userInfo");
        var fields = event.getParam("fields");
        var project = component.get('v.parentprojectRecordId');
        var queVal = component.get('v.question');
        //alert('queVal'+queVal);
        //alert('project'+project);
        //alert('rfq'+component.get("v.recordId"));
        //alert('contactid'+component.get("v.contactid"));
        //alert('contact'+component.get("v.contact"));
        if(project != null){
            fields["buildertek__Project__c"] = project;
        }
        fields.buildertek__RFQ__c = component.get("v.recordId");
        fields.buildertek__Status__c = 'RFI Sent';
        fields.buildertek__Assigned_To__c = component.get("v.contactid");
        fields.buildertek__Submitted_By__c = username;
        // alert(fields["buildertek__Subject__c"]);
        /* if(queVal != null){
            fields.buildertek__Status__c = queVal; 
         }*/
         event.preventDefault(); // Prevent default submit
         //component.find('recordViewForm').submit(fields); // Submit form      
         //buildertek__RFI_Assigned_To__c
         var action = component.get("c.saveNewRFI");
         action.setParams({
             recId : component.get("v.recordId"),
             assignedTo :  component.get("v.contactid"),
             submittedby : component.get("v.contact"),
             projectid : project,
             subject : fields["buildertek__Subject__c"],
             duedate : fields["buildertek__Due_Date__c"],
             contactname : component.get("v.contact"),
             rfiassignedto :  fields["buildertek__RFI_Assigned_To__c"]
             
         })
         action.setCallback(this, function (response) {
             var result =response.getReturnValue();             
             //alert(result);
             var msg = result.split('~')[0];
             var recid  = result.split('~')[1];
             alert(recid);
             component.set('v.rfiId',recid);
             
             component.set("v.successmodel",true);
             component.set("v.IsSpinner",false);
             
             
         })
         $A.enqueueAction(action); 
         
     },
    
    
    
    handleFilesChange: function(component, event, helper) {
        var fileName = "No File Selected..";
        for (var i = 0; i < event.getSource().get("v.files").length; i++) {
            if(fileName == "No File Selected.."){
                fileName = event.getSource().get("v.files")[i]['name'];
            } else{
                fileName = fileName+','+event.getSource().get("v.files")[i]['name'];
            }  
        }
        component.set("v.fileName", fileName);
    }, 
    closesuccessModal: function(component, event, helper) {
        component.set("v.successmodel", false);  
        
        
        //helper.sendEmail(component, event, helper);
        var fileInput = component.find("fuploader").get("v.files");
        if(fileInput != null){
            helper.uploadHelper(component, event, helper);
        } else{
            component.set("v.IsSpinner",false);            
        }
        // $A.get('e.force:refreshView').fire();
    },
    
   /* newRFIFunction : function(component, event, helper) {
        component.set("v.openNewRFIModal", true);  
        component.set("v.IsSpinner",false);
      //  $A.get('e.force:refreshView').fire();
    },*/
})