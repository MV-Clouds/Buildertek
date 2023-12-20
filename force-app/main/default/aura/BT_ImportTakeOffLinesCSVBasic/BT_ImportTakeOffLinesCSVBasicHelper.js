({
  save: function (component, helper) {
    try {
      
      var MAX_FILE_SIZE = 750000;
      var fileInput = component.find("file").getElement();
      var file = fileInput.files[0];
      console.log('file',file);
      console.log('fileContents',file);
      if (file != undefined) {
        if (file.size > MAX_FILE_SIZE) {
          alert(
            "File size cannot exceed " +
            MAX_FILE_SIZE +
            " bytes.\n" +
            "Selected file size: " +
            file.size
            );
            return;
          }
          var fr = new FileReader();
          fr.readAsText(file);

          var self = this;
          fr.onload = function (event) {
            console.log('event ',event);
            // console.log('data check ',base64.decode(event.target.result));
            var cleanData = event.target.result;
            let data1 = Papa.parse(cleanData, {skipEmptyLines:'greedy'});
            let data = data1.data.map(row => row.map(value => value.trim()));
            console.log(data);
            debugger;
            var isValid = helper.validateProductColumn(data);
            if (isValid) {
                            
              var headerlst = data[0].join(',');
              var header = headerlst.split(',');
              if (
                  header[0] !== 'Product' ||
                  header[1] !== 'Price Book' ||
                  header[2] !== 'Vendor' ||
                  header[3] !== 'Product SKU' ||
                  header[4] !== 'Product Code' ||
                  header[5] !== 'Build Phase' ||
                  header[6] !== 'CategoryPL' ||
                  header[7] !== 'Trade Type' ||
                  header[8] !== 'Location' ||
                  header[9] !== 'Quantity' ||
                  header[10] !== 'UOM' ||
                  header[11] !== 'Cost Code' 
              ) {
                  helper.showToast(component, 'Error', 'File Header Format is Invalid!');
                  return '';
              }

              for (var i = 0; i < header.length; i++) {
                header[i] = header[i].trim().replace(/\s+/g, '');
              }

              var fileContents;
              let headers = header;
              // Convert data to JSON
              let jsonData = data.slice(1).map(row => {
                let obj = {};
                headers.forEach((header, index) => {
                  obj[header] = row[index];
                });
                return obj;
              });
              fileContents = JSON.stringify(jsonData,null,2); 
              console.log('result -->>>>',typeof(fileContents));
              
              helper.upload(component, helper, fileContents);
            };
          }
        } else {
          helper.showToast(component, "error", "Please select file to import");
        }
      } catch (error) {
        console.log('error ',error); 
      }
    },
    
    upload: function (component, helper, fileContents) {
      component.set("v.Spinner",true);
      var action = component.get("c.importRecords");
      action.setParams({
          takeOffId: component.get("v.recordId"),
          fileData: fileContents,
      });
    
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
    
          var result = response.getReturnValue();
          console.log("result ", result);
          if (result.isSuccess) {
            helper.showToast(component, "success", result.strMessage);
            window.setTimeout(
              $A.getCallback(function() {
                window.location.reload();
              }), 2000
            );
          } else {
            helper.showToast(component, "error", result.strMessage);
          }
          
        } else {
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
      });
    
      $A.enqueueAction(action);
    },

  validateProductColumn: function (data) {
    var productEmptyLines = [];

    // Assuming the first row contains headers and data starts from the second row
    for (var i = 1; i < data.length; i++) {
      var productValue = data[i][0]; // Assuming Product column is at index 0
      if (!productValue.trim()) {
        // Product column is empty, perform validation logic here
        productEmptyLines.push(i + 1);
      }
    }
    if (productEmptyLines.length > 0) {
      
      var productEmptyNo = productEmptyLines.join(', ');
      console.log(productEmptyNo);
     
      var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": "Product value is required and can not be empty.Please review the row No. " + productEmptyNo + ".", 
            "duration": 7000
        });
        toastEvent.fire();
        return false;
    }
    return true;
  },
 
  convertArrayOfObjectsToCSV : function(component,event,helper){
     // declare variables
     var csvStringResult, keys, columnDivider;
     columnDivider = ',';
     keys = ['Product','Price Book', 'Vendor', 'Product SKU','Product Code','Build Phase','CategoryPL','Trade Type','Location','Quantity','UOM','Cost Code'];
   
     csvStringResult = '';
     csvStringResult += keys.join(columnDivider);
    
     return csvStringResult;        
 },


showToast: function (component, type, message) {
  component.set("v.Spinner",false);
 var toastEvent = $A.get("e.force:showToast");

 toastEvent.setParams({
   "type": type,
   "message": message,
   duration: '5000',
   mode: 'dismissible'
 });

 toastEvent.fire();
},

});