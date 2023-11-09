({    
    CreateRecord: function (component, event, helper) {
        component.set("v.Spinner", true);
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if (file){
            console.log("File--->",file);
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                console.log('csv file-->', csv);
                var result = helper.CSV2JSON(component,csv);
                console.log('Result = ',JSON.parse(result));
                helper.CreateInspectionLine(component,result);
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }
        
    },  
    
    onFileSelected: function (component, event, helper) {
        var fullPath = document.getElementById("file-upload-input-01").value;
        var split = fullPath.split(/(\\|\/)/g).pop();
        document.getElementById("fileName").innerHTML = split;
    },
    
    downloadCsv : function(component,event,helper){
        var csv = helper.convertArrayOfObjectsToCSV(component,event,helper);   
        if (csv == null){return;} 
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'InspectionLines.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }, 

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();    
    }
})