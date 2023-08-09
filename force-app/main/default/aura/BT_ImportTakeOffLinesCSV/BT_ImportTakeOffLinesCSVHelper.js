({
    /*save: function (component, helper) {
        var MAX_FILE_SIZE = 750000;
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];

        if (file != undefined) {
            if (file.size > this.MAX_FILE_SIZE) {
                alert(
                    "File size cannot exceed " +
                    this.MAX_FILE_SIZE +
                    " bytes.\n" +
                    "Selected file size: " +
                    file.size
                );
                return;
            }
            var fr = new FileReader();

            var self = this;
            fr.onload = function () {
                var fileContents = fr.result;
                var base64Mark = "base64,";
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

                fileContents = fileContents.substring(dataStart);

                helper.upload(component, helper, file, fileContents);
            };

            fr.readAsDataURL(file);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: "sticky",
                message: "Please select file to import",
                type: "error",
                duration: "10000",
                mode: "dismissible",
            });
            toastEvent.fire();
        }
    },

    upload: function (component, helper, file, fileContents) {
        var action = component.get("c.importRecords");
        action.setParams({
            budgetId: component.get("v.RecordId"),
            fileData: fileContents,
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("result ", result);
                if (result.isSuccess) {
                    helper.showToast(component, "success", result.strMessage);
                } else {
                    helper.showToast(component, "error", result.strMessage);
                }
                $A.util.removeClass(
                    component.find("uploading").getElement(),
                    "notUploading"
                );
                document.getElementById("uploadingCSVSpinnerText").innerHTML = "";
            } else {
                $A.util.removeClass(
                    component.find("uploading").getElement(),
                    "notUploading"
                );
                document.getElementById("uploadingCSVSpinnerText").innerHTML = "";

                var errors = response.getError();
                var error = "";

                if (errors) {
                    if (errors[0] && errors[0].message) {
                        error = error + errors[0].message;
                    }

                    helper.showToast(component, "error", error);
                } else {
                    helper.showToast(
                        component,
                        "error",
                        "Unknown error, please try again."
                    );
                }
            }

            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        });

        $A.enqueueAction(action);
    },*/
    
    showToast: function (component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            type: type,
            message: message,
            mode: "sticky",
        });
        
        toastEvent.fire();
    },
    CSV2JSON: function (component, event, helper, csv) {
        debugger;
        var arr = [];
        arr = csv.split('\r\n');
       // arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        console.log('Header:::',headers);
        var buildPhaseHeaders = ['Build Phase','Build Proposal'];
       // alert(headers[0]);
       /*(headers[0] !== 'Trade Type' || headers[1] !== 'Category' || headers[2] !== 'Product Type' || headers[3] !== 'Location' || headers[4] !== 'Quantity' || headers[5] !== 'UOM' || headers[6] !== 'Product SKU' || headers[7] !== 'Product Code' ||  headers[8] !== 'Build Phase' ||
            headers[9] !== 'Length' || headers[10] !== 'Width' || headers[11] !== 'Thickness' || headers[12] !== 'Edge' || headers[13] !== 'Height' || headers[14] !== 'Base Location' || headers[15] !== 'Location Detailed Area' || headers[16] !== 'Area Reference' || 
            headers[17] !== 'Build Reference 1' || headers[18] !== 'Install Location' || headers[19] !== 'Install Location Reference' || headers[20] !== 'Item Count' || headers[21] !== 'Linear Feet' || headers[22] !== 'Location Detail Reference 1' || headers[23] !== 'Material Value' ||
            headers[24] !== 'Other Cut Outs' || headers[25] !== 'Record Type' || headers[26] !== 'Series Number' || headers[27] !== 'Sink Cut Out' || headers[28] !== 'Slab SQF' || headers[29] !== 'Stove Cut Out' || headers[30] !== 'Sub-Series Item' || headers[31] !== 'Sub-Series Number'||
            headers[32] !== 'Summary Value 1' || headers[33] !== 'Top SQFT' || headers[34] !== 'Unit Count' || headers[35] !== 'Version' ) {*/
        
       if ( headers[0] !== 'Last Estimate Date' || headers[1] !== 'Version' || !buildPhaseHeaders.includes(headers[2]) || headers[3] !== 'Record Type' || headers[4] !== 'Product Type' || headers[5] !== 'Category' || headers[6] !== 'UOM' || headers[7] !== 'Product SKU' || headers[8] !== 'Product Code' || 
            headers[9] !== 'Trade Type' || headers[10] !== 'Slab SQF' || headers[11] !== 'Summary Value 1' || headers[12] !== 'Build Reference 1' || headers[13] !== 'Base Location' || headers[14] !== 'Location' || headers[15] !== 'Location Detailed Area' || headers[16] !== 'Location Detail Reference 1' || 
            headers[17] !== 'Install Location' || headers[18] !== 'Install Location Reference' || headers[19] !== 'Series Number' || headers[20] !== 'Sub Series Number' || headers[21] !== 'Sub Series Item' || headers[22] !== 'Area Reference' || headers[23] !== 'Quantity' ||
            headers[24] !== 'Material Value' || headers[25] !== 'Length' || headers[26] !== 'Width' || headers[27] !== 'Height' || headers[28] !== 'Thickness' || headers[29] !== 'Top SQFT' || headers[30] !== 'Edge' || headers[31] !== 'Linear Edge'||
            headers[32] !== 'Linear Feet' || headers[33] !== 'Sink Cut Out' || headers[34] !== 'Stove Cut Out' || headers[35] !== 'Other Cut Outs' || headers[36] !== 'Service Category' || headers[37] !== 'Quantity 2' || headers[38] !== 'Slab SQFT 2' || headers[39] !== 'Suppress Record' || headers[40] !== 'Product Count' || headers[41] !== 'Price Book' ) {
                                                                                                                                                                                                                                                        
            component.set("v.Spinner", false);
            component.set("v.isErrorOccured", true);
            component.set("v.errorMessage", 'File Header Format is Invalid!');
            return '';
        }
        for(var h=0;h<headers.length;h++){
        	if(headers[h].includes(' ')){
                headers[h] = headers[h].replaceAll(' ', '');	    
            }    
        }
        for (var i = 1; i < arr.length; i++) {
            if (i >= 23) {
                // debugger;
            }
            if (arr[i] != undefined && arr[i] != '') {
                console.log('arr::::::::',arr);
                console.log('arr[i].match::::::::',arr[i].match(new RegExp('"' + "(.*)" + '"')));
                // debugger;
                var TradeType = arr[i].match(new RegExp('"' + "(.*)" + '"'));
                // alert(TradeType);
                if (TradeType != null  && TradeType != '') {
                    console.log("TradeType => ", TradeType);
                    debugger;
                    // Updated by: Poojan Gabani
                    // Date:27-07-2023  Ticket No: TKS-20
                    var dataInit = [];
                    dataInit = arr[i].split(',');

                    arr[i] = arr[i].match(new RegExp(TradeType[1] + '",' + "(.*)"))[1];

                    var data = arr[i].split(',');
                    var obj = {};
                    obj.TradeType = TradeType[1];
                    //obj[headers[j + 1].trim()] = data[j].trim();
                    console.log(' data.length => ',  data.length);
                    for(var j = 0; j < data.length; j++){
                        // alert(headers[j]);
                        if (headers[j + 5].trim() == 'BuildProposal') {
                            obj.BuildPhase = data[j].trim();
                        }
                        else {
                            if(j<4){
                                obj[headers[j].trim()] = dataInit[j].trim();
                            } 

                            if(headers[j + 4].trim() == 'ProductType'){
                                obj[headers[j + 4].trim()] = TradeType[1];
                            }
                            if(headers[j + 5].trim() == 'TradeType'){
                                obj[headers[j + 5].trim()] = TradeType[1];
                            } else{
                                obj[headers[j + 5].trim()] = data[j].trim();
                            }
                        }
                    }
                } else {
                   // alert("hai");
                    var data = arr[i].split(',');
                    var obj = {};
                    for (var j = 0; j < data.length; j++) {
                        if(headers[j].trim() == 'BuildProposal')
                        {
                            obj.BuildPhase = data[j].trim();
                        }
                        else
                        {
                            obj[headers[j].trim()] = data[j].trim();
                        }
                    }
                    console.log('obj:::::::',obj);
                    console.log('date:::::::',data);
                }
                jsonObj.push(obj);
            }
        }
        console.log('jsonObj::::::',jsonObj);
        var json = JSON.stringify(jsonObj);
        //alert(json);
        console.log('json::::::::',json);
        return json;
    },
    
    CreateAccount: function (component, jsonstr) {
        debugger;
        var jsonData = JSON.parse(jsonstr);
       // alert(jsonData);
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
            var state = response.getReturnValue();
            console.log('response => ', JSON.stringify(state));
         // alert(JSON.stringify(state));
         // var result = response.getReturnValue();
         if (state == "SUCCESS") {
             component.set("v.Spinner", false);
             $A.get("e.force:closeQuickAction").fire();
                
                var toastEvent = $A.get("e.force:showToast");
                
                toastEvent.setParams({
                    title: "Success!",
                    type: "Success",
                    duration:'5000',
                    message: 'TakeOff Lines Created Successfully',
                    mode: 'dismissible'
                });
                
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                //var baseURL = component.get("v.BaseURLs");
                //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Project_Takeoff__c/' + escape(recordId) + '/view', '_self');
            }
            else if (state == "ERROR") {
                 component.set("v.Spinner", false);
            //    alert(response.getError());
                var toastEvent = $A.get("e.force:showToast");
                
                toastEvent.setParams({
                    type: "error",
                    message: 'INVALID OR NULL FOR RESTRICTED PICKLIST',
                    mode: "dismissible",
                });
                
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    convertArrayOfObjectsToCSV : function(component,event,helper){
        // declare variables
        var csvStringResult, keys, columnDivider;
        columnDivider = ',';
        keys = [ 'Last Estimate Date','Version','Build Phase','Record Type','Product Type','Category','UOM','Product SKU','Product Code',
                'Trade Type','Slab SQF','Summary Value 1','Build Reference 1','Base Location','Location','Location Detailed Area','Location Detail Reference 1',
                'Install Location','Install Location Reference','Series Number','Sub Series Number','Sub Series Item','Area Reference','Quantity',
                'Material Value','Length','Width','Height','Thickness','Top SQFT','Edge','Linear Edge','Linear Feet','Sink Cut Out','Stove Cut Out','Other Cut Outs','Service Category','Quantity 2','Slab SQFT 2','Suppress Record','Product Count','Price Book'];
       /* keys = ['Trade Type','Category','Product Type','Location','Quantity','UOM','Product SKU','Product Code','Build Phase','Length',
               'Width','Thickness','Edge','Height','Base Location','Location Detailed Area','Area Reference','Build Reference 1','Install Location',
               'Install Location Reference','Item Count','Linear Feet','Location Detail Reference 1','Material Value','Other Cut Outs','Record Type',
               'Series Number','Sink Cut Out','Slab SQF','Stove Cut Out','Sub Series Item','Sub Series Number','Summary Value 1','Top SQFT',
               'Unit Count','Version  buildertek__TO_LAST_EST_DATE__c'buildertek__TL_SERVICE_CATEGORY__c];*/
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        /*for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }*/// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
});