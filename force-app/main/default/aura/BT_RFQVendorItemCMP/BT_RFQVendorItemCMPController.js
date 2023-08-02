({
    doInit: function(component, event, helper) {
        var action1 = component.get("c.getobjectName");
            action1.setParams({
                recordId: component.get("v.recordId"),
            });
            action1.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    if(objName == 'buildertek__RFQ__c'){
                        var recordId = component.get("v.recordId");
                        component.set("v.rfqrecordId", recordId);
                        helper.getrelatedrfqvendorlist(component, event, helper);
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
                                 helper.getrelatedrfqvendorlist(component, event, helper);
                            } 
                        });
                        $A.enqueueAction(action);
                    }
                } 
            });
        $A.enqueueAction(action1);
        var action2 = component.get("c.getrfqfiles");
            action2.setParams({
                recordId: component.get("v.recordId"),
            });
            action2.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var result = response.getReturnValue();
                    component.set("v.rfqfiles",result);
                } 
            });
        $A.enqueueAction(action2);
        /* var action3 = component.get("c.getvendorlines");
            action3.setParams({
                recordId: component.get("v.recordId"),
            });
            action3.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var result = response.getReturnValue();
                    component.set("v.rfqfiles",result);
                } 
            });
        $A.enqueueAction(action3);*/
    },

    onSave : function( component, event, helper ) {   
          
        var updatedRecords = component.find( "itemsTable" ).get( "v.draftValues" );  
        //alert('hi');
        //alert(updatedRecords);
        //alert(JSON.stringify(updatedRecords));
        //alert(JSON.stringify(component.get("v.UpdatedList")));
        var action = component.get( "c.updateVendorItems" );  
        action.setParams({  
            'updatedItemsList' : updatedRecords  
        });  
        action.setCallback( this, function( response ) {  
            var state = response.getState();  
            //alert(state); 
            //alert(response.getReturnValue()); 
            if ( state === "SUCCESS" ) {  
  
                if ( response.getReturnValue() === true ) {  
                      
                    helper.toastMsg( 'success', 'Records Saved Successfully.' );  
                    //component.find( "itemsTable" ).set( "v.draftValues", null );  
                    location.reload();
                } else {   
                      
                    helper.toastMsg( 'error', 'Something went wrong. Contact your system administrator.' );  
                      
                }  
                  
            } else {  
                  
                helper.toastMsg( 'error', 'Something went wrong. Contact your system administrator.' );  
                  
            }  
              
        });  
        $A.enqueueAction( action );  
          
    },
    canceldeletescreen :function(component, event, helper) {
        component.set("v.isdelete", false);
    },
    deleteline :function(component, event, helper) {
       var action = component.get( "c.DeleteVendorItems" );  
               action.setParams({  
                   "recordId": component.get("v.isdeleterecoedid")
               });  
               action.setCallback( this, function( response ) {  
                   var state = response.getState();  
                   if ( state === "SUCCESS" ) {  
                       helper.toastMsg( 'success', 'Selected RFQ line is Deleted Successfully.' ); 
                       component.set("v.isdelete", false);
                       location.reload();
                   } 
               });  
               $A.enqueueAction( action ); 
    },
    viewRecord : function(component, event, helper) {
        var recId = event.getParam('row').Id;
        var actionName = event.getParam('action').name;
       if (actionName == 'Delete') {
           component.set("v.isdelete", true);
           component.set("v.isdeleterecoedid", recId);
      /* var action = component.get( "c.DeleteVendorItems" );  
        action.setParams({  
             "recordId": recId
        });  
        action.setCallback( this, function( response ) {  
            var state = response.getState();  
            if ( state === "SUCCESS" ) {  
                    helper.toastMsg( 'success', 'Records Deleted Successfully.' );  
                    location.reload();
            } 
        });  
        $A.enqueueAction( action );*/
           /* var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId": recId
            });
            editRecordEvent.fire();*/
        } 
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.showPopup", true);
     },
     
     closefilesModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.Isfiles", false);
        component.set("v.Isrfqfiles", false);
     },
     
     closenofilesModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.Isnofiles", false);
     },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.showPopup", false);
     },
    

    handleSubmit: function(component, event, helper) {
        //alert('handleSubmit');            
        var fields = event.getParam('fields');
        //alert( JSON.stringify(fields));
        fields.buildertek__Vendor__c = component.get("v.rfqtovendorId");
        fields.buildertek__isVendorRFQSubmited__c=true;
       // fields.buildertek__Unit_Price__c = component.get("v.rfqunitprice");
        // alert(component.get("v.rfqunitprice"));
        event.preventDefault();       // stop the form from submitting
        //alert(fields);
        //alert(fields["Name"]);
        //alert(fields["buildertek__Project__c"]);
        //alert(fields["buildertek__Status__c"]);
        component.find('recordEditForm').submit(fields);
    },

    handleSuccess : function(component,event,helper) {
        //alert('handleSuccess');
         var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        //alert(payload.id);
        helper.toastMsg( 'success', 'Vendor item created successfully.' );  
        component.set("v.showPopup",false);
        location.reload();
    },


    uploadFile : function(component, event, helper) {
        
        var recid= component.get("v.rfqtovendorId");
          
        
        $A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "Upload File",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_AddFiles", {
                    "mainObjectFieldAPI": component.get("v.objectAPI"),
                    "mainObjectId":recid,
                    "selectedFiles": component.get("v.selectedFiles"),
                    "onCancel":function(){
                        component.get('v.modalPromise').then(function (modal) {
                            modal.close();
                            //$A.enqueueAction(component.get("c.doInit"));
                        });
                    },
                    "onSuccess":function(file){
                        component.get('v.modalPromise').then(function (modal) {
                            modal.close();
                            //$A.enqueueAction(component.get("c.doInit"));
                        });
                        
                        //alert('file --------> '+file);
                        var selectedFiles = [];
                        for(var i=0; i<file.length; i++){
                            selectedFiles.push({
                                "Id" : file[i].Id,
                                "Name" : file[i].Name
                            });    
                        }
                        //alert('selectedFiles ---------> '+selectedFiles.length);
                        component.set("v.selectedFiles", selectedFiles);
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    var modalPromise = component.find('overlay').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer") ,
                        showCloseButton: true,
                        cssClass: '',
                        closeCallback: function() {
                            location.reload();
                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
    },
     viewrfqDocuments : function(component,event,helper) {
        var fileslist = component.get('v.rfqfiles');
        if(fileslist.length > 0){
            component.set("v.Isrfqfiles",true);
        }
     },
    
    viewDocuments : function(component,event,helper) {
        var fileslist = component.get('v.files');
            //alert('fileslist'+ fileslist.length);
        if(fileslist.length > 0){
            component.set("v.Isfiles",true);
            component.set("v.isrfi",false);
        }else{
            // component.set("v.Isnofiles",true);
            component.set("v.isrfi",false);
        }
       /* var recid= component.get("v.rfqtovendorId");
        var action = component.get("c.getContentDocs"); 
        action.setParams( { 
            arecordId : recid
        }); 
        action.setCallback(this, function(actionResult) {
            //alert(actionResult);
            component.set('v.files',actionResult.getReturnValue()); 
            var fileslist = component.get('v.files');
            //alert('fileslist'+ fileslist.length);
            if(fileslist.length > 0){
                component.set("v.Isfiles",true);
                component.set("v.isrfi",false);
            }else{
               // component.set("v.Isnofiles",true);
                component.set("v.isrfi",false);
            }
        }); 
        $A.enqueueAction(action);  */
        
    },
                
                
                


})