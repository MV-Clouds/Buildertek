({
      doInit: function (component, event, helper) {
          var recId = component.get("v.recordId");
          var action = component.get("c.getowner");
          //var action = component.get("c.getfields");
          action.setParams({
              "recId":recId
          });
          action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result == true){
                       component.set("v.istimecard",true);
                    }else{
                       component.set("v.istimecard",false); 
                    }
                }
            }
        })
        $A.enqueueAction(action);
      },
      
     sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    
    
   /*  handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    }*/
})