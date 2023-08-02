({
  init: function (component, event, helper) {
    component.set("v.Spinner", true);
    var dbAction = component.get("c.getTemplates");
    dbAction.setParams({
      recordId: component.get("v.recordId"),
    });
    dbAction.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.templates", response.getReturnValue());
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(dbAction);
  },

  preiewEmailTemplate: function (component, event, helper) {
    var selectedTemplate = component.get("v.selectedTemplate");
    console.log("selectedTemplate => " + selectedTemplate);

    if (selectedTemplate != undefined) {
      component.set("v.isTemplateSelected", true);

      var recordId = component.get("v.recordId");
      console.log("recordId here :: ", recordId);
      var action = component.get("c.getSalesOrderLines");
      action.setParams({
        recordId: recordId,
        templateId: component.get("v.selectedTemplate"),
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          console.log("result => ", { result });
          component.set("v.changeOrderLines", result);
        }
      });
      $A.enqueueAction(action);
    }
  },

  closeModel: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },

  sendEmail: function (component, event, helper) {
    component.set("v.Spinner", true);
    var toIds = [];
    var ccIds = [];
    var to = component.get("v.selectedToContact");
    var cc = component.get("v.selectedCcContact");
    to.forEach(function (v) {
      toIds.push(v.Id);
    });
    cc.forEach(function (v) {
      ccIds.push(v.Id);
    });
    var subject = "SalesOrder [ref:" + component.get("v.recordId") + "]";
    console.log("htmls Body => ", component.get("v.changeOrderLines"));
    console.log("htmls Body => ", component.get("v.recordId"));
    console.log("htmls Body => ", component.get("v.selectedTemplate"));
    console.log("htmls Body => ", toIds);
    console.log("htmls Body => ", ccIds);
    console.log("htmls Body => ", subject);
    if (toIds.length != 0) {
      var action = component.get("c.sendProposal");
      action.setParams({
        htmlBody: component.get("v.changeOrderLines"),
        recordId: component.get("v.recordId"),
        templateId: component.get("v.selectedTemplate"),
        to: toIds,
        cc: ccIds,
        Emailsubject: subject,
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        //var subject = 'changeOrder[ref:'+component.get("v.recordId")+']';
        console.log("returned state :; ", { state });

        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          debugger;
          console.log("result for email :; ", { result });
          if (result === "Success") {
            component.set("v.Spinner", false);
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Success!",
              type: "success",
              message: "Email Sent Successfully",
            });
            toastEvent.fire();
          } else {
            var errors = response.getError();
            console.log("error msg  ==>  ", { errors });
            $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "error",
              message: result,
            });
            toastEvent.fire();
          }
          $A.get("e.force:refreshView").fire();
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set("v.Spinner", false);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Error!",
        type: "error",
        message: "Please select To Address to send Email",
      });
      toastEvent.fire();
    }
  },
});