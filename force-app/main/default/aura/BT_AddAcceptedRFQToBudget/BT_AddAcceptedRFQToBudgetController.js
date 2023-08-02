({
  doInit: function (component, event, helper) {
    var pageNumber = component.get("v.PageNumber");
    var pageSize = component.get("v.pageSize");
    helper.getBudgetList(component, pageNumber, pageSize);
  },

  handleNext: function (component, event, helper) {
    var pageNumber = component.get("v.PageNumber");
    var pageSize = component.get("v.pageSize");
    pageNumber++;
    helper.getBudgetList(component, pageNumber, pageSize);
  },

  handlePrev: function (component, event, helper) {
    var pageNumber = component.get("v.PageNumber");
    var pageSize = component.get("v.pageSize");
    pageNumber--;
    helper.getBudgetList(component, pageNumber, pageSize);
  },

  handleCheck: function (component, event, helper) {
    var selectedId = event.getSource().get("v.text");
    var records = component.get("v.recordList");
    for (var i in records) {
      if (records[i].Id == selectedId) {
        records[i].budgetCheck = !records[i].budgetCheck;
      }
    }
    component.set("v.recordList", records);
  },

  selectAll: function (component, event, helper) {
    var selectedHeaderCheck = event.getSource().get("v.value");
    var recordList = component.get("v.recordList");
    var getAllId = component.find("checkBudget");
       if (getAllId != undefined) {
    if (recordList != null) {
      if (recordList.length > 1) {
        if (!Array.isArray(getAllId)) {
          if (selectedHeaderCheck == true) {
            component.find("checkBudget").set("v.value", true);
          } else {
            component.find("checkBudget").set("v.value", false);
          }
        } else {
          if (selectedHeaderCheck == true) {
            for (var i = 0; i < getAllId.length; i++) {
              component.find("checkBudget")[i].set("v.value", true);
              var checkbox = component.find("checkBudget")[i].get("v.text");
              recordList[i].budgetCheck = true;
            }
          } else {
            for (var i = 0; i < getAllId.length; i++) {
              component.find("checkBudget")[i].set("v.value", false);

              var checkbox = component.find("checkBudget")[i].get("v.text");
              //var recordList = component.get("v.masterBudgetsList");
              recordList[i].budgetCheck = false;
            }
          }
        }
      } else {
        var i = 0;
        if (selectedHeaderCheck == true) {
         // component.find("checkBudget").set("v.value", true);
         // var checkbox = component.find("checkBudget").get("v.text");
          //recordList[i].budgetCheck = true;
        } else {
          component.find("checkBudget").set("v.value", false);

          var checkbox = component.find("checkBudget").get("v.text");
          var recordList = component.get("v.recordList");
          recordList[i].budgetCheck = false;
        }
      }
    }
       }
  },

  addToBudget: function (component, event, helper) {
    var records = component.get("v.recordList");
    var budgetIds = [];
    for (var i in records) {
      if (records[i].budgetCheck) {
        budgetIds.push(records[i].Id);
      }
    }
    if(budgetIds.length>0){
      helper.addRFQToBudget(component, event, helper, budgetIds);
    }else{
      helper.showErrorToast(component,event,helper,'Error!','Please Select Budget.');
    }
  },

  closeModal: function (component, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },
});