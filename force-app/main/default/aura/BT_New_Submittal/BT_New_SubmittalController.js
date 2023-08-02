({
   doInit: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
    	var context = '';
    	var parentRecordId = '';
    	component.set("v.parentRecordId",parentRecordId);
    	
    	if(value != null){
    		context = JSON.parse(window.atob(value)); 
    		parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId",parentRecordId);
		}else{
		    var relatedList = window.location.pathname;
		    var stringList = relatedList.split("/");
		    parentRecordId = stringList[3]
		    component.set("v.parentRecordId",parentRecordId);
		} 
        if(parentRecordId != null && parentRecordId != ''){
                var action = component.get("c.getobjectName");
                action.setParams({
                    recordId: parentRecordId,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var objName = response.getReturnValue();
                        if(objName == 'Contact'){
                            component.set("v.newSubmittal.buildertek__Responsible_Contact__c", parentRecordId);
                        }else if(objName == 'buildertek__Project__c'){
                            component.set("v.projectId", parentRecordId);
                        }/*else if(objName == 'buildertek__Cost_Codes__c'){
                            component.set("v.billId", parentRecordId);
                        }*/else if(objName == 'Account'){
                            component.set("v.newSubmittal.buildertek__Responsible_Vendor__c", parentRecordId);
                        }
                    } 
                });
                $A.enqueueAction(action);
            }
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
      /*  var oDate = component.find("oDate");
        oDate.set("v.value", today);*/
        
        var action = component.get("c.getCurrentLoggedInUser");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
              var result = response.getReturnValue(); 
              if(result != undefined){
                  component.set("v.currentUserName", result.Name); 
                  component.set("v.currentUserId", result.Id); 
              }
            }
        });
        $A.enqueueAction(action);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
        var parentRecordId = component.get("v.parentRecordId");
        if(parentRecordId != undefined){
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
            relatedListEvent.setParams({
                "relatedListId": "buildertek__Submittals__r",
                "parentRecordId": component.get("v.parentRecordId")
            });
            relatedListEvent.fire();    
        }else{
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            //alert('baseURL -------> '+baseURL);
            window.open(baseURL+'/lightning/o/buildertek__Submittal__c/list?filterName=Recent', '_self');
        }
        /*var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "buildertek__Submittals__r",
            "parentRecordId": component.get("v.parentRecordId")
        });
        relatedListEvent.fire();*/
   },
   
   save : function(component, event, helper) {
        component.set("v.Spinner", true);
        var submittalToInsert = JSON.stringify(component.get("v.newSubmittal"));
        var currentUser = component.get("v.currentUserId");  
        var currentStatus = component.get("v.defaultStatus"); 
       // var submmittedDate = component.find("oDate").get("v.value");
        var projectId = component.get("v.projectId");
        //alert('projectId ---------> '+projectId);
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        /*if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }*/
        var action = component.get("c.createNewSubmittal");
        action.setParams({
            submittalRecord : submittalToInsert,
            userId : currentUser,
            projectId : projectId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                component.set("v.isSaveAndNew",false);
                component.set("v.submittalRecordId",result);
                if(result){
                    var fileCount=component.get("v.fileCount") ;
                    if(fileCount > 0){
                        var attachAction = component.get("c.uploadFiles");
                        $A.enqueueAction(attachAction);
                    }else{
                        $A.get("e.force:closeQuickAction").fire();
                        
                        var workspaceAPI = component.find("workspace");
                        workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({tabId: focusedTabId});
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                        
                        //var params = event.getParams();
                        // alert(params.response.id);
                        var parentRecordId = component.get("v.parentRecordId");
                        component.set("v.Spinner", false); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Submittal created successfully',
                            type : 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        
                        window.open ("/"+escape(result),"_Self");
                    }
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                    
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                    //var params = event.getParams();
                    // alert(params.response.id);
                    var parentRecordId = component.get("v.parentRecordId");
                    component.set("v.Spinner", false); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Submittal created successfully',
                        type : 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                    window.open ("/"+escape(result),"_Self");
                }
            }
            
            //old code
            /*if(state === "SUCCESS"){
                var result = response.getReturnValue();
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                $A.get("e.force:closeQuickAction").fire();
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                     workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
                
                //var params = event.getParams();
                   // alert(params.response.id);
                var parentRecordId = component.get("v.parentRecordId");
                component.set("v.Spinner", false); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Submittal created successfully',
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                    
                window.open ("/"+escape(result),"_Self");
            }*/
        });
        $A.enqueueAction(action);
   },
   
   saveAndNew : function(component, event, helper) {
       component.set("v.Spinner", true);
        var submittalToInsert = JSON.stringify(component.get("v.newSubmittal"));
        var currentUser = component.get("v.currentUserId");  
        var currentStatus = component.get("v.defaultStatus"); 
      //  var submmittedDate = component.find("oDate").get("v.value");
        var projectId = component.get("v.projectId");
        //alert('projectId ---------> '+projectId);
        /*var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }*/
        var action = component.get("c.createNewSubmittal");
        action.setParams({
            submittalRecord : submittalToInsert,
            userId : currentUser,
            projectId : projectId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                component.set("v.newSubmittal", null);
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = response.getReturnValue();
                component.set("v.isSaveAndNew",true);
                component.set("v.submittalRecordId",result);
                if(result){
                    var fileCount=component.get("v.fileCount");
                    if(component.get("v.fileCount") > 0){
                        var attachAction = component.get("c.uploadFiles");
                        $A.enqueueAction(attachAction);
                    }else{
                        component.set("v.Spinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Submittal created successfully',
                            type : 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        window.location.reload(true);
                    }
                    
                }
                /*if(projectId == undefined){
                    component.find('consoleProjectNameId').set("v.value", null);       
                }*/
                /*component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Submittal created successfully',
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                window.location.reload(true);*/
            }
            
            //old code
            /*if(state === "SUCCESS"){
                component.set("v.newSubmittal", null);
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = response.getReturnValue();
                /*if(projectId == undefined){
                    component.find('consoleProjectNameId').set("v.value", null);       
                }*/
                /*component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Submittal created successfully',
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                window.location.reload(true);
            }*/
        });
        $A.enqueueAction(action);    
   },
    
    
    
    
    handleFilesChange: function(component, event, helper) {
        var fileName = "No File Selected..";
        var fileCount=component.find("fileId").get("v.files").length;
        var files='';
        component.set("v.fileCount",fileCount);
        if (fileCount > 0) {
            for (var i = 0; i < fileCount; i++) 
            {
                fileName = component.find("fileId").get("v.files")[i]["name"];
                files=files+', '+fileName;
            }
        }
        else
        {
            files=fileName;
        }
        component.set("v.fileName", files);
    },
    
    uploadFiles: function(component, event, helper) {
        if(component.find("fileId").get("v.files")==undefined)
        {
            helper.showMessage('Select files',false);
            return;
        }
        if (component.find("fileId").get("v.files").length > 0) {
            var s = component.get("v.FilesUploaded");
            var fileName = "";
            var fileType = "";
            var fileCount=component.find("fileId").get("v.files").length;
            component.set("v.fileCount",fileCount);
            if (fileCount > 0) {
                for (var i = 0; i < fileCount; i++) 
                {
                    helper.uploadHelper(component, event,component.find("fileId").get("v.files")[i]);
                }
            }
        } else {
            //helper.showMessage("Please Select a Valid File",false);
             //alert('Please Select a Valid File');
        }
    },
    
    
  	/*handleUploadFinished: function (cmp, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
		var uploadFileList = [];
        component.set("v.fileCount", uploadedFiles.length);
        // Get the file name
        uploadedFiles.forEach(function(file){
            uploadFileList.push(file.documentId) 
        });
        conponent.set("v.uploadedFileIds",uploadFile)
    },*/
 
})