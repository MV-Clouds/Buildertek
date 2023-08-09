({
    doInit : function(component, event, helper) {	
        //  $A.get("e.force:closeQuickAction").fire();
        component.set('v.up',true);
     /*   var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;            
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Vendor SOVs",
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom:custom5",
                iconAlt: "Vendor SOVs"
            });
        })
        .catch(function(error) {
            console.log(error);
        }); */
        
        debugger;
        
        helper.getcurr(component, event, helper);
        
        var action1 = component.get("c.getSovType");
        action1.setParams({
            "recordId": component.get("v.recordId")
        });
        action1.setCallback(this, function (response1) {
            if (response1.getState() == 'SUCCESS') {
                var result = response1.getReturnValue();
                
                if(result.buildertek__Status__c == 'Customer Approved'){
                   $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Error!",
                    message : 'You cannot make changes to Customer Approved SOV',
                    type: 'error',
                    duration: '1000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire(); 
            }else{
                helper.fetchSOVs(component, event, helper);
            }
        }
            
        });
        $A.enqueueAction(action1);
        
        
        
        
    },
    
    selectAllRfq : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.sovsList")));
        var getAllId = component.find("checkRFQ");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", true);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", true);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedSOVIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", false);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", false);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedSOVIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    selectRfq: function (component, event, helper) {
        var checkbox = event.getSource();
        
        //alert('Chechbox--------------  '+component.find("checkRFQ").get("v.name"));
        var selectedRfqIds = component.get("v.listOfSelectedSOVIds");
        var getAllId = component.find("checkRFQ");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckRFQ").get("v.checked")){
                    component.find("headCheckRFQ").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckRFQ").get("v.checked")){
                        component.find("headCheckRFQ").set("v.checked",true);
                    }
                }
            }
            
            var sovlist =  component.get("v.sovsList");            
            for(var i=0;i<sovlist.length;i++){
                if(sovlist[i].RecordId==checkbox.get("v.name")){
                    sovlist[i].isChecked = checkbox.get("v.checked");
                }
            }
            component.set("v.sovsList",sovlist);
            
        }else{
            if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedSOVIds",selectedRfqIds);
        
        
        // alert(event.getSource().get("v.name"));
        
        
    },
    
    toggle: function(component, event, helper) {
        var parentItems = component.get("v.sovsList"),
            parentIndex = event.getSource().get("v.title");
        
        
        var items = component.get("v.sovlinesList"),
            index = event.getSource().get("v.value");
        
        parentItems[parentIndex].expanded = !parentItems[parentIndex].expanded;
        component.set("v.sovsList", parentItems);
    },
    
    AcceptSov: function(component, event, helper) {
        if(component.get("v.listOfSelectedSOVIds").length>0){
            component.set("v.ApproveSOV",true) 
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOVs',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        
    },
    
    rejectSOV: function(component, event, helper) {     
        
        if(component.get("v.listOfSelectedSOVIds").length>0){
            component.set("v.up",false);
            component.set("v.RejectSOV",true)
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOVs',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    
    ConfirmApproveSOV: function(component, event, helper) {
        component.set("v.ApproveSOV",false)
        
        var sovlineslist = component.get("v.listOfSelectedSOVIds");
        var action = component.get("c.ApproveSOV"); 
        action.setParams({
            "recId" : component.get("v.masterSOVId"),
            "sovIds": component.get("v.listOfSelectedSOVIds")
        });        
        action.setCallback(this, function (result) {
            var state = result.getState();
            //alert(state);
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                //alert(resultData);
                
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Selected SOVs Accepted Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });  
        $A.enqueueAction(action);
    },
    
    ConfirmRejectSOV: function(component, event, helper) {
        component.set("v.RejectSOV",false);
        $A.get("e.force:closeQuickAction").fire();
        var sovlineslist = component.get("v.listOfSelectedSOVIds");
        var action = component.get("c.rejectSOVs"); 
        action.setParams({
            "recId" : component.get("v.masterSOVId"),
            "sovIds": component.get("v.listOfSelectedSOVIds")
        });        
        action.setCallback(this, function (result) {
            var state = result.getState();
            //alert(state);
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Selected SOVs Rejected Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success', 
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });  
        $A.enqueueAction(action);
    },
    
    closeModal: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        
        //   var workspaceAPI = component.find("workspace");
        //   workspaceAPI.getFocusedTabInfo().then(function(response) {
        //      var focusedTabId = response.tabId;
        //      workspaceAPI.closeTab({tabId: focusedTabId});
        //   })
        //   .catch(function(error) {
        //       console.log(error);
        //   });
    },
    
    closepopUp: function(component, event, helper) {
        component.set("v.RejectSOV",false)
        component.set("v.ApproveSOV",false)
        component.set("v.up",true);
    },
    
    selectSOVLine: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedSOVLineIds");
        var getAllId = component.find("checkSOVLine");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckSOVLines").get("v.checked")){
                    component.find("headCheckSOVLines").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckSOVLines").get("v.checked")){
                        component.find("headCheckSOVLines").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckSOVLines").get("v.checked")){
                component.find("headCheckSOVLines").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedSOVLineIds",selectedRfqIds);
        
    },
    
    selectAllSOVLines : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.sovsList")));
        var sovIndex = event.getSource().get("v.name")
        var getAllId = component.find("checkSOVLine");
        var recordIds = [];
        
        
        if(checkStatus){
            if(rfqRecordList[sovIndex].sovlinesList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkSOVLine").set("v.checked", true);
                    var Id = component.find("checkSOVLine").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkSOVLine")[i].set("v.checked", true);
                        var Id = component.find("checkSOVLine")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedSOVLineIds",recordIds);
            }
        }else{
            if(rfqRecordList[sovIndex].sovlinesList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkSOVLine").set("v.checked", false);
                    var Id = component.find("checkSOVLine").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkSOVLine")[i].set("v.checked", false);
                        var Id = component.find("checkSOVLine")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedSOVLineIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.showPopup", false);
        component.set("v.up",true);
    },
    
    
    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        
        var fields = event.getParam('fields');
        
        //alert(fields["Name"]);
        //alert(fields["buildertek__Project__c"]);
        component.find('recordEditForm').submit(fields);
        
    },
    
    handleSuccess : function(component,event,helper) {
        // Return to the contact page and
        // display the new case under the case related list
        var record = event.getParams();  
        //console.log(record.id);
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        //alert(eventId);
        component.set("v.masterSOVId",eventId);
        
        helper.generateMasterSOV(component, event, helper);
        helper.generateMasterSOVLines(component, event, helper);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : "Success!",
            message : 'Master SOV created successfully',
            type: 'success',
            duration: '10000',
            key: 'info_alt',
            mode: 'pester'
        });
        toastEvent.fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": eventId,
            "slideDevName": "related"
        });
        navEvt.fire();
        
        
        
        
    },
    
    handleCreateLoad: function(component, event, helper) {
        // component.find("newSovStatus").set("v.value","Approved");
    },
    
    
    
    
    
    handleCreateMasterSOV : function (component, event, helper){
        debugger;
        
        var sovlineids  = component.get("v.listOfSelectedSOVLineIds");
       //  alert(sovlineids)
        //alert(component.get("v.listOfSelectedSOVLineIds"));
         if(component.get("v.listOfSelectedSOVLineIds").length>0){
            component.set("v.showPopup",true);    
         }else if(component.get("v.listOfSelectedSOVIds").length>0){
             component.set("v.showPopup",true);
             component.set("v.up",false);
             
         }  else{
            
            if(component.get("v.sovsList").length < 1){
              var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'There are no sov lines',
                type: 'error',
                duration: '1000',
                    key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire()
            }else{
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOVs',
                type: 'error',
                duration: '1000',
                    key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire(); 
            }
            
           
        }
        
         
        
        
    },
    close : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    calculateWidth : function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        console.log('final tag Name'+parObj.tagName);
        
        var mouseStart=event.clientX; 
        component.set("v.mouseStart",mouseStart);
        component.set("v.oldWidth",parObj.offsetWidth);
        event.stopPropagation()
    },
    setNewWidth : function(component, event, helper) {
        var childObj = event.target
        var parObj = childObj.parentNode;
        var count = 1;
        //parent element traversing to get the TH
        while(parObj.tagName != 'TH') {
            parObj = parObj.parentNode;
            count++;
        }
        var mouseStart = component.get("v.mouseStart");
        var oldWidth = component.get("v.oldWidth");
        //To calculate the new width of the column
        var newWidth = event.clientX- parseFloat(mouseStart)+parseFloat(oldWidth);
        parObj.style.width = newWidth+'px';//assign new width to column
        event.stopPropagation();
    },
        ImportSOVLines: function (component, event, helper){
            debugger;
            component.set("v.IsSpinner",true);
        var SOVIds=component.get("v.listOfSelectedSOVIds");
       // alert('SOVIds------------'+SOVIds);
        //alert('newRecId--------'+newRecId);
        var action = component.get("c.createSOVLines");
           console.log(SOVIds.length);
            debugger;
        action.setParams({
            selectedSOV : SOVIds,
            newSOV : component.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var fieldSetObj = response.getReturnValue();
            //alert(fieldSetObj);
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.IsSpinner",false);
                if(fieldSetObj < 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : "Error!",
                        message : 'No sov lines',
                        type: 'error',
                        duration: '5000',
                        key: 'info_alt',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }else{
                     component.set("v.IsSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "SOV lines imported successfully."
                });
                toastEvent.fire();
                component.set("v.up",false);
                    component.set("v.IsSpinner",false);
                    $A.get("e.force:closeQuickAction").fire()
                    $A.get('e.force:refreshView').fire();
                }
                
            }
            
            //component.set("v.rfiList",fieldSetObj);
        })
       
        if(SOVIds.length < 1){
             component.set("v.IsSpinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOVs',
                type: 'error',
                duration: '5000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }else{
           $A.enqueueAction(action); 
        }
        
    },
    
    
    
})