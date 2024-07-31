({
    doInit: function (component, event, helper) {
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        component.set("v.BaseURLs", baseURL);
    },

    closeModel: function () {
        $A.get("e.force:closeQuickAction").fire();
    },

    save: function (component, event, helper) {
        component.set("v.Spinner", true);
        var fileInput = component.find("file").get("v.files");
        var file = fileInput[0];
        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component, event, helper, csv);
                if (result != undefined && result != '') {
                    window.setTimeout(
                        $A.getCallback(function () {
                            helper.createPOLine(component, result);
                        }), 100
                    );
                } else {
                    component.set("v.Spinner", false);
                }
            };
            reader.onerror = function (evt) {
                console.log("error reading file");
                component.set("v.Spinner", false);
                helper.showToast('error', 'Error', 'Error while reading file');
            };
        } else {
            component.set("v.Spinner", false);
        }
    },

    handleFilesChange: function (component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            component.set("v.isSelect", false);
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },

    downloadCsv: function (component, event, helper) {
        var csv = helper.convertArrayOfObjectsToCSV();
        if (csv == null) {
            return;
        }
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self';
        hiddenElement.download = 'Import Purchase Order Lines.csv';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    },
})