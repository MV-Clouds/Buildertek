({
    doInit: function (component, event, helper) {
        component.set("v.isOpen", true);
        var url = location.href;
        
        var baseURL = url.substring(0, url.indexOf('--', 0));
      //  alert('baseurl'+baseURL);
        console.log('baseURL',baseURL);
        component.set("v.BaseURLs", baseURL);
    },
    CreateRecord: function (component, event, helper) {
        console.log(event.currentTarget)
        
        console.log(component.find('importBtn'));
        component.set("v.Spinner", true);
        component.set("v.showMessage",true);
        /*  var fileInput = component.find("file").get("v.files");
        var file = fileInput[0];
        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,event, helper, csv);
                if(result != undefined && result != ''){
                    window.setTimeout(
                       
                        $A.getCallback(function () {
                            helper.CreateAccount(component, result);
                        }), 100
                    );
                }
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }*/
        
        var fileInput = component.find("file").get("v.files");
     
        if(fileInput == null){
            
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
             var file = fileInput[0];
        //alert(file);
        
        
        if (file){
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                
                //console.log("EVT FN");
                var csv = evt.target.result;
                //console.log('csv file contains'+ csv);
                var result = helper.CSV2JSON(component,csv);
                //console.log('result = ' + result);
                //console.log('Result = '+JSON.parse(result));
                helper.CreateAccount(component,result);
                if(document.getElementsByClassName('importPurchaseBtn')){
                    document.getElementsByClassName('importPurchaseBtn')[0].blur();
                }
                document.body.click(); 
                
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        }
        }
        
       
        
    },
    
    /* showfiledata :  function (component, event, helper){        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file) {
            component.set("v.showcard", true);
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var table = document.createElement("table");
                var rows = csv.split("\n");
                for (var i = 0; i < rows.length; i++) {
                    var cells = rows[i].split(",");
                    if (cells.length > 1) {
                        var row = table.insertRow(-1);
                        for (var j = 0; j < cells.length; j++) {
                            var cell = row.insertCell(-1);
                            cell.innerHTML = cells[j];
                        }
                    }
                }
                var divCSV = document.getElementById("divCSV");
                divCSV.innerHTML = "";
                divCSV.appendChild(table);
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        }
    }, */   
    
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
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId; 
            workspaceAPI.closeTab({tabId: focusedTabId});
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/o/buildertek__Purchase_Order__c/list?filterName=Recent'
            });
            urlEvent.fire();
        })
        .catch(function(error) {
            console.log(error);
        });
        
    }
    
})