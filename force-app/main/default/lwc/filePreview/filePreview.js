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
    @track isLoading = false;
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

    getFiles() {
        console.log('getFiles');
        if (!this.recIdList) {
            return;
        }
        this.isLoading = true; 
        const recList = [this.recIdList];

        getRelatedFiles({ lstParentIds: recList })
            .then((response) => {
                console.log(response);
                if (Object.values(response)[0]) {
                    let flist = [];
                    for (let i = 0; i < Object.values(response).length; i++) {
                        for (let j = 0; j < Object.values(response)[i].length; j++) {
                            flist.push(Object.values(response)[i][j]);
                        }
                    }
                    this.files = flist;
                    this.isFileExist = true;
                    this.recIdList = '';
                } else {
                    this.isFileExist = false; 
                }
            })
            .catch((error) => {
                console.log(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
    
    connectedCallback(){
        this.getFiles();
    } 

    // renderedCallback(){
    //     this.getFiles();
    // }
    

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