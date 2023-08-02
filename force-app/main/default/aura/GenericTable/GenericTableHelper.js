({
    onCheck : function(component, event, helper){
        var checkbox = event.getSource();
        var RecordSelected =  checkbox.get("v.value");
        var selectedRecordId = checkbox.get("v.text");
        var selectedRecordList = [];
        if(RecordSelected && component.get("v.selectedRecordList").indexOf(selectedRecordId) < 0){
            selectedRecordList.push(selectedRecordId);
            component.get('v.selectedRecordList').push(selectedRecordId);            
        }
        else{
            component.set('v.isAllSelected', false);
            var index = component.get("v.selectedRecordList").indexOf(selectedRecordId);
            if (index > -1) {
                component.get("v.selectedRecordList").splice(index, 1); 
            }
        }
        helper.fireEvent(component, event,helper)
    },
    fireEvent: function(component, event,helper) {
        var evt = component.getEvent("sendRecords");
        evt.setParams({"selectedRecordList" : component.get("v.selectedRecordList")});  //set the parameter value
        evt.fire();  // fire the event
    }    
})