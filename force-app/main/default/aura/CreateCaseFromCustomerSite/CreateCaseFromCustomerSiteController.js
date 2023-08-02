({
    
    /*
     * This method is being called from init event
     * to fetch all available recordTypes
     * */
    fetchListOfRecordTypes: function(component, event, helper) {
        helper.getCustomerSiteDetail(component,event,helper);
        helper.fetchListOfRecordTypes(component, event, helper);
    },
    
    /*
     * This method will be called when "Next" button is clicked
     * It finds the recordTypeId from selected recordTypeName
     * and passes same value to helper to create a record
     * */
    createRecord: function(component, event, helper, sObjectRecord) {
        helper.getSelectRecordType(component, event, helper, sObjectRecord);
    },
    /*
     * closing quickAction modal window
     * */
    closeModal : function(component, event, helper){
        helper.closeModal();
    }
    
})