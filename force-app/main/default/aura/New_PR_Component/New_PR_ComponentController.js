({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        console.log('value-->>',{value});
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        var action2 = component.get("c.getFieldSet");
        action2.setParams({
            objectName: 'buildertek__Pricing_Request__c',
            fieldSetName: 'buildertek__New_PR_ComponentFields'
        });
        action2.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.Spinner", false);
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log('listOfFields0-->>',{listOfFields0});
                component.set("v.listOfFields0", listOfFields0);
            }
        });
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
            console.log('parentRecordId---->>',{parentRecordId});
            component.set("v.Spinner", false);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
            component.set("v.parentRecordId", parentRecordId);
            console.log('parentRecordId-->>',{parentRecordId});
        }
        if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getobjectName");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                component.set("v.Spinner", false);
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    if(objName == 'buildertek__Project__c'){
                        component.set("v.parentprojectRecordId", parentRecordId);
                    }
                } 
            });
            $A.enqueueAction(action);
        }
        $A.enqueueAction(action2);
    },

    closeModel: function(component, event, helper) {
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
        window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
   },

  handleSubmit : function(component, event, helper) {
      console.log('handleSubmit');
      event.preventDefault();  
      var fields = event.getParam('fields');
      console.log('fields: ' + JSON.stringify(fields));
      var data = JSON.stringify(fields);
      console.log('data-->>',{data});
      var action = component.get("c.saveRecord");
      action.setParams({
          "data": data
      });
      action.setCallback(this, function (response) {
          var state = response.getState();
          var error = response.getError();
          console.log('Error =>',{error});
          if (state === "SUCCESS") {
              console.log('success');
              console.log(response.getReturnValue());
              var recordId = response.getReturnValue();
              console.log('recordId-->>',{recordId});
              
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  "type": "Success",
                  "title": "Success!",
                  "message": "The record has been created successfully."
              });
              toastEvent.fire();

              var saveNnew = component.get("v.isSaveNew");
              console.log('saveNnew: ' + saveNnew);

              if(saveNnew){
                  $A.get('e.force:refreshView').fire();
              }
              else{
                  console.log('---Else---');
                  console.log('saveAndClose');
                  var navEvt = $A.get("e.force:navigateToSObject");
                  navEvt.setParams({
                      "recordId": recordId,
                      "slideDevName": "Detail"
                  });
                  navEvt.fire();
                  component.set("v.parentRecordId", null);

                  var focusedTabId = '';
                  var workspaceAPI = component.find("workspace");
                  workspaceAPI.getFocusedTabInfo().then(function(response) {
                      focusedTabId = response.tabId;
                  })

                  window.setTimeout(
                      $A.getCallback(function() {
                          workspaceAPI.closeTab({tabId: focusedTabId});
                      }), 1000
                  );
              }
          }
          else if (state === "ERROR") {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  "type": "Error",
                  "title": "Error!",
                  "message": "Something Went Wrong"
              });
              toastEvent.fire();
              console.log('error', response.getError());
          }
      });
      $A.enqueueAction(action);
  },

  handlesaveNnew : function(component, event, helper) {
      component.set("v.isSaveNew", true);
  },

  saveNnew : function(component, event, helper) {
      component.set("v.saveAndNew", true);
      console.log('saveNnew');
  }
})