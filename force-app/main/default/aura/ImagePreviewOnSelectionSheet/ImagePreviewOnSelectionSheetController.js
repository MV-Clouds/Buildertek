({
    doInit: function (component, event, helper) {
        helper.getSelectionSheetRelatedCategories(component,event.helper);
    },
    handleCategoryChange : function(component, event, helper) {
        console.log('In handleCategoryChange');

        var selectedCategoryId = event.getSource().get("v.value");
        var selectedCategoryName = '';
        // Iterate through selectionCategories to find the matching category name
        var selectionCategories = component.get("v.selectionCategories");
        for (var i = 0; i < selectionCategories.length; i++) {
            if (selectionCategories[i].Id === selectedCategoryId) {
                selectedCategoryName = selectionCategories[i].Name;
                break;
            }
        }
        // Use the selectedCategoryId and selectedCategoryName as needed
        console.log('Selected Category Id: ' + selectedCategoryId);
        console.log('Selected Category Name: ' + selectedCategoryName);
        component.set("v.showChildComponent",  false);
        if (selectedCategoryId != '' && selectedCategoryName != '') {
            component.set("v.selectedCategoryName", selectedCategoryName);
            component.set("v.selectedCategoryId", selectedCategoryId);
            component.set("v.showChildComponent",  true);
        }

    }
})