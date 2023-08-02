({
    doInit: function (component, event, helper) {
        
        var recId = component.get("v.recordId");
        component.set("v.recordId",recId);
        
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
                    if(objName == 'buildertek__Pricing_Request_Line__c'){
                        component.set("v.parentprojectRecordId", parentRecordId);
                        var action = component.get("c.getRecordField");
                        action.setParams({
                            recordId: parentRecordId
                        });
                        action.setCallback(this, function (response) {
                            if (response.getState() == 'SUCCESS') {
                                if(response.getReturnValue() != 'Empty'){
                                    component.set("v.parentContactRecordId", response.getReturnValue());
                                }
                            }
                        });
                        $A.enqueueAction(action);
                    }
                } 
            });
            $A.enqueueAction(action);
        }
        
        debugger;
        var action = component.get("c.checkIsRFQ");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response1) {
            if (response1.getState() == 'SUCCESS') {
                
                var result = response1.getReturnValue();
               
                if(result){
                     $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'You have already Created the RFQ for this Record',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                    });
                    toastEvent.fire();
                    
                }else{
                   helper.getFields(component, event, helper);  
                }
            }
            
        });
        $A.enqueueAction(action);
        
        
       
        
        
       
    },

    closeModel: function (component, event, helper) {
      /*   var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        }); */
        
        $A.get("e.force:closeQuickAction").fire();
        
    

    },
        /* gotoList : function (component, event, helper) {
    var action = component.get("c.getListView");
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            var listviews = response.getReturnValue();
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": listviews.Id,
                "listViewName": null,
                "scope": "buildertek__RFQ__c"
            });
            navEvent.fire();
        }
    });
    $A.enqueueAction(action);
},*/


    handleSubmit: function (component, event, helper) {
        debugger;
        component.set('v.isLoading', true);
        var fields = event.getParam("fields");
        //if(fields.buildertek__Status__c == null || fields.buildertek__Status__c == '' || fields.buildertek__Status__c == undefined){
           fields.buildertek__Status__c = component.get("v.status"); 
        //}
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
    },

    onRecordSuccess: function (component, event, helper) {
         component.set('v.isLoading', true);
        var payload = event.getParams().response;
        debugger;
       /* var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        });*/
        setTimeout(function () {
            //component.set('v.isLoading', false);
            var payload = event.getParams().response;
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'RFQ created successfully',
                messageTemplate: "RFQ created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__RFQ__c/' + escape(payload.id) + '/view',
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
                "slideDevName": "detail"
            });
            navEvt.fire();
        }, 200);
        var action = component.get("c.updateRfqq");
        action.setParams({
            recordId : component.get("v.recordId"),
            rfId : payload.id
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
            } 
        });
        $A.enqueueAction(action);
    },

    saveAndNew: function (component, event, helper) {
        debugger;
        
          var Name = component.get("v.rfqName");
       // alert(Name);
         if(Name != null){
             //alert("hai");
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("listOfFields");
        component.find('recordViewForm').submit(fields); // Submit form
        $A.get('e.force:refreshView').fire();
              } else{
                  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Please Enter the RFQ Description.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
             }
    }
})