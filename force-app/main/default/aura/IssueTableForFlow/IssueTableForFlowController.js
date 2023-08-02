({
    doInit : function(component, event, helper) {
        component.set('v.wraaperValue', [
            {fieldLabel: 'Name', fieldAPIName: 'Name'},
            {fieldLabel: 'Failure Component', fieldAPIName: 'Failure_Component__c', type: 'text'}
        ]);
        component.set("v.displayList",true);
    }
})