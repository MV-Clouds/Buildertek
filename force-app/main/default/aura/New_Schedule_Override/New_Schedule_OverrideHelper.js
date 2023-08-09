({
  getParameterByName: function (component, event, name) {
    console.log("===getParameterByName===");
    console.log("name1 : " + name);
    name = name.replace(/[\[\]]/g, "\\$&");
    console.log("name2 : " + name);
    var url = window.location.href;
    var regex = new RegExp("[?&]" + name + "(=1.([^&#]*)|&|#|$)");
    var results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return "";
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  },
  getFields: function (component, event, helper) {
    console.log("===getFields===");
    var action = component.get("c.getFieldSet");
    action.setParams({
      objectName: "buildertek__Schedule__c",
      fieldSetName: "buildertek__ScheduleFields",
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS" && response.getReturnValue()) {
        var listOfFields = JSON.parse(response.getReturnValue());
        component.set("v.listOfFields", listOfFields);
      } else {
        console.log("Error");
      }
    });
    $A.enqueueAction(action);
  },

  savefunc: function (component, event, helper) {
    console.log("===savefunc===");

    var newSchId = component.get("v.schedulerecId");
    var masterItems = component.get("v.scheduleLineItems");
    var action = component.get("c.newSchedule");
    var scheduleId = [];
    scheduleId.push(component.get("v.selectedMasterId"));
    console.log("scheduleId => " + scheduleId);
    action.setParams({
      newScheduleId: newSchId,
      masterId: scheduleId,
      // masterSchItems : masterItems
    });
    action.setCallback(this, function (response) {
      var ScheduleItems = response.getReturnValue();
      // alert(response.getState());
      console.log("check new ScheduleItems ==> ", { ScheduleItems });
      // debugger;
      if (response.getState() == "SUCCESS") {
        var workspaceAPI = component.find("workspace");
        var isSaveNew = component.get("v.isSaveAndNew");
        component.set("v.Spinner", false);
        component.set("v.showMessage", false);
        if (!isSaveNew) {
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
        }
        // alert(JSON.stringify(ScheduleItems));
        // setTimeout(function () {
        //component.set('v.isLoading', false);
        var payload = event.getParams().response;
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf("/", 14));

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          mode: "sticky",
          message: "Schedule created successfully",
          messageTemplate: "Schedule created successfully.",
          messageTemplateData: [
            {
              url:
                baseURL +
                "/lightning/r/buildertek__Schedule__c/" +
                escape(payload.id) +
                "/view",
              label: payload.name,
            },
          ],
          type: "success",
          duration: "5000",
          mode: "dismissible",
        });
        toastEvent.fire();
        if (!isSaveNew) {
          var navEvt = $A.get("e.force:navigateToSObject");
          navEvt.setParams({
            recordId: payload.id,
            slideDevName: "related",
          });
          //navEvt.fire();
          component.set("v.isSaveAndNew", false);
          console.log(payload);
          let myPromise = new Promise(function (myResolve, myReject) {
            navEvt.fire();
            //toastEvent.fire();
            if (component.get("v.Iscommunity")) {
              location.reload();
            } else {
              setTimeout(function () {
                myResolve(); // when successful
                myReject();
              }, 2500);
            }
            // when error
          });

          myPromise.then(function (value) {
            if (payload) {
              // window.open(baseURL + '/lightning/r/buildertek__Schedule__c/' + escape(payload.id) + '/view','_top');
            } else {
              //location.reload();
            }
          });
        } else {
          $A.get("e.force:refreshView").fire();
        }

        // }, 500);
      } else {
        console.log(response);
        // alert(response.getError()[0].message);
      }
      // component.set("v.scheduleLineItems", ScheduleItems);
    });
    $A.enqueueAction(action);
  },

  getProjectManagerId: function (component, event, RecordId) {
    console.log("===getProjectManagerId===");
    var action = component.get("c.getProjectManager");
    action.setParams({ recordId: RecordId });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        if (result != "Error") {
          component.set("v.ProjectManagerId", result);
        }
      } else if (state === "INCOMPLETE") {
        console.log("Incomplete Error Line 140 in helper");
      } else if (state === "ERROR") {
        var errors = response.getError();
        console.error(errors);
        if (errors) {
          if (errors[0] && errors[0].message) {
            console.log("Error message: " + errors[0].message);
          }
        } else {
          console.log("Unknown error");
        }
      }
    });
    $A.enqueueAction(action);
  },
});