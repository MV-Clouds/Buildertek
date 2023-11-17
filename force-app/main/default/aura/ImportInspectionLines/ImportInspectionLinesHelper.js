({
    CSV2JSON: function (component, csv) {
        try {
            console.log('csv data-->', csv);
            var arr = csv.split('\r\n');
            var jsonObj = [];
            var headers = arr[0].split(',');
    
            if (
                headers[0] !== 'Description' ||
                headers[1] !== 'Status' ||
                headers[2] !== 'Comments' ||
                headers[3] !== 'Date Due'
            ) {
                this.showToast(component, 'Error', 'File Header Format is Invalid!');
                return '';
            }
    
            for (var i = 0; i < headers.length; i++) {
                headers[i] = headers[i].trim().replace(/\s+/g, '');
            }
    
            console.log('headers-->', headers);
    
            if (arr.length > 1) {
                for (var i = 1; i < arr.length; i++) {
                    if (arr[i].trim() === '') {
                        continue;
                    }
    
                    console.log('arr[i]:', arr[i]);
    
                    var data = [];
                    var insideQuote = false;
                    var temp = '';
    
                    for (var char of arr[i]) {
                        if (char === '"') {
                            insideQuote = !insideQuote;
                        } else if (char === ',' && !insideQuote) {
                            data.push(temp.trim());
                            temp = '';
                        } else {
                            temp += char;
                        }
                    }
    
                    // Add the last value
                    data.push(temp.trim());
    
                    if (data.length > headers.length) {
                        this.showToast(component, 'error', 'Data row has more values than header columns.');
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
            } else {
                this.showToast(component, 'error', 'File is Empty.');
                return '';
            }
        } catch (error) {
            console.log('error-->', error);
            this.showToast(component, 'error', error);
            return '';
        }
    },
    
    
    
    
    CreateInspectionLine: function(component, jsonstr) {
        component.set("v.Spinner", true);
        var InspectionId = component.get("v.recordId");
        var action = component.get('c.insertData');
        action.setParams({
            inspecId: InspectionId,
            strfromle: jsonstr
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('Result--->', { result });
            
            component.set("v.Spinner", false);
            
            if (result === 'SUCCESS') {
                this.showToast(component, 'Success', 'Inspection Line Inserted Successfully.');
            } else {
                this.showToast(component, 'Error', result);
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }); 
        $A.enqueueAction(action);
    },
    
    
    convertArrayOfObjectsToCSV : function(component,event,helper){
        var csvStringResult, keys, columnDivider;
        columnDivider = ',';
        keys = ['Description','Status','Comments','Date Due'];
      
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
       
        return csvStringResult;        
    },

    showToast: function (component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
      
        toastEvent.setParams({
            "type": type,
            "message": message,
            duration: '3000',
            mode: 'dismissible'
        });
      
        toastEvent.fire();
    },
})