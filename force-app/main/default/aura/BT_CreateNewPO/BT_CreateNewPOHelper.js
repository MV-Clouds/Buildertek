({
  savehelper: function (component, event) {
    var recordId = component.get("v.recordId");
    var vender = component.get("v.vender");
    var billToAddress = component.get("v.billToAddress");
    var description = component.get("v.description");
    var POtype = component.get("v.POtype");
    var requiredDeliverydate = component.get("v.requiredDeliverydate");
    var shiptoAddress = component.get("v.ShipAddress");
    var shiptoCity = component.get("v.shiptoCity");
    var shiptoState = component.get("v.shiptoState");
    var shiptoZip = component.get("v.shiptoZip");
    // var shiptoCountry = component.get("v.shiptoCountry");
    var shiptoCountry = component.find("shiptocntryId").get("v.value");
    var value = component.get("v.value");
    // alert('shiptoCountry---'+shiptoCountry);
    var action = component.get("c.saveNewPO");
    var objectName = component.get("v.objectAPIName");
    action.setParams({
      objName : objectName,  
        recordId :recordId,
      vender: vender,
      billToAddress: billToAddress,
      description: description,
      POtype: POtype,
      requiredDeliverydate: requiredDeliverydate,
      shiptoAddress: shiptoAddress,
      shiptoCity: shiptoCity,
      shiptoState: shiptoState,
      shiptoZip: shiptoZip,
      shiptoCountry: shiptoCountry,
      contractlinelist : value,
    });
    action.setCallback(this, function (response) {
      var result = response.getState();
      console.log("savepurchaseorder::", result);

      if (result === "SUCCESS") {
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
              console.log("Error", JSON.stringify(error));
          });
          component.set("v.purchaseOrderId", response.getReturnValue());
      } else {
        console.log("There was a problem : " + response.getError());
      }
        var purchaseOrderid = component.get("v.purchaseOrderId");
        if(purchaseOrderid != null && purchaseOrderid != '' && purchaseOrderid != undefined){
          setTimeout(function () { 
              var navEvt = $A.get("e.force:navigateToSObject");
              navEvt.setParams({
                  recordId: purchaseOrderid,
                  slideDevName: "detail"
              });
              navEvt.fire(); 
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  type: "Success",
                  title: "Success!",
                  message: "Purchase Order has been created successfully.",
              });
              toastEvent.fire();
          }, 500);
      }
      component.set("v.isOpen", false);
    });
    $A.enqueueAction(action);
  },
});