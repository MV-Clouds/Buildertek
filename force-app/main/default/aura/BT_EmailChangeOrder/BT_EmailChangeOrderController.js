({
	 doInit: function (component, event, helper) {
         var recordid = component.get("v.records");
       //  alert("records List : "+recordid)
       //  alert('recordid.........'+recordid[0]);
         /* var objectNames = component.get("v.objectAPI");
        var dbAction1 = component.get("c.getdetails");
        dbAction1.setParams({
            recordId : component.get("v.records"),
            objectAPIName: 'buildertek__Change_Order__c',
        });
        dbAction1.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               alert(state);
                alert('kkkkkkkkkkk'+response.getReturnValue());
				//component.set("v.selectedTemplate", response.getReturnValue());
            }
        });
        $A.enqueueAction(dbAction1);*/
           helper.getTemplate(component, event, helper);
          },
    
     closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
          debugger;
       // component.set("v.isOpen", false);
    // alert(component.get("v.parentRecordId"));
     var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId; 
            workspaceAPI.closeTab({tabId: focusedTabId});
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/o/buildertek__Change_Order__c/list?filterName=Recent'
            });
            urlEvent.fire();
        })
        .catch(function(error) {
            console.log(error);
        });
        //    window.open("/lightning/r/buildertek__Project__c/"+component.get("v.parentRecordId")+"/related/buildertek__Change_Orders__r/view","_self");
        var vfFunction = window.myVFAction;
        $A.getCallback(function() {
            vfFunction();
        })();



      /*   var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
             "url": "/lightning/r/buildertek__Project__c/"+component.get("v.parentRecordId")+"/related/buildertek__Change_Orders__r/view"
         });
         urlEvent.fire(); */
     /*  var recordid = component.get("v.records");
       var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
          //  $A.get("e.force:closeQuickAction").fire();  
               // $A.get('e.force:refreshView').fire();  
      window.close();
         window.location.href="/{'/lightning/o/buildertek__Change_Order__c/list?filterName=Recent'}";
         window.self.close();
        //  window.top.close();
     // console.log("Window Opened");
      //  window.close('/apex/buildertek__BT_EmailChangeOrderVf');
         //console.log("Window closed")
      /*  var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId; 
            workspaceAPI.closeTab({tabId: focusedTabId});
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/o/buildertek__Change_Order__c/list?filterName=Recent'
            });
            urlEvent.fire();
        })
        .catch(function(error) {
            console.log(error);
        });
      //  window.top.close();*/
    },
   
     emailTemplate : function(component, event, helper) {
       var objectName = component.get("v.objectAPI");
         // alert('component.get("v.selectedbodyTemplateItem")'+component.get("v.selectedbodyTemplateItem"));
          /*  if(objectName == 'buildertek__Account_Payable__c'){
                component.set("v.showBodyTemplate",true);
                helper.getbodyTemplate(component, event, helper);
            }*/
          helper.getBodyContent(component,component.get("v.selectedbodyTemplateItem"));
           // helper.getBodyContent(component, event, helper);
    },   
	sendemail : function(component, event, helper) {
		console.log("selectedToContact--->",component.get("v.selectedToContact"));
		console.log("selectedCcContact--->",component.get("v.selectedCcContact"));
		console.log("selectedCcContact--->",component.get("v.selectedFiles"));
	    if(component.get("v.selectedToContact") != ''){ 
            if(component.get("v.selectedfilesFill").length>0) {
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
              //  alert(component.get("v.recordId"))
                helper.uploadHelper(component, event, component.get("v.recordId"),helper);    
            }else{
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
              //  alert("helper");
                helper.send(component, event, helper);
            }
        }else{
          /*  var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Please Select To Address',
                type : 'error',
                duration: '5000',
                mode: 'dismissible'
            });
            toastEvent.fire();  */
              sforce.one.showToast({
                        
                        "title": "",
                        
                        "message": "Please Select To Address",
                        
                        "type": "error" //supported types are error, success, info, warning
                        
                    });
        }
	},
	uploadFileAdd : function(component, event, helper) {
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
	
	
     onEmailChange: function (component, event, helper) {
        var emailId = component.find('emailForm').get('v.value');
        var emailIds = component.get('v.emailIds');
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if (emailId.charAt(emailId.length - 1) == ';') {
            emailId = emailId.replace(';', '');
            if (reg.test(emailId)) {
                component.set("v.toEmail", '');
                if (!emailIds.includes(emailId)) {
                    emailIds.push(emailId);
                }
            }
        }
        if(emailIds != null && emailIds != ''){
          component.set('v.emailIds', emailIds);  
        }else{
            component.set('v.emailIds', emailId);
        }
        
    },
     handleEmailRemove: function (component, event, helper) {
        var removeIndex = event.getSource().get("v.name");
        var emailIds = component.get('v.emailIds');
        emailIds.splice(removeIndex, 1);
        component.set('v.emailIds', emailIds);
    },
    
	handleFilesChange: function(component, event, helper) {
            var fileName = 'No File Selected..';                
                //alert(event.getSource().get("v.files").length);
            if (event.getSource().get("v.files").length > 0) {
               // fileName = event.getSource().get("v.files")[0]['name'];
            }
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
        component.set("v.fileName", files);            
        component.set("v.selectedfilesFill",mapData);
        //alert(typeof event.getSource().get("v.files"));        
        //component.set("v.fileName", fileName);
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
     closeFocusedTab : function(component, event, helper) {
        // alert("ok")
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
                
})