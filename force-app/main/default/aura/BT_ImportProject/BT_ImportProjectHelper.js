({
    CSV2JSON: function (component,csv) {
        //  console.log('Incoming csv = ' + csv);
        
        //var array = [];
        var arr = []; 
        
        arr =  csv.split('\n');
        //console.log('Array  = '+array);
        // console.log('arr = '+arr);
        //arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        component.set("v.Spinner", false);
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
                //console.log('obj headers = ' + obj[headers[j].trim()]);
            }
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        //console.log('json = '+ json);
        return json;
        
        
    },
    
    CreateAccount : function (component,jsonstr){
        component.set("v.Spinner", true);
        component.set("v.showMessage",true);
        // console.log('jsonstr' + jsonstr);
        var action = component.get('c.insertData');
        //  alert('Server Action' + action);    
        action.setParams({
            strfromle : jsonstr
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") { 
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId; 
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
                
                if(response.getReturnValue() == 'SUCCESS'){
                    
                    component.set("v.Spinner", false);
                    component.set("v.showMessage",false);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Projects Imported Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                   /* document.getElementsByClassName('importPojectBtn')[0].blur();
                    document.body.click(); 
                    document.getElementsByClassName('closeModal')[0].click();*/
                    component.closeModalPopup();
                    
                    
                    component.set("v.isOpen", false);
                   /* var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/lightning/o/buildertek__Project__c/list?filterName=Recent'
                    });
                    urlEvent.fire();*/
                    
                    var result=response.getReturnValue();
                    component.set("v.Spinner", false);
                    component.set("v.showMessage",false);
                    //location.href = '/lightning/o/buildertek__Project__c/list?filterName=Recent';
                }
                
            }
            else{
                component.set("v.Spinner", false);
                component.set("v.showMessage",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: response.getReturnValue(),
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            /*document.getElementsByClassName('importPojectBtn')[0].blur();
            document.body.click();  */
        }); 
        
        $A.enqueueAction(action);    
        
    },
    
    
    //export helper start from here
    onLoad: function(component, event) {
        //call apex class method
        var action = component.get('c.fetchContact');
        action.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //set response value in ListOfContact attribute on component.
                component.set('v.ListOfContact', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
        
        // in the keys variable store fields API Names as a key 
        // this labels use in CSV file header  
        keys = ['projectName','ContractAmount','Stage', 'Address','City','State','Zip','ProjectManager','Account','AccountCity','AccountState','AccountPhone','AccountEmail' ];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey]; 
                
                // add , [comma] after every String value,. [except first]
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                } 
                // if condition for blank column display if value is empty
                if(objectRecords[i][skey] != undefined){
                    csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                }else{
                    csvStringResult += '"'+ '' +'"';
                }
                counter++;
                
                
            } // inner for loop close 
            csvStringResult += lineDivider;
        }// outer main for loop close 
        
        // return the CSV formate String 
        return csvStringResult; 
        
    },
})