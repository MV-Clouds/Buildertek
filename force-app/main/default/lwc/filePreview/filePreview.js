import { LightningElement,api, wire, track } from 'lwc';

// importing Apex class method
import getRelatedFiles from '@salesforce/apex/filePreviewController.getRelatedFiles';


// importing navigation service
import { NavigationMixin } from 'lightning/navigation';

// extends the class to 'NavigationMixin'
export default class FilePrivewInLWC extends NavigationMixin(LightningElement) {
    // reactive variables
    @api files;
    @api recIdList;
    @api isFileExist = false;
    // Reteriving the files to preview
    /* @wire(getRelatedFiles,{lstParentIds: '$recIdList'})
    filesData({data, error}) {
        if(data) {
            window.console.log('data ===> '+data);
            this.files = data;
        }
        else if(error) {
            window.console.log('error ===> '+JSON.stringify(error));
        }
    } */

    getFiles(){
        var that = this;
        var recList = [];
        if(this.recIdList){
            recList.push(this.recIdList)
        }
        if(recList.length){
            getRelatedFiles({lstParentIds: recList}).then(function(response){

                console.log(response)
                if(Object.values(response)[0]){
                    var flist = [];
                    for(var i=0;i<Object.values(response).length;i++){
                        for(var j=0;j<Object.values(response)[i].length;j++){
                            flist.push(Object.values(response)[i][j]);
                        }
                        
                    }
                    that.files = flist;
                    //that.files = Object.values(response)[0];
                    that.isFileExist = true;
                    that.recIdList = '';
    
                }
                
                //this.records = response;
            }).catch(function(error){
                console.log(error);
            })
        }
        
    }

    /* connectedCallback(){
        this.getFiles();
    } */
    renderedCallback(){
        this.getFiles();
    }
    

    // when you click the preview button this method will call and
    // it will show the preview of the file based on ContentDocumentId
    filePreview(event) {
        // Naviagation Service to the show preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId:event.currentTarget.dataset.id
            }
          })
    }
}