({
    CSV2JSON: function (component, event, helper, csv) {
        var arr = [];
        arr = csv.split('\n');
        
        if (arr[arr.length - 1] == '' || arr[arr.length - 1] == undefined || arr[arr.length - 1] == null) {
            arr.pop();
        }
        
        var jsonObj = [];
        var headers = arr[0].split(',');
        console.log('headers::', headers);
        if (headers[0] !== "Name" || headers[1] !== "Dependency" || headers[2] !== "StartDate" || headers[3] !== "Duration" || headers[4] !== "% Complete" || headers[5] !== "Phase" || headers[6] !== "Notes" || headers[7] !== "Lag\r") {
            component.set("v.Spinner", false);
            component.set("v.isErrorOccured", true);
            component.set("v.errorMessage", 'File Header Format is Invalid!');
            return '';
        }
        var startIndex;
        var endIndex;

        for (var i = 1; i < arr.length; i++) {
            if (arr[i] != undefined) {
                while (arr[i].indexOf('"') > -1) {
                    if (startIndex == null) {
                        startIndex = arr[i].indexOf('"');
                        arr[i] = arr[i].substring(0, startIndex) + ':quotes:' + arr[i].substring(startIndex + 1, arr[i].length);
                    } else {
                        if (endIndex == null) {
                            endIndex = arr[i].indexOf('"');
                            arr[i] = arr[i].substring(0, endIndex) + ':quotes:' + arr[i].substring(endIndex + 1, arr[i].length);
                        }
                    }

                    if (startIndex != null && endIndex != null) {
                        var sub = arr[i].substring(startIndex, endIndex);
                        sub = sub.replaceAll(',', ':comma:');
                        arr[i] = arr[i].substring(0, startIndex) + sub + arr[i].substring(endIndex, arr[i].length);
                        startIndex = null;
                        endIndex = null;
                    }
                }

                var data = arr[i].split(',');
                var obj = {};
                var month = '';
                var day = '';
                for (var j = 0; j < data.length; j++) {
                    var myStr = data[j];
                    var newStr = myStr.replace(/:comma:/g, ',');
                    newStr = newStr.replace(/:quotes:/g, '');
                    data[j] = newStr;
                    if (headers[j].trim() == 'StartDate' && data[j].trim() != '') {
                        var date = data[j].trim();
                        var splitDate = date.split("/");
                        //   alert(JSON.stringify(parseInt(splitDate[0])))
                        // debugger;
                        if (parseInt(splitDate[0]) < 10 && parseInt(splitDate[0]).length < 2) {
                            month = '0' + splitDate[0]
                        } else {
                            month = splitDate[0]
                        }
                        if (parseInt(splitDate[1]) < 10 && parseInt(splitDate[1]).length < 2) {
                            day = '0' + splitDate[1]
                        } else {
                            day = splitDate[1]
                        }

                        obj[headers[j].trim()] = month.split('-').reverse().join('-');
                    } else {
                        if (headers[j].trim() == '% Complete') {
                            obj['percentComplete'] = data[j].trim();
                        } else {
                            obj[headers[j].trim()] = data[j].trim();
                        }

                    }
                    // }
                }

                if (obj.StartDate != undefined && obj.StartDate != '') {
                    jsonObj.push(obj);
                } else {
                    var today = new Date();
                    var dd = String(today.getDate()).padStart(2, '0');
                    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                    var yyyy = today.getFullYear();

                    today = yyyy + '-' + mm + '-' + dd;
                    obj.StartDate = today;
                    console.log('today ',today);
                    console.log('obj.StartDate ',obj.StartDate);
                    jsonObj.push(obj);

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'StartDate should not be null',
                        duration: ' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.startdateError", true);
                    component.set("v.Spinner", false);
                }
                if (obj.percentComplete != "" && obj.percentComplete != undefined) {

                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Percent Complete should not be null',
                        duration: ' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    component.set("v.startdateError", true);
                    component.set("v.Spinner", false);
                }

            }
        }

        console.log('jsonObj ', jsonObj);
        const taskMap = new Map();
        for (let i = 0; i < jsonObj.length; i++) {
            let element = jsonObj[i];
            taskMap.set('PT - ' + i, element.Name);
        }

        for (let i = 0; i < jsonObj.length; i++) {
            let e = jsonObj[i];
            e.ID = 'PT - ' + i;
        }

        jsonObj.forEach(ele => {
            for (let [key, value] of taskMap.entries()) {
                if (ele.Dependency === value) {
                    ele.parentID = key;
                }
            }
        });

        let parentMap = new Map();
        jsonObj.forEach(element => {
            parentMap.set(element.ID, element.parentID);
        });
        console.log('parentMap ==> ',parentMap);

        var circularDependency = false;
        let totalLoop = 0;
        var dependentRecord;
        jsonObj.every(ele => {
            var currentId = ele.ID;
            for (let index = 0; index <= jsonObj.length+1; index++) {
                totalLoop++
                if (parentMap.has(currentId)) {
                    currentId = parentMap.get(currentId);
                    if(index > jsonObj.length){
                        circularDependency = true;
                        console.log('ele.Name ==> '+ele.Name);
                        component.set("v.CircularDependencyName", ele.Name);
                        dependentRecord = ele;
                        break;
                    }
                } else{
                    break;
                }
            }
            return !circularDependency;
        });

        console.log("Total Loop => "+totalLoop);
        if (circularDependency) {
            console.log('dependentRecord ==> ',dependentRecord);
            console.log('Circular Dependency');
            return '';
        } else{
            var json = JSON.stringify(jsonObj);
            return json;
        }
    },

    /*  parseFile : function(component,uploadFile) {
        //var fileInput = component.find("file").getElement();
        var file = uploadFile //fileInput.files[0];
        var filename = file.name;
        var fileType = filename.substring(filename.lastIndexOf('.')+1, filename.length);
        if (file.size > 10000000) {
            var message = 'File size cannot exceed 10000000 bytes.\n Selected file size: ' + file.size;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": message
            });
            toastEvent.fire();
            alert();
            return;
        }
        if(fileType == 'csv'){
            //component.set("v.showButton", false);
            this.parse(component,file);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Please select csv files only"
            });
            toastEvent.fire();
        }
    },*/


    /*   parse : function(component,thing) {
        var complete = $A.getCallback(function(results,file) {
            console.log("Parsing complete:", results, file);
            console.log('results --------> '+JSON.stringify(results));
            var data = results.data.slice(1).filter(function(row){
                return row[0];
            });
            var headers = results.data[0];
            for(var h=0;h<headers.length;h++){
                if(headers[h].includes(' ')){
                    headers[h] = headers[h].replaceAll(' ', '_');
                }
            }
            var jsonObj = [];
            for(var i=0;i<data.length;i++){
                var obj = {};
                var rowData = data[i];
                for(var j=0;j<rowData.length;j++){
                    if(headers[j] != '' && rowData[j] != ''){
                        obj[headers[j]] = rowData[j];
                    }
                }
                jsonObj.push(obj);
            }
            console.log('jsonObj -------> '+JSON.stringify(jsonObj));
            component.set("v.csvJSON", JSON.stringify(jsonObj));
            component.set('v.headers',headers);
            component.set('v.rows',data);
            console.log('rows -------> '+JSON.stringify(component.get('v.rows')));
            console.log('headers -------> '+JSON.stringify(component.get('v.headers')));
        })

        Papa.parse(thing,{complete: complete});
    },*/



    CreateAccount: function (component, jsonstr) {
        // component.set("v.isOpen", false);
        var jsonData = JSON.parse(jsonstr);
        var recordId = component.get("v.RecordId");
        var action = component.get("c.insertData");
        console.log('CSv FIle::', JSON.stringify(jsonData));

        action.setParams({
            "recordId": component.get("v.RecordId"),
            "strFileData": JSON.stringify(jsonData)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log({ state });
            // debugger;
            if (state === "SUCCESS") {
                if (response.getReturnValue() == 'SUCCESS') {
                    //alert( JSON.stringify(response.getReturnValue()));
                    component.set("v.Spinner", false);
                    component.set("v.showMessage", false);
                    component.set("v.isOpen", false);

                    var baseURL = component.get("v.BaseURLs");
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('--', 0));

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Schedule lines Imported Successfully.',
                        duration: ' 10000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();

                    if (component.get('v.isNewGantt')) {
                        var workspaceAPI = component.find("workspace");
                        if (workspaceAPI.getFocusedTabInfo()) {
                            workspaceAPI.getFocusedTabInfo().then(function (response) {
                                var focusedTabId = response.tabId;
                                workspaceAPI.closeTab({ tabId: focusedTabId }).then(function (res) {
                                    window.setTimeout(function () {
                                        window.open('/' + recordId, '_top');
                                        location.reload();
                                    }, 2000)
                                    if (workspaceAPI.getFocusedTabInfo()) {
                                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                                            var focusedTabId = response.tabId;
                                            //location.reload();
                                            // $A.get('e.force:refreshView').fire();
                                            window.setTimeout(function () {
                                                window.open('/' + recordId, '_top');
                                                location.reload();
                                            }, 2000)
                                            // component.set("v.isOpen", false);
                                        })
                                            .catch(function (error) {
                                                console.log(error);


                                            });
                                    }


                                    //$A.enqueueAction(component.get('c.doInit'))
                                    // $A.enqueueAction(navEvt.fire());
                                });

                            })
                                .catch(function (error) {
                                    console.log(error);
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({

                                        "recordId": recordId,
                                        "slideDevName": "detail"
                                    });
                                    window.setTimeout(function () {
                                        location.reload();
                                    }, 500)
                                    navEvt.fire();
                                    // $A.enqueueAction(component.get('c.doInit'))
                                    //$A.enqueueAction(navEvt.fire());

                                });
                        } else {
                            window.open('/' + recordId, "_top");
                            //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
                        }
                        // window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_top');
                    } else {
                        window.open('/apex/BT_Task_Manager?recordId=' + escape(recordId), '_self')
                    }
                    // window.open('/apex/BT_Task_Manager?recordId=' + escape(recordId), '_self')
                } else {

                    component.set("v.Spinner", false);
                    component.set("v.showMessage", false);
                    console.log("error--->", response.getReturnValue())
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'There was an error uploading your file. Please Contact your Administrator for assistance',
                        duration: ' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                //window.open(baseURL + '.lightning.force.com/lightning/r/buildertek__Schedule__c/' + escape(recordId) + '/view', '_self');
            } else {
                // sakina 5th sept
                component.set("v.Spinner", false);
                console.error(response.getError());
            }
        });

        var ph = false;
        var du = false;
        var nam = false;
        if (JSON.stringify(jsonData).includes('"Phase":""')) {
            //alert('Phase-------------------'+JSON.stringify(jsonData).includes('"Phase":""'));
            ph = true;
        }
        if (JSON.stringify(jsonData).includes('"Duration":""')) {
            // alert('Duration------------------'+JSON.stringify(jsonData).includes('"Duration":""'));
            du = true;
        }
        if (JSON.stringify(jsonData).includes('"Name":""')) {
            //alert('Name------------------------'+JSON.stringify(jsonData).includes('"Name":""'));
            nam = true;
        }

        // if(ph==true && du==true && nam==true){
        if (du == true && nam == true) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'You are missing Name, Duration in your CSV file.',
                duration: ' 10000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
            /* }else if(ph==true && du==true && nam==false){
         // alert(ph,du);
          var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You are missing Duration, Phase in your CSV file.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);
     }else if(ph==true && du==false && nam==false){
         // alert(ph,du);
          var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You are missing the Phase value in your CSV file.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);*/
        } else if (du == true && nam == false) {
            // alert(ph,du);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'You are missing the Duration value in your CSV file.',
                duration: ' 10000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
            /*   }else if(ph==true && du==false && nam==true){
         // alert(ph,du);
          var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You are missing Name, Phase in your CSV file.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);*/
        } else if (du == false && nam == true) {
            // alert(ph,du);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'You must have a Name value on all records.',
                duration: ' 10000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            component.set("v.Spinner", false);
            /* }else if(ph==false && du==true && nam==true){
         // alert(ph,du);
          var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You are missing Name, Duration in your CSV file.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);*/
        } else if (component.get("v.startdateError") == true) {

        } else {
            $A.enqueueAction(action);
        }

        /* if(JSON.stringify(jsonData).includes('"Phase":""' &&  '"Duration":""'  && '"Name" :""') ){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You are missing the Phase,Name Value in your CSV file.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);
  } else if(JSON.stringify(jsonData).includes('"Duration":""') ){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You are missing the Duration in your CSV file.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);
             }else if(JSON.stringify(jsonData).includes('"Phase":""') ){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You are missing the Phase value in your CSV file.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);
        }else if(JSON.stringify(jsonData).includes('"Name":""')){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'You must have a Name value on all records.',
                        duration:' 10000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
            component.set("v.Spinner", false);
        }else if(component.get("v.startdateError") == true){

        }
        else{
            $A.enqueueAction(action);
        }*/

    },
    convertArrayOfObjectsToCSV: function (component, event, helper) {
        // declare variables
        var csvStringResult, keys, columnDivider;
        columnDivider = ',';
        keys = ['Name', 'Dependency', 'StartDate', 'Duration', '% Complete', 'Phase', 'Notes', 'Lag'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        // return the CSV formate String
        return csvStringResult;
    },
})