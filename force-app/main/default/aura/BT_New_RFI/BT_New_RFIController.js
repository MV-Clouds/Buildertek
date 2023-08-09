({
	doInit: function (component, event, helper) {
       var action = component.get("c.getFieldSet");
       var recordid=component.get("v.projRecordId");
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
                    if(listofchange[i].name != 'Name' && listofchange[i].name != 'buildertek__Assigned_To__c' 
                       && listofchange[i].name != 'OwnerId' && listofchange[i].name != 'buildertek__Status__c'){
                        collist.push(listofchange[i]);
                    }
                component.set("v.fieldSetValues",collist);
            }
        })
        $A.enqueueAction(action);
        var action1 = component.get("c.getproject");
        action1.setParams({
            projectId : component.get("v.recordId")
        })
        action1.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            component.set("v.parentprojectRecordId", fieldSetObj.buildertek__Project__c);
            //alert(component.get("v.parentprojectRecordId"));
            component.set("v.rfqrec", fieldSetObj);                         
        })
         $A.enqueueAction(action1);
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
         //var dateOriginallySent = system.today();
         //var today = new Date();
         //alert(today);
       // var dateOriginallySent = $A.localizationService.formatDate(today, "MM-DD-YYYY HH:mm:ss A Z");
				//var date=new Date();
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
        fields.buildertek__RFQ__c = component.get("v.recordId");
        fields.buildertek__Status__c = 'RFI Sent';
        fields.buildertek__Assigned_To__c = component.get("v.contactid");
        fields.buildertek__Submitted_By__c = username;
        fields.buildertek__RFI_Assigned_To__c = rfqrec.buildertek__RFI_Owner__c; 
        
        //  fields.buildertek__Date_Sent__c =today; 
       // component.set('v.currentDate', today);
         //alert(fields["buildertek__Vendor_Account__c"]);
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
          var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        //alert('eventId       '+eventId);
        console.log('onRecordSuccess');
        
        
        
        /*var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));*/
      
        
        component.set('v.rfiId',eventId);
        
        var fileInput = component.find("fuploader").get("v.files");
        if(fileInput != null){
            helper.uploadHelper(component, event, helper);
        }
        
        helper.sendEmail(component, event, helper);
            /*component.set("v.IsSpinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Success!",
                message : 'RFI created successfully',
                type: 'success',
                duration: '10000',
                 key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();*/
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.rfiId'),
                "slideDevName": "related"
            });
            navEvt.fire();
        
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


   
})