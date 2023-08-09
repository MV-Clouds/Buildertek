({
    initialize : function(component, event, helper) {
       var groupFilter = "buildertek__Contract__c ='"+component.get("v.recordId")+"'";
       component.set("v.groupFilter",groupFilter);
    }
})