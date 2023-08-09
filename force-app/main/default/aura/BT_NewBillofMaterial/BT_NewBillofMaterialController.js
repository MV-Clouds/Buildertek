({
    doInit: function (component, event, helper) {
        component.set('v.isBOM', true);
        var parenttakeoffId = component.get("v.parenttakeoffId");
        // component.find("Name").set("v.autocomplete","off");
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
            component.set("v.parentRecordId", parentRecordId);
        }
        
        if(parentRecordId != null && parentRecordId != ''){
                var action = component.get("c.getobjectName");
                action.setParams({
                    recordId: parentRecordId,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var objName = response.getReturnValue();
                        if(objName == 'buildertek__Project__c'){
                            component.set("v.parentprojectId", parentRecordId);
                        }else if(objName == 'buildertek__Project_Takeoff__c'){
                            component.set("v.parenttakeoffId", parentRecordId);
                            helper.vendors(component,event,helper);
                        }
                    } 
                });
                $A.enqueueAction(action);
            }
        helper.getFields(component, event, helper);
            },
    closeModel: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                console.log(error);
            });
        $A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },
    cancelModel : function (component, event, helper) {
        component.set('v.isBOM', true);
        component.set('v.isImporttakeoff', false);
    },
    handleSubmit: function (component, event, helper) {
        component.set('v.isLoading', true);
        var fields = event.getParam("fields");
       /*  var name = component.find("Name").get("v.value");
        if(name != null){ 
        	fields["Name"] = name;
        }*/
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
         //helper.saveandnext(component,event,helper);
    },
    onRecordSuccess: function (component, event, helper) {
        var payload = event.getParams().response;
        // component.set('v.isBOM', false);
        // component.set('v.isImporttakeoff', true);
        component.set('v.BOMRecordId', payload.id);
        component.set('v.BOMRecordName', payload.name);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        });
        setTimeout(function () {
            component.set('v.isLoading', false);
          //  component.set('v.isImporttakeoff', true);
            var payload = event.getParams().response;
             // component.set('v.BOMRecordId', payload.id);
       // component.set('v.BOMRecordName', payload.name);
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Bill of Material created successfully',
                messageTemplate: "Bill of Material created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Project_Selection_Sheet_Takeoff__c/' + escape(payload.id) + '/view',
                    label: payload.name,
                }],
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();

            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": payload.id,
                "slideDevName": "related"
            });
            navEvt.fire();
        }, 200);
    },
    saveAndNew: function (component, event, helper) {
     //   var payload = event.getParams().response;
       // component.set('v.BOMRecordId', payload.id);
      //  component.set('v.BOMRecordName', payload.name);
        var Name = component.get("v.bomName");
         if(Name != null){
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("listOfFields");
        component.find('recordViewForm').submit(fields); // Submit form
        $A.get('e.force:refreshView').fire();
         } else{
                  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Please enter the Name.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
             }
    },
     saveAndNext: function (component, event, helper) {
          var Name = component.get("v.bomName");
         // var project = component.get("v.parentprojectId");
      //  alert('haiii'+project);
         if(Name != null){
         component.set('v.isBOM', false);
         component.set('v.isImporttakeoff', true);
         var Name = component.get("v.bomName");
        var parentprojectId = component.get("v.parentprojectId");
         var action = component.get("c.bomrec");
         action.setParams({
             RecordId: parentprojectId,
             BOMName : Name,
         });
         action.setCallback(this, function (response) {
             if (response.getState() == 'SUCCESS') {
                 var result = response.getReturnValue();
                 component.set("v.BOMRecordId", result);
                  component.set("v.BOMRecordId", result.Id);
             } else {
                 console.log('Error');
             }
         });
         $A.enqueueAction(action);
         helper.saveandnext(component,event,helper);
         }else{
              var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Please enter the Name.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
             
         }
         /* if(project != ''){
             // alert("hai");
         component.set('v.isBOM', false);
         component.set('v.isImporttakeoff', true);
         var Name = component.get("v.bomName");
        var parentprojectId = component.get("v.parentprojectId");
         var action = component.get("c.bomrec");
         action.setParams({
             RecordId: parentprojectId,
             BOMName : Name,
         });
         action.setCallback(this, function (response) {
             if (response.getState() == 'SUCCESS') {
                 var result = response.getReturnValue();
                 component.set("v.BOMRecordId", result);
                  component.set("v.BOMRecordId", result.Id);
             } else {
                 console.log('Error');
             }
         });
         $A.enqueueAction(action);
         helper.saveandnext(component,event,helper);
         }else{
              var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Please select the project.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
             
         }*/
    },
       selectAllPayApp : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.ImportVendorPaymentAppsList")));
        var getAllId = component.find("checkPayApp");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkPayApp").set("v.checked", true);
                    var Id = component.find("checkPayApp").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkPayApp")[i].set("v.checked", true);
                        var Id = component.find("checkPayApp")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkPayApp").set("v.checked", false);
                    var Id = component.find("checkPayApp").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkPayApp")[i].set("v.checked", false);
                        var Id = component.find("checkPayApp")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedRFQIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    
     selectPayApp: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedRFQIds");
        var getAllId = component.find("checkPayApp");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckPayApp").get("v.checked")){
                    component.find("headCheckPayApp").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckPayApp").get("v.checked")){
                        component.find("headCheckPayApp").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckPayApp").get("v.checked")){
                component.find("headCheckPayApp").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedRFQIds",selectedRfqIds);
    },
    
    
    importtakeoff: function (component, event, helper) {
        if(component.get("v.listOfSelectedRFQIds").length != 0){
        component.set("v.Spinner2",true);
        var recIds = component.get("v.listOfSelectedRFQIds");
        var bomid = component.get("v.BOMRecordId");
        var action = component.get("c.createlines");
        action.setParams({
            "recordId" : recIds,
            "bomId" : bomid,
        })
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                });
        setTimeout(function () {
            var payload = event.getParams().response;
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Bill of Material created successfully',
                messageTemplate: "Bill of Material created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Project_Selection_Sheet_Takeoff__c/' + bomid + '/view',
                    label:  component.set('v.bomName'),
                }],
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": bomid,
                "slideDevName": "related"
            });
            navEvt.fire();
        }, 200);
            }
        }); 
          $A.enqueueAction(action);
         }else{
                    component.set("v.Spinner2",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'No Takeoffs are selected.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                }
      }
})