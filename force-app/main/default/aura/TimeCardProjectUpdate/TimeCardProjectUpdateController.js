({
      doInit: function (component, event, helper) {
          var recId = component.get("v.recordId");
          var action = component.get("c.gettimecardRec");
          action.setParams({
              "recId":recId
          });
          action.setCallback(this,function(response){
              if(response.getState() == "SUCCESS"){
                  var state = response.getState();
                  if (state === "SUCCESS") {
                      var result = response.getReturnValue();
                      component.set("v.istimecard",true);
                  }
              }
          })
          $A.enqueueAction(action);
      },
    updatetimecard : function (component, event, helper) {
        var action = component.get("c.updatetimecardRec");
          action.setParams({
              "recId":component.get("v.recordId")
          });
          action.setCallback(this,function(response){
              if(response.getState() == "SUCCESS"){
                  var state = response.getState();
                  if (state === "SUCCESS") {
                      var result = response.getReturnValue();
                      if(result == 'nobudgetlist'){
                          component.set("v.istimecard",false);
                          component.set("v.timecard",true);
                      }else if(result == 'success'){
                          component.set("v.istimecard",false);
                          var navEvt = $A.get("e.force:navigateToSObject");
                          navEvt.setParams({
                              "recordId": component.get('v.recordId'),
                              "slideDevName": "related"
                          });
                          navEvt.fire();
                          $A.get('e.force:refreshView').fire();
                      }
                     /* var navEvt = $A.get("e.force:navigateToSObject");
                      navEvt.setParams({
                          "recordId": component.get('v.recordId'),
                          "slideDevName": "related"
                      });
                      navEvt.fire();
                      $A.get('e.force:refreshView').fire();*/
                  }
              }
          })
          $A.enqueueAction(action);
    },
    closeModel: function (component, event, helper) {
        var action = component.get("c.updatetimecardRecforcancel");
          action.setParams({
              "recId":component.get("v.recordId"),
              "oldproject" : 'setoldproject'
          });
          action.setCallback(this,function(response){
              if(response.getState() == "SUCCESS"){
                  var state = response.getState();
                  if (state === "SUCCESS") {
                      var result = response.getReturnValue();
                      if(result == 'nobudgetlist'){
                          component.set("v.istimecard",false);
                          component.set("v.timecard",false);
                          var navEvt = $A.get("e.force:navigateToSObject");
                          navEvt.setParams({
                              "recordId": component.get('v.recordId'),
                              "slideDevName": "related"
                          });
                          navEvt.fire();
                          $A.get('e.force:refreshView').fire();
                      }
                  }
              }
          })
          $A.enqueueAction(action);
        
    },
})