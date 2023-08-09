({
  getBudgetList: function (component, pageNumber, pageSize) {
    var recId = component.get("v.recordId");
    var action = component.get("c.getBudgetData");
    action.setParams({
      pageNumber: pageNumber,
      pageSize: pageSize,
      RFQRecId : recId
    });
    action.setCallback(this, function (result) {
      var state = result.getState();
      if (component.isValid() && state === "SUCCESS") {
        var resultData = result.getReturnValue();
        for(var i in resultData.recordList){
            resultData.recordList[i].budgetCheck =false;
        }
        component.set("v.recordList", resultData.recordList);
        component.set("v.PageNumber", resultData.pageNumber);
        component.set("v.TotalRecords", resultData.totalRecords);
        component.set("v.RecordStart", resultData.recordStart);
        component.set("v.RecordEnd", resultData.recordEnd);
        component.set(
          "v.TotalPages",
          Math.ceil(resultData.totalRecords / pageSize)
        );
      }
    });
    $A.enqueueAction(action);
  },

  addRFQToBudget: function (component, event, helper,budgetIds) {
    var recordId = component.get("v.recordId");
    if (recordId != undefined && recordId != "") {
      var action = component.get("c.addAcceptedRFQToBudget");
      action.setParams({
        recordId: recordId,
        budgetIds:JSON.stringify(budgetIds)
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          console.log("Response::", result);
          if (result != undefined && result != "" && result == "200") {
            helper.showSuccessToast(
              component,
              event,
              helper, 
              "Success!",
              'Successfully added RFQ to Budget!'
            );
          } else if (
            result != undefined &&
            result != "" &&
            result == "404"
          ) {
            helper.showWarningToast(
              component,
              event,
              helper,
              "Warning!",
              "You cannot add an RFQ to the Budget if it has not been Accpeted by the Vendor"
            );
          }else{
              helper.showErrorToast(
                  component,
                  event,
                  helper,
                  "Error occurs",
                  "Something went wrong!"
              );
          }
          $A.get("e.force:closeQuickAction").fire();
        } else {
          helper.showErrorToast(
            component,
            event,
            helper,
            "Error occurs",
            "Something went wrong!"
          );
          $A.get("e.force:closeQuickAction").fire();
        }
      });
      $A.enqueueAction(action);
    }
  },

  showErrorToast: function (component, event, helper, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      duration: "5000",
      key: "info_alt",
      type: "error",
      mode: "pester",
    });
    toastEvent.fire();
  },

  showSuccessToast: function (component, event, helper, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      duration: "5000",
      key: "info_alt",
      type: "success",
      mode: "pester",
    });
    toastEvent.fire();
  },

  showWarningToast: function (component, event, helper, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      duration: "5000",
      key: "info_alt",
      type: "warning",
      mode: "pester",
    });
    toastEvent.fire();
  },
});