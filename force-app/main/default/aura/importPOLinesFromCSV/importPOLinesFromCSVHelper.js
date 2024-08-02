({
    showToast: function (type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
            mode: "dismissible",
        });
        toastEvent.fire();
    },

    CSV2JSON: function (component, event, helper, csv) {
        try {
            var arr = csv.split('\r\n');
            var jsonObj = [];
            var headers = arr[0].split(',');

            if (headers[0] !== 'PO Line Name' || headers[1] !== 'Description' || headers[2] !== 'Quantity' || headers[3] !== 'Unit Price' || headers[4] !== 'Tax Rate (%)' || headers[5] !== 'Cost Code' || headers[6] !== 'Trade Type' || headers[7] !== 'Cost Type' || headers[8] !== 'Section') {
                this.showToast('error', 'Error', 'Invalid CSV file format.');
                component.set("v.isErrorOccured", true);
                component.set("v.Spinner", false);
                return '';
            }

            headers = headers.map(header => header.trim().replace(/\s+/g, ''));

            for (var i = 1; i < arr.length; i++) {
                if (arr[i].trim() === '') continue;
                var data = arr[i].split(',');
                
                if (data.length > headers.length) {
                    this.showToast('error', 'Error', 'Invalid CSV file format.');
                    component.set("v.Spinner", false);
                    return '';
                }
                
                if (data[0].trim() === ''){
                    this.showToast('error', 'Error', 'PO Line Name is required.');
                    component.set("v.Spinner", false);
                    return '';
                }
                
                var obj = {};
                for (var j = 0; j < data.length; j++) {
                    obj[headers[j].trim()] = data[j].trim();
                }
                jsonObj.push(obj);
            }
            var json = JSON.stringify(jsonObj);
            return json;
        } catch (error) {
            console.log('Error parsing CSV file:', error);
            this.showToast('error', 'Error', 'Error parsing CSV file.');
            component.set("v.Spinner", false);
            return '';
        }
    },

    createPOLine: function (component, jsonResult) {
        var action = component.get("c.importPOLines");
        action.setParams({
            "poId": component.get("v.recordId"),
            "csvData": jsonResult
        });

        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (result === "Success") {
                this.showToast('success', 'Success', 'PO Lines imported successfully.');
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
                this.showToast('error', 'Error', 'Error importing PO Lines: ' + result);
            }
            component.set("v.Spinner", false);
        });

        $A.enqueueAction(action);
    },

    convertArrayOfObjectsToCSV: function () {
        var keys = ['PO Line Name', 'Description', 'Quantity', 'Unit Price', 'Tax Rate (%)', 'Cost Code', 'Trade Type', 'Cost Type', 'Section'];
        return keys.join(',');
    }
})