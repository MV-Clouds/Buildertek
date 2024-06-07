({

    handleSave: function(component, event, helper) {
        if (component.find("fuploader").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
            alert('Please Select a Valid File');
        }
    },

    handleFilesChange: function(component, event, helper) {
        var fileInput = component.find("fuploader").get("v.files");
		// get the first file using array index[0]
		var file = fileInput[0];

        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0 && file.size < 4500000) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + '4500000' + ' bytes.\n' + ' Selected file size: ' + file.size);
        } else {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.fileName", fileName);
        }
    },

    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})