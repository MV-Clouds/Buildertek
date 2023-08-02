({
	doInit : function(component, event, helper) {
        component.set("v.selectedUsers",[]);
        component.set("v.selectedContacts",[]); 
        var rfiaction = component.get("c.getRFISettings");
        rfiaction.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.rfisettings", fieldSetObj);
            /* var rfisett=component.get("v.rfisettings");
            alert('rfisett      '+rfisett);*/
        })
        $A.enqueueAction(rfiaction);
        
         var useraction = component.get("c.getUser");
        useraction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('getuser'+storeResponse);
                if(storeResponse == 'true'){
                    component.set("v.Isnewrfiresponse", true); 
                }else{
                    component.set("v.Isnewrfiresponse", false);
                }
            }
        });
        $A.enqueueAction(useraction);
        
     	var recId = component.get("v.recordId");
      // alert(recId);
        var action = component.get("c.getrfiRecord"); 
        action.setParams({
            parentRecordId : recId
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            
            if(fieldSetObj.buildertek__Status__c=='Closed'){
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
            }
            
            //alert(JSON.stringify(fieldSetObj));
            //alert(component.get("v.Isnewrfiresponse"));            
                /*if(fieldSetObj.buildertek__Submitted_By__c!=null){
                    component.set("v.ReplyTo",fieldSetObj.buildertek__Submitted_By__r.Name);                    
                }*/
                if(component.get("v.rfisettings")==false){
                    if(component.get("v.Isnewrfiresponse")==true){
                        if(fieldSetObj.buildertek__RFI_Assigned_To__c!=null){
                            component.set("v.ReplyTo",fieldSetObj.buildertek__RFI_Assigned_To__r.Name);
                        } 
                        
                    }else{
                        if(fieldSetObj.buildertek__Submitted_By__c!=null){
                            component.set("v.ReplyTo",fieldSetObj.buildertek__Submitted_By__r.Name);
                        }                      
                    }
                }else if(component.get("v.rfisettings")==true){
                    if(fieldSetObj.buildertek__Submitted_By2__c!=null){
                        component.set("v.ReplyTo",fieldSetObj.buildertek__Submitted_By2__r.Name);
                    }   
                }
                
            
            
             component.set("v.rfqId",fieldSetObj.buildertek__RFQ__c );
        });
        $A.enqueueAction(action);
        
        
        
        var recId = component.get("v.recordId");
        var action = component.get("c.getRFQRec");
        action.setParams({
            rfiId : recId
        })
        action.setCallback(this, function (response) {
            var rfq = response.getReturnValue();
            //alert('rfq     '+rfq);
            component.set("v.rfqId",rfq);
                        
             });
        $A.enqueueAction(action);
        var rfqId=component.get("v.rfqId");
      //  alert('rfqId            '+rfqId);
        var recId = component.get("v.recordId");
        var action = component.get("c.getRecContacts");
        action.setParams({
            rfiId1 : recId
        })
        action.setCallback(this, function (response) {
            var connames = JSON.stringify(response.getReturnValue());
            //alert('connames'+connames);
            component.set("v.selectedContacts",connames);
                        
             });
        $A.enqueueAction(action);
        
         var action = component.get("c.getRecUsers");
        action.setParams({
            rfiId : recId
        })
         action.setCallback(this, function (response) {
            var usernames = JSON.stringify(response.getReturnValue());
           // alert('usernames'+usernames);
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
        
          var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName : "buildertek__RFI__c",
            fieldSetName  : "buildertek__New_RFI_Community_Field_Set",
            parentRecordId : component.get("v.recordId")
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
       // var parentresponseId = component.get("v.parentresponseId");
        var fields = event.getParam("fields");
        var rfiid = component.get("v.recordId"); 
       // parentid = rfiid;
        //alert('parentid-->'+parentid);
        fields.buildertek__RFI__c = rfiid;
        fields.buildertek__Response_Date__c = today;
        fields.buildertek__Responder__c = username;
       // fields.buildertek__Parent__c = parentresponseId;
        /*if(users.length>0 || cons.length>0 ){
        	fields.buildertek__Show_In_Community__c = false;     
        } */       
        event.preventDefault(); // Prevent default submit
       component.find('recordViewForm').submit(fields); // Submit form
    },
    onRecordSuccess: function (component, event, helper) {
        var user1=component.get("v.selectedUsers");
        var con1=component.get("v.selectedContacts");
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
       //  alert('Response Id  '+eventId);
       // alert('selected Users-------'+JSON.stringify(user1));
      //  alert('selected Users-------'+JSON.stringify(con1));
       component.set('v.rfiresponseId',eventId);
       
       var action = component.get("c.updateRFQ");
        //  var recordid=component.get("v.projRecordId");
        action.setParams({
            RecordId : component.get("v.rfiresponseId"),
            selectedUsers:component.get("v.selectedUsers"),
            selectedContacts:component.get("v.selectedContacts")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
        })
       
        var fileInput = component.find("fuploader").get("v.files");
        
        if(fileInput != null){
          //alert('fileInput         '+JSON.stringify(fileInput));
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
         //var rfirecordid = event.currentTarget.dataset.rowid;
        var action = component.get("c.deleteFile");
        //alert(component.get("v.recordId"));
        //alert(component.get('v.uploadedFileIds'));
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
         
        
        //location.reload();
         var dismissActionPanel = $A.get("e.force:closeQuickAction");
         dismissActionPanel.fire();
    },
    filelist : function(component, event, helper) {
        var rfirecordid = event.currentTarget.dataset.rowid;
        var action = component.get("c.getContentDocs"); 
        action.setParams( { 
            arecordId : rfirecordid
        }); 
        action.setCallback(this, function(actionResult) {
            component.set('v.files',actionResult.getReturnValue()); 
            var fileslist = component.get('v.files');
            //alert('fileslist'+ JSON.stringify(fileslist));
            if(fileslist.length > 0){
                component.set("v.Isfiles",true);
                component.set("v.isrfi",false);
            }else{
               // component.set("v.Isnofiles",true);
                component.set("v.isrfi",false);
            }
        }); 
        $A.enqueueAction(action); 
    },
    sendResponse:function(component, event, helper) {
        
        var users= component.get("v.selectedUsers");
        var cons= component.get("v.selectedContacts");
        var rfiid=component.get("v.rfiId");
        var recId = component.get("v.recordId");
        var username = component.get("v.userInfo");
        var varresponse = component.get("v.templateBody");
        if(component.get("v.Isnewrfiresponse")==true){
            //alert(component.get("v.Isnewrfiresponse"));
            users=[];
            cons=[];
        }
        //alert('fileslist'+ JSON.stringify(component.get("v.selectedFiles")));
        //alert(JSON.stringify(component.get('v.uploadedFileIds')));
        if(varresponse !=''){
             component.set("v.IsSpinner",true);
        var action = component.get("c.createRFIResponse");
        action.setParams({
            rfiRecId:recId,
            userId:username,
            response:varresponse,
            selectedUsers:users,
            selectedContacts:cons,
            selectedFiles: component.get("v.selectedFiles")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            var newRec=response.getReturnValue();
            if (state === "SUCCESS") {
                 //component.set("v.IsSpinner",false);
                var newresponserecid = newRec.Id;
                
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success!",
                    message : 'RFI Response created successfully',
                    type: 'success',
                    duration: '10000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();*/
                  
                //alert(component.find("fuploader").get("v.files").length);   
                /*if (component.find("fuploader").get("v.files") != undefined) {
                    if(component.find("fuploader").get("v.files").length > 0){
                        helper.uploadHelper(component, event, newresponserecid,helper);
                        
                    }
                }else{
                    component.set("v.IsSpinner",false);
                }*/
                
                if(component.get('v.uploadedFileIds').length > 0){
                    helper.copyfilesHelper(component,newresponserecid);
                    
                    component.set("v.IsSpinner",false);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": newresponserecid
                    });
                    navEvt.fire();
                }else{
                    helper.showMessage('RFI Response created successfully',true);
                    
                    
                    component.set("v.IsSpinner",false);
                    
                    //location.reload();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": newresponserecid
                    });
                    navEvt.fire();
                }
                component.set("v.selectedUsers",[])
                
                //var fileInput = component.find("file").getElement();
                //alert(fileInput.length);
                //if(fileInput.length > 0){
                    //helper.save(component,newresponserecid);
                  // helper.uploadHelper(component, event, newresponserecid,helper); 
                //}
                 
               component.set("v.newRFIResponse", newRec.Id);
                
                
                
                
                //location.reload();
           // alert(component.get("v.newRFIResponse"));
            }
        })
        $A.enqueueAction(action);
        }else{
             component.set("v.errorMSG", true);
           // alert("Error");
        }
       
        //location.reload();
    },
    uploadFilebtfile : function(component, event, helper) {
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
                },
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
 
 
 
     
    /*save : function(component, event, helper) {
        helper.save(component);
    },*/
 
 
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
            var fileId = uploadedFiles[i]["name"];
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
    	//alert(JSON.stringify(component.get('v.uploadedFileIds')));
    	debugger;
    //alert(JSON.stringify(mapData));
    	component.set("v.selectedfilesFill",mapData);                 

            		
    
    
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