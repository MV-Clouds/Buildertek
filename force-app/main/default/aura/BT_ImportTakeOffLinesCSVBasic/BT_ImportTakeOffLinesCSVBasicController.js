({
    save: function (component, event, helper) {
        helper.save(component, helper);
    },

    onFileSelected: function (component, event, helper) {
        var fullPath = document.getElementById("file-upload-input-01").value;
        var split = fullPath.split(/(\\|\/)/g).pop();
        document.getElementById("fileName").innerHTML = split;
    },

    
    downloadCsv : function(component,event,helper){
    var csv = helper.convertArrayOfObjectsToCSV(component,event,helper);   
        if (csv == null){return;} 
    // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'Import TakeOff Lines Basic.csv';  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }, 
   
    
    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();    
    }
});