({
    doInit : function(component, event, helper) {
        var rfiaction = component.get("c.getRFISettings");
        rfiaction.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.rfisettings", fieldSetObj);                      
           /* var rfisett=component.get("v.rfisettings");
            alert('rfisett      '+rfisett);*/
        })
        $A.enqueueAction(rfiaction);
        
         //component.set("v.showpopup",true);
        /*-------------- Get  User Record --------------------*/
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
      /*--------------------------------END-------------------------*/
        /* ------------ Get RFI Response Record ------------------- */
        var recId = component.get("v.recordId");
        var rfiaction = component.get("c.getrfidetailsecord"); 
        rfiaction.setParams({
            parentRecordId : recId
        })
        rfiaction.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert(fieldSetObj);
            component.set("v.rfiId",fieldSetObj.responserec.buildertek__RFI__c);
            var connames = JSON.stringify(fieldSetObj.contacts);            
            //alert('connames'+connames);
            component.set("v.selectedContacts",connames);

            var usernames = JSON.stringify(fieldSetObj.users);
            //alert('usernames'+usernames);
            component.set("v.selectedUsers",usernames);                        
            
            //alert('rfi assigned to'+fieldSetObj.rfirec.buildertek__RFI_Assigned_To__r.Name);
            
            //alert(component.get("v.rfisettings"));
            
            
            if(component.get("v.rfisettings")==false){
                if(component.get("v.Isnewrfiresponse")==true){
                    //alert('true');
                    if(fieldSetObj.rfirec.buildertek__RFI_Assigned_To__c!=null){
                        component.set("v.ReplyTo",fieldSetObj.rfirec.buildertek__RFI_Assigned_To__r.Name);
                    } 
                    
                }else{
                    //alert('false');
                    if(fieldSetObj.rfirec.buildertek__Submitted_By__c!=null){
                        component.set("v.ReplyTo",fieldSetObj.rfirec.buildertek__Submitted_By__r.Name);
                      //  alert(fieldSetObj.rfirec.buildertek__Submitted_By__r.Name);
                    }                      
                }
            }else if(component.get("v.rfisettings")==true){
                if(fieldSetObj.rfirec.buildertek__Submitted_By2__c!=null){
                    component.set("v.ReplyTo",fieldSetObj.rfirec.buildertek__Submitted_By2__r.Name);
                }   
            }
             
            // alert('fieldSetObj   ----'+JSON.stringify(fieldSetObj));
            // alert(component.get("v.Isnewrfiresponse"));            
            //component.set("v.rfiId",fieldSetObj.buildertek__RFI__c);
            /*if(fieldSetObj.buildertek__Responder__c!=null){
                component.set("v.ReplyTo",fieldSetObj.buildertek__Responder__r.Name);
                
            } */
            //alert('rfiid-----------------'+component.get("v.rfiId"));
            if(fieldSetObj.rfirec.buildertek__Status__c=='Closed'){
                //alert('true');
  				component.set("v.showpopup", false);   
                component.set("v.Isnewrfiresponse", false);
                $A.get("e.force:closeQuickAction").fire();
                var showToast = $A.get( "e.force:showToast" );   
                showToast.setParams({   
                    title : "Error!",
                    message : "You cannot respond to this RFI because this RFI is already Closed.",
                    type: 'error',
                    duration: '1000',
                    key: 'info_alt',
                    mode: 'pester'
                });   
                showToast.fire();
        }else{            
            //alert('false');
            component.set("v.showpopup",true);
        }
    
           // component.set("v.showpopup",true);
        });
        $A.enqueueAction(rfiaction);  
        
        
        //alert();
        /*--------------------------------Get RFQ ---------------------*/
        //var rfiid=component.get("v.rfiId");
        //alert('rfiid **********------------'+rfiid);
       /* var rfqaction = component.get("c.getRFQRec1"); 
        rfqaction.setParams({
            rfiIdr : rfiid
        })
        rfqaction.setCallback(this, function (response) {
            var fieldSetObj2 = response.getReturnValue();
            var state = response.getState();
            //alert(component.get("v.Isnewrfiresponse"));            
            if (state === "SUCCESS") {
                component.set("v.rfqId",fieldSetObj2.Id);
                
            } 
        });
        $A.enqueueAction(rfqaction);*/
       /*--------------------------------END-------------------------*/
        /*var rfirecId=component.get("v.rfiId");
        alert('RFI                  '+component.get("v.rfiId"));
        var conaction = component.get("c.getRecContacts");
        conaction.setParams({
            rfiId1 : rfirecId
        })
        conaction.setCallback(this, function (response) {
            var connames = JSON.stringify(response.getReturnValue());
            
           alert('connames'+connames);
            component.set("v.selectedContacts",connames);
        });
        $A.enqueueAction(conaction);
        var rfirecId=component.get("v.rfiId");
       // alert('rfirecId'+rfirecId);
        var useraction = component.get("c.getRecUsers");
        useraction.setParams({
            rfiId : rfirecId
        })
        useraction.setCallback(this, function (response) {
            var usernames = JSON.stringify(response.getReturnValue());
            alert('usernames'+usernames);
            component.set("v.selectedUsers",usernames);
        });
        $A.enqueueAction(useraction);*/
        
        var fuseraction = component.get("c.fetchUser");
        fuseraction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(fuseraction);
        
        
        
        /*var action = component.get("c.getFieldSet");
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
                    /*if(listofchange[i].name != 'OwnerId' && listofchange[i].name != 'buildertek__Submitted_By__c' && listofchange[i].name != 'buildertek__Assigned_To__c'){
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
        $A.enqueueAction(action);*/
    },
    handleSubmit: function (component, event, helper) {
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        //alert("Users Ids-------------"+JSON.stringify(users));
        //alert("Contact Ids-----------"+JSON.stringify(cons));
        //alert(users.length);
        //alert(cons.length);
        var username = component.get("v.userInfo");
        component.set("v.IsSpinner",true);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        //alert('today'+today);
        //component.set('v.today', today);
        // var parentid = component.get("v.parentrfiresponseId");
        var parentresponseId = component.get("v.recordId");
        var fields = event.getParam("fields");
        var rfiid = component.get("v.rfiId"); 
        // parentid = rfiid;
        //alert('parentid-->'+parentid);
        fields.buildertek__RFI__c = rfiid;
        fields.buildertek__Response_Date__c = today;
        fields.buildertek__Responder__c = username;
        fields.buildertek__Parent__c = parentresponseId;
        /*if(users.length>0 || cons.length>0 ){
        	fields.buildertek__Show_In_Community__c = false;     
        } */       
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
    },
    onRecordSuccess: function (component, event, helper) {
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        component.set('v.rfiresponseId',eventId);
        var action = component.get("c.updateRFQ");
        //  var recordid=component.get("v.projRecordId");
        action.setParams({
            RecordId : component.get("v.recordId"),
            selectedUsers:component.get("v.selectedUsers"),
            selectedContacts:component.get("v.selectedContacts")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
        })
        
        var fileInput = component.find("fuploader").get("v.files");
        if(fileInput != null){
            helper.uploadHelper(component, event, helper);
            helper.getrfirecords(component, event, helper);
        } else{
            component.set("v.IsSpinner",false);
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
            
            helper.getrfirecords(component, event, helper);
            //$A.enqueueAction(component.get("c.expandCollapseGroups"));
            /* var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.recordId'),
                "slideDevName": "related"
            });
            navEvt.fire();*/
        }
        location.reload();
        $A.enqueueAction(action);
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
    
    doCancel: function(component, event, helper) {
        debugger;
        console.log(component.get("v.recordId"))
        //location.reload();
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
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        component.set("v.templateBody", '');
         component.set("v.selectedFiles", '');
    },
    sendResponse:function(component, event, helper) {
        component.set("v.IsSpinner",true);
         var file1=component.get("v.selectedFiles");
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        var rfiid=component.get("v.rfiId");
        var recId = component.get("v.recordId");
        var username = component.get("v.userInfo");
        var varresponse = component.get("v.templateBody");
        
        if(component.get("v.Isnewrfiresponse")==true){
            users=[];
            cons=[];
        }        
        if(varresponse !=''){ 
             component.set("v.IsSpinner",true);
            var action = component.get("c.createRFIResponse1");
            action.setParams({
                rfiRecId:rfiid,
            userId:username,
            response:varresponse,           
            selectedUsers:users,
            selectedContacts:cons,
            selectedFiles: component.get("v.selectedFiles") ,
             parentId:recId
                
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                var newRec=response.getReturnValue();
                if (state === "SUCCESS") {
                   component.set("v.IsSpinner",false);
                    var newresponserecid = newRec.Id;
                   /* var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : "Success!",
                        message : 'RFI Response created successfully',
                        type: 'success',
                        duration: '10000',
                        key: 'info_alt',
                        mode: 'pester'
                    });
                    toastEvent.fire();*/
                      /* if (component.find("fuploader").get("v.files") != undefined) {
                    if(component.find("fuploader").get("v.files").length > 0){
                        //alert(newresponserecid);
                        helper.uploadHelper(component, event, newresponserecid,helper);
                        
                        
                    }
                }
                    component.set("v.newRFIResponse", newRec.Id);*/
                    // alert(component.get("v.newRFIResponse"));
                   
                    
                    if(component.get('v.uploadedFileIds').length > 0){
                        component.set("v.IsSpinner",true);
                        helper.copyfilesHelper(component,newresponserecid);
                        component.set("v.IsSpinner",false);
                    }else{
                        helper.showMessage('RFI Response created successfully',true);
                        
                        
                        component.set("v.IsSpinner",false);
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": newresponserecid,
                "slideDevName": "related"
            });
            navEvt.fire();
                        
                        //location.reload();
                    }
                    component.set("v.selectedUsers",[])
                    component.set("v.newRFIResponse", newRec.Id);
                    
                    
                }
            })
            
            $A.enqueueAction(action);
        }else{
            component.set("v.errorMSG", true);
            component.set("v.IsSpinner",false);
        }
        //location.reload();
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
                
                closeErrorMSG : function(component, event, helper) {
                component.set("v.errorMSG", false);
                }
                ,
                               // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.selectedfilesFill"); 
        
                var action = component.get("c.deleteFile");
        //alert(component.get("v.recordId"));
        action.setParams( { 
            RecordId : component.get("v.recordId")
        }); 
        action.setCallback(this, function(actionResult) {
            
            var state = actionResult.getState();
            if(state == 'SUCCESS'){
               var fieldSetObj = actionResult.getReturnValue(); 
                component.set("v.Isfileuploaded",false);
            }
            
        });
        if(component.get("v.Isfileuploaded") == true){
            $A.enqueueAction(action);
        }
                
                
                
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
 


                
                
                
                
 })