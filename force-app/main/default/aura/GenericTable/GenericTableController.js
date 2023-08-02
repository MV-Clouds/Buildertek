({
    onCheck : function(component, event, helper) {
        helper.onCheck(component, event, helper);
    },
    selectAllCheckbox : function(component, event, helper) {
        var checkbox = component.find('checkbox'); 
        var selectedRecordList = [];
        
        var isSelected = component.get('v.isAllSelected');
        if(checkbox != undefined){
            if (!Array.isArray(checkbox)) {
                checkbox = [checkbox];
            }           
            for (var i = 0; i < checkbox.length; i++) {
                checkbox[i].set('v.value', component.get('v.isAllSelected'));
                var selectedRecordId=checkbox[i].get("v.text");
                selectedRecordList.push(selectedRecordId);
                component.get('v.selectedRecordList').push(selectedRecordId);           
            }
        }
        helper.fireEvent(component, event,helper)
    }
})