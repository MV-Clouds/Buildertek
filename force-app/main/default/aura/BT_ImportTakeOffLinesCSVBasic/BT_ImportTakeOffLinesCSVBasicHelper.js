({
  save: function (component, helper) {
      var MAX_FILE_SIZE = 750000;
      var fileInput = component.find("file").getElement();
      var file = fileInput.files[0];
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
          helper.showToast(component, "error", "Please select file to import");
      }
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

upload: function (component, helper, file, fileContents) {
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