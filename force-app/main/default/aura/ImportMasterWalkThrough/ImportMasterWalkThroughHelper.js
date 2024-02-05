({
    updateCheckboxValues: function (component) {
        try {
            var PaginationList = component.get("v.PaginationList");
            var checkedRecordIds = component.get("v.checkedRecordIds");
        
            // Iterate through PaginationList and update checkbox values
            PaginationList.forEach(function (record) {
                // Get the record ID for the checkbox
                var recordId = record.Id;
        
                // Get the checkbox by name attribute
                var checkboxes = component.find("checkContractor");
        
                // If there are multiple checkboxes, component.find() returns an array
                if (Array.isArray(checkboxes)) {
                    // Loop through the array of checkboxes
                    checkboxes.forEach(function (checkbox) {
                        if (checkbox.get("v.text") === recordId) {
                            // Update the checkbox value based on checkedRecordIds
                            checkbox.set("v.value", checkedRecordIds.includes(recordId));
                        }
                    });
                } else {
                    // If there's only one checkbox
                    if (checkboxes.get("v.text") === recordId) {
                        // Update the checkbox value based on checkedRecordIds
                        checkboxes.set("v.value", checkedRecordIds.includes(recordId));
                    }
                }
            });
        } catch (error) {
            console.log('Error---> ',error);
        }
    },
})