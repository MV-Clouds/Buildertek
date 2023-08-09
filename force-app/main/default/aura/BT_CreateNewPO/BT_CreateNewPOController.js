({
  doInit: function (component, event, helper) {
    var pageRef = component.get("v.pageReference");
    var state = pageRef.state;
    var base64Context = state.inContextOfRef;
    if (base64Context.startsWith("1.")) {
      base64Context = base64Context.substring(2);
    }
    var addressableContext = JSON.parse(window.atob(base64Context));
    component.set("v.recordId", addressableContext.attributes.recordId);
    var recordId = component.get("v.recordId");
     var parentRecordId = component.get("v.recordId");
      if(parentRecordId != null && parentRecordId != '' && parentRecordId != undefined){
    var action = component.get("c.getobjectName");
                action.setParams({
                    recordId: parentRecordId,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var objName = response.getReturnValue();
                        component.set("v.objectAPIName", objName);
                        if(objName == 'buildertek__Project__c'){
                            component.set("v.recordId", parentRecordId);
                           // helper.CustomerAccount(component,event,helper);
                        }else if(objName == 'buildertek__RFQ__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Contract__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Change_Order__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Budget__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Accounting_Period__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Service_Request__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Project_Task__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Quote__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Cost_Codes__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'Contact'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Community__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'buildertek__Budget_Item__c'){
                            component.set("v.recordId", parentRecordId);
                        }else if(objName == 'Account'){
                            component.set("v.recordId", parentRecordId);
                        }
                    } 
                });
                $A.enqueueAction(action);
    var POAddressaction = component.get("c.getPOAddress");
    POAddressaction.setParams({
      recordId: component.get("v.recordId"),
    });
    POAddressaction.setCallback(this, function (res) {
      var state = res.getState();
      if (state === "SUCCESS") {
        console.log('Result::', JSON.stringify(res.getReturnValue()));
        var result = res.getReturnValue();
        //   if ( result != undefined && result.buildertek__Ship_To_Account__c != undefined && result.buildertek__Ship_To_Account__c != null) {
        //     component.set("v.billToAddress", result.buildertek__Ship_To_Account__c);
        //   }
        //   if (
        //     result != undefined &&
        //     result.buildertek__Ship_To_Account__r != undefined &&
        //     result.buildertek__Ship_To_Account__r != null
        //   ) {
        //     if (result.buildertek__Ship_To_Account__r.ShippingStreet != undefined) {
        //       component.set(
        //         "v.ShipAddress",
        //         result.buildertek__Ship_To_Account__r.ShippingStreet
        //       );
        //     }
        //     if (result.buildertek__Ship_To_Account__r.ShippingPostalCode != undefined) {
        //       component.set(
        //         "v.shiptoZip",
        //         result.buildertek__Ship_To_Account__r.ShippingPostalCode
        //       );
        //     }
        //     if (result.buildertek__Ship_To_Account__r.ShippingState != undefined) {
        //       component.set(
        //         "v.shiptoState",
        //         result.buildertek__Ship_To_Account__r.ShippingState
        //       );
        //     }
        //     if (result.buildertek__Ship_To_Account__r.ShippingCity != undefined) {
        //       component.set(
        //         "v.shiptoCity",
        //         result.buildertek__Ship_To_Account__r.ShippingCity
        //       );
        //     }
        //     if (result.buildertek__Ship_To_Account__r.ShippingCountry != undefined) {
        //       component.set(
        //         "v.newPo.buildertek__Ship_To_Country__c",
        //         result.buildertek__Ship_To_Account__r.ShippingCountry
        //       );
        //     }
        //   }
        // }
        if (result != undefined && result.buildertek__Ship_To_Account__c != undefined && result.buildertek__Ship_To_Account__c != null) {
          //component.set("v.billToAddress", result.buildertek__Ship_To_Account__c);
        }
        if (result != undefined) {
          if (result.buildertek__Address__c != undefined) {
            component.set("v.ShipAddress", result.buildertek__Address__c);
          }
          if (result.buildertek__Zip__c != undefined) {
            component.set("v.shiptoZip", result.buildertek__Zip__c);
          }
          if (result.buildertek__State__c != undefined) {
            component.set("v.shiptoState", result.buildertek__State__c);
          }
          if (result.buildertek__City__c != undefined) {
            component.set("v.shiptoCity", result.buildertek__City__c);
          }
          if (result.buildertek__Country__c != undefined) {
            component.set("v.newPo.buildertek__Ship_To_Country__c", result.buildertek__Country__c);
          }
        }
      }
    });
    $A.enqueueAction(POAddressaction);
      }
  },

  handleClose: function (component, event, helper) {
    component.set("v.isOpen", false);
    //window.history.back();
    var workspaceAPI = component.find("workspace");
    workspaceAPI
      .getFocusedTabInfo()
      .then(function (response) {
        var focusedTabId = response.tabId;
        workspaceAPI.closeTab({
          tabId: focusedTabId,
        });
      })
      .catch(function (error) {
        console.log("Error", error);
      });
  },

  onSave: function (component, event, helper) {
    helper.savehelper(component, event);
  },

  onSaveandNew: function (component, event, helper) {
    helper.savehelper(component, event);
    $A.get("e.force:refreshView").fire();
  },
  getContractRec: function (component, event, helper) {
   var options=[];
   var Vendervalue = component.get("v.vender")+'';
   if(Vendervalue != ''){
    var action = component.get("c.contractdetails");
    action.setParams({
      venderId: Vendervalue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
          if(result != ''){
              component.set("v.contractList",result);
              component.set("v.isOpen", false);
              component.set("v.isContract",true); 
          }
        /*  for(var j=0; j<result.length; j++){
              options.push({'label':result[j].Name +'   -   ' + result[j].buildertek__Revised_Contract_Amount__c ,'value':result[j].Id});
          }
          component.set("v.contractList",options); */
      }
    });
    $A.enqueueAction(action); 
   }
      else if(Vendervalue == ''){
       component.set("v.isContract",false);
       component.set("v.isOpen", true);
      }
  },
    CloseModel : function (component, event, helper) {
        component.set("v.isContract",false);
        component.set("v.isOpen", true);
        component.set("v.value",'');
        //component.set("v.vender",'');
    },
    SaveModel : function (component, event, helper) {
      /*  var contractValue = component.get("v.value");
        if(contractValue == null){
            component.find('notifLib').showNotice({
					"variant": "error",
					"header": "Please Select Contract!",
					"message": "Please Select Contract to Create Purchase Order.",
					closeCallback: function () {}
				});
            component.set("v.isContract",true);
            component.set("v.isOpen", false);
        }else{*/
            component.set("v.isContract",false);
            component.set("v.isOpen", true);
        //}
        
        
    },
    optionSelected : function (component, event, helper) {
        var recordName = event.target.getAttribute("value");
        component.set("v.value",recordName);
    },
   
});