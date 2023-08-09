({
    doInit: function (component, event, helper) {
        debugger;
        
               
        component.set("v.isOpen", true);
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.communityUserId",commUserId);
                    component.set("v.Vendorname",result.buildertek__Account_Id__c);
                    component.set("v.Iscommunity",true);
                }else{
                    var myPageRef = component.get("v.pageReference");
                    var recordId = myPageRef.state.buildertek__parentId;
                    
                    if(recordId != null || recordId != undefined){
                        component.set("v.recordId",recordId);
                    }else{
                        var recId = component.get("v.recordId");
                        component.set("v.recordId",recId);
                    }
                }
            }
        });
        $A.enqueueAction(action);
        
        if(location.href.includes('dummy')){
            var loc = location.href.split('id=')[1];
            var recordId = location.href.split('id=')[1].split("&dummy=")[0];
            // component.set("v.commrecordId",recordId)
            component.set("v.recordId",recordId)
        }
        
        
    },
    CreateRecord: function (component, event, helper) {
        console.log(event.currentTarget)
        
        console.log(component.find('importBtn'));
        component.set("v.Spinner", true);
        component.set("v.showMessage",true);
        
        var fileInput = component.find("file").get("v.files");
       // alert( JSON.stringify(fileInput));
        
        if(fileInput == null){
            component.set("v.Spinner", false);
            component.set("v.showMessage",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please upload a file to Import',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            component.set("v.Spinner", true);
            component.set("v.showMessage",true);  
            //var fileContent;
            var file = component.find("file").get("v.files")[0];
        var reader  = new FileReader();
		reader.readAsText(file, "UTF-8");
        reader.onload = function(e) {
            var fileContent = e.target.result;
           // alert(fileContent);
           // 
            var base64 = 'ScheduledValue';
            var dataStart = fileContent.indexOf(base64) + base64.length;
            //alert(fileContent.indexOf(base64));
            //alert(base64.length);
			//alert('dataStart   '+dataStart);
            fileContent = fileContent.substring(dataStart);
           // alert('fileContent   '+JSON.stringify(fileContent));
             if (fileContent!=''){
               
                //console.log("File");
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = function (evt) {
                    
                    //console.log("EVT FN");
                    var csv = evt.target.result;
                   // alert('csv    '+JSON.stringify(csv));
                    //console.log('csv file contains'+ csv);
                    var result = helper.CSV2JSON(component,csv);
                    //console.log('result = ' + result);
                    //console.log('Result = '+JSON.parse(result));
                    
                    
                    helper.CreateAccount(component,result);
                    if(component.get("v.Iscommunity") == true){
                        if(document.getElementsByClassName('importPurchaseBtn1')){
                            document.getElementsByClassName('importPurchaseBtn1')[0].blur();
                        }
                        document.body.click(); 
                    }else{
                        if(document.getElementsByClassName('importPurchaseBtn')){
                            document.getElementsByClassName('importPurchaseBtn')[0].blur();
                        }
                        document.body.click(); 
                    }
                    
                    
                }
                reader.onerror = function (evt) {
                    //console.log("error reading file");
                }
            }else  {
                component.set("v.Spinner", false);
                //alert('else');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message:'There are No SOV Lines in Your CSV file. Please provide SOV Lines.',
                    type: 'error',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            //uploadFile(file, fileContent, component);
        }
           
        }
        
        
        
    },
    
    handleFilesChange: function (component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    // export data start from here    
    // ## function call on component load  
    loadContactList: function(component, event, helper){
        component.set("v.isOpen", true);
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        console.log('baseURL',baseURL);
        component.set("v.BaseURLs", baseURL);
        helper.onLoad(component, event);
    },
    
    // ## function call on Click on the "Download As CSV" Button. 
    downloadCsv : function(component,event,helper){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.ListOfContact");
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }, 
    
    closeModel: function (component, event, helper) {
        component.set("v.isOpen", false);
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
                $A.get('e.force:refreshView').fire();
            }else{
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                $A.get('e.force:refreshView').fire();
            }
            
            
        }
        
        
    },
    close : function (component, event, helper) {
        
        
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var recId = component.get("v.recordId")
            workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"
                });
                navEvt.fire();
            })
        })
        .catch(function(error) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
            console.log(error);
        });
        

      /*  var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        }); */
    },
    
    downloadCsv : function(component,event,helper){
        var csv = helper.convertArrayOfObjectsToCSV(component,event,helper);   
        if (csv == null){return;} 
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'SOV Lines.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }, 
    
})