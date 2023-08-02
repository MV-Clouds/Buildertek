({
    doInit: function (component, event, helper) {
        //component.set("v.isnewwarranty",true);
        component.set("v.parentRecordId", component.get("v.recordId"));
        component.set("v.isWarranty",true);
        component.set("v.isnewwarranty",false); 
         helper.getpreviousWarrantyRec(component, event, helper);
        setTimeout(function () {
            helper.getFields(component, event, helper);
        }, 200);
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
    handleLoad : function (component, event, helper) {
        var projectId = component.get("v.parentRecordId");
      /*  component.set('v.typevalue', 'Material');
        var RecordId = component.get("v.parentRecordId");
        if(component.get('v.parentobjectName') == 'buildertek__Budget__c'){
            component.find("incidentlookupid").set("v.value", RecordId);
        }
        if(component.get('v.parentobjectName') == 'buildertek__Project__c' && component.get('v.isProjectFieldExist') == true){
            component.find("projectlookupid").set("v.value", RecordId);
        } */
        component.find("projectlookupid").set("v.value", projectId);
        if(component.get("v.effectiveDate") != null){
           component.find("effectid").set("v.value", component.get("v.effectiveDate"));
        }
        component.find("statusid").set("v.value", 'Open');
       
    },
    handleSubmit: function (component, event, helper) {
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields["buildertek__Project__c"] = component.get("v.parentRecordId");
        if(component.get("v.effectiveDate") != null){
          eventFields["buildertek__Effective_Date__c"] = component.get("v.effectiveDate");
        }
        //eventFields["buildertek__Due_Date__c"] = component.get("v.effectiveDate");
        eventFields["buildertek__Parent_Warranty__c"] = component.get("v.value");
        component.set('v.isLoading', false);
        component.find('recordViewForm').submit(eventFields); // Submit form'
    },
    handleError: function(component, event, helper) {
        var errorMsg = event.getParam("detail");
    },

    handleSuccess: function (component, event, helper) {
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        component.set('v.newwarrantyId',eventId);
        helper.updateDueDate(component, event, helper);
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
            var payload = event.getParams().response;
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Warranty created successfully',
                messageTemplate: "Warranty created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Warranty__c/' + escape(payload.id) + '/view',
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
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("listOfFields");
        component.find('recordViewForm').submit(fields); // Submit form
        $A.get('e.force:refreshView').fire();
    },
   /*  getWarrantyRec: function (component, event, helper) {
       helper.getpreviousWarrantyRec(component, event); 
       var warrantyRec = component.find("projectlookupid").get("v.value");
        if(warrantyRec != ''){
            var action = component.get("c.warrantydetails");
            action.setParams({
                projectrecId: warrantyRec
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result != ''){
                        component.set("v.warrantyList",result);
                       // component.set("v.isOpen", false);
                        component.set("v.isWarranty",true); 
                    }
                }
            });
            $A.enqueueAction(action); 
        }
        else if(warrantyRec == ''){
            component.set("v.isWarranty",false);
            //component.set("v.isOpen", true);
        }
    }, */
    CloseModel : function (component, event, helper) {
        component.set("v.isWarranty",false);
        component.set("v.isnewwarranty",true);
        if(component.get("v.isnewwarranty") == true){
           helper.getparentrecord(component, event);
        }
         //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                   //dismissActionPanel.fire();
       // component.set("v.isnewwarranty",true);
      //  component.set("v.isOpen", true);
    },
    SaveModel : function (component, event, helper) {
       // var contractValue = component.get("v.value");
        var wList = component.get("v.warrantyList");
        for(var i=0; i < wList.length; i++){
            if(wList[i].selectedWarranty == true){
                component.set("v.value",wList[i].WarrantyRec.Id);
                component.set("v.lagValue",wList[i].LagValue);
            }
        }
        helper.savehelper(component, event);
        window.setTimeout(
            $A.getCallback(function () {
                
                if(component.get("v.value") == null){
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Please Select Warranty!",
                        "message": "Please Select Warranty",
                        closeCallback: function () {}
                    });
                    component.set("v.isWarranty",true);
                }else{
                    component.set("v.isWarranty",false);
                    component.set("v.isnewwarranty",true);
                    // component.set("v.isOpen", true);
                }
            }), 500
        );
    },
    optionSelected : function (component, event, helper) {
        //var recordName = event.target.getAttribute("value");
        //component.set("v.value",recordName);
       // alert('hii');
        var wList = component.get("v.warrantyList");
        for(var i=0; i < wList.length; i++){
           // alert('hello'+wList[i].selectedWarranty);
            if(wList[i].selectedWarranty == true){
              //  alert('hjjjjjj');
                component.set("v.value",wList[i].WarrantyRec.Id);
               // alert(component.get("v.value"));
                component.set("v.lagValue",wList[i].LagValue);
            }
        }
        helper.savehelper(component, event);
    },
   
    
})