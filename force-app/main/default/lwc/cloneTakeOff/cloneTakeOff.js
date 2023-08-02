import { LightningElement, api, track} from 'lwc';
import gettakeoffdata from '@salesforce/apex/cloneTakeOffController.gettakeoffdata';

export default class CloneTakeOff extends LightningElement {
    @api recordId;
    Name;

    connectedCallback(){
        console.log(this.recordId);
        gettakeoffdata({
            recordId: this.recordId,
        })
        .then(result => {
            this.Name = result.Name;
        })
    }

    renderedCallback() {
        console.log(this.recordId);
        gettakeoffdata({
            recordId: this.recordId,
        })
        .then(result => {
            this.Name = result.Name;
        })
    }
}