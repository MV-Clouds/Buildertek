({
  
    CSV2JSON: function (component, event, helper, csv) {
        debugger;
        var arr = [];
        arr = csv.split('\n');
        arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        console.log('Header:::',headers);
        if (headers[0] !== 'TradeType' || headers[1] !== 'Category' || headers[2] !== 'ProductType' || headers[3] !== 'Location' || headers[4] !== 'Quantity' || headers[5] !== 'UOM\r') {
            component.set("v.Spinner", false);
            component.set("v.isErrorOccured", true);
            component.set("v.errorMessage", 'File Header Format is Invalid!');
            return '';
        }
        for (var i = 1; i < arr.length; i++) {
            if (i >= 23) {
                debugger;
            }
            if (arr[i] != undefined) {
                console.log('arr::::::::',arr);
                console.log('arr[i].match::::::::',arr[i].match(new RegExp('"' + "(.*)" + '"')));
                debugger;
                var TradeType = arr[i].match(new RegExp('"' + "(.*)" + '"'));
                if (TradeType != null) {
                    arr[i] = arr[i].match(new RegExp(TradeType[1] + '",' + "(.*)"))[1];
                    var data = arr[i].split(',');
                    var obj = {};
                    obj.TradeType = TradeType[1];
                    obj[headers[j + 1].trim()] = data[j].trim();
                } else {
                    var data = arr[i].split(',');
                    var obj = {};
                    for (var j = 0; j < data.length; j++) {
                        obj[headers[j].trim()] = data[j].trim();
                    }
                    console.log('obj:::::::',obj);
                    console.log('date:::::::',data);
                }
                jsonObj.push(obj);
            }
        }
        console.log('jsonObj::::::',jsonObj);
        var json = JSON.stringify(jsonObj);
        console.log('json::::::::',json);
        return json;
    },
    
    CreateAccount: function (component, jsonstr) {
        debugger;
        var jsonData = JSON.parse(jsonstr);
        var recordId = component.get("v.recordId");
        var action = component.get("c.insertData");
        console.log('jsonData:::::::'+jsonData);
        console.log('recordId:::::::'+recordId);
        console.log('CSv FIle::', JSON.stringify(jsonData));
        action.setParams({
            "recordId": recordId,
            "strFileData": JSON.stringify(jsonData)
        });
        action.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Spinner", false);
                $A.get("e.force:closeQuickAction").fire();  
                //var baseURL = component.get("v.BaseURLs");
                //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Package__c/' + escape(recordId) + '/view', '_self');
            }
        });
        $A.enqueueAction(action);
    },
    convertArrayOfObjectsToCSV : function(component,event,helper){
        // declare variables
        var csvStringResult, keys, columnDivider;
        columnDivider = ',';
        keys = [ 'TradeType','Category','ProductType','Location','Quantity','UOM'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
       // return the CSV formate String 
        return csvStringResult;        
    },

})