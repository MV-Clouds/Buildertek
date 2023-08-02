({
  doInit: function (component, event, helper) {
    debugger;
    var loc = location.href.split("id=")[1];
    var recordId;
    if (loc) {
      recordId = location.href.split("id=")[1].split("&dummy=")[0];
    }

    if (recordId) {
      component.set("v.recordId", recordId);
    } else {
      recordId = component.get("v.recordId");
      component.set("v.recordId", recordId);
    }

    var workspaceAPI = component.find("workspace");
    workspaceAPI.getEnclosingTabId().then((response) => {
      let opendTab = response.tabId;
      workspaceAPI.setTabLabel({
        tabId: opendTab,
        label: "CO Payment Tracking Lines",
      });
      workspaceAPI.setTabIcon({
        tabId: opendTab,
        icon: "custom:custom5",
        iconAlt: "CO Payment Tracking Lines",
      });
    });

    helper.getcurr(component, event, helper);
    helper.fetchSOVLinesList(component, event, helper, recordId);
    helper.getHeaderDetails(component, event, helper, recordId);
  },

  UpdateCOPayAppLines: function (component, event, helper) {
    component.set("v.Spinner", true);
    component.set("v.showMessage", true);
    var action = component.get("c.updateLines");

    action.setParams({
      recordId: component.get("v.recordId"),
      LinesList: component.get("v.sovLineList"),
    });

    action.setCallback(this, function (response) {
      debugger;
      console.log("Inside setcallback method of helper");
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.Spinner", false);
        component.set("v.showMessage", false);
        var result = response.getReturnValue();
        console.log({result});

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: component.get("v.recordId"),
          slideDevName: "detail",
        });
        navEvt.fire();

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          message: "Tracking Lines Updated Successfully",
          type: "Success",
        });
        toastEvent.fire();

        $A.get("e.force:refreshView").fire();
      } else {
        component.set("v.Spinner", false);
        component.set("v.showMessage", false);
      }
    });
    console.log("Exiting helper");
    $A.enqueueAction(action);
  },

  closeModal: function (component, event, helper) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: component.get("v.recordId"),
      slideDevName: "detail",
    });
    navEvt.fire();

    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      var focusedTabId = response.tabId;
      window.setTimeout(
        $A.getCallback(function () {
          workspaceAPI.closeTab({ tabId: focusedTabId });
        }),
        1000
      );
    });
  },

  NavToSovRec: function (component, event, helper) {
    var COId = event.currentTarget.dataset.change;

    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: COId,
      slideDevName: "detail",
    });
    navEvt.fire();

    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      var focusedTabId = response.tabId;
      window.setTimeout(
        $A.getCallback(function () {
          workspaceAPI.closeTab({ tabId: focusedTabId });
        }),
        1000
      );
    });
  },

  navtoParent: function (component, event, helper) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: component.get("v.recordId"),
      slideDevName: "detail",
    });
    navEvt.fire();

    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function (response) {
      var focusedTabId = response.tabId;
      window.setTimeout(
        $A.getCallback(function () {
          workspaceAPI.closeTab({ tabId: focusedTabId });
        }),
        1000
      );
    });
  },

  changeValue: function (component, event, helper) {
    debugger;
    var localId = event.getSource().getLocalId();
    var value = event.getSource().get("v.value");
    event.getSource().set("v.value", value);

    var workCompletedThisPeriod;
    var inputField = event.getSource();

    if (localId == "buildertek__Work_Completed_This_Period__c") {
      workCompletedThisPeriod = event.getSource().get("v.value");
    }

    var updatedLinesInGroup = component.get("v.sovLineList");
    var updatedLines = [];

    var recIndex = event.getSource().get("v.title");

    if (updatedLinesInGroup[recIndex]) {
      var recordItem = updatedLinesInGroup[recIndex];
      if (!value) {
        value = 0;
      }

      if (localId == "buildertek__Scheduled_Value__c") {
        updatedLinesInGroup[recIndex].buildertek__Scheduled_Value__c =
          parseInt(value);
      }

      if (localId == "buildertek__Work_Completed_From_Previous_App__c") {
        updatedLinesInGroup[
          recIndex
        ].buildertek__Work_Completed_From_Previous_App__c = parseInt(value);
      }

      if (localId == "buildertek__Work_Completed_This_Period__c") {
        updatedLinesInGroup[
          recIndex
        ].buildertek__Work_Completed_This_Period__c = Number(value);
      }

      if (Math.sign(Number(recordItem.buildertek__Scheduled_Value__c)) === -1) {
      }

      updatedLinesInGroup[recIndex].buildertek__Balance_To_Finish__c =
        Number(recordItem.buildertek__Scheduled_Value__c) -
        (Number(recordItem.buildertek__Work_Completed_From_Previous_App__c) +
          Number(recordItem.buildertek__Work_Completed_This_Period__c));

      var TotalAmount =
        parseInt(recordItem.buildertek__Work_Completed_From_Previous_App__c) +
        parseFloat(recordItem.buildertek__Work_Completed_This_Period__c);

      var balToFinish =
        Number(recordItem.buildertek__Scheduled_Value__c) -
        Number(
          TotalAmount -
            Number(recordItem.buildertek__Work_Completed_This_Period__c)
        );

      if (localId == "buildertek__Work_Completed_This_Period__c") {
        if (
          Math.sign(Number(recordItem.buildertek__Scheduled_Value__c)) === -1
        ) {
          if (balToFinish > workCompletedThisPeriod) {
            inputField.setCustomValidity(
              "Work Completed This Period must be less than Balance To Finish"
            );
            component.set("v.IsSaveDisable", true);
          } else {
            inputField.setCustomValidity("");
            component.set("v.IsSaveDisable", false);
          }
        } else if (
          Math.sign(Number(recordItem.buildertek__Scheduled_Value__c)) === 1
        ) {
          if (workCompletedThisPeriod > balToFinish) {
            inputField.setCustomValidity(
              "Work Completed This Period must be less than Balance To Finish"
            );
            component.set("v.IsSaveDisable", true);
          } else {
            inputField.setCustomValidity("");
            component.set("v.IsSaveDisable", false);
          }
        }
      }
    }

    component.set("v.sovLineList", updatedLinesInGroup);
  },
});