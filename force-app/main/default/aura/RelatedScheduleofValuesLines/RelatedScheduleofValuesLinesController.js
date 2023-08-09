({
    doInit: function(component, event, helper) {
        var action = component.get("c.getRelatedList");
        action.setParams({
            recId : component.get("v.recordId")
        })
        action.setCallback(this, function(data){
            var state = data.getState();
            if (state === "SUCCESS") {
                var result = data.getReturnValue();
                if(result.ScheduleOfValueLineList.length>0){
                    result.ScheduleOfValueLineList.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    });
                }
                
                component.set("v.ScheduleOfValuesLineList",result.ScheduleOfValueLineList);
                component.set("v.ScheduleofValuesId",result.ScheduleofValuesRec.Id);
                
                var actions = [
                    {label: 'Delete', name: 'delete'}
                ];
                
                component.set('v.columns', [
                    {label: 'SOV Id', fieldName: 'linkName',type: 'url', 
                     typeAttributes:{label: { fieldName: 'Name' }, target: '_self'}},
                    {label: 'Description of Work', fieldName: 'buildertek__Description_of_Work__c'},
                    {label: 'Scheduled Value', fieldName: 'buildertek__Scheduled_Value__c' , type: "currency", hideDefaultActions: true,
                     cellAttributes: 
                     { alignment: 'left'}, typeAttributes: {
                         currencyCode: "USD" ,currencyDisplayAs: "code" 
                     } },
                    {label: 'Status', fieldName: 'buildertek__Status__c'},
                    {label: 'Rejection Reason', fieldName: 'buildertek__Rejection_Reason__c'},
                    {type: 'action', typeAttributes: { rowActions: actions } }
                ]);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'view':
                helper.viewRecord(component, event);
                break;
            case 'edit':
                helper.editRecord(component, event);
                break;
            case 'delete':
                helper.deleteRecord(component, event);
                break;
        }
    },
})