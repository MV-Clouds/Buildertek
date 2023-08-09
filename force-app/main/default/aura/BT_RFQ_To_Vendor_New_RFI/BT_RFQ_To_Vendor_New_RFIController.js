({
    doInit: function (component, event, helper) {
        
        var rfqtovendorrecaction = component.get("c.getRFQtovendorrec");
        rfqtovendorrecaction.setParams({
            recordId : component.get("v.recordId")
        })
        rfqtovendorrecaction.setCallback(this, function (response) {
            var result =   response.getReturnValue();
            //alert('ew');
            console.log(result);
            //alert(result.buildertek__Status__c);
            if(result.buildertek__Status__c=='Quote Submitted'){
                component.set("v.isRFQsubmitted",true);
                component.set("v.showpopup",false);
                $A.get("e.force:closeQuickAction").fire();
                var showToast = $A.get( "e.force:showToast" );   
                showToast.setParams({   
                    title : "Error!",
                    message : "You cannot submit RFI because this RFQ is already submitted.",
                    type: 'error',
                    duration: '1000',
                    key: 'info_alt',
                    mode: 'pester'
                });   
                showToast.fire();
            }else if(result.buildertek__RFQ__c){
                if(result.buildertek__RFQ__r.buildertek__Status__c == 'Accepted' || 
                   result.buildertek__RFQ__r.buildertek__Status__c == 'Awarded' ||
                   result.buildertek__RFQ__r.buildertek__Status__c == 'Canceled'){
                    component.set("v.showpopup",false);
                    $A.get("e.force:closeQuickAction").fire();
                    var showToast = $A.get( "e.force:showToast" );   
                    showToast.setParams({   
                        title : "Error!",
                        message : "You cannot create new RFI because the RFQ is already "+result.buildertek__RFQ__r.buildertek__Status__c+".",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });   
                    showToast.fire();
                }else{
                    component.set("v.showpopup",true);
                }
            }else{
                component.set("v.showpopup",true);
            }       
            
        })
        $A.enqueueAction(rfqtovendorrecaction);
        
        
        var rfqtovendoraction = component.get("c.getRFQFromRFQToVendor");
        rfqtovendoraction.setParams({
            recordId : component.get("v.recordId")
        })
        rfqtovendoraction.setCallback(this, function (response) {
            var fieldSetObj =  JSON.stringify(response.getReturnValue());
            // alert(fieldSetObj);
            component.set("v.rfq_Id", fieldSetObj);
            
            
        })
        $A.enqueueAction(rfqtovendoraction);
        
        
        var action = component.get("c.getFieldSet");
        var recordid=component.get("v.projRecordId");
        action.setParams({
            sObjectName : "buildertek__RFI__c",
            fieldSetName  : "buildertek__New_RFI_Community_Field_Set",
            parentRecordId : component.get("v.rfq_Id")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            var listofchange = component.get("v.fieldSetValues");
            var collist = [];
            for (var i = 0; i < listofchange.length; i++) {
                if(listofchange[i].name != 'Name' && listofchange[i].name != 'buildertek__Assigned_To__c' 
                   && listofchange[i].name != 'OwnerId' && listofchange[i].name != 'buildertek__Status__c'){
                    collist.push(listofchange[i]);
                }
                component.set("v.fieldSetValues",collist);
            }
        })
        $A.enqueueAction(action);
        var recId = component.get("v.recordId");
        //alert('Vendor id ----------'+recId);
        var rfqaction = component.get("c.getrfqdetailsecord"); 
        rfqaction.setParams({
            recId :  component.get("v.recordId")
        })
        rfqaction.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert(JSON.stringify(fieldSetObj.rfqrec.id));
            component.set("v.rfqrec", fieldSetObj.rfqrec); 
            component.set("v.rfq_Id",fieldSetObj.rfqrec.Id);
            
        })
        $A.enqueueAction(rfqaction);
        
        
        
        var action2 = component.get("c.getcontact");
        action2.setCallback(this, function (response) {
            var getcon = response.getReturnValue();
            component.set("v.contactid", response.getReturnValue());
        })
        $A.enqueueAction(action2);
        
        
        
        
        
        var action3 = component.get("c.fetchUser1");
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse.Id);
                component.set("v.userdata",storeResponse);
                //alert(component.get("v.userInfo"));
                //alert(component.get("v.userdata"));
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
        var rfqrec = component.get("v.rfqrec");
        var userdata = component.get("v.userdata");
        
        console.log('username'+username);
        console.log('project'+project); 
        console.log('queVal'+queVal);
        console.log('rfqrec'+rfqrec);
        console.log('before submit');
        //alert(component.get("v.contactid"));
        
        // alert('queVal'+queVal);
        /*if(project != null){
            fields["buildertek__Project__c"] = project;
        }*/
        //fields["buildertek__Vendor_Account__c"] = userdata.AccountId;
        fields.buildertek__RFQ__c = rfqrec.Id;
        fields.buildertek__Status__c = 'RFI Sent';
        //fields.buildertek__Assigned_To__c = component.get("v.contactid");
        fields.buildertek__Submitted_By__c = username;
        fields.buildertek__RFI_Assigned_To__c = rfqrec.buildertek__RFI_Owner__c;  
        fields.buildertek__RFQ_To_Vendor__c = component.get("v.recordId");
        //alert(fields["buildertek__RFQ_To_Vendor__c"]); 
        //alert(component.get("v.recordId"));
        ////alert(fields["buildertek__Vendor_Account__c"]);
        //alert(rfqrec.OwnerId);
        /* if(queVal != null){
            fields.buildertek__Status__c = queVal; 
         }*/
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
        console.log('after submit');
    },
    
    onRecordSuccess: function (component, event, helper) {
        //alert(JSON.stringify(component.get("v.selectedFiles")));
        console.log('onRecordSuccess');
        /*var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));*/
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        component.set('v.rfiId',eventId);
        
        
        var newresponserecid = payload.id;
        helper.SendEmailstoQueue(component,newresponserecid);
        if(component.get('v.uploadedFileIds').length > 0){
            helper.copyfilesHelper(component,newresponserecid);
        }else{
            debugger;
            helper.showMessage('RFI created successfully',true);
            
            
            component.set("v.IsSpinner",false);
            var navEvt = $A.get("e.force:navigateToSObject");
           // alert('newresponserecid----'+newresponserecid);
            navEvt.setParams({
                "recordId": newresponserecid,
                "slideDevName": "related"
            });
            navEvt.fire();
            
            //location.reload();
        }
        component.set("v.selectedUsers",[])
        component.set("v.newRFIResponse", newRec.Id);
        
        
        helper.sendEmail(component, event, helper);
        component.set("v.IsSpinner",false);
        
        var fileInput = component.find("fuploader").get("v.files");
        if(fileInput != null){
            //helper.uploadHelper(component, event, helper);
        } 
        
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : "Success!",
            message : 'RFI created successfully',
            type: 'success',
            duration: '10000',
            key: 'info_alt',
            mode: 'pester'
        });
        toastEvent.fire(); 
        
        var dateSent = component.get("c.updateDateOriginalSent");
        dateSent.setParams({
            newRFIId :eventId
        })
        dateSent.setCallback(this, function(response) {
            var state = response.getState();
            var getRFI = response.getReturnValue();
            if (state === "SUCCESS") {
                //alert('getRFI   '+getRFI);
                
            }
        });
        $A.enqueueAction(dateSent);
        
    },
    closeModel: function (component, event, helper) {
           var action = component.get("c.deleteFile");
        //alert(component.get("v.recordId"));
        action.setParams( { 
            RecordId : component.get("v.recordId"),
            fileIds: component.get('v.uploadedFileIds')
        }); 
        action.setCallback(this, function(actionResult) {
            
            var state = response.getState();
            if(state == 'SUCCESS'){
               var fieldSetObj = response.getReturnValue(); 
                component.set("v.Isfileuploaded",false);
            }
            
        });
        if(component.get("v.Isfileuploaded") == true){
            $A.enqueueAction(action);
        }
        
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';                    
        component.set("v.selectedfileslist",event.getSource().get("v.files"));   
        var fileCount=event.getSource().get("v.files").length;
        var files='';
        var mapData = [];
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) 
            {
                fileName = event.getSource().get("v.files")[i]["name"];
                var obj = {};
                obj['Name'] = fileName;                
                if(i == 0){
                    files=fileName;    
                }else{
                    files=files+','+fileName;
                }
                mapData.push(obj);                
            }
        }
        else
        {
            files=fileName;
        }
        component.set("v.selectedfilesFill",mapData);
    },
    uploadFileadd : function(component, event, helper) {
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
                
                
                // function for clear the Record Selaction 
                clear :function(component,event,heplper){
                var selectedPillId = event.getSource().get("v.name");
                var AllPillsList = component.get("v.selectedfilesFill"); 
                
                for(var i = 0; i < AllPillsList.length; i++){
                if(AllPillsList[i].Name == selectedPillId){
            AllPillsList.splice(i, 1);
            component.set("v.selectedfilesFill", AllPillsList);
        }  
    }
},      
 handleUploadFinished: function (component, event) {
    // Get the list of uploaded files
    var uploadedFiles = event.getParam("files");
    var fileIds = [];
    
    var mapData = [];
    var files='';
    for (var i = 0; i < uploadedFiles.length; i++) { 
        //alert(JSON.stringify(uploadedFiles[i]));
        console.log(JSON.stringify(uploadedFiles[i]));
        fileIds.push(uploadedFiles[i]["contentVersionId"]);
        var fileName  =  uploadedFiles[i]["name"]; 
        //alert(fileName); 
        var obj = {};
        obj['Name'] = fileName;                
        if(i == 0){
            files=fileName;    
        }else{
            files=files+','+fileName;
        }
        mapData.push(obj);
        //alert(uploadedFiles[i]["name"]);
        //alert(uploadedFiles[i]["documentId"]);
        //alert(uploadedFiles[i]["contentVersionId"]);
    }
    component.set('v.uploadedFileIds',fileIds);
    component.set("v.selectedfilesFill",mapData);                 
    //alert(JSON.stringify(component.get('v.uploadedFileIds')));
    
    
    
    
    // show success message – with no of files uploaded
    var toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
        "title": "Success!",
        "type" : "success",
        "message": uploadedFiles.length+" files has been uploaded successfully!"
    });
    toastEvent.fire();
    component.set("v.Isfileuploaded",true);
    //$A.get('e.force:refreshView').fire();
    
    // Close the action panel
    //var dismissActionPanel = $A.get('e.force:closeQuickAction');
    //dismissActionPanel.fire();
},
    
    
    
    sendResponse:function(component, event, helper) {
        
        var RRId=component.get("v.CMPId");
        // alert("Response --------"+RRId);
        var file1=component.get("v.selectedFiles");
        //alert('file1'+file1);
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        var rfiid=component.get("v.recordId");
        //var recId = component.get("v.recordId");
        var username = component.get("v.userInfo");
        var varresponse = component.get("v.templateBody");
        
        if(component.get("v.Isnewrfiresponse")==true){
            users=[];
            cons=[];
        }        
        if(varresponse !=''){ 
            component.set("v.IsSpinner",true);
            component.set("v.openResponseModel",false); 
            
            var responseaction = component.get("c.createRFIResponse1");
            responseaction.setParams({
                rfiRecId:component.get("v.recordId"),
                userId:username,
                response:varresponse,           
                selectedUsers:users,
                selectedContacts:cons,
                selectedFiles: component.get("v.selectedFiles") ,
                parentId:RRId
            })
            responseaction.setCallback(this, function (response) {
                var state = response.getState();
                //alert('state  '+state);
                var newRec=response.getReturnValue();
                //alert('new RFI Response *******  '+newRec.Id);
                if (state === "SUCCESS") {
                    //component.set("v.IsSpinner",false);
                    var newresponserecid = newRec.Id;
                    /*//alert(newresponserecid);
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : "Success!",
                        message : 'RFI Response created successfully',
                        type: 'success',
                        duration: '10000',
                        key: 'info_alt',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    helper.uploadHelper(component, event, newresponserecid,helper);
                    
                    //alert(component.find("fuploader1"));   
                    /*if (component.find("fuploader").get("v.files") != undefined) {
                        if(component.find("fuploader").get("v.files").length > 0){
                            //alert(newresponserecid);
                            helper.uploadHelper(component, event, newresponserecid,helper);
                             
                        }
                    }*/
                    
                    
                    /*component.set("v.newRFIResponse", newRec.Id);*/ 
                    //alert(component.get("v.newRFIResponse"));
                    if(component.get('v.uploadedFileIds').length > 0){
                        helper.copyfilesHelper(component,newresponserecid);
                    }else{
                        helper.showMessage('RFI Response created successfully',true);
                        
                        
                        component.set("v.IsSpinner",false);
                        
                        //location.reload();
                    }
                    component.set("v.selectedUsers",[])
                    component.set("v.newRFIResponse", newRec.Id);
                    
                    
                    
                }else{
                    // component.set("v.IsSpinner",false);
                    // alert('Error         ');
                }
            })
            
            $A.enqueueAction(responseaction);
            
            /*var action = component.get("c.getrfiresponselists");
            action.setParams({
                parentRecordId : component.get("v.recordId")
            })
            action.setCallback(this, function (response) {
                var fieldSetObj = response.getReturnValue();
                // alert(fieldSetObj);
                
                component.set("v.rfiList",fieldSetObj);
            })
            $A.enqueueAction(action);*/
        }else{
            component.set("v.IsSpinner",false);
            component.set("v.errorMSG", true);
            // alert("Error");
        }
    },
        
        
        
        
})