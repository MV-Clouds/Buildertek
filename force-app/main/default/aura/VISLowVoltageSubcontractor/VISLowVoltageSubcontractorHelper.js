({
	 readFiles : function(component, event, helper, file){
        var filesList = component.get("v.fileData");
        var reader = new FileReader(); 
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]; 
            var fileData = {
                'fileName': file.name,
                'fileContent': base64,
                'parentId': component.get("v.RecordId")
            }
            //filesList.push(fileData);
            //component.set("v.fileData", filesList);
            component.get("v.fileData").push(fileData);
        }
        reader.readAsDataURL(file);
    },
     sendtoBox: function(component,event,helper,currentFile,boxfolderId,accessToken,iterator){
            return new Promise($A.getCallback(function (resolve, reject) {
                var data = new FormData();
                        data.append('file['+iterator+']', currentFile); 
                        const url = 'https://upload.box.com/api/2.0/files/content?parent_id='+boxfolderId;
                        const xhr = new XMLHttpRequest();
                        xhr.open("POST", url, true);
                        xhr.setRequestHeader('Access-Control-Allow-Origin', '*');
                        xhr.setRequestHeader('Authorization', 'Bearer '+accessToken);               
                        xhr.onload = function() {
                            var result = JSON.parse(this.responseText);
                            if(this.status === 200 || this.status === 201) {
                                var elmnt = document.getElementById("pageTop");
                                elmnt.scrollIntoView(); 
                                resolve(result);
                            }
                            else{
                                console.log(result.message);
                                reject(result.message);
                            }  
                        };
                        xhr.send(data);
            }));
    },
       
        
        
        
 submitForm : function(component, event, helper, fileContents){
            // let button = event.getSource();
       // button.set('v.disabled',true);
        component.set("v.Spinner", true);
          console.log("*********************************8"+JSON.stringify(component.get("v.acc")));
         console.log("submitting clear id"+JSON.stringify(component.get("v.acc")));
        var act = JSON.stringify(component.get("v.acc"));
        //alert(JSON.stringify(component.get("v.isDataCleared")));
            	var action = component.get("c.updateAcc");
         action.setParams({
            "ac" : act,
             "projectlist1" : JSON.stringify(component.get("v.project1")),
             "projectlist2" : JSON.stringify(component.get("v.project2")),
             "projectlist3" : JSON.stringify(component.get("v.project3")),
             "refList1" : JSON.stringify(component.get("v.reference1")),
             "refList2" : JSON.stringify(component.get("v.reference2")),
             "refList3" : JSON.stringify(component.get("v.reference3")),
             "isClear" : JSON.stringify(component.get("v.isDataCleared")),
             "AccountID" : component.get("v.RecordId"),
             "project1Id" : component.get("v.project1.Id"),
             "project2Id" : component.get("v.project2.Id"),
             "project3Id" : component.get("v.project3.Id"),
             "reference1Id" : component.get("v.reference1.Id"),
             "reference2Id" : component.get("v.reference2.Id"),
             "reference3Id" : component.get("v.reference3.Id"),
             
            
         });
        console.log("ACC"+JSON.stringify(act.Name));
         action.setCallback(this, function(response){
              var filesList = component.get("v.uploadFileList")
            
              if(response.getState() === 'SUCCESS' || !filesList){
                var result = response.getReturnValue();
                 // alert(result);
                var boxfolderId = result.boxFolderId
                // HTML file input, chosen by user
                    var allFilesUploaded = false;
                    var allFilesErrorMessages = [];
                let promises = [];
                    for(let i=0;i<filesList.length;i++){
                        promises.push(helper.sendtoBox(component,event,helper,filesList[i],boxfolderId,result.accessToken,i));
                    }
           				Promise.all(promises)
                        .then((result) => {
                            var elmnt = document.getElementById("pageTop");
                    		   elmnt.scrollIntoView();
                             component.set("v.showSuccessMessage", true);
                                    component.set("v.isDisabled", true);
                                    component.set("v.Spinner", false);
                                    component.set("v.message", 'file(s) uploaded successfully');
                                    component.set("v.isSuccess", true);
                                    component.set("v.isError", false);
                                    component.set("v.Spinner", false);
                                    component.set("v.Spinner", false); 
                        })
                        .catch((error) => {
                            component.set("v.Spinner", false);
                                    component.set("v.isError",true);
                            if(error == 'Item with the same name already exists'){
                            component.set("v.message", 'File with the same name already exists');
                        }else{
                            component.set("v.message", error);
                        }
                        })
                        /*
                        helper.sendtoBox(component,event,helper,filesList[0][i],boxfolderId,result.accessToken,i).then(
                            $A.getCallback(function(result) {
                                console.log(result);
                            }),
                            $A.getCallback(function(error){
                                console.log(error);
                                allFilesUploaded = false;
                                let ErrorMessage = 'For file '+i+' '+error.message;
                                allFilesErrorMessages.push(error.Message);
                            })  
                        ).then(function(){
                            console.log(i+'ccc');
                           if( i== filesList[0].length-1){
                               var elmnt = document.getElementById("pageTop");
                    		   elmnt.scrollIntoView();
                                if(allFilesUploaded){     
                                    component.set("v.showSuccessMessage", true);
                                    component.set("v.isDisabled", true);
                                    component.set("v.Spinner", false);
                                    component.set("v.message", 'file(s) uploaded successfully');
                                    component.set("v.isSuccess", true);
                                    component.set("v.isError", false);
                                    component.set("v.Spinner", false);
                                    component.set("v.Spinner", false); 
                                }else{
                                    console.log(allFilesErrorMessages);
                                    component.set("v.Spinner", false);
                                    component.set("v.isError",true);
                                    component.set("v.message", allFilesErrorMessages.toString());
                                }
                           } 
                        });*/ 
                        
                   // }
                }else{
                    var result = response.getReturnValue();
                    var elmnt = document.getElementById("pageTop");
                    elmnt.scrollIntoView();
                    //component.set("v.message", result.Message);
                    component.set("v.message", result.boundary);
                    component.set("v.isSuccess", false);
                    component.set("v.isError", true);
                    component.set("v.Spinner", false);
                }
                 
        });
        $A.enqueueAction(action);
}
})