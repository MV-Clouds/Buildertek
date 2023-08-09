({
    handleOnChange : function(component, event, helper) {
        component.set( "v.selectedRecordId", event.getParams( "fields" ).value );
    }
})