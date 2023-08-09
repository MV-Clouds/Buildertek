import { LightningElement,api } from 'lwc';

export default class NumberLWC extends LightningElement {
    @api index;
    get position() {
        return this.index + 1;
    }
}