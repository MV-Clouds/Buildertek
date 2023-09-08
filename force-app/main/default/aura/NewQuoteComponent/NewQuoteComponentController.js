({
    doInit : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        console.log('value-->>',{value});
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        var action2 = component.get("c.getFieldSet");
        action2.setParams({
            objectName: 'buildertek__Quote__c',
            fieldSetName: 'buildertek__New_Quote_ComponentFields'
        });
        action2.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log({listOfFields0});
                component.set("v.listOfFields0", listOfFields0);
            }
            
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        });
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
            console.log('parentRecordId---->>',{parentRecordId});
            // component.set("v.Spinner", false);
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
                // component.set("v.Spinner", false);
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    console.log('objName '+objName);
                    if(objName == 'buildertek__Project__c'){
                        component.set("v.parentprojectRecordId", parentRecordId);
                    } if(objName == 'Opportunity'){
                        component.set("v.parentOppRecordId", parentRecordId);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        $A.enqueueAction(action2);
        helper.masterQuoteRecord(component, event, helper);
    },

    closeModel: function(component, event, helper) {
          var workspaceAPI = component.find("workspace");
          workspaceAPI.getFocusedTabInfo().then(function(response) {
              var focusedTabId = response.tabId;
              workspaceAPI.closeTab({tabId: focusedTabId});
          })
          .catch(function(error) {
              console.log(error);
              //force:navigateToObjectHome
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    "scope": "buildertek__Quote__c"
                });
                homeEvent.fire();
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
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

        console.log('handleSubmit');
        event.preventDefault();
        var fields = event.getParam('fields');
        console.log('fields: ' + JSON.stringify(fields));
        var data = JSON.stringify(fields);
        console.log('data-->>',{data});
        debugger;
        var action = component.get("c.saveRecord");
        action.setParams({
            "data": data,
            "masterQuoteId":component.get('v.selectedMasterQuoteId')
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

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        });
        $A.enqueueAction(action);
    },

    handlesaveNnew : function(component, event, helper) {
        component.set("v.isSaveNew", true);
    },

    saveNnew : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        component.set("v.saveAndNew", true);
        console.log('saveNnew');
    },
    handleSelectedRow:function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedMasterQuoteId", selectedRows[0].Id);
        console.log(selectedRows[0].Id);
    },

    handleLoadMoreQuotes:function(component, event, helper) {
        helper.getMoreQuotes(component, component.get('v.rowsToLoad')).then($A.getCallback(function (getMasterQuoteRecords) {
            if (component.get('v.masterQuoteData').length == component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
            } else {
                var currentMasterQuoteData = component.get('v.masterQuoteData');
                var newMasterQuoteData = [...currentMasterQuoteData , ...getMasterQuoteRecords];
                component.set('v.masterQuoteData', newMasterQuoteData);
            }
            event.getSource().set("v.isLoading", false);
        }));
    },
})