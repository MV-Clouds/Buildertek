({
    getAllTemplates : function(component, event, helper) {
        var action = component.get("c.getTemplates");	
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result){
                    var innerList = JSON.parse(result)
                    console.log(result);
                    var options = [];
                    for(var i=0;i<innerList.length;i++){
                        options.push(
                            {label: innerList[i]['NameLabel'], value: innerList[i]['NameApi']}
                        );
                    }
                    component.set("v.templatesList", options);
                }
                /*var myArr = result.split(",");
                if(result != null){
                    if(result.includes(',')){
                        var options = [];
                        for(var i=0;i<result.length;i++){
                            if(myArr[i] != undefined && myArr[i] != null && myArr[i] != ""){
                                
                                options.push(
                                    {label: myArr[i], value: myArr[i]}
                                );
                            }
                        }
                        component.set("v.templatesList", options);
                    }else{
                        var options  = [];
                        options.push(
                            {label: result, value: result}
                        );
                        component.set("v.templatesList", options);
                    }   
                }*/
                
            }    
        });
        $A.enqueueAction(action);	
    },
    getContacts : function(component, event, helper){
        var action = component.get("c.getPrimaryContacts");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                
                var result = response.getReturnValue();
                
              /*  if(result.primary != undefined && result.primary != "" && result.primary != null){
                    component.set("v.selectedToContact", result.primary[0]);
                    
                } *//*if (result.acclist[0].buildertek__MSA_Additional_Email__c != null && result.acclist[0].buildertek__MSA_Additional_Email__c != undefined && result.acclist[0].buildertek__MSA_Additional_Email__c != '')
                {
                   
                    component.set("v.toEmail", result.acclist[0].buildertek__MSA_Additional_Email__c);
                } */
                
                
            }    
        });
        $A.enqueueAction(action);
    },
    readFiles2 : function(component, event, helper, file){
        var filesList = component.get("v.fileData2");
        var reader = new FileReader(); 
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]; 
            var fileData2 = {
            'fileName': file.name,
            'fileContent': base64,
        }
        console.log(JSON.stringify(fileData2));
        
       
        //filesList.push(fileData2);
        //component.set("v.fileData2", filesList);
        component.get("v.fileData2").push(fileData2);
        component.set("v.fileBody", filesList.fileName);
        
       
        
    }
    //alert("eVENT"+JSON.stringify(component.get("v.fileData2")));
    reader.readAsDataURL(file);
},
 
 })