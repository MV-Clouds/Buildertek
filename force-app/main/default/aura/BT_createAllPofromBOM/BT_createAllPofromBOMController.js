({
    doInit : function(component, event, helper) {
       try {
           console.log('doInit called');
            
       } catch (error) {
            console.log('Error in doInit : ', error.stack);
       }
    },

    submitDetails:function(component,event,helper){
        var selectedOption = component.get("v.selectedOption");
        console.log('selectedOption : ', selectedOption);
        if(selectedOption == 'buildertek__Vendor__c'){
            component.set("v.isoptionModal", false);
            component.set("v.isLoading", true);
            helper.createPOwithVendor(component, event, helper);
        }else if(selectedOption == 'buildertek__Cost_Code__c'){
            component.set("v.isoptionModal", false);
            component.set("v.isLoading", true);
            helper.createPOwithCostCode(component, event, helper);
        }else if(selectedOption == 'buildertek__Trade_Type__c'){
            component.set("v.isoptionModal", false);
            component.set("v.isLoading", true);
            helper.createPOwithTradeType(component, event, helper);
        }else if(selectedOption == 'buildertek__Build_Phase__c'){
            component.set("v.isoptionModal", false);
            component.set("v.isLoading", true);
            helper.createPOwithBuildPhase(component, event, helper);
        }else if(selectedOption == 'buildertek__Category__c'){
            component.set("v.isoptionModal", false);
            component.set("v.isLoading", true);
            helper.createPOwithCategory(component, event, helper);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Developer is working",
                "duration" : 3000,
            });
            toastEvent.fire();
            component.set("v.isoptionModal", false);
            $A.get("e.force:closeQuickAction").fire()
        }

    },

    closeModel: function(component, event, helper) {
        component.set("v.isoptionModal", false);
        $A.get("e.force:closeQuickAction").fire() 
    }
})