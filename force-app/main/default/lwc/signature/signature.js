import { LightningElement, api, track } from 'lwc';
import getbase64 from '@salesforce/apex/BT_GenerateQuotePDFSignature.getbase64';

export default class Signature extends LightningElement {
    @track base64;
    @api recordId;

    connectedCallback(){
        
        console.log('in lwc component:'+this.recordId);
        getbase64( { recordId : this.recordId })
        .then((result) =>  {
            console.log('in lwc component:'+result);
            this.base64 = result;
            this.template.querySelector('.signature').style = 'background-image:url("data:image/png;base64,'+this.base64;
        })
        .catch(error => {

        });
    }
}