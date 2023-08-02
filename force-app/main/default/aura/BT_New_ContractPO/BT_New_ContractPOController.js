({
    doInit : function(component, event, helper) {
         component.set("v.Spinner",false);
        component.set("v.isnew", true);
    },
    
    handleChangeButtonGroup:function(component, event, helper){
        var auraIdField = event.getSource().getLocalId();
        component.set("v.checkBoxValue",component.find(auraIdField).get("v.value"));
    },
    
    closeEditPopup1 :function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire()
        component.set("v.isnew", false);
        component.set("v.openModel", false);
    },
    
    isNext:function(component, event, helper){
        var optionSelected = component.get("v.checkBoxValue");
        if(optionSelected == 'option1'){
            component.set("v.Spinner",true);
            var action = component.get("c.createlines")
            action.setParams({
                "conId" : component.get("v.recordId") 
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    //alert(result);
                    component.set("v.contractList",result);
                    component.set("v.Spinner",false);
                    component.set("v.isnew", false);
                     var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Success',
                message: 'Purchase Order Created Successfully ',
                duration: "5000",
                key: "info_alt",
                type: "Success",
                mode: "pester",
            });
            toastEvent.fire();
                    
                   // $A.get('e.force:refreshView').fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.contractList"),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }
            });
            $A.enqueueAction(action)
        }else if(optionSelected == 'option2'){
            component.set("v.isnew", false);
            component.set("v.openModel", true);
        }else if(optionSelected == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'ERROR',
                message: 'Please Select an Option',
                duration: "5000",
                key: "info_alt",
                type: "error",
                mode: "pester",
            });
            toastEvent.fire();
        }
        
    },
    
      Save:function(component, event, helper){
           var unitprice = component.get("v.unitprice");
          if(unitprice != null){
               component.set("v.Spinner",true);
            var action = component.get("c.create")
            action.setParams({
                "conId" : component.get("v.recordId"),
                "unit" : component.get("v.unitprice"),
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                    component.set("v.contractList",result);
                    component.set("v.Spinner",false);
                    component.set("v.isnew", false);
                      component.set("v.openModel", false);
                     var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Success',
                message: ' Purchase Order Created Successfully ',
                duration: "5000",
                key: "info_alt",
                type: "Success",
                mode: "pester",
            });
         toastEvent.fire();
                   
                    // $A.get('e.force:refreshView').fire();
            var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.contractList"),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }
            });
            $A.enqueueAction(action)
          }else{
              //alert("hai");
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: ' Please Enter a Value ',
                duration: "5000",
                key: "info_alt",
                type: "Error",
                mode: "pester",
            });
         toastEvent.fire();
              
          }
      }
    
})