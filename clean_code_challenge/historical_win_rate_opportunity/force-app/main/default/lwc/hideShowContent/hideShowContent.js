import { LightningElement, api, track } from 'lwc';

export default class HideShowContent extends LightningElement {
    @api label;
    @track cssClass = 'slds-p-around_medium slds-hide';
    @track iconName = 'utility:right';
    @api expand = false;

    toggleContent() {
        this.expand = !this.expand;
        if (this.expand) {
            this.cssClass = 'slds-p-around_medium slds-show';
            this.iconName = 'utility:down';
        } else {
            this.cssClass = 'slds-p-around_medium slds-hide';
            this.iconName = 'utility:right';
        }
    }
}
