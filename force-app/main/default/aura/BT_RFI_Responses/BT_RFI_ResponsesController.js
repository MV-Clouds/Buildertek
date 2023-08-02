({
    doInit : function(component, event, helper) {
       
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
        var action = component.get("c.getrfiresponselists");
        action.setParams({
            parentRecordId : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            // alert(fieldSetObj);
            
            component.set("v.rfiList",fieldSetObj);
        })
        $A.enqueueAction(action);
        
        
        
        /*var rfiid=component.get("v.rfiId");
        // alert('rfiid------------------'+rfiid);
        var action = component.get("c.getRFQRec"); 
        action.setParams({
            rfiId : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj2 = response.getReturnValue();
            var state = response.getState();
            //alert(component.get("v.Isnewrfiresponse"));            
            if (state === "SUCCESS") {
                component.set("v.rfqId",fieldSetObj2.Id);
                
            } 
        });
        $A.enqueueAction(action);*/
       var rfirecId=component.get("v.recordId");
       var action = component.get("c.getRecContacts");
       action.setParams({
           rfiId1 : component.get("v.recordId")
       })
       action.setCallback(this, function (response) {
           var connames = JSON.stringify(response.getReturnValue());
           
           //alert('connames'+connames);
           component.set("v.selectedContacts",connames);
       });
       $A.enqueueAction(action);
       var rfirecId=component.get("v.recordId");
       // alert('rfirecId'+rfirecId);
       var action = component.get("c.getRecUsers");
       action.setParams({
           rfiId : component.get("v.recordId")
       })
       action.setCallback(this, function (response) {
           var usernames = JSON.stringify(response.getReturnValue());
           //alert('usernames'+usernames);
           component.set("v.selectedUsers",usernames);
       });
       $A.enqueueAction(action);
       
       var action = component.get("c.fetchUser");
       action.setCallback(this, function(response) {
           var state = response.getState();
          // alert('state      '+state);
           if (state === "SUCCESS") {
               
               var storeResponse = response.getReturnValue();
               component.set("v.userInfo", storeResponse);
               
           }
       });
       $A.enqueueAction(action);
        
        
        
        
         var action = component.get("c.fetchUser1");
       action.setCallback(this, function(response) {
           var state = response.getState();
          // alert('state      '+state);
           if (state === "SUCCESS") {
               
               var storeResponse = response.getReturnValue();
              //alert('storeResponse      '+JSON.stringify(storeResponse.Name));
              component.set("v.userInfo1", storeResponse.Name);
               
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
                //component.set("v.showpopup",true);
                component.set("v.fieldSetValues",collist);
            }
        })
        $A.enqueueAction(action);
       var rfirecId=component.get("v.recordId")
      
   },
    
    openRecordPage: function (component, event, helper) {
        //alert("test");
        var recordId = event.currentTarget.dataset.id;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    openuserPage: function (component, event, helper) {
        var recordId = event.currentTarget.dataset.id;
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    
    handleClick: function (component, event, helper) {
        
        var RRrecordId = event.currentTarget.dataset.id;
        component.set("v.CMPId",RRrecordId);
        //alert("RRrecordId------------------ "+RRrecordId);          
        var action = component.get("c.getrfiRRRecord"); 
        action.setParams({
            parentRecordId : RRrecordId
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert('fieldSetObj   ----'+JSON.stringify(fieldSetObj));
            //alert(component.get("v.Isnewrfiresponse"));    
            component.set("v.rfiId",fieldSetObj.buildertek__RFI__c);       
            if(fieldSetObj.buildertek__Responder__c!=null){
                component.set("v.ReplyTo",fieldSetObj.buildertek__Responder__r.Name);
                
            } 
            if(fieldSetObj.buildertek__RFI__r.buildertek__Status__c=='Closed'){
                //alert('true');
  				component.set("v.openResponseModel", false);                
                //$A.get("e.force:closeQuickAction").fire();
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
            component.set("v.openResponseModel",true);
        }
            
        });
        $A.enqueueAction(action);
        
            },
    doCancel: function(component, event, helper) {
        debugger;
         //var rfirecordid = event.currentTarget.dataset.rowid;
        var action = component.get("c.deleteFile");
        //alert(component.get("v.recordId"));
        action.setParams( { 
            RecordId : component.get("v.recordId"),
            fileIds: component.get('v.uploadedFileIds')
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
        
        
        
        //location.reload();openResponseModel
        component.set("v.openResponseModel",false);
        component.set("v.errorMSG",false);
        component.set("v.templateBody",'');
        component.get("v.selectedFiles",[]);
        component.set("v.selectedfilesFill",[]);
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
                    
                    location.reload();
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
    	//alert(JSON.stringify(component.get('v.uploadedFileIds')));
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