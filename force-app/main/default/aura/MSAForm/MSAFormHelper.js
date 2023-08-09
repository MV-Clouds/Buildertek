({
	handleclick : function(component,event,helper) {
        
		 component.set("v.Spinner", true);
        component.set("v.isDisabled",true);
		var name = component.get("v.Name");
        var address = component.get("v.Address");
        var citystate = component.get("v.Citystate");
        var state = component.get("v.State");
        var zip = component.get("v.Zip");
        var phone = component.get("v.Phone");
        var fax = component.get("v.Fax");
        var contractorlicence = component.get("v.ContractorLicense");
        var federaltaxId = component.get("v.FederalTaxID");
        
        var subBy = component.get("v.subContractorBy");
        var subprintedName = component.get("v.subContractorprintedName");
        var subVendorName = component.get("v.subContractorVendorName");
        var subDate = component.get("v.subContractorDate");
        
        var By = component.get("v.ContractorBy");
        var printedName = component.get("v.ContractorprintedName");
        var Date = component.get("v.ContractorDate");
         var Day =  component.get("v.day");
        var Month =  component.get("v.month");
        
        
           
        
        var JsonString = {};
        JsonString.jName = name;
        JsonString.jaddress = address;
        JsonString.jcitystate = citystate;
        JsonString.jstate = state;
        JsonString.jzip = zip;
        JsonString.jphone = phone;
        JsonString.jfax = fax;
        JsonString.jcontractorlicence = contractorlicence;
        JsonString.jfederaltaxId = federaltaxId;
        
        JsonString.jsubBy = subBy;
        JsonString.jsubprintedName = subprintedName;
        JsonString.jsubVendorName = subVendorName;
        JsonString.jsubDate = subDate;
        
        JsonString.jcontractorby = By;
        JsonString.jprintedName = printedName;
         JsonString.jcontractorDate = Date;
         JsonString.jday = Day;
        JsonString.jmonth = Month;
        var recid = component.get("v.recordId");
        
        
         var resend;
        var boolmsa = component.get("v.resendMSA");
        
        if(boolmsa == 'true'){
           
            resend = 'YES';
        }else{
          
            resend = 'NO';
        }
      
        var action = component.get("c.getJSonString");
          action.setParams({
            "jsonData" : JSON.stringify(JsonString),
              "AccountId" : recid,
              "FileId" : component.get("v.fileimageId"),
              "isContractor" : component.get("v.Contractor"),
               "isresendMSA" : resend
        });  
         action.setCallback(this, function(response){
              var state = response.getState();
             if(state === "SUCCESS"){
                var elmnt = document.getElementById("pageTop");
                elmnt.scrollIntoView();
               component.set("v.isSuccess",true);
                component.set("v.Message","Contract signed successfully");
                 component.set("v.Spinner", false);
                 
             }else if(state === "ERROR"){
                 var elmnt = document.getElementById("pageTop");
                 elmnt.scrollIntoView();
                 component.set("v.isSuccess",false);
                  component.set("v.isError",true);
                 component.set("v.Message",response.getReturnValue());
                 component.set("v.Spinner", false);
             }
              });
        $A.enqueueAction(action);  
	}
})