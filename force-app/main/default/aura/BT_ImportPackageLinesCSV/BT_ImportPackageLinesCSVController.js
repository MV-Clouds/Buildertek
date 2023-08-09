({
    doInit: function (component, event, helper) {
        //component.set("v.isOpen", true);
        var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        console.log('baseURL',baseURL);
        component.set("v.BaseURLs", baseURL);
    },
    
    save: function (component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        var fileInput = component.find("file").get("v.files");
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
        }
    },
     handleFilesChange: function (component, event, helper) {
         debugger;
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
             component.set("v.isSelect", false);
            fileName = event.getSource().get("v.files")[0]['name'];
        }
         console.log('fileName:::',fileName);
        component.set("v.fileName", fileName);
    },
    closeModel : function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    downloadCsv : function(component,event,helper){
        var csv = helper.convertArrayOfObjectsToCSV(component,event,helper);   
         if (csv == null){return;} 
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'Import Package Lines.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }, 
       

   
});