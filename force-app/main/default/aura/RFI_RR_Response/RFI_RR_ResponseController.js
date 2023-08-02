({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        //alert('response  '+recId);
        var action = component.get("c.getrfiRRRecord"); 
        action.setParams({
            parentRecordId : recId
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert('fieldSetObj   ----'+JSON.stringify(fieldSetObj));
            //alert(component.get("v.Isnewrfiresponse"));            
            if(fieldSetObj.buildertek__Responder__c!=null){
                component.set("v.ReplyTo",fieldSetObj.buildertek__Responder__r.Name);
                component.set("v.rfiId",fieldSetObj.buildertek__RFI__c);
            } 
           
        });
        $A.enqueueAction(action);        
        //alert();
        var rfiid=component.get("v.rfiId");
        // alert('rfiid------------------'+rfiid);
        var action = component.get("c.getRFQRec"); 
        action.setParams({
            rfiId : rfiid
        })
        action.setCallback(this, function (response) {
            var fieldSetObj2 = response.getReturnValue();
            var state = response.getState();
            //alert(component.get("v.Isnewrfiresponse"));            
            if (state === "SUCCESS") {
                component.set("v.rfqId",fieldSetObj2.Id);
                
            } 
        });
        $A.enqueueAction(action);
        
        var rfirecId=component.get("v.rfiId");
        //alert('rfi id   '+rfirecId);
        var action = component.get("c.getRecContacts");
        action.setParams({
            rfiId1 : rfirecId
        })
        action.setCallback(this, function (response) {
            var connames = JSON.stringify(response.getReturnValue());
            
         //   alert('connames'+connames);
            component.set("v.selectedContacts",connames);
        });
        $A.enqueueAction(action);
        var rfirecId=component.get("v.rfiId");
        // alert('rfirecId'+rfirecId);
        var action = component.get("c.getRecUsers");
        action.setParams({
            rfiId : rfirecId
        })
        action.setCallback(this, function (response) {
            var usernames = JSON.stringify(response.getReturnValue());
         //   alert('usernames'+usernames);
            component.set("v.selectedUsers",usernames);
        });
        $A.enqueueAction(action);
        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
        
        var useraction = component.get("c.getUser");
        useraction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                //alert(storeResponse);
                if(storeResponse == 'true'){
                    component.set("v.Isnewrfiresponse", true); 
                }else{
                    component.set("v.Isnewrfiresponse", false);
                }
            }
        });
        $A.enqueueAction(useraction); 
        
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName : "buildertek__RFI__c",
            fieldSetName  : "buildertek__New_RFI_Community_Field_Set",
            parentRecordId : component.get("v.rfiId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj); 
            var listofchange = component.get("v.fieldSetValues");
            var collist = [];
            for (var i = 0; i < listofchange.length; i++) {
                
                if(component.get("v.rfisettings") == true || component.get("v.rfisettings") == 'true'){
                    /*if(listofchange[i].name != 'buildertek__Assigned_To__c'){
                        collist.push(listofchange[i]);
                    }*/
                    if(listofchange[i].name != 'OwnerId' && listofchange[i].name != 'buildertek__Submitted_By__c' && listofchange[i].name != 'buildertek__Assigned_To__c'){
                        collist.push(listofchange[i]);
                    } 
                }else{
                    if(listofchange[i].name != 'buildertek__Submitted_By__c' && listofchange[i].name != 'buildertek__Submitted_By2__c' && listofchange[i].name != 'buildertek__Assigned_To__c'){
                        collist.push(listofchange[i]);
                    } 
                }
                
                component.set("v.showpopup",true);
                component.set("v.fieldSetValues",collist);
            }
        })
        $A.enqueueAction(action);
    },
    sendResponse:function(component, event, helper) {
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        var rfiid=component.get("v.rfiId");
        var recId = component.get("v.recordId");
        var username = component.get("v.userInfo");
        var varresponse = component.get("v.templateBody");
        // alert('response     '+varresponse);
        var action = component.get("c.createRFIResponse");
        action.setParams({
            rfiRecId:rfiid,
            userId:username,
            response:varresponse,
            parentId:recId,
            selectedUsers:users,
            selectedContacts:cons
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            var newRec=response.getReturnValue();
           // alert('new RFI Response *******  '+newRec.Id);
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success!",
                    message : 'RFI Response created successfully',
                    type: 'success',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
               component.set("v.newRFIResponse", newRec.Id); 
            //alert(component.get("v.newRFIResponse"));
            }
        })
        
        $A.enqueueAction(action);
        location.reload();
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
        var filename=  component.get("v.fileName");
        
    }, 
    uploadFile : function(component, event, helper) {
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
                    "mainObjectId": component.get("v.recordId"),
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
                            
                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
                },
                
                doCancel: function(component, event, helper) {
                //location.reload();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
               dismissActionPanel.fire();
                //component.set("v.showpopup",false);
                }
                })