({
    CSV2JSON: function (component,csv) {
       
        var arr = [];         
        arr =  csv.split('\n');
       
        var jsonObj = [];
        var headers = arr[0].split(',');
        
        component.set("v.Spinner", false);
        for(var i = 1; i < arr.length; i++) {
            console.log('arr  = ' + i +  arr[i]);
            var startIndex;
            var endIndex;  
            while(arr[i].indexOf('"') > -1){
                if(startIndex == null){
                    startIndex = arr[i].indexOf('"');
                   
                    arr[i] = arr[i].substring(0, startIndex) + ':quotes:' + arr[i].substring(startIndex+1, arr[i].length);
                    
                }else{
                    if(endIndex == null){
                        endIndex = arr[i].indexOf('"');
                       
                        arr[i] = arr[i].substring(0, endIndex) + ':quotes:' + arr[i].substring(endIndex+1, arr[i].length);
                    }
                }
                
                if(startIndex != null && endIndex != null){
                    var sub = arr[i].substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    arr[i] = arr[i].substring(0, startIndex) + sub + arr[i].substring(endIndex, arr[i].length);
                    startIndex = null;
                    endIndex = null;
                   
                }
            }
            
            debugger;
            var data = arr[i].split(','); 
            var obj = {};
            console.log('data length = ' + data.length);
            //alert(data.length);
            if(data.length>1){
               
                for(var j = 0; j < data.length; j++) {
                    console.log('j' + j);
                   
                    var myStr = data[j];
                    var newStr = myStr.replace(/:comma:/g, ',');
                    newStr= newStr.replace(/:quotes:/g, '');
                    if(headers[j] == headers[2]){
                     
                    newStr= newStr.replace(/[^0-9.]/g, ''); 
                    }
                    obj[headers[j].trim()] = data[j].trim() != '' ? newStr.trim() : null;                    
                 
                } 
                console.log('obj' + obj);
                jsonObj.push(obj);
               
            }            
        }
   
        
        debugger;
        for(var j = 0; j < jsonObj.length; j++) {
            debugger;
            if(jsonObj[j]['ScheduledValue'] == ''){
                jsonObj[j]['ScheduledValue'] = null;
            }
            
        }
        var json = JSON.stringify(jsonObj); 
        
        
        return json;
        
        
    },
    
    CreateAccount : function (component,jsonstr){
        debugger;
        
        component.set("v.Spinner", true);
        component.set("v.showMessage",true);
        var action = component.get('c.insertData');
        
        action.setParams({
            strfromle : jsonstr,
            recordId : component.get("v.recordId"),
            vendorName : component.get("v.Vendorname")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                
                if(response.getReturnValue() == 'SUCCESS'){
                    
                    component.set("v.Spinner", false);
                    component.set("v.showMessage",false);
                    
                    if(location.href.includes("fromsovsheet")){
                        var address = '/schedule-of-value-lines?id='+component.get("v.recordId")+'&dummy=ignore'+'/';
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": address,
                            "isredirect" :false
                        });
                        urlEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        
                    }else{
                        var fromsovsheet = component.get("v.sheetPage");
                        
                        if(fromsovsheet == 'gotoSheetPage'){
                            
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef : "c:ScheduleOfValueLines",
                                componentAttributes: {
                                    recordId : component.get("v.recordId"),
                                }
                            });
                            evt.fire();
                            
                            var workspaceAPI = component.find( "workspace" );
                            workspaceAPI.getFocusedTabInfo().then( function( response ) {
                                var focusedTabId = response.tabId;
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        workspaceAPI.closeTab( { tabId: focusedTabId } );
                                        
                                    }), 1000);
                            })
                            
                            $A.get('e.force:refreshView').fire();
                        }else{
                            
                            
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.recordId"),
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                            
                            var workspaceAPI = component.find( "workspace" );
                            workspaceAPI.getFocusedTabInfo().then( function( response ) {
                                var focusedTabId = response.tabId;
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        workspaceAPI.closeTab( { tabId: focusedTabId } );
                                        
                                    }), 1000);
                            })
                            // $A.get('e.force:refreshView').fire();
                        }
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'SOV Lines Imported Successfully',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        
                        // component.closeModalPopup();
                        // location.reload();
                        component.set("v.isOpen", false);
                        var result=response.getReturnValue();
                      //  location.reload();
                    }
                    
                }
                
            }else if (state === "ERROR") {
                debugger;
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                var errorMessage = response.getError();
                var message = 'Something went wrong!';
                if (errorMessage[0].pageErrors[0].message != undefined && errorMessage[0].pageErrors[0].message.includes('Required fields are missing') && errorMessage[0].pageErrors[0].message.includes('Description of Work')) {
                    message = 'You are missing Description of Work in your CSV file.';
                } 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: message,
                    type: 'error',
                    duration: '1000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + response.getError());
            }
          
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
        keys = ['ItemNo', 'DescriptionofWork', 'ScheduledValue'];
        
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
    
    
    convertArrayOfObjectsToCSV : function(component,event,helper){
        // declare variables
        var csvStringResult, keys, columnDivider;
        columnDivider = ',';
        keys = ['ItemNo', 'DescriptionofWork', 'ScheduledValue'];
        
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
})