({
    init: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Cash Disbursement#', fieldName: 'buildertek__Payment__c', type: 'url' , typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
            {label: 'Payment Amount', fieldName: 'buildertek__Payment_Amount__c',type: 'currency', typeAttributes: { currencyCode: 'USD'}, cellAttributes: { alignment: 'left' }},
            {label: 'Payment Date', fieldName: 'buildertek__Payment_Date__c', type: 'date'},
            {label: 'Type', fieldName: 'buildertek__Type__c', type: 'text'},
            {label: 'Project', fieldName: 'ProjectName' , type: 'text'},
            {label: 'Payment Status', fieldName: 'buildertek__Payment_Status__c',  type: 'text'}
        ]);
        helper.fetchCDData(component,event,helper);
    }
});
