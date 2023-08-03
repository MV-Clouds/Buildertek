({
    doInit: function (component, event, helper) {
        component.set("v.isOpen", true);
        component.set("v.Spinner", true);

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
        console.log('parent-------'+ parentRecordId);
        helper.fetchpricebooks(component, event, helper);
        helper.getFieldSetforTakeOffLines(component, event, helper , parentRecordId);
    },

    handleComponentEvent: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newprojecttakeoffline.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },

    handleComponentEvents: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newprojecttakeoffline.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },

    closeModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getFocusedTabInfo().then(function (response) {
        //         var focusedTabId = response.tabId;
        //         workspaceAPI.closeTab({
        //             tabId: focusedTabId
        //         });
        //     })
        //     .catch(function (error) {
        //         console.log(error);
        //     });
        // $A.get("e.force:closeQuickAction").fire();
        // component.set("v.isOpen", false);
        // var parentRecordId = component.get("v.parentRecordId");
        // if (parentRecordId != undefined) {

        // } else {
        //     var url = location.href;
        //     var baseURL = url.substring(0, url.indexOf('/', 14));
        //     //alert('baseURL -------> '+baseURL);
        //     window.open(baseURL + '/lightning/o/buildertek__Project_Takeoff_Lines__c/list?filterName=Recent', '_self');
        // }

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        component.set("v.isOpen", false);
    },

    save: function (component, event, helper) {
        // alert('test');


        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if (selectedTradeType != undefined) {
            selTradeType = selectedTradeType.Id;
        } else {
            selTradeType = null;
        }

        var selectedprojecttakeoff = component.get("v.selectedprojecttakeoff");
        var parentRecordId = component.get("v.parentRecordId");
        var selectedPToff;
        if (parentRecordId != undefined) {
            selectedPToff = component.get("v.parentRecordId");
        } else {
            if (selectedprojecttakeoff != undefined) {
                selectedPToff = selectedprojecttakeoff.Id;
            } else {
                selectedPToff = null;
            }
        }



        component.set("v.newprojecttakeoffline.buildertek__Trade_Type__c", selTradeType);

        //component.set("v.newprojecttakeoffline.buildertek__Project_Takeoff__c", selectedPToff);
        var ProjtakeoffLineToInsert = JSON.stringify(component.get("v.newprojecttakeoffline"));
        if (selectedPToff != undefined) {
            // alert('test2--'); 
            component.set("v.Spinner", true);
            var action = component.get("c.savePToffline");
            action.setParams({
                takeoffLines: ProjtakeoffLineToInsert,
                PtoffId: selectedPToff
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.Spinner", false);
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    $A.get("e.force:closeQuickAction").fire();
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
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: ' Project Takeoff Line was created ',
                        messageTemplate: " Project Takeoff Line {0} was created",
                        /*   messageTemplateData: [{
                           url: baseURL+'/lightning/r/buildertek__Project_Takeoff_Lines__c/'+escape(result.Id)+'/view',
                           label: result.Name,
                           }],*/
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();

                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result.Id,
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                    // window.open ("/"+result.Id,"_Self");     
                }
            });
            $A.enqueueAction(action);
        } else {
            var pillTarget = component.find("errorId");
            $A.util.addClass(pillTarget, 'showErrorMessage');
        }

    },
    saveAndNew: function (component, event, helper) {
        console.log('saveAndNew Button Click');
        // component.set("v.Spinner", true);
        component.set("v.isSaveNew", true);
        // debugger;

        // var selectedTradeType = component.get("v.selectedTradeType");
        // var selTradeType;
        // if (selectedTradeType != undefined) {
        //     selTradeType = selectedTradeType.Id;
        // } else {
        //     selTradeType = null;
        // }
        // var selectedprojecttakeoff = component.get("v.selectedprojecttakeoff");
        // var parentRecordId = component.get("v.parentRecordId");
        // var selectedPToff;
        // if (parentRecordId != undefined) {
        //     selectedPToff = component.get("v.parentRecordId");
        // } else {
        //     if (selectedprojecttakeoff != undefined) {
        //         selectedPToff = selectedprojecttakeoff.Id;
        //     } else {
        //         selectedPToff = null;
        //     }
        // }
        // component.set("v.newprojecttakeoffline.buildertek__Trade_Type__c", selTradeType);
        // //component.set("v.newprojecttakeoffline.buildertek__Project_Takeoff__c", selectedPToff);
        // var ProjtakeoffLineToInsert = JSON.stringify(component.get("v.newprojecttakeoffline"));
        // if (selectedPToff != undefined) {
        //     var action = component.get("c.savePToffline");
        //     action.setParams({
        //         takeoffLines: ProjtakeoffLineToInsert,
        //         PtoffId: selectedPToff
        //     });
        //     action.setCallback(this, function (response) {
        //         var state = response.getState();
        //         if (state === "SUCCESS") {
        //             var url = location.href;
        //             var baseURL = url.substring(0, url.indexOf('/', 14));
        //             var result = response.getReturnValue();
        //             component.set("v.newprojecttakeoffline", null);
        //             component.set("v.Spinner", false);
        //             var toastEvent = $A.get("e.force:showToast");
        //             toastEvent.setParams({
        //                 mode: 'sticky',
        //                 message: ' Project Takeoff Line was created',
        //                 messageTemplate: " Project Takeoff Line {0} was created",
        //                 messageTemplateData: [{
        //                     url: baseURL + '/lightning/r/buildertek__Project_Takeoff_Lines__c/' + escape(result.Id) + '/view',
        //                     label: result.Name,
        //                 }],
        //                 type: 'success',
        //                 duration: '10000',
        //                 mode: 'dismissible'
        //             });
        //             toastEvent.fire();
        //             var navEvt = $A.get("e.force:navigateToSObject");
        //             navEvt.setParams({
        //                 "recordId": result.Id,
        //                 "slideDevName": "related"
        //             });
        //             navEvt.fire();
        //             window.location.reload(true);
        //         }
        //     });
        //     $A.enqueueAction(action);
        // }

    },

    changefamily: function (component, event, helper) {

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        // component.set('v.newprojecttakeoffline.buildertek__Item_Name__c', '');
        //  component.set('v.newprojecttakeoffline.buildertek__Unit_Price__c', '');  

    },
    changeEvent: function (component, event, helper) {

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();

        var pribooknames = component.get("v.pricebookName");
        var action = component.get("c.getProductfamilyRecords");
        // set param to method  
        action.setParams({
            'ObjectName': "Product2",
            'parentId': component.get("v.pricebookName")
        });
        // set a callBack    
        action.setCallback(this, function (response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                // helper.fetchPickListVal(component, event, helper);
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listofproductfamily", storeResponse);

                if (component.get("v.listofproductfamily").length > 0) {
                    component.set("v.productfamily", component.get("v.listofproductfamily")[0].productfamilyvalues);
                }

            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },

    handleSubmit : function(component, event, helper) {
        component.set("v.Spinner", true);
          console.log('handleSubmit');
          event.preventDefault();  
          var fields = event.getParam('fields');
          console.log('fields: ' + JSON.stringify(fields));
          var data = JSON.stringify(fields);
          console.log('data-->>',{data});
          var action = component.get("c.saveTakeOffLineRecords");
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
                //   console.log('recordId-->>',{recordId});
                //   var listofPOItems = component.get("v.listofPOItems");
                  component.set("v.Spinner", false);              
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
})